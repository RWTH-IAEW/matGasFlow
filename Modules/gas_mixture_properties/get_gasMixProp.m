function [gasMixProp] = get_gasMixProp(gasMixAndCompoProp)
%GET_GASMIXPROP physical properties of the gas composition
%   GETGASMIXTUREPROPERTIES(GN) calculates...
%       M_avg           [kg/mol]    Average molar mass
%       rho_n_avg       [kg/m^3]    Average values of gas properties at standard conditions
%       V_m_n_avg       [m^3/mol]   Average molar volume at standard conditions
%       Z_n_avg         [-]         Average compressibility factor at standard conditions
%       V_m_n_avg       [m^3/mol]   Average molar volume
%       rho_n_avg       [kg/m^3]    Average gravimetric densitiy
%       p_pc            [Pa]       Pseudo critical pressure
%       T_pc            [K]         Pseudo critical temperature
%       T_pc_adj_v1     [K]         Adjusted pseudo critical temperature (variante 1)
%       p_pc_adj_v1     [Pa]       Adjusted pseudo critical pressure (variante 1)
%       T_pc_adj_v2     [K]         Adjusted pseudo critical temperature (variante 2)
%       p_pc_adj_v2     [Pa]       Adjusted pseudo critical pressure (variante 2)
%       V_m_pc          [m^3/mol]   Pseudo critical molar volume
%       H_i_n_avg       [J/m^3]     Average inferior caloric value at standard conditions
%       H_s_n_avg       [J/m^3]     Average superior caloric value at standard conditions
%       Wobbe_i_n_avg   [J/m^3]     Average inferior Wobbe index
%       Wobbe_s_n_avg   [J/m^3]     Average superior Wobbe index
%
%   ... and returns the results in gasMixProp.
%
%   Note: Standard conditions 273.15 K, 101325 Pa
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2021, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Average molar mass [kg/mol]
gasMixProp.M_avg = sum(gasMixAndCompoProp.x_mol .* gasMixAndCompoProp.M);

%% Average values of gas properties at standard conditions (273.15 K, 101325 Pa)
% Average compressibility factor [-]
% Reference: ISO 6976:1995, [Mis15] S.118 Gl. 9.61
% gasMixProp.Z_n_avg = 1 - sum(gasCompoProp.x_mol .* sqrt(1-gasCompoProp.Z_n))^2;

% Reference: DIN 6976:2016
gasMixProp.Z_n_avg = 1 - sum(gasMixAndCompoProp.x_mol .* gasMixAndCompoProp.sum_factor).^2;

% Average molar volume [m^3/mol]
gasMixProp.V_m_n_avg = sum(gasMixAndCompoProp.x_mol .* gasMixAndCompoProp.V_m_n);

% Average gravimetric densitiy [kg/m^3]
gasMixProp.rho_n_avg = sum(gasMixAndCompoProp.x_vol .* gasMixAndCompoProp.rho_n);

%% Pseudo critical data
% Pseudo critical pressure [Pa]
gasMixProp.p_pc =  sum(gasMixAndCompoProp.x_mol .* gasMixAndCompoProp.p_c);

% Pseudo critical temperature [K]
gasMixProp.T_pc =  sum(gasMixAndCompoProp.x_mol .* gasMixAndCompoProp.T_c);

% Adjusted pseudo critical data
% Reference: Mischner 2015, S. 117, (9.52)...(9.54)
% Option 1: Wichtert and Aziz
epsilon = 120 * ( (gasMixAndCompoProp.x_mol('H2S') + gasMixAndCompoProp.x_mol('CO2'))^0.9 - (gasMixAndCompoProp.x_mol('H2S') + gasMixAndCompoProp.x_mol('H2'))^1.6 ) ...
    + 15  * ( gasMixAndCompoProp.x_mol('H2S')^0.5 - gasMixAndCompoProp.x_mol('H2S')^4 );
gasMixProp.T_pc_adj_v1 = 5/9 * (1.8 * gasMixProp.T_pc - epsilon);
gasMixProp.p_pc_adj_v1 = gasMixProp.p_pc * 1.8 * gasMixProp.T_pc_adj_v1 / (1.8 *gasMixProp.T_pc + gasMixAndCompoProp.x_mol('H2S') * (1-gasMixAndCompoProp.x_mol('H2S')) *epsilon);

% Option 2: Carr, Kobayashi and Burrows
gasMixProp.T_pc_adj_v2 = gasMixProp.T_pc - 44.4 * gasMixAndCompoProp.x_mol('CO2') + 72.2 * gasMixAndCompoProp.x_mol('H2S') - 138.9 * gasMixAndCompoProp.x_mol('N2');
gasMixProp.p_pc_adj_v2 = gasMixProp.p_pc + 30.3 * gasMixAndCompoProp.x_mol('CO2') + 41.1 * gasMixAndCompoProp.x_mol('H2S') - 11.7  * gasMixAndCompoProp.x_mol('N2');

% Pseudo critical molar volume [m^3/mol] - unecessary
% gasMixProp.V_m_pc = sum(gasMixAndCompoProp.x_mol .* gasMixAndCompoProp.V_m_c);

%% Caloric value
% Average inferior caloric value [J/m^3]
gasMixProp.H_i_n_avg = sum(gasMixAndCompoProp.x_vol .* gasMixAndCompoProp.H_i_n);

% Average superior caloric value [J/m^3]
gasMixProp.H_s_n_avg = sum(gasMixAndCompoProp.x_vol .* gasMixAndCompoProp.H_s_n);

%% Wobbe index [J/m^3]
%Physical constants
CONST = getConstants();

% Relative density
d = gasMixProp.rho_n_avg / CONST.rho_n_air;

% Inferior and superior Wobbe index
gasMixProp.Wobbe_i_n_avg = gasMixProp.H_i_n_avg / sqrt(d);
gasMixProp.Wobbe_s_n_avg = gasMixProp.H_s_n_avg / sqrt(d);

end