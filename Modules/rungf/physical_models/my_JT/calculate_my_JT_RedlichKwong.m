function [my_JT] = calculate_my_JT_RedlichKwong(V_m, T, c_p, M_avg, gasMixAndCompoProp)
%CALCULATE_MY_JT_REDLICHKWONG
%
%   [my_JT] = calculate_my_JT_RedlichKwong(c_p, T, V_m, M, a, b)
%   Input quantities:
%       c_p [J/kg K]        - specific isobaric heat capacity
%       T   [K]             - temperature
%       V_m [m^3/mol]       - molar volume
%       M   [kg/mol]        - molar mass
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
CONST           = getConstants();

%% Quantities
R_m             = CONST.R_m;
p_c_i           = gasMixAndCompoProp.p_c;
T_c_i           = gasMixAndCompoProp.T_c;
x_mol_i         = gasMixAndCompoProp.x_mol;

%% Internal pressure a and covolume b of the gas components
a_i             = 1/9/(2^(1/3)-1) * R_m^2 * T_c_i.^2 ./ p_c_i;
b_i             = (2^(1/3)-1)/3   * R_m   * T_c_i    ./ p_c_i;
b               = sum(x_mol_i.*b_i);

%% a*alpha and its partial derivations
a_alpha         =   sum(x_mol_i * x_mol_i' .* sqrt((a_i * a_i') .* sqrt(T_c_i * T_c_i')),"all")      * T.^(-0.5);
d_a_alpha_dT    = - sum(x_mol_i * x_mol_i' .* sqrt((a_i * a_i') .* sqrt(T_c_i * T_c_i')),"all") *1/2 * T.^(-1.5);

%% Partial derivations
dp_dT           = R_m ./(V_m-b) - 1./(V_m.*(V_m+b)) .* d_a_alpha_dT;
dp_dV_m         = -R_m.*T./(V_m-b).^2 + a_alpha .* (2.*V_m+b)./(V_m.*(V_m+b)).^2;

%% my_JT
my_JT           = -1./c_p .* (V_m + T .* dp_dT./dp_dV_m)/M_avg;

end

