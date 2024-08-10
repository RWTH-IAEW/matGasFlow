function [Z, V_m, V_m_2, V_m_3] = calculate_Z_PengRobinson(p, T, gasMixAndCompoProp)
%CALCULATE_Z_PENGROBINSON
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
CONST       = getConstants();

%% Quantities
R_m         = CONST.R_m;
p_c_i       = gasMixAndCompoProp.p_c;
T_c_i       = gasMixAndCompoProp.T_c;
x_mol_i     = gasMixAndCompoProp.x_mol;
omega_i     = gasMixAndCompoProp.omega;

%% Internal pressure a and covolume b of the gas components
a_i         = 0.457235 * R_m^2 * T_c_i.^2 ./ p_c_i;
b_i         = 0.077796 * R_m   * T_c_i    ./ p_c_i;
m_i         = 0.37463 + 1.54226.*omega_i - 0.26992.*omega_i.^2;
b           = sum(x_mol_i.*b_i);

%% a*alpha and its partial derivations
a_alpha     = ...
      sum(x_mol_i * x_mol_i' .* sqrt( (a_i*a_i') ) .* ((1+m_i)*(1+m_i)')                                          ,"all") ...
    - sum(x_mol_i * x_mol_i' .* sqrt( (a_i*a_i') ) .* ((1+m_i)*(m_i./sqrt(T_c_i))' + (m_i./sqrt(T_c_i))*(1+m_i)') ,"all") * sqrt(T) ...
    + sum(x_mol_i * x_mol_i' .* sqrt( (a_i*a_i') ) .* ((m_i./sqrt(T_c_i))*(m_i./sqrt(T_c_i))')                    ,"all") * T;

%% Solve Cubic Equation V_m^3 + B * V_m^2 + C * V_m + D = 0
B           = b - R_m .* T ./ p;                                    % [m^3/mol]
C           = ( a_alpha      - 2 * b   * R_m .* T )./p - 3*b.^2; % [m^6/mol^2]
D           = (-a_alpha .* b +     b^2 * R_m .* T )./p +   b^3;  % [m^9/mol^3]
[V_m, V_m_2, V_m_3] = solve_cubic_equation(B,C,D);  % [m^3/mol]
Z           = p.*V_m./(R_m.*T);

end

