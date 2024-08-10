function [ PHYMOD ] = getDefaultPhysicalModels()
%GETDEFAULTPHYSICALMODELS Default setting for physical models
%
%   [PYHMOD] = getDefaultPhysicalModels() returns a struct with default
%   settings for different phyical models.
%
%   PHYMOD.Z - Equation of state
%       Models for any gas mixtures:
%           0: AGA8-92DC (DEFAULT)
%           1: Van der Waals
%           2: Redlich-Kwong
%           3: Soave-Redlich-Kwong
%           4: Peng-Robinson
%           5: Benedict-Webb-Rubin - TODO
%       Models for natural gas:
%           10: DVGW-G 2000
%           11: [Mischner 2015], S. 121, Eq. 9.67
%           12: [Mischner 2015], S. 121, Eq. 9.68
%           13: ONTP 51-1-85 - TODO
%           14: NTP MG - TODO
%           15: Papay / [Mischner 2015], S. 122, Eq. 9.75
%           16: DIN EN ISO 6976 - TODO
%       Models for pure hydrogen:
%           20: 100% H2
%           21: Virial equation for H2
%       Further models:
%           30: Constant value, PHYMOD.Z_const must be specified
%
%   PHYMOD.c_p - Specific isobaric heat capacity
%       Models for gas mixtures:
%           0: AGA8-92DC (DEFAULT)
%           1: Van der Waals
%           2: Redlich-Kwong
%           3: Soave-Redlich-Kwong
%           4: Peng-Robinson
%       Models for natural gas:
%           10: DVGW-G 2000
%           11: [Sucharjev; Karasjevitsch 2000], [Sardanaschwili 2005], see [Mischner 2015] p.131 et sqq.
%           12: NTP MG, [Mischner 2015] p.132
%       Models for natural gas hydrogen:
%           20: 100% H2
%       Further models:
%           30: Constant value, PHYMOD.c_p_const must be specified
%
%   PHYMOD.c_p_0 - Ideal specific isobaric heat capacity (only relevant for PHYMOD.c_p = 1, 2, 3, 4, 10 and PHYMOD.kappa = 1, 2, 3, 4, 10)
%           0: VDI-Atlas
%           1: Gasunie/AGA
%           2: Heintz
%
%   PHYMOD.my_JT - Joule Thomson coefficient
%       Models for gas mixtures:
%           0: AGA8-92DC (DEFAULT)
%           1: Van der Waals
%           2: Redlich-Kwong
%           3: Soave-Redlich-Kwong
%           4: Peng-Robinson
%       Models for natural gas:
%           10: DVGW 2000
%           11: NTP MG
%       Models for natural gas hydrogen:
%           20: 100% H2
%       Further models:
%           30: Constant value, PHYMOD.my_JT_const must be specified
%
%   PHYMOD.kappa - Heat capacity ratio - kappa
%       Models for gas mixtures:
%           0: AGA8-92DC (DEFAULT)
%           1: Van der Waals
%           1.5 Van der Waals model for ideal gases (c_p/c_v)
%           2: Redlich-Kwong
%           3: Soave-Redlich-Kwong
%           4: Peng-Robinson
%       Models for natural gas:
%           10: DVGW 2000
%           11: Russian Standards and Technical Regulations (GOST)
%       Models for natural gas hydrogen:
%           20: 100% H2
%       Further models:
%           30: Constant value, PHYMOD.kappa_const must be specified
%
%   PHYMOD.eta - Dynamic viscosity
%       Models for gas mixtures:
%           0: Lohrenz-Bray-Clark (DEFAULT)
%           1: Herning-Zipperer
%           2: Lucas [VDI-Waermeatlas]
%           3: Wilke
%           4: Chung et al.
%           5: Reichenberg - TODO
%       Models for natural gas:
%           10/11: Lee-Gonzalez-Eakin
%           12: Lee-Gonzalez-Eakin optimized coefficient
%           13: NTP MG [Mischner 2015] S. 130
%       Models for natural gas hydrogen:
%           20: 100% H2
%       Further models:
%           30: Constant value, PHYMOD.eta_const must be specified
%
%   PHYMOD.reducedQuantities - Reduced Quantities
%           1: sum(x_mol*T_c) (DEFAULT)
%           2: [Mischner 2015] 9.52
%           3: [Mischner 2015] 9.54
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
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

PHYMOD.gasMixProp           = '';%'standard conditions'; TODO
PHYMOD.Z                    = 0;
PHYMOD.Z_const              = [];
PHYMOD.c_p                  = 0;
PHYMOD.c_p_0                = 0;
PHYMOD.my_JT                = 0;
PHYMOD.kappa                = 0;
PHYMOD.eta                  = 0;
PHYMOD.eta_const            = [];
PHYMOD.reducedQuantities    = 1;
PHYMOD.comp                 = 1;
PHYMOD.comp_stages          = 1;
PHYMOD.comp_cooler_stages   = 1;

end

