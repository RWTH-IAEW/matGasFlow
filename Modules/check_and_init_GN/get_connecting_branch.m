function [GN] = get_connecting_branch(GN)
%GET_ICONNECTINGBRANCHES Summary of this function goes here
%   Detailed explanation goes here
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2021, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

g = graph(GN.branch.i_from_bus, GN.branch.i_to_bus);
t = minspantree(g, 'Root', find(GN.bus.slack_bus));
g_array = g.Edges.EndNodes;
t_array = t.Edges.EndNodes;
iBranch_temp = ismember(g_array,t_array,'row');
connecting_branch = g_array(~iBranch_temp,:);
GN.branch.connecting_branch = ...
    ismember([GN.branch.i_from_bus,GN.branch.i_to_bus],connecting_branch,'rows') | ...
    ismember([GN.branch.i_to_bus,GN.branch.i_from_bus],connecting_branch,'rows');

end

