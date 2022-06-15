function [GN] = check_GN_area_restrictions(GN, keep_slack_properties)
%CHECK_GN_AREA_RESTRICTIONS
%   [GN] = check_GN_area_restrictions(GN)
%   Checks:
%       - Check and update bus area_ID
%       - Check and update pipe area_ID
%       - Check and update valve_group_ID
%       - Set area_ID of unsupplied bussus to NaN
%       - Busses must not have more than one valve_from_bus AND not more
%           than one valve_to_bus
%       - Check for islands
%       - Initialize Incidence Matrix
%       - Check bus types
%           1) Check if there is exactly one slack_bus in each area
%           2) Check if two or more non-pipe_branches feed the same bus
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
    keep_slack_properties = true;
end

%% Check and initialize area_ID
GN = check_and_init_area_ID(GN);

%% Check for islands
GN = check_GN_islands(GN);

%% Incidence Matrix
GN = get_INC(GN);

% GN.MAT % UNDER CONSTRUCTION: Include INC
GN = get_GN_MAT(GN);

%% Set interconnecting active_branches out of service
GN = set_interconnecting_active_branches_out_of_service(GN);

%% Connecting branches
GN = get_connecting_branch(GN);

%% Check and init slack bus and slack branch % UNDER CONSTRUCTION: rename
GN = check_and_init_slack(GN, keep_slack_properties);

%% Check and init nodal pressure
GN = check_and_init_p_i__barg(GN);

%% Check output
% Each area must have one slack_bus
number_of_slack_busses_in_each_area = GN.MAT.area_bus * GN.bus.slack_bus;
if any(number_of_slack_busses_in_each_area ~= 1)
    error('Something went wrong. Each area need one slack_bus.')
end

% to_bus of slack_branch must be slack_bus
if any(~GN.bus.slack_bus(GN.branch.i_to_bus(GN.branch.slack_branch)))
    error('Something went wrong. The to_bus of a slack_branch must be a slack_bus.')
end

% All slack_branches must be in_service
if any(GN.branch.slack_branch & ~GN.branch.in_service)
    error('All slack_branches must be in_service.')
end

% All slack_branches must be active_branches
if any(GN.branch.slack_branch & ~GN.branch.active_branch)
    error('All slack_branches must be active_branches.')
end

end

