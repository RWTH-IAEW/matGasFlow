function [GN] = get_kappa_VanDerWaals_iG(GN, PHYMOD)
%GET_KAPPA_VANDERWAALS_IG
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Global quantities
CONST = getConstants;
R_m   = CONST.R_m;
M_avg = GN.gasMixProp.M_avg;

%% bus
% Quantities
T     = GN.bus.T_i;
c_p   = GN.bus.c_p_i;

% Specific isochoric heat capacity
if ~ismember('c_p_0_i', GN.bus.Properties.VariableNames)
    GN.bus.c_p_0_i = calculate_c_p_0(T, GN.gasMixProp.M_avg, GN.gasMixAndCompoProp, PHYMOD);
end
GN.bus.c_V_i = GN.bus.c_p_0_i - R_m/M_avg; % [J/(kg*mol)]
c_V = GN.bus.c_V_i;

% kappa
GN.bus.kappa_i = calculate_kappa_VanDerWaals_iG(c_p, c_V);

%% prs
if isfield(GN, 'prs')
    % Quantities
    T     = GN.prs.T_ij_mid;
    c_p   = GN.prs.c_p_ij_mid;
    
    % Specific isochoric heat capacity
    if ~ismember('c_p_0_ij_mid', GN.prs.Properties.VariableNames)
        GN.prs.c_p_0_ij_mid = calculate_c_p_0(T,GN.gasMixProp.M_avg, GN.gasMixAndCompoProp, PHYMOD);
    end
    GN.prs.c_V_ij_mid = GN.prs.c_p_0_ij_mid - R_m/M_avg; % [J/(kg*mol)]
    c_V = GN.prs.c_V_ij_mid;

    % kappa
    GN.prs.kappa_ij_mid = calculate_kappa_VanDerWaals_iG(c_p, c_V);
end

end

