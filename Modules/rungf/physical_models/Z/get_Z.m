function [ GN ] = get_Z(GN, PHYMOD, object, NUMPARAM)
%GET_Z Compressibility factor
%   [ GN ] = GET_Z(GN, PHYMOD)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin < 3
    object = {'bus','source','pipe'};
end

%% Compressibility K_i and Compressibility Factor Z_i
if PHYMOD.Z == 0
    %% AGA8-92DC (ISO 12213-2)
    if nargin < 4
        NUMPARAM = getDefaultNumericalParameters;
    end
    if ~ismember('Z_i',GN.bus.Properties.VariableNames) && any(ismember(object,{'all','bus'}))
        GN = get_Z_PengRobinson(GN, object);
    end
    GN = get_Z_AGA8_92DC(GN, object, NUMPARAM);

elseif PHYMOD.Z == 1
    %% Van der Waals Equation
    GN = get_Z_VanDerWaals(GN, object);
    
elseif PHYMOD.Z == 2
    %% Redlich-Kwong Equation
    GN = get_Z_RedlichKwong(GN, object);
    
elseif PHYMOD.Z == 3
    %% Soave-Redlich-Kwong Equation
    GN = get_Z_RedlichKwongSoave(GN, object);
    
elseif PHYMOD.Z == 4
    %% Peng-Robinson Equation
    GN = get_Z_PengRobinson(GN, object);
    
elseif PHYMOD.Z == 5
    %% Benedict-Webb-Rubin Equation
    GN = get_Z_BenedictWebbRubin(GN, object);

elseif PHYMOD.Z == 10
    %% DVGW-G 2000
    GN = get_Z_DVGW2000(GN);
    
elseif PHYMOD.Z == 11
    %% [Mischner 2015], S. 121, Eq. 9.67
    GN = get_Z_Mis15__9_67(GN);
    
elseif PHYMOD.Z == 12
    %% [Mischner 2015], S. 121, Eq. 9.68
    GN = get_Z_Mis15__9_68(GN);
    
elseif PHYMOD.Z == 13 % TODO
    %% ONTP 51-1-85
    GN = get_Z_ONTP(GN);
    
elseif PHYMOD.Z == 14 % TODO
    %% NTP MG
    GN = get_Z_NTPMG(GN);
    
elseif PHYMOD.Z == 15
    %% Papay / [Mischner 2015], S. 122, Eq. 9.75
    GN = get_Z_Papay(GN);
    
elseif PHYMOD.Z == 16 % TODO
    %% DIN EN ISO 6976
    GN = get_Z_DIN_EN_ISO_6976(GN);

elseif PHYMOD.Z == 17
    %% AGA
    GN = get_Z_AGA(GN);

elseif PHYMOD.Z == 20 % TODO
    %% 100% H2
    GN = get_Z_H2(GN);

elseif PHYMOD.Z == 21
    %% Virial equation for H2
    GN = get_Z_VirialEquationH2(GN, object);
    
elseif PHYMOD.Z == 30
    %% Constant value, PHYMOD.Z_const must be specified
    GN = get_Z_const(GN, PHYMOD);
    
else
    error(['PHYMOD.Z = ',num2str(PHYMOD.Z),' is invalid.'])
end

end

