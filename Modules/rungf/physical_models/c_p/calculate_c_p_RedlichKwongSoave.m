function [c_p, c_p_0, dp_dT, dp_dV_m, int_d2p_dT2] = calculate_c_p_RedlichKwongSoave(V_m, T, M_avg, gasMixAndCompoProp, PHYMOD)
%CALCULATE_C_P_REDLICHKWONGSOAVE
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

%% a*alpha and its partial derivations
a_alpha     = ...
      sum(x_mol_i * x_mol_i' .* sqrt( (a_i*a_i') ) .* ((1+m_i)*(1+m_i)')                                          ,"all") ...
    - sum(x_mol_i * x_mol_i' .* sqrt( (a_i*a_i') ) .* ((1+m_i)*(m_i./sqrt(T_c_i))' + (m_i./sqrt(T_c_i))*(1+m_i)') ,"all") * sqrt(T) ...
    + sum(x_mol_i * x_mol_i' .* sqrt( (a_i*a_i') ) .* ((m_i./sqrt(T_c_i))*(m_i./sqrt(T_c_i))')                    ,"all") * T;
d_a_alpha_dT = ...
    - sum(x_mol_i * x_mol_i' .* sqrt( (a_i*a_i') ) .* ((1+m_i)*(m_i./sqrt(T_c_i))' + (m_i./sqrt(T_c_i))*(1+m_i)') ,"all") / 2 ./ sqrt(T) ...
    + sum(x_mol_i * x_mol_i' .* sqrt( (a_i*a_i') ) .* ((m_i./sqrt(T_c_i))*(m_i./sqrt(T_c_i))')                    ,"all");
d2_a_alpha_dT2 = ...
      sum(x_mol_i * x_mol_i' .* sqrt( (a_i*a_i') ) .* ((1+m_i)*(m_i./sqrt(T_c_i))' + (m_i./sqrt(T_c_i))*(1+m_i)') ,"all") / 4 .* T.^(-1.5);

%% Partial derivations of p(T,V_m)
dp_dT       = R_m ./(V_m-b) - 1./(V_m.*(V_m+b)) .* d_a_alpha_dT;
dp_dV_m     = -R_m.*T./(V_m-b).^2 + a_alpha .* (2.*V_m+b)./(V_m.*(V_m+b)).^2;
int_d2p_dT2 = -d2_a_alpha_dT2 ./b .* log(V_m./(V_m+b));

%% Ideal specific isobaric heat capacity of the gas mixture at each bus [J/(kg*K)]
c_p_0       = calculate_c_p_0(T, M_avg, gasMixAndCompoProp, PHYMOD);

%% Real specific isobaric heat capacity of the gas mixture [J/(kg*K)]
c_p         = c_p_0 + T.*int_d2p_dT2/M_avg - T.*dp_dT.^2./dp_dV_m/M_avg - R_m/M_avg;

end