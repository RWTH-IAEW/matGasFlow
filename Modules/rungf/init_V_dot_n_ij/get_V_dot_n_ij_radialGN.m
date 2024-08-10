function [GN] = get_V_dot_n_ij_radialGN(GN, NUMPARAM, update_f)
%GET_V_DOT_N_IJ_RADIALGN solves INC * V_dot_n_ij = V_dot_n_i for radial gas
%   networks
%
%   Algorithm:
%   1) Ignore parallel pipes
%   2) Solve INC * V_dot_n_ij = V_dot_n_i 
%   3) Division of gas flow at parallel pipes
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 3
    update_f = true;
end

%% Update of the slack bus: sum(V_dot_n_i)=!=0
GN = get_V_dot_n_slack(GN, 'GN', NUMPARAM);

%% Solving system of linear equations
GN.branch.V_dot_n_ij(GN.branch.parallel_branch) = 0;

n_conBr_parBr = sum(GN.branch.connecting_branch | GN.branch.parallel_branch);
if n_conBr_parBr > 0
    ii = 1:n_conBr_parBr;
    jj = find(GN.branch.connecting_branch | GN.branch.parallel_branch);
    A_2 = sparse(ii, jj, 1, n_conBr_parBr, size(GN.MAT.INC,2));
else
    A_2 = [];
end
A           = [GN.MAT.INC; A_2];
b           = [-GN.bus.V_dot_n_i; GN.branch.V_dot_n_ij(GN.branch.connecting_branch | GN.branch.parallel_branch)];
V_dot_n_ij  = A\b;
GN.branch.V_dot_n_ij(~GN.branch.connecting_branch & ~GN.branch.parallel_branch) = ...
    V_dot_n_ij(~GN.branch.connecting_branch & ~GN.branch.parallel_branch);

%% Check result
if any(norm(A * GN.branch.V_dot_n_ij - b) > 1e-6)   
    error('Something went wrong.')
end

%% Division of gas flow at parallel pipes
GN = get_V_dot_n_ij_parallelPipes(GN, NUMPARAM);

%% Nodal equation f
if update_f
    GN.bus.f = GN.MAT.INC * GN.branch.V_dot_n_ij + GN.bus.V_dot_n_i;
    
    % set convergence
    GN = set_convergence(GN, 'update f');
end

end

