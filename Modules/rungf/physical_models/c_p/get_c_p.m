function [GN] = get_c_p(GN, PHYMOD)
%GET_C_P Specific isobaric heat capacity of the pipes and the busses
%   c_p [J/(kg*K)]
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if PHYMOD.c_p == 0
    %% AGA8-92DC (ISO 12213-2)
    GN = get_c_p_AGA8_92DC(GN);

elseif PHYMOD.c_p == 1
    %% Van der Waals
    GN = get_c_p_VanDerWaals(GN, PHYMOD);
    
elseif PHYMOD.c_p == 2
    %% Redling-Kwong
    GN = get_c_p_RedlichKwong(GN, PHYMOD);
    
elseif PHYMOD.c_p == 3
    %% Soave-Redling-Kwong
    GN = get_c_p_RedlichKwongSoave(GN, PHYMOD);
    
elseif PHYMOD.c_p == 4
    %% Peng-Robinson
    GN = get_c_p_PengRobinson(GN, PHYMOD);
    
elseif PHYMOD.c_p == 10
    %% DVGW-G 2000
    GN = get_c_p_DVGW2000(GN, PHYMOD);

elseif PHYMOD.c_p == 11
    %% [Sucharjev; Karasjevitsch 2000], [Sardanaschwili 2005], see [Mischner 2015] p.131 et sqq.
    GN = get_c_p_SucharjevKarasjevitsch(GN);
    
elseif PHYMOD.c_p == 12
    %% NTP MG, [Mischner 2015] p.132
    GN = get_c_p_NTPMG(GN);
    
elseif PHYMOD.c_p == 20
    %% 100% H2
    GN = get_c_p_H2(GN);
    
elseif PHYMOD.c_p == 30
    %% Constant value, PHYMOD.c_p_const must be specified
    GN = get_c_p_const(GN,PHYMOD);
    
else
    error(['PHYMOD.c_p = ',num2str(PHYMOD.c_p),' is invalid.'])
end

end

