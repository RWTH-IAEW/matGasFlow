function [GN] = init_T_i(GN)
%INIT_T_I Initialization of nodal temperature T_i
%   [GN] = init_T_i(GN)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
<<<<<<< HEAD
%   Copyright (c) 2020-2022, High Voltage Equipment and Grids,
=======
%   Copyright (c) 2020-2021, High Voltage Equipment and Grids,
>>>>>>> Merge to public repo (#1)
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

<<<<<<< HEAD
%% Initialize T_i
if ~any(strcmp('T_i',GN.bus.Properties.VariableNames))
    GN.bus.T_i = NaN(size(GN.bus,1),1);
end

%% Loop - UNDER CONSTRUCTION: avoid loop
while any(isnan(GN.bus.T_i)) 
=======
while any(isnan(GN.bus.T_i))
>>>>>>> Merge to public repo (#1)
    if GN.isothermal == 0
        T_i_set           = GN.bus.T_i(~isnan(GN.bus.T_i));
        areas_T_bus         = GN.bus.area_ID(~isnan(GN.bus.T_i));
        [~,area_idx]        = ismember(GN.bus.area_ID,areas_T_bus);
        GN.bus.T_i(area_idx~=0)    = T_i_set(area_idx(area_idx~=0));
        GN.bus.T_i(area_idx==0)    = GN.T_env;
        
    elseif GN.isothermal == 1
        GN.bus.T_i(:) = GN.T_env;
        
    end
<<<<<<< HEAD
=======
    
    GN = get_p_T_valve(GN);
>>>>>>> Merge to public repo (#1)
end
end