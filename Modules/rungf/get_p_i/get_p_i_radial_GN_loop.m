function [GN, success] = get_p_i_radial_GN_loop(GN, NUMPARAM, PHYMOD)
%GET_p_i_radial_GN_LOOP Start solution for nodal pressure p_i
%   [GN] = get_p_i_radial_GN(GN, PHYMOD) solves system of linear equations (SLE)
%   in a while loop: INC' * p_i^2 = -V^2/G_ij
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Success
success = true;

%% Check for pipes
if ~isfield(GN, 'pipe')
    return
end

%%
iter = 0;
while 1
    iter            = iter + 1;
    GN              = set_convergence(GN, ['get_p_i_radial_GN_loop, (',num2str(iter),')']);
    p_i_temp        = GN.bus.p_i;
    V_dot_n_ij_temp = GN.branch.V_dot_n_ij;
    
    %% Calculation of p_i
    [GN, success]   = get_p_i_radial_GN(GN, NUMPARAM, PHYMOD);
    if ~success
        return
    end
    
    %% Division of gas flow at parallel pipes
    [GN,success] = get_V_dot_n_ij_parallelPipes(GN, NUMPARAM);
    if ~success
        return
    end
    
    %% Check convergence
    if norm((p_i_temp - GN.bus.p_i)./ p_i_temp) < NUMPARAM.epsilon_p_i && ...
            norm((GN.branch.V_dot_n_ij(V_dot_n_ij_temp ~= 0) - V_dot_n_ij_temp(V_dot_n_ij_temp ~= 0))./V_dot_n_ij_temp(V_dot_n_ij_temp ~= 0)) < NUMPARAM.epsilon_norm_f
        break
    elseif iter >= NUMPARAM.maxIter
        success = false;
        break
    end
end

end
