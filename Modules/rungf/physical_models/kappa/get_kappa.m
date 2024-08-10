function [GN] = get_kappa(GN, PHYMOD)
%GET_KAPPA Calculation of heat capacity ratio
%   [GN] = GET_KAPPA(GN, PHYMOD)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Isentropic exponent kappa_i - Physical Models
if PHYMOD.kappa == 0
    %% AGA8-92DC (ISO 12213-2)
    GN = get_kappa_AGA8_92DC(GN);

elseif PHYMOD.kappa == 1
    %% Van der Waals model
    GN = get_kappa_VanDerWaals(GN, PHYMOD);
    
elseif PHYMOD.kappa == 1.5
    %% Van der Waals model for ideal gases
    GN = get_kappa_VanDerWaals_iG(GN, PHYMOD);
    
elseif PHYMOD.kappa == 2
    %% Redlich-Kwong
    GN = get_kappa_RedlichKwong(GN, PHYMOD);
    
elseif PHYMOD.kappa == 3
    %% Redlich-Kwong-Soave
    GN = get_kappa_RedlichKwongSoave(GN, PHYMOD);
    
elseif PHYMOD.kappa == 4
    %% Peng-Robinson
    GN = get_kappa_PengRobinson(GN, PHYMOD);
    
elseif PHYMOD.kappa == 10
    %% DVGW 2000
    GN = get_kappa_DVGW2000(GN, PHYMOD);

elseif PHYMOD.kappa == 11
    %% Russian Standards and Technical Regulations
    GN = get_kappa_GOST(GN);
    
elseif PHYMOD.kappa == 20
    %% 100% H2
    GN = get_kappa_H2(GN);
   
elseif PHYMOD.kappa == 30
    %% Constant value, PHYMOD.kappa_const must be specified
    GN = get_kappa_const(GN, PHYMOD);
    
else
    error(['PHYMOD.kappa = ',num2str(PHYMOD.kappa),' is invalid.'])
end

%% Check output
if any(isnan(GN.bus.kappa_i))
    error('')
end


end