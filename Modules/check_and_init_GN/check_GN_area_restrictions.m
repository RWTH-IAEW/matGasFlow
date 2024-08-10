function [GN] = check_GN_area_restrictions(GN, keep_slack_properties)
%CHECK_GN_AREA_RESTRICTIONS
%   [GN] = check_GN_area_restrictions(GN)
%   Checks:
%       - Check and update bus area_ID
%       - Check for islands
%       - Initialize Incidence Matrix and further system matrices
%       - set interconnecting active_branches out of service
%       - Specify connecting_branch
%       - Check and initialize slack
%       - Check and initialize p_i__barg
%       - Check output
%           * Each area must have one slack_bus
%           * to_bus of slack_branch must be slack_bus
%           * All slack_branches must be in_service
%           * All slack_branches must be active_branches
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

%% System Matrices
GN = get_GN_MAT(GN);

%% Set interconnecting active_branches out of service
GN = set_interconnecting_active_branches_out_of_service(GN);

%% Check and init slack bus and slack branch
GN = check_and_init_slack(GN, keep_slack_properties);

%% Check and init nodal pressure
GN = check_and_init_p_i__barg(GN);

%% Connecting branches
GN = get_connecting_branch(GN);

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

