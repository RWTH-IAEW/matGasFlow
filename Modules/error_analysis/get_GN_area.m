function [GN] = get_GN_area(GN, area_ID, apply_check_and_init_GN)
%GET_GN_AREA Summary of this function goes here
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

if nargin < 3
    apply_check_and_init_GN = true;
end

% Update V_dot_n_i
if ismember('V_dot_n_ij_preset',GN.branch.Properties.VariableNames)
    % Apply V_dot_n_ij
    GN.bus.f = GN.INC * GN.branch.V_dot_n_ij_preset(GN.branch.in_service) + GN.bus.V_dot_n_i; % UNDER CONSTRUCTION --> GN.INC muss immer alle branches abdecken! get_INC anpassen und in init_rungf anpassen
elseif ismember('V_dot_n_ij',GN.branch.Properties.VariableNames)
    % Apply V_dot_n_ij_preset
    GN.bus.f = GN.INC * GN.branch.V_dot_n_ij + GN.bus.V_dot_n_i;
else
    GN.bus.f = GN.bus.V_dot_n_i;
end
GN.bus.V_dot_n_i = GN.bus.f;

% Set slack_bus
if ~any(GN.bus.slack_bus(GN.bus.area_ID == area_ID))
    i_slack_bus = GN.branch.i_to_bus(GN.branch.slack_branch & GN.bus.area_ID(GN.branch.i_to_bus) == area_ID);
    if length(i_slack_bus) ~= 1
        error('Something went wrong: Areas with no slack_bus need exact one feeding slack_branch.')
    end
    GN.bus.slack_bus(i_slack_bus) = true;
end

% Delete busses outside of the area
GN.bus(GN.bus.area_ID ~= area_ID,:) = [];

% Delete pipes outside of the area
if isfield(GN, 'pipe')
    GN.pipe(GN.pipe.area_ID ~= area_ID,:) = [];
    if isempty(GN.pipe)
        GN = rmfield(GN,'pipe');
    end
end

% Delete comps and prs
if isfield(GN, 'comp')
    GN = rmfield(GN, 'comp');
end

if isfield(GN, 'prs')
    GN = rmfield(GN, 'prs');
end

% Delete vaves outside of the area
if isfield(GN, 'valve')
    GN.valve(GN.valve.area_ID ~= area_ID,:) = [];
    if isempty(GN.valve)
        GN = rmfield(GN,'valve');
    end
end

if apply_check_and_init_GN && size(GN.bus,1) > 1
    GN = check_and_init_GN(GN);
end

end