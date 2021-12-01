function [GN] = init_V_dot_n_ij(GN)
%INIT_V_DOT_N_IJ Initialization of standard gas flow rate V_dot_n_ij
%   [GN] = INIT_V_DOT_N_IJ(GN)
%   Solves INC * V_dot_n_ij = V_dot_n_i, where for n linearly independent
%   meshes the standard volume flow rate V_dot_n_ij of n branches is
%   initialized heuristically. Parallel branches are not considered as
%   meshes; the standard volume flow rate at parallel branches is divided
%   to sqrt(D_ij^5/L_ij) in case of pipelines and equally in case of active
%   branches
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2021, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Initialize V_dot_n_ij
GN.branch.V_dot_n_ij = zeros(size(GN.branch,1),1);
GN.branch.V_dot_n_ij(GN.branch.connecting_branch) = mean(abs(GN.bus.V_dot_n_i)) * (0.9:0.2/(sum(GN.branch.connecting_branch)-1):1.1);

%% Solving system of linear equations
GN = get_V_dot_n_ij_radialGN(GN);

end

