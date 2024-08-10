function [Z, V_m, V_m_2, V_m_3] = calculate_Z_RedlichKwongSoave(p, T, gasMixAndCompoProp)
%CALCULATE_Z_REDLICHKWONGSOAVE
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

%% Physical constants
CONST       = getConstants();

%% Quantities
R_m         = CONST.R_m;
p_c_i       = gasMixAndCompoProp.p_c;
T_c_i       = gasMixAndCompoProp.T_c;
x_mol_i     = gasMixAndCompoProp.x_mol;
omega_i     = gasMixAndCompoProp.omega;

%% Internal pressure a and covolume b of the gas components
a_i         = 1/9/(2^(1/3)-1) * R_m^2 * T_c_i.^2 ./ p_c_i;
b_i         = (2^(1/3)-1)/3   * R_m   * T_c_i    ./ p_c_i;
m_i         = 0.480 + 1.574.*omega_i - 0.176.*omega_i.^2;
b           = sum(x_mol_i.*b_i);

%% k_ij - TODO: no significant influence
% k_ij = zeros(13,13);
% k_ij(1,2)   = -0.0078;
% k_ij(1,3)   =  0.009;
% k_ij(1,6)   =  0.019;
% k_ij(1,10)  = -0.0022;
% k_ij(1,12)  =  0.0278;
% k_ij(12,13) = -0.0315;
% k_ij(2,1)   = -0.0078;
% k_ij(3,1)   =  0.009;
% k_ij(6,1)   =  0.019;
% k_ij(10,1)  = -0.0022;
% k_ij(12,1)  =  0.0278;
% k_ij(13,12) = -0.0315;


%% a*alpha and its partial derivations
% a_alpha     = ...
%       sum(x_mol_i * x_mol_i' .* sqrt( (a_i*a_i') ) .* ((1+m_i)*(1+m_i)')                                          .* (1-k_ij),"all") ...
%     - sum(x_mol_i * x_mol_i' .* sqrt( (a_i*a_i') ) .* ((1+m_i)*(m_i./sqrt(T_c_i))' + (m_i./sqrt(T_c_i))*(1+m_i)') .* (1-k_ij),"all") * sqrt(T) ...
%     + sum(x_mol_i * x_mol_i' .* sqrt( (a_i*a_i') ) .* ((m_i./sqrt(T_c_i))*(m_i./sqrt(T_c_i))')                    .* (1-k_ij),"all") * T;

%% a*alpha and its partial derivations
a_alpha     = ...
      sum(x_mol_i * x_mol_i' .* sqrt( (a_i*a_i') ) .* ((1+m_i)*(1+m_i)')                                          ,"all") ...
    - sum(x_mol_i * x_mol_i' .* sqrt( (a_i*a_i') ) .* ((1+m_i)*(m_i./sqrt(T_c_i))' + (m_i./sqrt(T_c_i))*(1+m_i)') ,"all") * sqrt(T) ...
    + sum(x_mol_i * x_mol_i' .* sqrt( (a_i*a_i') ) .* ((m_i./sqrt(T_c_i))*(m_i./sqrt(T_c_i))')                    ,"all") * T;

%% Solve Cubic Equation V_m^3 + B * V_m^2 + C * V_m + D = 0
B           = - R_m .* T ./ p;                      % [m^3/mol]
C           = (a_alpha - R_m .* T * b)./p - b.^2;   % [m^6/mol^2]
D           = -a_alpha .* b ./ p;                   % [m^9/mol^3]
[V_m, V_m_2, V_m_3] = solve_cubic_equation(B,C,D);  % [m^3/mol]
Z           = p.*V_m./(R_m.*T);

end

