function [Z, V_m, V_m_2, V_m_3] = calculate_Z_RedlichKwong(p, T, gasMixAndCompoProp)
%CALCULATE_Z_REDLICHKWONG
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

%%% Physical constants
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

%% Solve Cubic Equation V_m^3 + B * V_m^2 + C * V_m + D = 0
B               = - R_m .* T ./ p;                          % [m^3/mol]
C               = (a_alpha - R_m .* T * b)./p - b.^2;       % [m^6/mol^2]
D               = -a_alpha .* b ./ p;                       % [m^9/mol^3]
[V_m, V_m_2, V_m_3] = solve_cubic_equation(B,C,D);  % [m^3/mol]
Z               = p.*V_m./(R_m.*T);

end

