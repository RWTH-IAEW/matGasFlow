function [max_branch_ID] = get_max_branch_ID(GN)
%GET_MAX_BRANCH_ID
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

max_branch_ID = 0;
if isfield(GN,'pipe') && ismember('branch_ID', GN.pipe.Properties.VariableNames)
    max_branch_ID = max(max_branch_ID, max(GN.pipe.branch_ID));
end
if isfield(GN,'comp') && ismember('branch_ID', GN.comp.Properties.VariableNames)
    max_branch_ID = max(max_branch_ID, max(GN.comp.branch_ID));
end
if isfield(GN,'prs') && ismember('branch_ID', GN.prs.Properties.VariableNames)
    max_branch_ID = max(max_branch_ID, max(GN.prs.branch_ID));
end
if isfield(GN,'valve') && ismember('branch_ID', GN.valve.Properties.VariableNames)
    max_branch_ID = max(max_branch_ID, max(GN.valve.branch_ID));
end
end

