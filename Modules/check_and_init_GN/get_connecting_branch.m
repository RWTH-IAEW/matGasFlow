function [GN] = get_connecting_branch(GN)
<<<<<<< HEAD
%GET_CONNECTING_BRANCH
=======
%GET_CONNECTING_BRANCHES
>>>>>>> Merge to public repo (#1)
%
%   Initializes GN.branch.connecting_branch, identifies connecting in
%   a meshed grid with the help of a minimum spanning tree algorithm and
%   sets them to true.
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
branch_temp                 = GN.branch;
branch_temp(branch_temp.parallel_branch,:) = [];
idx                         = true(size(branch_temp,1),1);
weights                     = ones(size(branch_temp,1),1);
weights(branch_temp.preset) = 1000000;
% UNDER CONSTRUCTION
% if any(branch_temp.valve_branch)
%     weights(branch_temp.valve_branch) = 10000000000;
% end

g       = graph(branch_temp.i_from_bus(idx), branch_temp.i_to_bus(idx), weights);
t       = minspantree(g,'Method','sparse');
islands = unique(conncomp(t));
if length(islands) > 1
    error('GN has isolated busses.')
end
g_array         = g.Edges.EndNodes;
t_array         = t.Edges.EndNodes;
iBranch_temp    = ismember(g_array,t_array,'row');
connecting_branch_from_to_bus = g_array(~iBranch_temp,:);

branch_temp.connecting_branch = ...
    ismember([branch_temp.i_from_bus,branch_temp.i_to_bus],connecting_branch_from_to_bus,'rows') | ...
    ismember([branch_temp.i_to_bus,branch_temp.i_from_bus],connecting_branch_from_to_bus,'rows');

[~,idx] = ismember(branch_temp.branch_ID(branch_temp.connecting_branch), GN.branch.branch_ID);
GN.branch.connecting_branch(:) = false;
GN.branch.connecting_branch(idx) = true;
=======
g = graph(GN.branch.i_from_bus, GN.branch.i_to_bus);
t = minspantree(g, 'Root', find(GN.bus.slack_bus));
g_array = g.Edges.EndNodes;
t_array = t.Edges.EndNodes;
iBranch_temp = ismember(g_array,t_array,'row');
connecting_branch = g_array(~iBranch_temp,:);
GN.branch.connecting_branch = ...
    ismember([GN.branch.i_from_bus,GN.branch.i_to_bus],connecting_branch,'rows') | ...
    ismember([GN.branch.i_to_bus,GN.branch.i_from_bus],connecting_branch,'rows');
>>>>>>> Merge to public repo (#1)

end

