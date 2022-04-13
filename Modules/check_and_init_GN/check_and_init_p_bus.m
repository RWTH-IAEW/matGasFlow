function [GN] = check_and_init_p_bus(GN, keep_bus_properties)
%CHECK_AND_INIT_P_BUS Summary of this function goes here
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

%% Initialize p_bus
if ~ismember('p_bus',GN.bus.Properties.VariableNames)
    GN.bus.p_bus(:)                 = false;
    GN.bus.p_bus                    = logical(GN.bus.p_bus);
elseif isnumeric(GN.bus.p_bus)
    GN.bus.p_bus = GN.bus.p_bus == 1;
end

%% Areas with p_bus to be specified
if keep_bus_properties
    % get area_IDs of areas with less or more than one p_bus
    number_of_p_bus_in_each_area    = GN.MAT.area_bus * GN.bus.p_bus;
    area_IDs                        = find(number_of_p_bus_in_each_area ~= 1);
else
    % choose all areas
    area_IDs = unique(GN.bus.area_ID);
end

%% Reset p_bus setting in the specifid areas
idx                 = ismember(GN.bus.area_ID, area_IDs);
GN.bus.p_bus(idx)   = false;


%% branch weight
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

%% Choose slack_branch, slack_bus and p_bus
for ii = 1:length(area_IDs)
    
    if sum(GN.bus.area_ID == area_IDs(ii)) == 1
        % area has only one bus
        GN.bus.p_bus(GN.bus.area_ID == area_IDs(ii)) = true;
        
    elseif sum(~isnan(GN.bus.p_i__barg(GN.bus.area_ID == area_IDs(ii)))) == 1
        % Specify the only bus with the p_i__barg value as p_bus
        GN.bus.p_bus(GN.bus.area_ID == area_IDs(ii) & ~isnan(GN.bus.p_i__barg)) = true;
        
    else
        % area has more than one bus
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
        i_p_bus = i_bus_unique(ranks == max(ranks));
        if isempty(i_p_bus)
            disp('...')
        end
        GN.bus.p_bus(i_p_bus(1))    = true;
        
    end
end

%% Check output
number_of_p_bus_in_each_area    = GN.MAT.area_bus * GN.bus.p_bus;
if any(number_of_p_bus_in_each_area ~= 1)
    error('Something went wrong. Each area need one p_bus.')
end

end

