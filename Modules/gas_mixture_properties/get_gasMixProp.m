function [gasMixProp] = get_gasMixProp(gasMixAndCompoProp, PHYMOD)
%GET_GASMIXPROP physical properties of the gas mixture
%   GETGASMIXTUREPROPERTIES(GN) calculates...
%       M_avg           [kg/mol]    Average molar mass
%       Z_n_avg         [-]         Average compressibility factor at standard conditions
%       V_m_n_avg       [m^3/mol]   Average molar volume
%       rho_n_avg       [kg/m^3]    Average values of gas properties at standard conditions
%       V_m_n_avg       [m^3/mol]   Average molar volume at standard conditions
%       rho_n_avg       [kg/m^3]    Average gravimetric densitiy
%       p_pc            [Pa]        Pseudo critical pressure
%       T_pc            [K]         Pseudo critical temperature
%       H_i_n_avg       [J/m^3]     Average inferior caloric value at standard conditions
%       H_s_n_avg       [J/m^3]     Average superior caloric value at standard conditions
%       Wobbe_i_n_avg   [J/m^3]     Average inferior Wobbe index
%       Wobbe_s_n_avg   [J/m^3]     Average superior Wobbe index
%
%   ... and returns the results in gasMixProp (struct).
%
%   Note: Standard conditions T = 273.15 K, p = 101325 Pa
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 2
    PHYMOD = getDefaultPhysicalModels;
end    

%% Physical constants
CONST = getConstants;

%% Average molar mass [kg/mol]
gasMixProp.M_avg = sum(gasMixAndCompoProp.x_mol .* gasMixAndCompoProp.M);

%% Average values of gas properties at standard conditions (273.15 K, 101325 Pa)
% Average molar volume [m^3/mol]
gasMixProp.V_m_n_avg = sum(gasMixAndCompoProp.x_mol .* gasMixAndCompoProp.V_m_n);

% Average gravimetric densitiy [kg/m^3]
gasMixProp.rho_n_avg = sum(gasMixAndCompoProp.x_vol .* gasMixAndCompoProp.rho_n);

% Average compressibility factor [-]
% Reference: ISO 6976:1995, [Mischner 2015] S.118 Gl. 9.61
% Z_n = CONST.p_n * gasMixAndCompoProp.V_m_n / CONST.R_m / CONST.T_n;
% gasMixProp.Z_n_avg = 1 - sum(gasMixAndCompoProp.x_mol .* sqrt(1-                   Z_n))^2;
% gasMixProp.Z_n_avg = 1 - sum(gasMixAndCompoProp.x_mol .* sqrt(1-gasMixAndCompoProp.Z_n))^2;
% gasMixProp.Z_n_avg = 1 - sum(gasMixAndCompoProp.x_mol .* gasMixAndCompoProp.sum_factor )^2;

gasMixProp.Z_n_avg  = CONST.p_n * gasMixProp.V_m_n_avg / CONST.R_m / CONST.T_n;

gasMixProp.PHYMOD   = PHYMOD.gasMixProp;

%% Pseudo critical data
% Pseudo critical pressure [Pa]
gasMixProp.p_pc =  sum(gasMixAndCompoProp.x_mol .* gasMixAndCompoProp.p_c);

% Pseudo critical temperature [K]
gasMixProp.T_pc =  sum(gasMixAndCompoProp.x_mol .* gasMixAndCompoProp.T_c);

if PHYMOD.reducedQuantities == 2
    % Adjusted pseudo critical data - Wichtert and Aziz
    % Reference: Mischner 2015, S. 117, (9.52)...(9.54)
    epsilon = 120 * ( ...
        (gasMixAndCompoProp.x_mol('H2S') + gasMixAndCompoProp.x_mol('CO2'))^0.9 ...
        - (gasMixAndCompoProp.x_mol('H2S') + gasMixAndCompoProp.x_mol('H2'))^1.6 ) ...
        + 15  * ( gasMixAndCompoProp.x_mol('H2S')^0.5 - gasMixAndCompoProp.x_mol('H2S')^4 );
    
    % Pseudo critical temperature [K]
    gasMixProp.T_pc = gasMixProp.T_pc - 5/9 * epsilon;
    
    % Pseudo critical pressure [Pa]
    gasMixProp.p_pc = gasMixProp.p_pc * 9/5 * gasMixProp.T_pc ...
        / (9/5 * gasMixProp.T_pc + gasMixAndCompoProp.x_mol('H2S') * (1-gasMixAndCompoProp.x_mol('H2S')) *epsilon);
    
elseif PHYMOD.reducedQuantities == 3
    % Adjusted pseudo critical data - Carr, Kobayashi and Burrows
    % Reference: Mischner 2015, S. 117, (9.52)...(9.54)
    
    % Pseudo critical pressure [Pa]
    gasMixProp.p_pc = gasMixProp.p_pc ...
        + 30.3 * gasMixAndCompoProp.x_mol('CO2') ...
        + 41.1 * gasMixAndCompoProp.x_mol('H2S') ...
        - 11.7  * gasMixAndCompoProp.x_mol('N2');
    
    % Pseudo critical temperature [K]
    gasMixProp.T_pc = gasMixProp.T_pc ...
        - 44.4 * gasMixAndCompoProp.x_mol('CO2') ...
        + 72.2 * gasMixAndCompoProp.x_mol('H2S') ...
        - 138.9 * gasMixAndCompoProp.x_mol('N2');
end
% Pseudo critical molar volume [m^3/mol]
gasMixProp.V_m_pc = sum(gasMixAndCompoProp.x_mol .* gasMixAndCompoProp.V_m_c);

% Pseudo critical molar volume [m^3/mol]
gasMixProp.Z_pc   = (gasMixProp.p_pc * gasMixProp.V_m_pc) / (CONST.R_m * gasMixProp.T_pc);

%% Caloric value
% Average inferior caloric value [J/m^3]
gasMixProp.H_i_n_avg = sum(gasMixAndCompoProp.x_vol .* gasMixAndCompoProp.H_i_n);

% Average superior caloric value [J/m^3]
gasMixProp.H_s_n_avg = sum(gasMixAndCompoProp.x_vol .* gasMixAndCompoProp.H_s_n);

%% Wobbe index [J/m^3]
% Relative density
d = gasMixProp.rho_n_avg / CONST.rho_n_air;

% Inferior and superior Wobbe index
gasMixProp.Wobbe_i_n_avg = gasMixProp.H_i_n_avg / sqrt(d);
gasMixProp.Wobbe_s_n_avg = gasMixProp.H_s_n_avg / sqrt(d);

%% sigma
% [Chung et al.], [Reid et al.]
x_mol               = gasMixAndCompoProp.x_mol;
V_m_c__cm3_per_mol  = gasMixAndCompoProp.V_m_c * 1e6;

idx_triu            = triu(true(size(gasMixAndCompoProp,1)),1);

sigma_i             = 0.809 * V_m_c__cm3_per_mol.^(1/3);
sigma_ij            = sqrt(sigma_i * sigma_i');
sigma_ij(idx_triu)  = 0;
gasMixProp.sigma_mix_pow3      = sum(sigma_ij.^3.*(x_mol*x_mol'),'all');
% gasMixProp.sigma_mix_pow2      = sigma_mix_pow3^(2/3); % TODO: this might be wrong, check [Poling et al., 2001, Properties of Gases and Liquids, 5th Edition]
gasMixProp.sigma_mix_pow2      = sum(sigma_ij.^2.*(x_mol*x_mol'),'all');

%% omega_mix - acentric factor
% [Chung et al.], [Reid et al.]
omega_ij                = (gasMixAndCompoProp.omega+gasMixAndCompoProp.omega')/2;
omega_ij(idx_triu)      = 0;
gasMixProp.omega_mix    = 1/(gasMixProp.sigma_mix_pow3) * sum(omega_ij .* sigma_ij.^3 .* (x_mol*x_mol'),'all');

%% epsilon per k [K]
% [Chung et al.], [Reid et al.]
epsilon_per_k_i                 = gasMixAndCompoProp.T_c/1.2593;
epsilon_per_k_ij                = sqrt(epsilon_per_k_i * epsilon_per_k_i');
epsilon_per_k_ij(idx_triu)      = 0;
epsilon_per_k_mix = 1/gasMixProp.sigma_mix_pow3 * sum(epsilon_per_k_ij .* sigma_ij.^3 .* (x_mol*x_mol'),'all');

%% Molar weight factor of gas mixture [kg/mol]
% [Chung et al.], [Reid et al.]
M_ij                        = 2*(gasMixAndCompoProp.M*gasMixAndCompoProp.M')./(gasMixAndCompoProp.M+gasMixAndCompoProp.M');
M_ij(idx_triu)              = 0;
gasMixProp.M_mix            = (1/(epsilon_per_k_mix*gasMixProp.sigma_mix_pow2) * sum(epsilon_per_k_ij .* sigma_ij.^2 .* sqrt(M_ij) .* (x_mol*x_mol'),'all'))^2;

%% my_dp_mix, my_dp_r_mix - dipole moment [debye] and reduced dipole moment [-]
% [Chung et al.], [Reid et al.]
V_m_c_mix__cm3_per_mol                  = gasMixProp.sigma_mix_pow3/0.809^3;
T_c_mix                                 = epsilon_per_k_mix*1.2593;
my_dp                                   = gasMixAndCompoProp.my_dp;
my_dp_mix_temp                          = ( (my_dp.^2 * (my_dp.^2)').*(x_mol*x_mol') )./sigma_ij.^3;
my_dp_mix_temp(isnan(my_dp_mix_temp))   = 0;
my_dp_mix_temp(isinf(my_dp_mix_temp))   = 0;
my_dp_mix                               = (gasMixProp.sigma_mix_pow3 * sum( my_dp_mix_temp,'all'))^(1/4);
gasMixProp.my_dp_r_mix                  = 131.3*my_dp_mix / sqrt(V_m_c_mix__cm3_per_mol * T_c_mix);
gasMixProp.my_dp_r_mix_2                = 52.46 * my_dp_mix^2 * gasMixProp.p_pc / gasMixProp.T_pc^2;
end