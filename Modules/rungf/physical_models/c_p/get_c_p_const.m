function [GN] = get_c_p_const(GN, PHYMOD)
%GET_C_P_CONST
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% bus
GN.bus.c_p_i(:) = PHYMOD.c_p_const;

%% non-isothermal
if ~GN.isothermal
    
    %% Source bus
    if ismember('source_bus', GN.bus.Properties.VariableNames)
        GN.bus.c_p_i_source(GN.bus.source_bus) = PHYMOD.c_p_const;
    end
    
    %% pipe
    if isfield(GN, 'pipe')
        GN.pipe.c_p_ij(:) = PHYMOD.c_p_const;
    end
    
    %% Branch output
    if isfield(GN, 'branch')
        GN.branch.c_p_ij_out(:) = PHYMOD.c_p_const;
    end
    
    %% comp
    if isfield(GN, 'comp')
        GN.comp.c_p_ij_mid(:) = PHYMOD.c_p_const;
    end
    
    %% prs
    if isfield(GN, 'prs')
        GN.prs.c_p_ij_mid(:) = PHYMOD.c_p_const;
    end
    
end

end

