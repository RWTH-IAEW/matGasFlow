function [GN] = get_V_dot_n_ij_radialGN(GN)
%GET_V_DOT_N_IJ_RADIALGN solves INC * V_dot_n_ij = V_dot_n_i for radial gas
%   networks
%
%   Algorithm:
%   1) Ignore parallel pipes
%   2) Solve INC * V_dot_n_ij = V_dot_n_i 
%   3) Division of gas flow at parallel pipes
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2021, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Division of the gas flow at parallel pipes
if isfield(GN,'pipe')
    if ~any(strcmp('G_ij',GN.pipe.Properties.VariableNames))
        GN.pipe.G_ij = sqrt(GN.pipe.D_ij.^5 ./ GN.pipe.L_ij);
    else
        GN = get_G_ij(GN, 1);
    end
end

%% Solving system of linear equations
if any(GN.branch.connecting_branch)
    b = -GN.bus.V_dot_n_i - GN.INC(:,GN.branch.connecting_branch) * GN.branch.V_dot_n_ij(GN.branch.connecting_branch);
else
    b = -GN.bus.V_dot_n_i;
end

A = GN.INC(:,~GN.branch.connecting_branch & ~GN.branch.parallel_branch);

GN.branch.V_dot_n_ij(~GN.branch.connecting_branch & ~GN.branch.parallel_branch) = A\b;
GN.branch.V_dot_n_ij(GN.branch.parallel_branch) = 0;

%% Division of gas flow at parallel pipes
if isfield(GN,'pipe')
    GN = get_V_dot_n_ij_parallelPipes(GN);
end

%% Nodal equation f
GN.bus.f = GN.INC * GN.branch.V_dot_n_ij + GN.bus.V_dot_n_i;

end

