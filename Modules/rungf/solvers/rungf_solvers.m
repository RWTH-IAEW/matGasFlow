function [GN, success] = rungf_solvers(GN, NUMPARAM, PHYMOD)
%UNTITLED
%   
%   Solver:
%   1) Newton-Raphson
%   2) Gradient descent
%   3) Levenberg-Marquardt
%   4) Secant method
%   5) Binary secant method
%   6/7) Linear pressure analog method
%   8) Adjacency matrix method
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

%% Constants
CONST = getConstants();

%% Preperation for linear pressure analog method (6,7) , adjacency matrix method (8)
if (NUMPARAM.solver == 6 || NUMPARAM.solver == 7 || NUMPARAM.solver == 8) && ~isfield(NUMPARAM,'AUX_SOLVER_FLAG')
    update_f = false;
    GN = get_V_dot_n_ij_radialGN(GN, NUMPARAM, update_f);
end

%% Levenberg-Marquardt
if NUMPARAM.solver == 3
    NUMPARAM.break_if_oscillation = false;
end

%% Loop
iter        = 0;
norm_f_temp = NaN(NUMPARAM.maxIter_solver,1);

while ( (NUMPARAM.norm_OR_rms && norm(GN.bus.f)>NUMPARAM.epsilon_norm_f) || (~NUMPARAM.norm_OR_rms && rms(GN.bus.f)>NUMPARAM.epsilon_norm_f) ) ...
        && iter < NUMPARAM.maxIter_solver ...
        && success
    
    %% Check for oscillation
    if NUMPARAM.break_if_oscillation && sum(round(norm_f_temp/NUMPARAM.epsilon_norm_f) == round(norm(GN.bus.f)/NUMPARAM.epsilon_norm_f)) == 2
        iter = NUMPARAM.maxIter_solver;
        break
    end

    iter                = iter + 1;
    GN                  = set_convergence(GN, ['rungf_solvers, ',num2str(NUMPARAM.solver),', (',num2str(iter),')']);
    norm_f_temp(iter)   = norm(GN.bus.f);
    GN_temp             = GN;

    if NUMPARAM.solver == 1
        %% Netwon-Raphson
        [GN, success] = Newton_Raphson_step(GN, NUMPARAM, PHYMOD, iter);
        
    elseif NUMPARAM.solver == 1.1
        %% Gauss-Newton = Netwon-Raphson
        [GN, success] = Gauss_Newton_step(GN, NUMPARAM, PHYMOD, iter);

    elseif NUMPARAM.solver == 2
        %% gradient descent
        if iter == 1
            n_unkonws = sum(~GN.bus.slack_bus)+sum(~GN.bus.V_bus)+sum(GN.branch.active_branch & ~GN.branch.preset);
            G = zeros(n_unkonws,1);
        end
        [GN, success, G] = gradient_descent_step(GN, G, NUMPARAM, PHYMOD, iter);
        
    elseif NUMPARAM.solver == 3
        %% Levenberg-Marquardt
        if iter == 1
            omega_LM = NUMPARAM.omega_LM;
        end
        [GN, success] = Levenberg_Marquardt_step(GN, NUMPARAM, PHYMOD, iter, omega_LM);
        
    elseif NUMPARAM.solver == 4
        %% secant method
        if iter == 1
            [GN, success] = Newton_Raphson_step(GN, NUMPARAM, PHYMOD, iter);
            GN_0 = GN_temp;
        else
            [GN, GN_0, success] = secant_method_step(GN, GN_0);
        end
        
    elseif NUMPARAM.solver == 5
        %% binary secant method
        if iter == 1
            [GN, success] = Gauss_Newton_step(GN, NUMPARAM, PHYMOD, iter);
        else
            [GN, GN_0, success] = binary_secant_method_step(GN, GN_0, NUMPARAM, PHYMOD);
        end
        
    elseif NUMPARAM.solver == 6 || NUMPARAM.solver == 7 || NUMPARAM.solver == 8
        %% Linear pressure anaolog method
        [GN, success] = linear_pressure_method_step(GN, NUMPARAM);
    
    elseif NUMPARAM.solver == 9
        %% Connecting branch interation method
        [GN, success] = connecting_branch_iteration_method(GN, NUMPARAM, PHYMOD);

    end
    
    %% Pressure correction
    if ~success || any(GN.bus.p_i < CONST.p_n)
        GN.bus.p_i(GN.bus.p_i < CONST.p_n) = CONST.p_n;
    end
    
    %% Update p_i dependent quantities and nodal equation
    GN = update_p_i_dependent_quantities(GN, NUMPARAM, PHYMOD);
    GN = get_f_nodal_equation(GN, NUMPARAM, PHYMOD, 'bus');
    
    %% Levenberg-Marquardt: update omega_LM
    if NUMPARAM.solver == 3
        if norm(GN.bus.f) > norm_f_temp(iter)
            omega_LM = omega_LM * NUMPARAM.scale_omega_LM;
            GN_temp.CONVERGENCE = GN.CONVERGENCE;
            GN = GN_temp;
        else
            omega_LM = omega_LM / NUMPARAM.scale_omega_LM;
        end
    end
    
    %% Auxiliary solver
    if isfield(NUMPARAM,'AUX_SOLVER_FLAG') && NUMPARAM.AUX_SOLVER_FLAG
        break
    end
    if ~isempty(NUMPARAM.aux_solver) && ismember(NUMPARAM.aux_solver,[1,2,3,4,5,6,7,8,9]) && norm(GN.bus.f)>norm(GN_temp.bus.f)
        NUMPARAM_temp                           = NUMPARAM;
        NUMPARAM_temp.solver                    = NUMPARAM_temp.aux_solver;
        NUMPARAM_temp.AUX_SOLVER_FLAG           = true;
        GN_temp.CONVERGENCE                     = GN.CONVERGENCE;
        [GN,success]                            = rungf_solvers(GN_temp, NUMPARAM_temp, PHYMOD);
    end
    
    %% Damping
    if NUMPARAM.omega_damping_model == 1
        [GN,success] = get_omega_DahmenReusken(GN, GN_temp, NUMPARAM, PHYMOD);
    elseif NUMPARAM.omega_damping_model == 2
        [GN,success] = get_omega_GSS(GN, GN_temp, NUMPARAM, PHYMOD);
    end

    %% Run until iter = max_iter_solver
    if ~success && NUMPARAM.run_until_maxIter_solver
        success = true;
    end

end

%% Check iteration
if iter >= NUMPARAM.maxIter_solver
%     if isfield(GN,'pipe') && ismember('Re_ij',GN.pipe.Properties.VariableNames) && any(GN.pipe.Re_ij<=CONST.Re_crit) && any(GN.pipe.Re_ij>CONST.Re_crit) && ~isfield(GN,'fixRe_ij')
%         GN.fixRe_ij = [];
%         [GN, success] = rungf_solvers(GN, NUMPARAM, PHYMOD);
%     else
        success = false;
%     end
end

end

