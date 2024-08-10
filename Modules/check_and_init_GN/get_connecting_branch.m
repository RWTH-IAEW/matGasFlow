function [GN] = get_connecting_branch(GN)
%GET_CONNECTING_BRANCH
%
%   Initializes GN.branch.connecting_branch, identifies connecting in
%   a meshed grid with the help of a minimum spanning tree algorithm and
%   sets them to true.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2022, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% GN - connecting branches
branch_temp                                 = GN.branch;
branch_temp(branch_temp.parallel_branch,:)  = [];
branch_temp(~branch_temp.in_service,:)      = [];

weights                                     = ones(size(branch_temp,1),1);
weights(branch_temp.preset)                 = 1e3;

g       = graph(branch_temp.i_from_bus, branch_temp.i_to_bus, weights);
t       = minspantree(g,'Method','sparse');
islands = unique(conncomp(t));
if length(islands) > 1
    error('GN has isolated busses.')
end

g_array                         = g.Edges.EndNodes;
t_array                         = t.Edges.EndNodes;
iBranch_temp                    = ismember(g_array,t_array,'row');
connecting_branch_from_to_bus   = g_array(~iBranch_temp,:);

branch_temp.connecting_branch   = ...
    ismember([branch_temp.i_from_bus,branch_temp.i_to_bus],connecting_branch_from_to_bus,'rows') | ...
    ismember([branch_temp.i_to_bus,branch_temp.i_from_bus],connecting_branch_from_to_bus,'rows');

[~,idx] = ismember(branch_temp.branch_ID(branch_temp.connecting_branch), GN.branch.branch_ID);
GN.branch.connecting_branch(:)      = false;
GN.branch.connecting_branch(idx)    = true;

%% Area - connecting branches
branch_temp                                 = GN.branch;
branch_temp(branch_temp.parallel_branch,:)  = [];
branch_temp(~branch_temp.in_service,:)      = [];
branch_temp(branch_temp.active_branch,:)    = [];

weights                                     = ones(size(branch_temp,1),1);
i_branch_at_slack_bus                       = GN.bus.slack_bus(branch_temp.i_from_bus) | GN.bus.slack_bus(branch_temp.i_to_bus);
weights(i_branch_at_slack_bus)              = 1e3;

g       = graph(branch_temp.i_from_bus, branch_temp.i_to_bus, weights);
t       = minspantree(g,'Type','forest','Method','sparse');

g_array                         = g.Edges.EndNodes;
t_array                         = t.Edges.EndNodes;
iBranch_temp                    = ismember(g_array,t_array,'row');
connecting_branch_from_to_bus   = g_array(~iBranch_temp,:);

branch_temp.connecting_branch   = ...
    ismember([branch_temp.i_from_bus,branch_temp.i_to_bus],connecting_branch_from_to_bus,'rows') | ...
    ismember([branch_temp.i_to_bus,branch_temp.i_from_bus],connecting_branch_from_to_bus,'rows');

[~,idx] = ismember(branch_temp.branch_ID(branch_temp.connecting_branch), GN.branch.branch_ID);
GN.branch.area_connecting_branch(:)      = false;
GN.branch.area_connecting_branch(idx)    = true;


end

