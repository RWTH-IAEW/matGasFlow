function [GN] = init_p_i(GN)
%INIT_P_I Initialize p_i
%   GN = init_p_i(GN)
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
% Physical constants
CONST = getConstants();

% p_i [Pa]
GN.bus.p_i = GN.bus.p_i__barg*1e5 + CONST.p_n;
GN.bus = movevars(GN.bus, 'p_i', 'After', 'p_i__barg');

if any(isnan(GN.bus.p_i) | isinf(GN.bus.p_i) | GN.bus.p_i < 0)
    error(['Missing or invalid pressure values in theses areas: ', num2str(find(isnan(GN.bus.p_i) | isinf(GN.bus.p_i) | GN.bus.p_i < 0))'])
=======
while any(isnan(GN.bus.p_i))
    p_i_p_bus           = GN.bus.p_i(GN.bus.p_bus & ~isnan(GN.bus.p_i));
    areas_p_bus         = GN.bus.area_ID(GN.bus.p_bus & ~isnan(GN.bus.p_i));
    [~,area_idx]        = ismember(GN.bus.area_ID,areas_p_bus);
    GN.bus.p_i(area_idx~=0)    = p_i_p_bus(area_idx(area_idx~=0));
    
    GN = get_p_T_valve(GN);
end

>>>>>>> Merge to public repo (#1)
end

