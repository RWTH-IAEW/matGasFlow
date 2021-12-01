function [GN] = get_V_dot_n_ij_parallelPipes(GN)
%GET_V_DOT_N_IJ_PARALLELPIPES
%
%   Devides V_dot_n_ij at parallel pipes corresponding to their friction
%   loss
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2021, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Matrix_section = sparse(GN.pipe.section_ID, 1:size(GN.pipe,1), 1);

G_ij_tot_section = Matrix_section * GN.pipe.G_ij;
G_ij_tot = G_ij_tot_section(GN.pipe.section_ID);

GN.branch.V_dot_n_ij(isnan(GN.branch.V_dot_n_ij)) = 0;
V_dot_n_ij_tot_section = Matrix_section * abs(GN.branch.V_dot_n_ij(GN.branch.pipe_branch));
V_dot_n_ij_tot = V_dot_n_ij_tot_section(GN.pipe.section_ID);

sign_V_dot_n_ij = sign(GN.branch.V_dot_n_ij(GN.branch.pipe_branch));
sign_V_dot_n_ij(sign_V_dot_n_ij == 0) = 1;

GN.branch.V_dot_n_ij(GN.branch.pipe_branch) = ...
    sign_V_dot_n_ij .* V_dot_n_ij_tot .* GN.pipe.G_ij ./ G_ij_tot;
GN.branch.V_dot_n_ij(isnan(GN.branch.V_dot_n_ij)) = 0;

end

