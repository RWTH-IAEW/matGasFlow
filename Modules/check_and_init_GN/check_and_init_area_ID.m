function [GN] = check_and_init_area_ID(GN)
%CHECK_AND_INIT_AREA_ID Summary of this function goes here
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2022, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Get bus and branch area_ID
[bus_area_ID, pipe_area_ID, valve_area_ID, valve_group_ID] = get_area_ID(GN);

%% Check and update bus area_ID
if ismember('area_ID',GN.bus.Properties.VariableNames)
    if any(~isnumeric(GN.bus.area_ID))
        warning('GN.bus: area_ID must be numeric. Entries have been updated.')
    elseif any(GN.bus.area_ID(~isnan(bus_area_ID)) ~= bus_area_ID(~isnan(bus_area_ID))) ...
            || any(isnan(GN.bus.area_ID) ~= isnan(bus_area_ID))
    end
end
GN.bus.area_ID = bus_area_ID;
GN.bus = movevars(GN.bus,'area_ID','After','bus_ID');

%% Check and update pipe area_ID
if isfield(GN, 'pipe')
    if ismember('area_ID',GN.pipe.Properties.VariableNames)
        if any(~isnumeric(GN.pipe.area_ID))
            warning('GN.pipe: area_ID must be numeric. Entries have been updated.')
        elseif any(GN.pipe.area_ID(~isnan(pipe_area_ID)) ~= pipe_area_ID(~isnan(pipe_area_ID))) ...
                || any(isnan(GN.pipe.area_ID) ~= isnan(pipe_area_ID))
        end
    end
    GN.pipe.area_ID = pipe_area_ID;
    GN.pipe = movevars(GN.pipe,'area_ID','After','in_service');
end

%% Check and update valve area_ID
if isfield(GN, 'valve')
    if ismember('area_ID',GN.valve.Properties.VariableNames)
        if any(~isnumeric(GN.valve.area_ID))
            warning('GN.valve: area_ID must be numeric. Entries have been updated.')
        elseif any(GN.valve.area_ID(~isnan(valve_area_ID)) ~= valve_area_ID(~isnan(valve_area_ID))) ...
                || any(isnan(GN.valve.area_ID) ~= isnan(valve_area_ID))
        end
    end
    GN.valve.area_ID = valve_area_ID;
    GN.valve = movevars(GN.valve,'area_ID','After','in_service');
end

%% Check and update valve_group_ID
if isfield(GN, 'valve')
    if ismember('valve_group_ID',GN.branch.Properties.VariableNames)
        if any(~isnumeric(GN.branch.valve_group_ID))
            warning('GN.branch: valve_group_ID must be numeric. Entries have been updated.')
        elseif any(GN.branch.valve_group_ID(~isnan(valve_group_ID)) ~= valve_group_ID(~isnan(valve_group_ID))) ...
                || any(isnan(GN.branch.valve_group_ID) ~= isnan(valve_group_ID))
            warning('GN.branch: valve_group_ID entries have been updated.')
        end
    end
    GN.branch.valve_group_ID = valve_group_ID;
    GN.branch = movevars(GN.branch,'valve_group_ID','After','in_service');
end

end

