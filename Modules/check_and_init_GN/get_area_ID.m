<<<<<<< HEAD
function [bus_area_ID, pipe_area_ID, station_ID, valveStation_ID, valve_area_ID] = get_area_ID(GN)
=======
function [bus_area_ID, pipe_area_ID, station_ID, valveStation_ID] = get_area_ID(GN)
>>>>>>> Merge to public repo (#1)
%GET_AREA_ID Area ID
%   [bus_area_ID, pipe_area_ID, station_ID, valveStation_ID] = get_area_ID(GN)
%   Output variables
%       bus_area_ID:
%           All busses that are part of a common area have the same
%           area_ID. An area is a sub-network that consists exclusively of
%           busses and pipes and is separated from other areas by non-pipe
%           branches (comp, prs or valve).
%
%       pipe_area_ID:
%           All pipes that are part of a common area have the same area_ID.
%           An area is a sub-network that consists exclusively of busses
%           and pipes and is separated from other areas by non-pipe
%           branches (comp, prs or valve).
%
%       station_ID:
%           UNDER CONSTRUCTION
%
%       valveStation_ID:
%           UNDER CONSTRUCTION
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
%% Bus area ID % UNDER CONSTRUCTION: Anpassung des valve Modells
GN_temp = GN;
GN_temp.branch(GN_temp.branch.active_branch,:) = [];
if isfield(GN,'pipe')
    GN_temp.branch(GN_temp.branch.pipe_branch & ~GN_temp.branch.in_service,:) = [];
end
if isfield(GN, 'valve')
    GN_temp.branch(GN_temp.branch.valve_branch & ~GN_temp.branch.in_service,:) = [];
end

=======
%% Bus area ID
% Set area_ID considering all branches in service
GN_temp = GN;
GN_temp.branch(~GN_temp.branch.pipe_branch,:) = [];
>>>>>>> Merge to public repo (#1)
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
<<<<<<< HEAD
    pipe_area_ID(~GN.pipe.in_service) = NaN;
=======
>>>>>>> Merge to public repo (#1)
else
    pipe_area_ID = NaN;
end

<<<<<<< HEAD
%% Valve area_ID
if isfield(GN,'valve')
    [~,i_from_bus] = ismember(GN.valve.from_bus_ID,GN.bus.bus_ID);
    valve_area_ID = bus_area_ID(i_from_bus);
    valve_area_ID(~GN.valve.in_service) = NaN;
else
    valve_area_ID = NaN;
end

%% station_ID % UNDER CONSTRUCTION: Anpassung des valve Modells
station_ID = NaN(size(GN.branch,1),1);
% if any(GN.branch.active_branch & GN.branch.in_service)
%     GN_temp_2               = GN;
%     GN_temp_2.branch        = GN_temp_2.branch(GN.branch.active_branch & GN.branch.in_service,:);
%     i_from_bus_actBranch    = GN_temp_2.branch.i_from_bus;
%     i_to_bus_actBranch      = GN_temp_2.branch.i_to_bus;
%     ADJACENY_compORprs      = sparse(...
%         [i_from_bus_actBranch', i_to_bus_actBranch'],...
%         [i_to_bus_actBranch', i_from_bus_actBranch'],...
%         1);
%     g               = graph(ADJACENY_compORprs);
%     bus_station_ID  = conncomp(g)';
%     station_ID(GN.branch.active_branch) = bus_station_ID(i_from_bus_actBranch);
% end
=======
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
>>>>>>> Merge to public repo (#1)

%% valveStation_ID
valveStation_ID = NaN(size(GN.branch,1),1);
if isfield(GN, 'valve')
<<<<<<< HEAD
    branch_temp         = GN.branch(GN.branch.valve_branch & GN.branch.in_service,:);
    i_from_bus_valve    = branch_temp.i_from_bus;
    i_to_bus_valve      = branch_temp.i_to_bus;
    ADJACENY_valve      = sparse(...
        [i_from_bus_valve', i_to_bus_valve'],...
        [i_to_bus_valve', i_from_bus_valve'],...
        1);
    g                   = graph(ADJACENY_valve);
    bus_valveStation_ID = conncomp(g)';
    valveStation_ID(GN.branch.valve_branch & GN.branch.in_service) = bus_valveStation_ID(i_from_bus_valve);
end



=======
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

>>>>>>> Merge to public repo (#1)
