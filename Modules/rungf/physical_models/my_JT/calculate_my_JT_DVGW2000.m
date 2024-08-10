function [my_JT] = calculate_my_JT_DVGW2000(V_m, T, Z_n_avg, M, c_p)
%CALCULATE_MY_JT_DVGW2000
%   [my_JT] = calculate_my_JT_DVGW2000(V_m, T, Z_n_avg, M, c_p)
%   Input quantities:
%       V_m [m^3/mol]       - molar volume
%       T   [K]             - temperature
%       Z_n_avg [-]         - compressibility factor at standard condition
%       M   [kg/mol]        - molar mass
%       c_p [J/kg K]        - specific isobaric heat capacity
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
p_ref   = 450 * 1e5;

%% Partial derivations
dp_dT       =  R_m*Z_n_avg*p_ref^2*V_m ./ (R_m*Z_n_avg*T + p_ref*V_m).^2;
dp_dV_m     = -R_m*Z_n_avg*p_ref^2*T   ./ (R_m*Z_n_avg*T + p_ref*V_m).^2;

%% my_JT
my_JT = -1./c_p .* (V_m + T .* dp_dT./dp_dV_m)/M;

end

