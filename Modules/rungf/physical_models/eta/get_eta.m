function [GN] = get_eta(GN, PHYMOD)
% GET_ETA Dynamic viscosity eta [Pa*s]
%   [GN] = GET_ETA(GN, PHYMOD)
%   Dynamic viscosity eta_ij(T,rho)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~isfield(GN, 'pipe')
    return
end

if PHYMOD.eta == 0
    %% Lohrenz-Bray-Clark, ISO 20765-5
    GN = get_eta_LBC(GN);

elseif PHYMOD.eta == 1 || PHYMOD.eta == 1.5
    %% Herning-Zipperer
    GN = get_eta_HerningZipperer(GN, PHYMOD);
    
elseif PHYMOD.eta == 2
    %% Lucas, VDI-Waermeatlas
    GN = get_eta_Lucas(GN);
    
elseif PHYMOD.eta == 3
    %% Wilke
    GN = get_eta_Wilke(GN);
    
elseif PHYMOD.eta == 4
    %% Chung et al.
    error('Method of Chung et al. has not been implemented yet.')
    %     GN = get_eta_Chung(GN);
    
elseif PHYMOD.eta == 5
    %% Reichenberg
    error('Method of Reichenberg has not been implemented yet.')
    
elseif PHYMOD.eta == 10 || PHYMOD.eta == 11 || PHYMOD.eta == 12
    %% LGE-Verfahren [Mischner 2015] S. 129
    GN = get_eta_LGE(GN,PHYMOD);
    
elseif PHYMOD.eta == 13
    %% NTP MG [Mischner 2015] S. 130
    GN = get_eta_NTPMG(GN);
    
elseif  PHYMOD.eta == 20
    %% 100% H2
    GN = get_eta_H2(GN);
    
elseif  PHYMOD.eta == 30
    %% Constant value, PHYMOD.eta_const must be specified
    GN.pipe.eta_ij(:) = PHYMOD.eta_const;
    
else
    %% ERROR
    error('PHYMOD.eta is invalid.')
    
end

end

