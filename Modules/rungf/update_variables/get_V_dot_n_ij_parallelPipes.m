function [GN, success] = get_V_dot_n_ij_parallelPipes(GN, NUMPARAM)
%GET_V_DOT_N_IJ_PARALLELPIPES
%
%   Devides V_dot_n_ij at parallel pipes corresponding to their friction
%   loss
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

success = true;

%% Division of the gas flow at parallel pipes
if ~isfield(GN,'pipe') || all(~GN.branch.parallel_branch)
    return
end

%% section_ID
max_bus_ID          = max(GN.pipe.from_bus_ID,GN.pipe.to_bus_ID);
min_bus_ID          = min(GN.pipe.from_bus_ID,GN.pipe.to_bus_ID);
[~,~,section_ID]    = unique([max_bus_ID,min_bus_ID],'rows');
Matrix_section      = sparse(section_ID, 1:size(GN.pipe,1), 1);

%% Initialize G_ij
if ~ismember('G_ij', GN.pipe.Properties.VariableNames) || ~ismember('V_dot_n_ij', GN.branch.Properties.VariableNames)
    GN.pipe.G_ij = sqrt(GN.pipe.D_ij.^5 ./ GN.pipe.L_ij);
else
    GN = get_G_ij(GN, 1);
end

%% V_dot_n_ij_tot
GN.branch.V_dot_n_ij(isnan(GN.branch.V_dot_n_ij))   = 0;
V_dot_n_ij_tot_section                  = abs(Matrix_section * GN.branch.V_dot_n_ij(GN.branch.pipe_branch));
V_dot_n_ij_tot                          = V_dot_n_ij_tot_section(section_ID);

sign_V_dot_n_ij                         = sign(GN.branch.V_dot_n_ij(GN.branch.pipe_branch));
sign_V_dot_n_ij(sign_V_dot_n_ij == 0)   = 1;

%% While loop
iter = 0;
while 1
    iter            = iter + 1;
    GN              = set_convergence(GN, ['get_V_dot_n_ij_parallelPipes, (',num2str(iter),')']);
    V_dot_n_ij_temp = GN.branch.V_dot_n_ij;
        
    %% Devide V_dot_n_ij at parallel pipes
    G_ij_tot_section        = Matrix_section * GN.pipe.G_ij;
    G_ij_tot                = G_ij_tot_section(section_ID);
    
    GN.branch.V_dot_n_ij(GN.pipe.i_branch) = ...
        sign_V_dot_n_ij .* V_dot_n_ij_tot .* GN.pipe.G_ij ./ G_ij_tot;
    
    GN.branch.V_dot_n_ij(isnan(GN.branch.V_dot_n_ij))   = 0;
    
    %% Check convergence
    if norm((GN.branch.V_dot_n_ij(V_dot_n_ij_temp ~= 0) - V_dot_n_ij_temp(V_dot_n_ij_temp ~= 0)) ./ V_dot_n_ij_temp(V_dot_n_ij_temp ~= 0)) < NUMPARAM.epsilon_norm_f
        break
    elseif iter >= NUMPARAM.maxIter
        success = false;
        break
    end
    
    %% Update G_ij
    GN = get_G_ij(GN, 1);

end

end

