function [GN, success] = rungf_meshed_GN(GN, NUMPARAM, PHYMOD)
%RUNGF_MESHED_GN
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% p_i start solution
if NUMPARAM.radial_GN_start_solution
    GN_temp                         = GN;
    GN                              = get_V_dot_n_ij_radialGN(GN, NUMPARAM);
    [GN, GN.success_p_i_radial_GN]  = get_p_i_radial_GN(GN, NUMPARAM, PHYMOD);
    if ~GN.success_p_i_radial_GN
        GN = GN_temp;
    else
        % Calculate nodal residuum
        GN = get_f_nodal_equation(GN, NUMPARAM, PHYMOD);
    end
end

%% loop: f(p) and T_i
iter = 0;
while 1
    iter    = iter + 1;
    GN      = set_convergence(GN, ['rungf_meshed_GN, (',num2str(iter),')']);
    
    %% f(p) - Solvers for non-linear system of equations
    [GN, success] = rungf_solvers(GN, NUMPARAM, PHYMOD);
    
    %% Nodal temperature
    if GN.isothermal || ~success
        break
    else
        T_i_temp = GN.bus.T_i;
        
        GN = get_T_loop(GN, NUMPARAM, PHYMOD);
        
        GN = get_f_nodal_equation(GN, NUMPARAM, PHYMOD);
        
        %% Check convergence
        if (norm(T_i_temp-GN.bus.T_i) < NUMPARAM.epsilon_T) && ((NUMPARAM.norm_OR_rms && norm(GN.bus.f)<NUMPARAM.epsilon_norm_f) || (~NUMPARAM.norm_OR_rms && rms(GN.bus.f)<NUMPARAM.epsilon_norm_f))
            break
        elseif iter >= NUMPARAM.maxIter
            error(['rungf_meshed_GN: Non-converging while-loop. Number of interation: ',num2str(iter)])
        end
        
    end
end

end

