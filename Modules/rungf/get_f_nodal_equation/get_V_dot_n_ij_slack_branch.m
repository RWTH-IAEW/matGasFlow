function [GN] = get_V_dot_n_ij_slack_branch(GN)
%GET_V_DOT_N_IJ_SLACK_BRANCH
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2022, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

f_area = GN.MAT.area_bus * GN.bus.f;

V_dot_n_ij = GN.MAT.area_active_branch' * f_area;

GN.branch.V_dot_n_ij(GN.branch.slack_branch) = GN.branch.V_dot_n_ij(GN.branch.slack_branch) + V_dot_n_ij(GN.branch.slack_branch);

end

