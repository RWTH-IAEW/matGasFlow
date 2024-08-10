function [kappa] = calculate_kappa_RedlichKwongSoave(p, V_m, T, c_p, c_V, gasMixAndCompoProp)
%CALCULATE_KAPPA_REDLICHKWONGSOAVE
%
%   [kappa] = get_Z_VanDerWaals(c_p, c_v, p, T, V_m, a, b)
%   Input quantities:
%       c_p [J/kg K]        - specific isobaric heat capacity
%       c_v [J/kg K]        - specific isochoric heat capacity
%       p   [Pa]            - pressure
%       T   [K]             - temperature
%       V_m [m^3/mol]       - molar volume
%       a   [N m^4/mol^2]   - internal pressure
%       b   [m^3/mol]       - covolume
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

%% Partial derivations of p(T,V_m)
dp_dV_m     = -R_m.*T./(V_m-b).^2 + a_alpha .* (2.*V_m+b)./(V_m.*(V_m+b)).^2;

%% Isothermal exponent
n_T         = -V_m ./ p .* dp_dV_m;

%% Isentropic exponent
kappa       = c_p./c_V .* n_T;

end

