function [GN] = get_my_JT(GN, PHYMOD)
%GET_MY_JT Joule-Thomson Coefficient for mixtures
%   [GN] = get_my_JT(GN, PHYMOD)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if PHYMOD.my_JT == 0
    %% AGA8-92DC (ISO 12213-2)
    GN = get_my_JT_AGA8_92DC(GN);

elseif PHYMOD.my_JT == 1
    %% Van der Waals model
    GN = get_my_JT_VanDerWaals(GN);

elseif PHYMOD.my_JT == 2
    %% Redlich-Kwong Equation
    GN = get_my_JT_RedlichKwong(GN);

elseif PHYMOD.my_JT == 3
    %% Soave-Redlich-Kwong Equation
    GN = get_my_JT_RedlichKwongSoave(GN);

elseif PHYMOD.my_JT == 4
    %% Soave-Redlich-Kwong Equation
    GN = get_my_JT_PengRobinson(GN);

elseif PHYMOD.my_JT == 10
    %% DVGW 2000
    GN = get_my_JT_DVGW2000(GN);

elseif PHYMOD.my_JT == 11
    %% NTP MG
    GN = get_my_JT_NTPMG(GN);

elseif PHYMOD.my_JT == 20
    %% 100% H2
    GN = get_my_JT_H2(GN);

elseif PHYMOD.my_JT == 30
    %% Constant value, PHYMOD.Z_const must be specified
    GN = get_my_JT_const(GN,PHYMOD);
    
else
    error(['PHYMOD.my_JT = ',num2str(PHYMOD.my_JT),' is invalid.'])
end

end

