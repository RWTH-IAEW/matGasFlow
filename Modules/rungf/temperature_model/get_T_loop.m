function [GN] = get_T_loop(GN, NUMPARAM, PHYMOD)
%GET_T_LOOP
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

%%
if GN.isothermal == 1
    return
end

if norm(GN.bus.f) > NUMPARAM.epsilon_norm_f*10
    error('Something went wrong: call get_T_loop only if norm(GN.bus.f) <= NUMPARAM.epsilon_norm_f.')
    % return
end
        
iter = 0;
while 1
    iter        = iter + 1;
    GN          = set_convergence(GN, ['get_T_loop, (',num2str(iter),')']);
    T_i_temp    = GN.bus.T_i;
    
    %% Bus and pipe temperature
    keep_T_env  = false; % TODO
    GN          = get_T(GN, NUMPARAM, PHYMOD, keep_T_env);
    
    %% Check convergence
    if norm(GN.bus.T_i - T_i_temp) < NUMPARAM.epsilon_T
        break
    elseif iter >= NUMPARAM.maxIter
        warning(['Something went wrong. Non-converging while-loop in get_T_loop. Number of interation: ',num2str(iter)])
    end
end

%% Update T dependent quantities
GN = update_T_dependent_quantities(GN, NUMPARAM, PHYMOD);

end

