function [bus_area_ID, pipe_area_ID, valve_area_ID, valve_group_ID] = get_area_ID(GN)
%GET_AREA_ID Area ID
%   [bus_area_ID, pipe_area_ID, valve_area_ID, valve_group_ID] = get_area_ID(GN)
%   Busses, pipes, and valves that are hydraulically connected via pipes or
%   valves form an area with the same area_ID. Areas are seperated by
%   active branches (comp and prs).
%   Output variables:
%       bus_area_ID:    area_ID of each bus
%       pipe_area_ID:   area_ID of each pipe
%       valve_area_ID:  area_ID of each valve
%       valve_group_ID: All valves that are connected to each other and are
%           in service get the same valve_group_ID
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2022, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Bus area ID
GN_temp = GN;
GN_temp.branch(GN_temp.branch.active_branch,:) = [];
if isfield(GN,'pipe')
    GN_temp.branch(GN_temp.branch.pipe_branch & ~GN_temp.branch.in_service,:) = [];
end
if isfield(GN, 'valve')
    GN_temp.branch(GN_temp.branch.valve_branch & ~GN_temp.branch.in_service,:) = [];
end

i_from_bus      = GN_temp.branch.i_from_bus;
i_to_bus        = GN_temp.branch.i_to_bus;
i_seperated_bus = find(~ismember((1:size(GN_temp.bus,1))',[i_from_bus;i_to_bus]));
ADJACENY = sparse(...
    [i_from_bus', i_to_bus', i_seperated_bus'],...
    [i_to_bus', i_from_bus', i_seperated_bus'],...
    1);
g = graph(ADJACENY);
bus_area_ID = conncomp(g)';

%% pipe_area_ID
if isfield(GN,'pipe')
    [~,i_from_bus] = ismember(GN.pipe.from_bus_ID,GN.bus.bus_ID);
    pipe_area_ID = bus_area_ID(i_from_bus);
    pipe_area_ID(~GN.pipe.in_service) = NaN;
else
    pipe_area_ID = NaN;
end

%% valve_area_ID
if isfield(GN,'valve')
    [~,i_from_bus] = ismember(GN.valve.from_bus_ID,GN.bus.bus_ID);
    valve_area_ID = bus_area_ID(i_from_bus);
    valve_area_ID(~GN.valve.in_service) = NaN;
else
    valve_area_ID = NaN;
end

%% valve_group_ID
valve_group_ID = NaN(size(GN.branch,1),1);
if isfield(GN, 'valve')
    branch_temp         = GN.branch(GN.branch.valve_branch & GN.branch.in_service,:);
    i_from_bus_valve    = branch_temp.i_from_bus;
    i_to_bus_valve      = branch_temp.i_to_bus;
    ADJACENY_valve      = sparse(...
        [i_from_bus_valve', i_to_bus_valve'],...
        [i_to_bus_valve', i_from_bus_valve'],...
        1);
    g                   = graph(ADJACENY_valve);
    bus_valve_group_ID = conncomp(g)';
    valve_group_ID(GN.branch.valve_branch & GN.branch.in_service) = bus_valve_group_ID(i_from_bus_valve);
end



