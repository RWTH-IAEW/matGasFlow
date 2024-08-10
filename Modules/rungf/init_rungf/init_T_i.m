function [GN] = init_T_i(GN)
%INIT_T_I Initialization of nodal temperature T_i
%   [GN] = init_T_i(GN)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~ismember('T_i',GN.bus.Properties.VariableNames)
    GN.bus.T_i(:)                   = GN.T_env;
end

if isfield(GN,'T_env')
    GN.bus.T_i(isnan(GN.bus.T_i))   = GN.T_env;
end

if ~GN.isothermal
	GN.bus.T_i(GN.bus.source_bus)   = GN.bus.T_i_source(GN.bus.source_bus);
end

end
