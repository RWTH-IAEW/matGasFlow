function [GN] = get_my_JT_NTPMG(GN)
%GET_MY_JT_NTPMG
%   see [Mischner 2015] p.136 eqn. 9.95 ff., [DIN 51896]
%   valid for 250K <= T <= 400K; p <= 150 bar
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Physical constants
CONST = getConstants();

%% Quantities
R_m     = CONST.R_m;

%% bus
p_r  = GN.bus.p_i/GN.gasMixProp.p_pc;
T_r  = GN.bus.T_i/GN.gasMixProp.T_pc;
GN.bus.my_JT_i = calculate_my_JT_NTPMG(p_r, T_r);

%% pipe and prs outflow
if isfield(GN, 'pipe') || isfield(GN, 'prs')
    V_dot_n_ij                  = GN.branch.V_dot_n_ij;
    i_bus_out                   = GN.branch.i_to_bus;
    i_bus_out(V_dot_n_ij < 0)   = GN.branch.i_from_bus(V_dot_n_ij < 0);
    p_r                         = GN.bus.p_i(i_bus_out)/GN.gasMixProp.p_pc;
    T_r                         = GN.branch.T_ij_out/GN.gasMixProp.T_pc;
    GN.branch.my_JT_ij_out      = calculate_my_JT_NTPMG(p_r, T_r);
end

%% prs
if isfield(GN, 'prs')
    p_r  = GN.prs.p_ij_mid/GN.gasMixProp.p_pc;
    T_r  = GN.prs.T_ij_mid/GN.gasMixProp.T_pc;
    GN.prs.my_JT_ij_mid = calculate_my_JT_NTPMG(p_r, T_r);
end

end

