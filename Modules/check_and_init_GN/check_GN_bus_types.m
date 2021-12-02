function check_GN_bus_types(GN)
%CHECK_GN_BUS_TYPES
%   check_GN_bus_types(GN)
%   1) Check if there is exactly one p_bus in each area
%   2) Check if there is exactly one f_0_bus in each area
%   3) Check if two or more non-pipe_branches feed the same bus
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2021, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Check if there is exactly one p_bus in each area
all_area_IDs = unique(GN.bus.area_ID);
all_area_IDs(isnan(all_area_IDs)) = [];

areas = GN.bus.area_ID(GN.bus.p_bus);
areas = sort(areas);

area_with_no_p_bus = areas(~ismember(areas,all_area_IDs));
area_with_multiple_p_bus = unique(areas([diff(areas) == 0;false]));
if any(area_with_no_p_bus)
    error(['These areas have no p_bus: ', num2str(area_with_no_p_bus),'. There must be exactly one p_bus in each area.'])
elseif any(area_with_multiple_p_bus)
    error(['These areas have more than one p_bus: ', num2str(area_with_multiple_p_bus),'. There must be exactly one p_bus in each area.'])
end

%% Check if there is exactly one f_0_bus in each area
areas = GN.bus.area_ID(GN.bus.f_0_bus);
areas = sort(areas);

area_with_no_f_0_bus = areas(~ismember(areas,all_area_IDs));
area_with_multiple_f_0_bus = areas(diff(sort(areas)) == 0);
if any(area_with_no_f_0_bus)
    error(['These areas have no f_0_bus: ', num2str(area_with_no_f_0_bus),'. There must be exactly one f_0_bus in each area.'])
end
if any(area_with_multiple_f_0_bus)
    error(['These areas have more than one f_0_bus: ', num2str(area_with_multiple_f_0_bus),'. There must be exactly one f_0_bus in each area.'])
end

%% Check if two or more non-pipe_branches feed the same bus
if any(GN.INC * ~GN.branch.pipe_branch(GN.branch.in_service) <= -2)
    error(['bus_ID with more than one in-feeding non-pipe branche: ',num2str(GN.bus.bus_ID(GN.INC * ~GN.branch.pipe_branch(GN.branch.in_service) <= -2))])
end

end

