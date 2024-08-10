function [ CONST ] = getConstants( ~ )
%GETCONSTANTS Struct of constants and quantities at standard condition
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

CONST.T_n           = 273.15;           % Norm temperature [K]
CONST.p_n           = 101325;           % Norm pressure [Pa]
CONST.R_m           = 8.31446261815324; % Universal gas constant [W*s/(mol*K)]
CONST.N_A           = 6.02214076*1e23;  % Avogadro constant [1/mol]
CONST.rho_n_air     = 1.29292;          % Norm density of air [kg/m^3]
CONST.V_m_n_ideal   = 0.022414;         % Ideal molar volume [m^3/mol] - (unused in matGaFlow)
CONST.Re_crit       = 2300;             % Critial Reynold number
CONST.g             = 9.81;             % Gravitational acceleration in Europe [m/s]=[N/kg]

end

