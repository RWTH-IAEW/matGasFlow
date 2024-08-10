function [GN, success] = rungf_radial_GN(GN, NUMPARAM, PHYMOD)
%RUNGF_RADIAL_GN
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

iter = 0;
while 1
    iter        = iter + 1;
    GN          = set_convergence(GN, ['rungf_radial_GN, (',num2str(iter),')']);
    T_i_temp    = GN.bus.T_i;
    
    %% Solving system of linear equations
    GN = get_V_dot_n_ij_radialGN(GN, NUMPARAM);

    %% Calculation of p_i based on general gas flow equation
    [GN, success] = get_p_i_radial_GN_loop(GN, NUMPARAM, PHYMOD);
    if ~success && iter == 1
        CONST = getConstants;
        GN.bus.p_i(GN.bus.p_i<CONST.p_n) = CONST.p_n;
        % Update p_i dependent quantities
        GN = update_p_i_dependent_quantities(GN, NUMPARAM, PHYMOD);
    elseif ~success
        return
    end
    
    %% Bus and pipe temperature
    if ~GN.isothermal
        GN = get_T_loop(GN, NUMPARAM, PHYMOD);
    end

    %% Update V_dot_n_i and f
    % V_dot_n_i demand of compressors
    GN = get_V_dot_n_i_comp(GN, PHYMOD);
    
    % V_dot_n_i demand of prs heater
    GN = get_V_dot_n_i_prs(GN, NUMPARAM, PHYMOD);
    
    % Update of the slack bus: flow rate balance to(+)/from(-) the slack bus
    GN = get_V_dot_n_slack(GN, 'GN', NUMPARAM);
    
    % Calculate f
    GN.bus.f = GN.MAT.INC * GN.branch.V_dot_n_ij + GN.bus.V_dot_n_i;
    
    % Set convergence
    GN = set_convergence(GN, 'update f');
    
    %% Check convergence
    if norm(GN.bus.f) < NUMPARAM.epsilon_norm_f && norm(GN.bus.T_i - T_i_temp) < NUMPARAM.epsilon_T
        break
    elseif iter >= NUMPARAM.maxIter
        warning(['rungf: Non-converging while-loop. Number of interation: ',num2str(iter)])
        success = false;
        break
    end
    
end

end

