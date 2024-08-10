function [GN] = get_kappa_DVGW2000(GN, PHYMOD)
%GET_KAPPA_DVGW2000
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Quantities
CONST   = getConstants;
R_m     = CONST.R_m;
M_avg   = GN.gasMixProp.M_avg;
Z_n_avg = GN.gasMixProp.Z_n_avg;

%% bus
% Quantities
p     = GN.bus.p_i;
T     = GN.bus.T_i;
V_m   = GN.bus.Z_i .* R_m .* T ./ p;
c_p   = GN.bus.c_p_i;

% Specific isochoric heat capacity
GN.bus.c_V_i = calculate_c_V_VanDerWaals(T, M_avg, GN.gasMixAndCompoProp, PHYMOD);

% kappa
GN.bus.kappa_i = calculate_kappa_DVGW2000(c_p, GN.bus.c_V_i, p, T, V_m, Z_n_avg);

%% prs
if isfield(GN, 'prs')
    % Quantities
    p     = GN.prs.p_ij_mid;
    T     = GN.prs.T_ij_mid;
    V_m   = GN.prs.Z_ij_mid .* R_m .* T ./ p;
    c_p   = GN.prs.c_p_ij_mid;
    
    % Specific isochoric heat capacity
    GN.prs.c_V_ij_mid = calculate_c_V_VanDerWaals(T, M_avg, GN.gasMixAndCompoProp, PHYMOD);
    
    % kappa
    GN.prs.kappa_ij_mid = calculate_kappa_DVGW2000(c_p, GN.prs.c_V_ij_mid, p, T, V_m, Z_n_avg);
end

end
