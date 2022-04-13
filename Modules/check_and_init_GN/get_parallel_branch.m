function [GN] = get_parallel_branch(GN)
%GET_PARALLEL_BRANCH Identify parallel branches
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2022, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

GN.branch.parallel_branch(:) = true;
max_bus_ID = max(GN.branch.from_bus_ID,GN.branch.to_bus_ID);
min_bus_ID = min(GN.branch.from_bus_ID,GN.branch.to_bus_ID);
[~,idx_pipe_branch_b] = unique([max_bus_ID,min_bus_ID],'rows');
GN.branch.parallel_branch(idx_pipe_branch_b) = false;

% Parallel active branches need preset values
if any(GN.branch.parallel_branch & GN.branch.active_branch & ~GN.branch.preset)
    warning('At least n-1 of n parallel active branches need presets.')
end

end