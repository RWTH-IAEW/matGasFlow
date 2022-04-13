function [GN] = check_GN_area_restrictions(GN, keep_bus_properties)
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
    keep_bus_properties = true;
end

%% active_bus
GN.bus.active_bus(:)    = false;
GN.bus.active_bus       = logical(GN.bus.active_bus);
GN.bus.active_bus(GN.branch.i_to_bus(GN.branch.active_branch & GN.branch.in_service)) = true;

%% Check and initialize area_ID
GN = check_and_init_area_ID(GN);

%% Check for islands
GN = check_GN_islands(GN);

%% Incidence Matrix
GN.INC = get_INC(GN);

% GN.MAT % UNDER CONSTRUCTION: Include INC
GN = get_GN_MAT(GN);

%% Set interconnecting active_branches out of service
GN = set_interconnecting_active_branches_out_of_service(GN);

%% Connecting branches (if-query necessary for NUMPARAM.OPTION_get_J = 2) % UNDER CONSTRUCTION: might be unnecessary
if ~isfield(GN,'flag_NUMPARAM_OPTION_get_J')
    GN = get_connecting_branch(GN); % UNDER CONSTRUCTION merge function with check_GN_islands
end

%% Check and init p_bus
GN = check_and_init_p_bus(GN, keep_bus_properties);

%% Check and init nodal pressure
GN = check_and_init_p_i__barg(GN);

%% Check and init slack bus and slack branch % UNDER CONSTRCUTION: rename
GN = check_and_init_slack(GN, keep_bus_properties);

%% Check output
area_active_branch_temp = GN.MAT.area_active_branch;
    area_active_branch_temp(area_active_branch_temp == 1) = 0;
if any(GN.MAT.area_bus*GN.bus.slack_bus - area_active_branch_temp*GN.branch.slack_branch ~= 1) %sum(GN.bus.slack_bus) + sum(GN.branch.slack_branch) ~= length(unique(GN.bus.area_ID))
    error('Something went wrong. Each area need one slack_bus or one slack_branch.')
elseif sum(GN.bus.p_bus) ~= length(unique(GN.bus.area_ID))
    error('Something went wrong. Each area need one p_bus.')
elseif sum(GN.bus.active_bus) ~= length(unique(GN.branch.i_to_bus(GN.branch.active_branch & GN.branch.in_service)))
    error('Something went wrong. the sum of active_bus must match the number of the to_busses of all active_branches.')
elseif any(GN.branch.slack_branch & ~GN.branch.active_branch) || any(GN.branch.slack_branch & ~GN.branch.in_service)
    error('...')
end

end

