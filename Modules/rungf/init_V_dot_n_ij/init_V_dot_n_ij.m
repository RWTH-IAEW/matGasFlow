function [GN] = init_V_dot_n_ij(GN)
%INIT_V_DOT_N_IJ
%
%   [GN] = INIT_V_DOT_N_IJ(GN) Initialization of standard gas flow rate
%   V_dot_n_ij for meshed grids
%   
%   For n linearly independent meshes the standard volume flow rate
%   V_dot_n_ij of n branches is initialized heuristically. Afterwards
%   get_V_dot_n_ij_radialGN is called.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2021, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Heuristical initialization of V_dot_n_ij
GN.branch.V_dot_n_ij = zeros(size(GN.branch,1),1);
GN.branch.V_dot_n_ij(GN.branch.connecting_branch) = mean(abs(GN.bus.V_dot_n_i)) * (0.9:0.2/(sum(GN.branch.connecting_branch)-1):1.1);

%% Solving system of linear equations
GN = get_V_dot_n_ij_radialGN(GN);

end

