function [ PHYMOD ] = getDefaultPhysicalModels()
%GETDEFAULTPHYSICALMODELS Summary of this function goes here
%   Detailed explanation goes here
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2021, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Equation of state - Z
PHYMOD.Z = 1;
% Models for gas mixtures:
% 1: Van-der-Waals
% 2: Redlich-Kwong, alpha=1/sqrt(T)
% 3: Soave-Redlich-Kwong
% 4: Graboski-Soave-Redlich-Kwong
% 5: Koebe-Soave-Redlich-Kwong
% 6: Peng-Robinson

% Models for natural gas:
% 10: DVGW-G 2000
% 11: [Mis15], S. 121, Eq. 9.67
% 12: [Mis15], S. 121, Eq. 9.68
% 13: Papay / [MIS15], S. 122, Eq. 9.75
% 14: DIN EN ISO 6976, interpolation from table data

% Models for natural gas hydrogen:
% 20: 100% H2

% Further models:
% 30: Hard coded value

%% Isobaric heat capacity - c_p
PHYMOD.c_p = 1;
% Models for gas mixtures:
% 1: Van-der-Waals

% Models for natural gas:
% 10: [Mis15] p.131 eqns. 9.87 - 9.89, p.132 table 9-13 
% 11: [Ned17]
% 12: [Ned17]

% Models for natural gas hydrogen:
% 20: 100% H2

% Further models:
% 30: Hard coded value

%% Joule Thomson coefficient - my_JT
PHYMOD.my_JT =1 ;
% Models for gas mixtures:
% 1: Van-der-Waals

% Models for natural gas:
% 10: [Mis15] p.136 eqn. 9.95 ff.
% 11: [Mar10]
% 12: [Mar10]

% Models for natural gas hydrogen:
% 20: 100% H2

% Further models:
% 30: Hard coded value

%% Dynamic viscosity - eta
PHYMOD.eta = 1;
% Models for gas mixtures:
% 1: Herning-Zipperer
% 2: Lukas [VDI-Waermeatlas]

% Models for natural gas:
% 10: Lee-Gonzalez-Eakin
% 11: Lee-Gonzalez-Eakin optimized coefficient

% Models for natural gas hydrogen:
% 20: 100% H2

% Further models:
% 30: Hard coded value

%% Heat capacity ratio - kappa
PHYMOD.kappa = 1;
% Models for gas mixtures:
% 1: van der Waals, kappa = c_p / c_v
%       Requirement: PHYMOD.Z = 3, PHYMOD.c_p = 4
% 2: van der Waals, kappa = c_p / c_v * isothermalExponent
%       Requirement: PHYMOD.Z = 3, PHYMOD.c_p = 4

% Models for natural gas:
% 10: Russian Standards and Technical Regulations, [Mis15] Gl. 9.100

% Models for natural gas hydrogen:
% 20: 100% H2

% Further models:
% 30: Hard coded value

%% Reduced Quantities
PHYMOD.reducedQuantities = 1;
% 1: sum(x_mol*T_c)
% 2: [Mis15] 9.52
% 3: [Mis15] 9.54

%% Compressor model
PHYMOD.comp = 1;
% 1: Isentropic compression 
% 2: Isothermal compression 
% 3: Polytropic compression

PHYMOD.comp_stages = 1;
% 1: One stage
% 2: Number of stages depends on R-values  
% 3: 10 stages to approximate the varible kappa-values over the compression

%% References
% [Mis15] J. Mischner, H.-G. Fasold, J. Heymer, 2015, gas2energy.net
% [Ned17]
% [Mar10]

end

