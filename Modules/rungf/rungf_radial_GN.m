function [GN, success] = rungf_radial_GN(GN, NUMPARAM, PHYMOD)
%RUNGF_RADIAL_GN Summary of this function goes here
%   Detailed explanation goes here
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2022, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

iter = 0;
while 1
    iter = iter + 1;
    
    % Update V_dot_n_ij
    GN = get_V_dot_n_ij_radialGN(GN);
    
    % Calculation of p_i based on general gas flow equation
    [GN, success] = get_p_i_SLE_loop(GN, NUMPARAM, PHYMOD);
    if ~success
        return
    end
    
    % V_dot_n_i demand of compressors
    GN = get_V_dot_n_i_comp(GN, PHYMOD);
    
    % V_dot_n_i demand of prs heater
    GN = get_V_dot_n_i_prs(GN);
    
    % Update of the slack bus: flow rate balance to(+)/from(-) the slack bus
    GN = get_V_dot_n_slack(GN, 'GN', NUMPARAM);
    
    % Calculate f
    GN.bus.f = GN.INC * GN.branch.V_dot_n_ij + GN.bus.V_dot_n_i;
    
    % Check convergence
    GN = set_convergence(GN, ['$$rungf rad. GN (',num2str(iter),')$$']);
    if norm(GN.bus.f) < NUMPARAM.epsilon_NR_f
        break
    elseif iter >= NUMPARAM.maxIter
        error(['rungf: Non-converging while-loop. Number of interation: ',num2str(iter)])
    end
    
end


end

