function [GN] = get_my_JT_AGA8_92DC(GN)
%GET_MY_JT_AGA8_92DC
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Read AGA8_92DC_tables.xlsx
if ~isfield(GN,'AGA8_92DC_tables')
    GN = get_AGA8_92DC_tables(GN);
end

%% bus
p   = GN.bus.p_i;
T   = GN.bus.T_i;
Z   = GN.bus.Z_i;
[~, ~, GN.bus.my_JT_i] = calculate_AGA8_92DC(p, T, Z, GN.AGA8_92DC_tables);

%% pipe and prs outflow
if isfield(GN, 'pipe') || isfield(GN, 'prs')
    %% Indices
    V_dot_n_ij                  = GN.branch.V_dot_n_ij;
    i_bus_out                   = GN.branch.i_to_bus;
    i_bus_out(V_dot_n_ij < 0)   = GN.branch.i_from_bus(V_dot_n_ij < 0);
    p  = GN.bus.p_i(i_bus_out);
    T  = GN.branch.T_ij_out;
    Z  = GN.branch.Z_ij_out;
    [~, ~, GN.branch.my_JT_ij_out] = calculate_AGA8_92DC(p, T, Z, GN.AGA8_92DC_tables);
end

%% prs
if isfield(GN, 'prs')
    p   = GN.prs.p_ij_mid;
    T   = GN.prs.T_ij_mid;
    Z   = GN.prs.Z_ij_mid;
    [~, ~, GN.prs.my_JT_ij_mid] = calculate_AGA8_92DC(p, T, Z, GN.AGA8_92DC_tables);
end

end

