function [GN] = get_parallel_branch(GN)
%GET_PARALLEL_BRANCH Update V_dot_n_ij at parallel pipes
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

GN.branch.parallel_branch = true(size(GN.branch,1),1);
max_bus_ID = max(GN.branch.from_bus_ID,GN.branch.to_bus_ID);
min_bus_ID = min(GN.branch.from_bus_ID,GN.branch.to_bus_ID);
[~,idx_pipe_branch_b] = unique([max_bus_ID,min_bus_ID],'rows');
GN.branch.parallel_branch(idx_pipe_branch_b) = false;

end