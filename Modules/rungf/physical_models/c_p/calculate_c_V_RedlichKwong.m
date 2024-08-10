function [c_V] = calculate_c_V_RedlichKwong(V_m, T, M_avg, gasMixAndCompoProp, PHYMOD)
%CALCULATE_C_V_REDLICHKWONG Specific isochoric heat capacity c_V [J/(kg*K)]
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
p_c_i   = gasMixAndCompoProp.p_c;
T_c_i   = gasMixAndCompoProp.T_c;
x_mol_i = gasMixAndCompoProp.x_mol;

%% Internal pressure a and covolume b of the gas components
a_i     = 1/9/(2^(1/3)-1) * R_m^2 * T_c_i.^2 ./ p_c_i;
b_i     = (2^(1/3)-1)/3   * R_m   * T_c_i    ./ p_c_i;
b       = sum(x_mol_i.*b_i);

%% Ideal specific isobaric heat capacity of the gas mixture at each bus [J/(kg*K)]
c_p_0 = calculate_c_p_0(T, M_avg, gasMixAndCompoProp, PHYMOD);

%% Partial derivations
d2_a_alpha_dT2  = 3/4 * T.^(-2.5) .* sum(x_mol_i * x_mol_i' .* sqrt((a_i * a_i') .* sqrt(T_c_i * T_c_i')),"all");
int_d2p_dT2     = - d2_a_alpha_dT2 ./ b .* log(V_m./(b+V_m));

%% Real specific isobaric heat capacity of the gas mixture [J/(kg*K)]
c_V = c_p_0 + T.*int_d2p_dT2/M_avg - R_m/M_avg;

end
