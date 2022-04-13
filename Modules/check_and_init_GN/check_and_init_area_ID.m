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
[bus_area_ID, pipe_area_ID, station_ID, valveStation_ID, valve_area_ID] = get_area_ID(GN); % UNDER CONSTRUCTION

%% Check and update bus area_ID
if any(strcmp('area_ID',GN.bus.Properties.VariableNames))
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
    if any(strcmp('area_ID',GN.pipe.Properties.VariableNames))
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
    if any(strcmp('area_ID',GN.valve.Properties.VariableNames))
        if any(~isnumeric(GN.valve.area_ID))
            warning('GN.valve: area_ID must be numeric. Entries have been updated.')
        elseif any(GN.valve.area_ID(~isnan(valve_area_ID)) ~= valve_area_ID(~isnan(valve_area_ID))) ...
                || any(isnan(GN.valve.area_ID) ~= isnan(valve_area_ID))
        end
    end
    GN.valve.area_ID = valve_area_ID;
    GN.valve = movevars(GN.valve,'area_ID','After','in_service');
end

%% Check and update station_ID
if any(~GN.branch.pipe_branch)
    if any(strcmp('station_ID',GN.branch.Properties.VariableNames))
        if any(~isnumeric(GN.branch.station_ID))
            warning('GN.branch: station_ID must be numeric. Entries have been updated.')
        elseif any(GN.branch.station_ID(~isnan(station_ID)) ~= station_ID(~isnan(station_ID))) ...
                || any(isnan(GN.branch.station_ID) ~= isnan(station_ID))
            warning('GN.branch: station_ID entries have been updated.')
        end
    end
    GN.branch.station_ID = station_ID;
    GN.branch = movevars(GN.branch,'station_ID','After','in_service');
end

%% Check and update valveStation_ID
if isfield(GN, 'valve')
    if any(strcmp('valveStation_ID',GN.branch.Properties.VariableNames))
        if any(~isnumeric(GN.branch.valveStation_ID))
            warning('GN.branch: valveStation_ID must be numeric. Entries have been updated.')
        elseif any(GN.branch.valveStation_ID(~isnan(valveStation_ID)) ~= valveStation_ID(~isnan(valveStation_ID))) ...
                || any(isnan(GN.branch.valveStation_ID) ~= isnan(valveStation_ID))
            warning('GN.branch: valveStation_ID entries have been updated.')
        end
    end
    GN.branch.valveStation_ID = valveStation_ID;
    GN.branch = movevars(GN.branch,'valveStation_ID','After','in_service');
end

end

