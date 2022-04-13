function [GN] = check_and_init_slack(GN, keep_bus_properties)
%CHECK_AND_INIT_SLACK Summary of this function goes here
%   Detailed explanation goes here
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2022, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 2
    keep_bus_properties = true;
end

%% Restrictions:
%   S L A C K   R E S T R I C T I O N
%   area_active_branch_temp = GN.MAT.area_active_branch;
%   area_active_branch_temp(area_active_branch_temp == 1) = 0;
%   all(GN.MAT.area_bus*GN.bus.slack_bus - area_active_branch_temp*GN.branch.slack_branch == 1)
%
%   slack_branch =!= active_branch
%
%   slack_branch =!= in_service
%
%   active_bus: to_bus(active_branch & )

%% Initialize slack_branch and slack_branch
if ~ismember('slack_branch', GN.branch.Properties.VariableNames)
    GN.branch.slack_branch(:) = false;
    GN.branch.slack_branch = logical(GN.bus.slack_branch);
elseif isnumeric(GN.branch.slack_branch)
    GN.branch.slack_branch = GN.branch.slack_branch == 1;
end

if ~ismember('slack_bus', GN.bus.Properties.VariableNames)
    GN.bus.slack_bus(:) = false;
    GN.bus.slack_bus = logical(GN.bus.slack_bus);
elseif isnumeric(GN.bus.slack_bus)
    GN.bus.slack_bus = GN.bus.slack_bus == 1;
end

%% Areas with slack_branch/slack_bus to be specified
if keep_bus_properties
    % get area_IDs of areas with less or more than one slack_bus/feeding slack_branch
    area_feeding_active_branch      = GN.MAT.area_active_branch;
    area_feeding_active_branch(area_feeding_active_branch == 1)     = 0;
    area_feeding_active_branch(area_feeding_active_branch == -1)    = 1;
    number_of_slack_in_each_area    = GN.MAT.area_bus * GN.bus.slack_bus + area_feeding_active_branch * GN.branch.slack_branch;
    area_IDs                        = find(number_of_slack_in_each_area ~= 1);
else
    % choose all areas
    area_IDs = unique(GN.bus.area_ID);
end

%% Reset slack setting in the specifid areas
idx                         = ismember(GN.bus.area_ID(GN.branch.i_to_bus),area_IDs) & GN.branch.slack_branch;
GN.branch.slack_branch(idx) = false;
idx                         = ismember(GN.bus.area_ID, area_IDs);
GN.bus.slack_bus(idx)       = false;

%% Set p_bus busses to be slack_bus
GN.bus.slack_bus(ismember(GN.bus.area_ID,area_IDs) & GN.bus.p_bus) = true;

%% UNDER CONSTRCUTION: Alternative: use slack_branch

%% Check output
area_feeding_active_branch      = GN.MAT.area_active_branch;
area_feeding_active_branch(area_feeding_active_branch == 1)     = 0;
area_feeding_active_branch(area_feeding_active_branch == -1)    = 1;
number_of_slack_in_each_area    = GN.MAT.area_bus * GN.bus.slack_bus + area_feeding_active_branch * GN.branch.slack_branch;
if any(number_of_slack_in_each_area ~= 1)
    error('Something went wrong. Each area need one p_bus.')
end

end

