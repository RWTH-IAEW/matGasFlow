function [kappa] = calculate_kappa_DVGW2000(c_p, c_V, p, T, V_m, Z_n_avg)
%CALCULATE_KAPPA_DVGW2000
%   [kappa] = calculate_kappa_DVGW2000(c_p, c_v, p, T, V_m, Z_n_avg)
%   Input quantities:
%       c_p [J/kg K]        - specific isobaric heat capacity
%       c_v [J/kg K]        - specific isochoric heat capacity
%       p   [Pa]            - pressure
%       T   [K]             - temperature
%       V_m [m^3/mol]       - molar volume
%       Z_n_avg [-]         - compressibility factor at standard condition
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
p_n     = CONST.p_n;
p_ref   = 450 * 1e5 + p_n;

%% Partial derivations
dp_dV_m     = -R_m*Z_n_avg*p_ref^2*T   ./ (R_m*Z_n_avg*T + p_ref*V_m).^2;

%% Isothermal exponent
isothermalExponent = -V_m ./ p .* dp_dV_m;

%% Isentropic exponent
kappa = c_p./c_V .* isothermalExponent;

end

