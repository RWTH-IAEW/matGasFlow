function [ PHYMOD ] = getDefaultPhysicalModels()
%GETDEFAULTPHYSICALMODELS Default setting for physical models
%
%   [PYHMOD] = getDefaultPhysicalModels() returns a struct with default
%   settings for different phyical models.
%
%   PHYMOD.Z - Equation of state
%       Models for any gas mixtures:
%           1: Van-der-Waals (DEFAULT)
%           2: Redlich-Kwong, alpha=1/sqrt(T)
%           3: Soave-Redlich-Kwong
%           4: Graboski-Soave-Redlich-Kwong
%           5: Koebe-Soave-Redlich-Kwong
%           6: Peng-Robinson
%       Models for natural gas:
%           10: DVGW-G 2000
%           11: [Mis15], S. 121, Eq. 9.67
%           12: [Mis15], S. 121, Eq. 9.68
%           13: Papay / [MIS15], S. 122, Eq. 9.75
%           14: DIN EN ISO 6976, interpolation from table data
%       Models for natural gas hydrogen:
%           20: 100% H2
%       Further models:
%           30: Hard coded value
%
%   PHYMOD.c_p - Isobaric heat capacity
%       Models for gas mixtures:
%           1: Van-der-Waals (DEFAULT)
%       Models for natural gas:
%           10: [Mis15] p.131 eqns. 9.87 - 9.89, p.132 table 9-13 
%           11: [Ned17]
%           12: [Ned17]
%       Models for natural gas hydrogen:
%           20: 100% H2
%       Further models:
%           30: Hard coded value
%
%   PHYMOD.my_JT - Joule Thomson coefficient
%       Models for gas mixtures:
%           1: Van-der-Waals (DEFAULT)
%       Models for natural gas:
%           10: [Mis15] p.136 eqn. 9.95 ff.
%           11: [Mar10]
%           12: [Mar10]
%       Models for natural gas hydrogen:
%           20: 100% H2
%       Further models:
%           30: Hard coded value
%
%   PHYMOD.eta - Dynamic viscosity
%       Models for gas mixtures:
%           1: Herning-Zipperer (DEFAULT)
%           2: Lukas [VDI-Waermeatlas]
%       Models for natural gas:
%           10: Lee-Gonzalez-Eakin
%           11: Lee-Gonzalez-Eakin optimized coefficient
%       Models for natural gas hydrogen:
%           20: 100% H2
%       Further models:
%           30: Hard coded value
%
%   PHYMOD.kappa - Heat capacity ratio - kappa
%       Models for gas mixtures:
%           1: van der Waals, kappa = c_p / c_v (DEFAULT)
%               Requirement: PHYMOD.Z = 3, PHYMOD.c_p = 4
%           2: van der Waals, kappa = c_p / c_v * isothermalExponent
%               Requirement: PHYMOD.Z = 3, PHYMOD.c_p = 4
%       Models for natural gas:
%           10: Russian Standards and Technical Regulations, [Mis15] Gl. 9.100
%       Models for natural gas hydrogen:
%           20: 100% H2
%       Further models:
%           30: Hard coded value
%
%   PHYMOD.reducedQuantities - Reduced Quantities
%           1: sum(x_mol*T_c) (DEFAULT)
%           2: [Mis15] 9.52
%           3: [Mis15] 9.54
%
%   PHYMOD.comp - Compressor model
%           1: Isentropic compression (DEFAULT)
%           2: Isothermal compression 
%           3: Polytropic compression
%
%   PHYMOD.comp_stages - Compressor stages
%           1: One stage (DEFAULT)
%           2: Number of stages depends on R-values  
%           3: 10 stages to approximate the varible kappa-values over the compression
%
%   See README for references.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2021, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

PHYMOD.Z = 1;
PHYMOD.c_p = 1;
PHYMOD.my_JT =1 ;
PHYMOD.eta = 1;
PHYMOD.kappa = 1;
PHYMOD.reducedQuantities = 1;
PHYMOD.comp = 1;
PHYMOD.comp_stages = 1;

end

