function [GN] = check_and_init_slack(GN, keep_slacks)
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
    keep_slacks = true;
end

%% Initialize slack_branch and slack_branch
if ~ismember('slack_branch', GN.branch.Properties.VariableNames)
    GN.branch.slack_branch(:) = false;
    GN.branch.slack_branch = logical(GN.bus.slack_branch);
elseif isnumeric(GN.branch.slack_branch)
    GN.branch.slack_branch = GN.branch.slack_branch == 1;
end

if ~ismember('slack_bus',GN.bus.Properties.VariableNames)
    GN.bus.slack_bus(:)                 = false;
    GN.bus.slack_bus                    = logical(GN.bus.slack_bus);
elseif isnumeric(GN.bus.slack_bus)
    GN.bus.slack_bus = GN.bus.slack_bus == 1;
end

%% to_bus of all slack_branches become slack_bus
GN.bus.slack_bus(GN.branch.i_to_bus(GN.branch.slack_branch)) = true;

%% Areas with slack_bus to be specified
if keep_slacks
    % get area_IDs of areas with less or more than one slack_bus
    number_of_slack_busses_in_each_area = GN.MAT.area_bus * GN.bus.slack_bus;
    area_IDs                            = find(number_of_slack_busses_in_each_area ~= 1);
else
    % choose all areas
    area_IDs = unique(GN.bus.area_ID);
end

%% Reset slack_bus setting in the specifid areas
idx                     = ismember(GN.bus.area_ID, area_IDs);
GN.bus.slack_bus(idx)   = false;
idx                     = ismember(GN.bus.area_ID(GN.branch.i_to_bus(GN.branch.slack_branch)), area_IDs);
i_slack_branch          = find(GN.branch.slack_branch);
GN.branch.slack_branch(i_slack_branch(idx)) = false;

%% branch weight
if ~isempty(area_IDs)
    branch_weight = NaN(size(GN.branch,1),1);
    
    if isfield(GN,'pipe')
        branch_weight(GN.branch.pipe_branch) = ...
            GN.pipe.L_ij(GN.branch.i_pipe(GN.branch.pipe_branch)) ...
            ./ GN.pipe.D_ij(GN.branch.i_pipe(GN.branch.pipe_branch)).^4;
    end
    
    if isfield(GN,'valve')
        if isfield(GN,'pipe')
            branch_weight(GN.branch.valve_branch) = min(branch_weight(GN.branch.pipe_branch)) * 1e-6;
        else
            branch_weight(GN.branch.valve_branch) = 1;
        end
    end
end

%% Choose slack_branch, slack_bus
for ii = 1:length(area_IDs)
    
    if sum(GN.bus.area_ID == area_IDs(ii)) == 1
        % Area has only one bus
        GN.bus.slack_bus(GN.bus.area_ID == area_IDs(ii)) = true;
        
    elseif sum(~isnan(GN.bus.p_i__barg(GN.bus.area_ID == area_IDs(ii)))) == 1
        % Area has more than one bus but only one bus with a p_i__barg value
        %   choose this bus to be slack_bus
        GN.bus.slack_bus(GN.bus.area_ID == area_IDs(ii) & ~isnan(GN.bus.p_i__barg)) = true;
        
    else
        % Area has more than one bus and more or less busses with a p_i__barg value
        GN_area                 = GN;
        branch_in_area          = GN_area.bus.area_ID(GN_area.branch.i_from_bus) == area_IDs(ii) & ~GN_area.branch.active_branch;
        i_from_bus              = GN_area.branch.i_from_bus(branch_in_area);
        i_to_bus                = GN_area.branch.i_to_bus(branch_in_area);
        i_bus_unique            = unique([i_from_bus; i_to_bus]);
        [~,i_i_from_bus]        = ismember(i_from_bus, i_bus_unique);
        [~,i_i_to_bus]          = ismember(i_to_bus, i_bus_unique);
        area_graph              = graph(i_i_from_bus, i_i_to_bus);
        area_graph.Edges.Weight = branch_weight(branch_in_area);
        closeness_ranks         = centrality(area_graph,'closeness','Cost',area_graph.Edges.Weight);
        ranks                   = closeness_ranks;
        i_slack_bus             = i_bus_unique(ranks == max(ranks));
        GN.bus.slack_bus(i_slack_bus(1))    = true;
        
    end
end

end