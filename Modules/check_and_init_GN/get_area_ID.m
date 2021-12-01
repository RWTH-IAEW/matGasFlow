function [bus_area_ID, pipe_area_ID, station_ID, valveStation_ID] = get_area_ID(GN)
%GET_AREA_ID Summary of this function goes here
%   Detailed explanation goes here
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2021, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Bus area ID
% Set area_ID considering all branches in service
GN_temp = GN;
GN_temp.branch(~GN_temp.branch.pipe_branch,:) = [];
i_from_bus = GN_temp.branch.i_from_bus;
i_to_bus = GN_temp.branch.i_to_bus;
i_seperated_bus = find(~ismember((1:size(GN_temp.bus,1))',[i_from_bus;i_to_bus]));
ADJACENY = sparse(...
    [i_from_bus', i_to_bus', i_seperated_bus'],...
    [i_to_bus', i_from_bus', i_seperated_bus'],...
    1);
g = graph(ADJACENY);
bus_area_ID = conncomp(g)';

%% Pipe area_ID
if isfield(GN,'pipe')
    [~,i_from_bus] = ismember(GN.pipe.from_bus_ID,GN.bus.bus_ID);
    pipe_area_ID = bus_area_ID(i_from_bus);
else
    pipe_area_ID = NaN;
end

%% station_ID
station_ID = NaN(size(GN.branch,1),1);
if any(~GN.branch.pipe_branch)
    GN_temp_2 = GN;
    GN_temp_2.branch = GN_temp_2.branch(~GN.branch.pipe_branch,:);
    i_from_bus_nonPipe = GN_temp_2.branch.i_from_bus;
    i_to_bus_nonPipe = GN_temp_2.branch.i_to_bus;
    ADJACENY_nonPipe = sparse(...
        [i_from_bus_nonPipe', i_to_bus_nonPipe'],...
        [i_to_bus_nonPipe', i_from_bus_nonPipe'],...
        1);
    g = graph(ADJACENY_nonPipe);
    bus_station_ID = conncomp(g)';
    station_ID(~GN.branch.pipe_branch) = bus_station_ID(i_from_bus_nonPipe);
end

%% valveStation_ID
valveStation_ID = NaN(size(GN.branch,1),1);
if isfield(GN, 'valve')
    GN_temp_2 = GN;
    GN_temp_2.branch = GN_temp_2.branch(GN.branch.valve_branch,:);
    i_from_bus_valve = GN_temp_2.branch.i_from_bus;
    i_to_bus_valve = GN_temp_2.branch.i_to_bus;
    ADJACENY_valve = sparse(...
        [i_from_bus_valve', i_to_bus_valve'],...
        [i_to_bus_valve', i_from_bus_valve'],...
        1);
    g = graph(ADJACENY_valve);
    bus_valveStation_ID = conncomp(g)';
    valveStation_ID(GN.branch.valve_branch) = bus_valveStation_ID(i_from_bus_valve);
end

