function [GN] = get_my_JT_PengRobinson(GN)
%GET_MY_JT_PENGROBINSON
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
M_avg   = GN.gasMixProp.M_avg;
R_m     = CONST.R_m;

%% bus
T   = GN.bus.T_i;
V_m = GN.bus.Z_i .* R_m .* T ./ GN.bus.p_i;
c_p = GN.bus.c_p_i;
GN.bus.my_JT_i = calculate_my_JT_PengRobinson(V_m, T, c_p, M_avg, GN.gasMixAndCompoProp);

%% pipe and prs outflow
if isfield(GN, 'pipe') || isfield(GN, 'prs')
    T   = GN.branch.T_ij_out;
    V_m = GN.branch.Z_ij_out .* R_m .* T ./ GN.bus.p_i(GN.branch.i_to_bus);
    c_p = GN.branch.c_p_ij_out;
    GN.branch.my_JT_ij_out = calculate_my_JT_PengRobinson(V_m, T, c_p, M_avg, GN.gasMixAndCompoProp);
end

%% prs
if isfield(GN, 'prs')
    T   = GN.prs.T_ij_mid;
    V_m = GN.prs.Z_ij_mid .* R_m .* T ./ GN.prs.p_ij_mid;
    c_p = GN.prs.c_p_ij_mid;
    GN.prs.my_JT_ij_mid = calculate_my_JT_PengRobinson(V_m, T, c_p, M_avg, GN.gasMixAndCompoProp);
end

end

