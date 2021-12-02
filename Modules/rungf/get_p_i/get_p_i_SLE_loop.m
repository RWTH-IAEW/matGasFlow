<<<<<<< HEAD
function [GN, success] = get_p_i_SLE_loop(GN, NUMPARAM, PHYMOD)
=======
function [GN] = get_p_i_SLE_loop(GN, NUMPARAM, PHYMOD)
>>>>>>> Merge to public repo (#1)
%GET_P_I_SLE_LOOP Start solution for nodal pressure p_i
%   [GN] = get_p_i_SLE(GN, PHYMOD) solves system of linear equations (SLE)
%   in a while loop: INC' * p_i^2 = -V^2/G_ij
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
<<<<<<< HEAD
%   Copyright (c) 2020-2022, High Voltage Equipment and Grids,
=======
%   Copyright (c) 2020-2021, High Voltage Equipment and Grids,
>>>>>>> Merge to public repo (#1)
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

<<<<<<< HEAD
%% Success
success = true;

=======
>>>>>>> Merge to public repo (#1)
%% Check if there is any volumen flow and check for pipes
if all(GN.branch.V_dot_n_ij == 0) || ~isfield(GN, 'pipe')
    return
end

%%
iter_1 = 0;
while 1
    iter_1 = iter_1 + 1;
    V_dot_n_ij_temp = GN.branch.V_dot_n_ij;
    
    iter_2 = 0;
    while 1
        iter_2 = iter_2 + 1;
        p_i_temp = GN.bus.p_i;
        
        %% Calculation of p_i
<<<<<<< HEAD
        [GN, success]  = get_p_i_SLE(GN, PHYMOD);
        if ~success
            return
        end
=======
        GN = get_p_i_SLE(GN, PHYMOD);
>>>>>>> Merge to public repo (#1)
                
        %% Calulation of nodal temperature
        if GN.isothermal ~= 1
            GN = get_T_loop(GN, NUMPARAM, PHYMOD);
        end
        
        %% Check convergence
        GN = set_convergence(GN, ['$$p_i SLE loop, p_i, (',num2str(iter_2),')$$']);
        if norm((p_i_temp - GN.bus.p_i) ./ p_i_temp) < NUMPARAM.epsilon_p_i_loop
            break
        elseif iter_2 >= NUMPARAM.maxIter
            error(['get_p_i_loop: Non-converging while-loop. Number of interation: ',num2str(iter_2)])
        end
    end
    
    %% Update nodal equation
<<<<<<< HEAD
    GN = get_f_nodal_equation(GN, NUMPARAM, PHYMOD);
=======
    GN = get_f_nodal_equation(GN, NUMPARAM, PHYMOD, 2);
>>>>>>> Merge to public repo (#1)
    
    %% Check convergence
    GN = set_convergence(GN, ['$$p_i SLE loop, \dot{V}_{dot,n,ij}, (',num2str(iter_1),')$$']);
    if norm((V_dot_n_ij_temp(V_dot_n_ij_temp ~= 0) - GN.branch.V_dot_n_ij(V_dot_n_ij_temp ~= 0)) ./ V_dot_n_ij_temp(V_dot_n_ij_temp ~= 0)) < NUMPARAM.epsilon_V_dot_n_ij_loop
        break
    elseif iter_1 >= NUMPARAM.maxIter
        error(['get_p_i_loop: Non-converging while-loop. Number of interation: ',num2str(iter_1)])
    end
    
end
end
