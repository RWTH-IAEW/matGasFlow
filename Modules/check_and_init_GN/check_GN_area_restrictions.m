function [GN] = check_GN_area_restrictions(GN)
%CHECK_GN_AREA_RESTRICTIONS
%   [GN] = check_GN_area_restrictions(GN)
%   Checks:
%       - Check and update bus area_ID
%       - Check and update pipe area_ID
%       - Check and update station_ID
%       - Check and update valveStation_ID
%       - Set area_ID of unsupplied bussus to NaN
%       - Busses must not have more than one valve_from_bus AND not more
%           than one valve_to_bus
%       - Check for islands
%       - Initialize Incidence Matrix
%       - Check bus types
%           1) Check if there is exactly one p_bus in each area
%           2) Check if there is exactly one f_0_bus in each area
%           3) Check if two or more non-pipe_branches feed the same bus
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2021, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Get bus and branch area_ID
[bus_area_ID, pipe_area_ID, station_ID, valveStation_ID] = get_area_ID(GN);

%% Check and update bus area_ID
if any(strcmp('area_ID',GN.bus.Properties.VariableNames))
    if any(~isnumeric(GN.bus.area_ID))
        warning('GN.bus: area_ID must be numeric. Entries have been updated.')
    elseif any(GN.bus.area_ID(~isnan(bus_area_ID)) ~= bus_area_ID(~isnan(bus_area_ID))) ...
            || any(isnan(GN.bus.area_ID) ~= isnan(bus_area_ID))
        warning('GN.bus: area_ID entries have been updated.')
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
            warning('GN.pipe: area_ID entries have been updated.')
        end
    end
    GN.pipe.area_ID = pipe_area_ID;
    GN.pipe = movevars(GN.pipe,'area_ID','After','in_service');
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

%% Unsupplied busses
% Set area_ID of unsupplied bussus to NaN
GN_temp = GN;
GN_temp.branch(~GN_temp.branch.in_service,:) = [];
GN.bus.supplied = (ismember(1:size(GN_temp.bus,1),[GN_temp.branch.i_from_bus;GN_temp.branch.i_to_bus]))';
if (any(strcmp('P_i',GN.bus.Properties.VariableNames)) && any(GN.bus.P_i(~GN.bus.supplied) ~= 0)) ...
        || (any(strcmp('V_dot_n_i',GN.bus.Properties.VariableNames)) && any(GN.bus.V_dot_n_i(~GN.bus.supplied) ~= 0))
    warning(['GN.bus: bus_ID of unsupplied sinks/sources: ',num2str(GN.bus.bus_ID(GN.bus.V_dot_n_i(~GN.bus.supplied) ~= 0)')])
end

%% Busses must not have more than one valve_from_bus AND not more than one valve_to_bus
if isfield(GN,'valve')
    i_from_bus = GN.branch.i_from_bus(GN.branch.valve_branch & GN.branch.in_service);
    i_to_bus = GN.branch.i_to_bus(GN.branch.valve_branch & GN.branch.in_service);
    if ~(length(i_from_bus) == length(unique(i_from_bus)) && length(i_to_bus) == length(unique(i_to_bus)))
        error('GN.valve: Busses must not have more than one valve from_bus AND not more than one valve to_bus.')
    end
end

%% Check for islands
GN = check_GN_islands(GN);

%% Incidence Matrix
GN.INC = get_INC(GN);

%% Check bus types
% 1) Check if there is exactly one p_bus in each area
% 2) Check if there is exactly one f_0_bus in each area
% 3) Check if two or more non-pipe_branches feed the same bus
check_GN_bus_types(GN);

end

