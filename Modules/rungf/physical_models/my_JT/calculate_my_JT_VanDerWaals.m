function [my_JT] = calculate_my_JT_VanDerWaals(V_m, T, c_p, M_avg, gasMixAndCompoProp)
%GET_MY_JT_VANDERWAALS
%   [my_JT] = calculate_my_JT_VanDerWaals(V_m, T, a, b, M, c_p)
%   Input quantities:
%       V_m [m^3/mol]       - molar volume
%       T   [K]             - temperature
%       a   [N m^4/mol^2]   - internal pressure
%       b   [m^3/mol]       - covolume
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
dp_dT       =  R_m   ./(V_m-b);
dp_dV_m     = -R_m.*T./(V_m-b).^2 + 2*a ./ V_m.^3;

%% my_JT
my_JT = -1./c_p .* (V_m + T .* dp_dT./dp_dV_m)/M_avg;

end

