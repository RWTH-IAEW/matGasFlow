function [GN] = get_kappa_AGA8_92DC(GN)
%GET_KAPPA_AGA8_92DC
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
% Quantities
p     = GN.bus.p_i;
T     = GN.bus.T_i;
Z     = GN.bus.Z_i;
[~, ~, ~, GN.bus.kappa_i, GN.bus.c_V_i] = calculate_AGA8_92DC(p, T, Z, GN.AGA8_92DC_tables);

%% prs
if isfield(GN, 'prs') && any(GN.prs.exp_turbine)
    % Quantities
    p     = GN.prs.p_ij_mid;
    T     = GN.prs.T_ij_mid;
    Z     = GN.prs.Z_ij_mid;
    [~, ~, ~, GN.prs.kappa_ij_mid, GN.prs.c_V_ij_mid] = calculate_AGA8_92DC(p, T, Z, GN.AGA8_92DC_tables);
end

end
