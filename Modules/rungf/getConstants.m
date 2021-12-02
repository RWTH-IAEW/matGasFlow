function [ CONST ] = getConstants( ~ )
%GETCONSTANTS Struct of constants and quantities at standard condition
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2021, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

CONST.T_n = 273.15;             % Norm temperature [K]
CONST.p_n = 101325;             % Norm pressure [Pa]
CONST.R_m = 8.3144598;          % Universal gas constant [W*s/(mol*K)]
CONST.rho_n_air = 1.29292;      % Norm density of air [kg/m^3]
% CONST.V_m_n_ideal = 0.022414;   % Ideal molar volume [m^3/mol] - unecessary constant

end

