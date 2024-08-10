function [GN] = get_Z_const(GN,PHYMOD)
%GET_Z_CONST
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if isempty(PHYMOD.Z_const)
    error('get_Z_const: PHYMOD.Z_const is empty.')
end

%% bus
GN.bus.Z_i(:) = PHYMOD.Z_const;

%% pipe
if isfield(GN,'pipe')
    GN.pipe.Z_ij(:) = PHYMOD.Z_const;
end

%% non-isothermal
if ~GN.isothermal
    
    %% source
    if any(GN.bus.source_bus)
        GN.bus.Z_i_source(GN.bus.source_bus) = PHYMOD.Z_const;
    end
    
    %% branch
    if isfield(GN,'branch')
        GN.branch.Z_ij_out(:) = PHYMOD.Z_const;
    end
    
    %% comp
    if isfield(GN,'comp')
        GN.comp.Z_ij_mid(:) = PHYMOD.Z_const;
    end
    
    %% prs
    if isfield(GN,'prs')
        GN.prs.Z_ij_mid(:) = PHYMOD.Z_const;
    end
    
end

end

