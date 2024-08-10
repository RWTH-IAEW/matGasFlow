function [kappa,dp_dV_m,V_m,a,b] = calculate_kappa_VanDerWaals(p, V_m, T, c_p, c_V, gasMixAndCompoProp)
%GET_KAPPA_VANDERWAALS
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

%% Internal pressure a and covolume b of the gas components
a_i         = 27/64 * R_m^2 .* T_c_i.^2 ./ p_c_i;
b_i         = 1/8   * R_m   .* T_c_i    ./ p_c_i;
a           = sum(x_mol_i * x_mol_i' .* sqrt(a_i * a_i'),'all');
b           = sum(x_mol_i.*b_i);

%% Partial derivations
dp_dV_m     = -R_m.*T./(V_m-b).^2 + 2*a ./ V_m.^3;

%% Isothermal exponent
n_T         = -V_m ./ p .* dp_dV_m;

%% Isentropic exponent
kappa       = c_p./c_V .* n_T;

end

