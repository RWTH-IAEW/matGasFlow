function [GN, success] = Newton_Raphson_method(GN, NUMPARAM, PHYMOD)
%NEWTON_RAPHSON_METHOD Newton Raphson method
%   GN = Newton_Raphson_method(GN, NUMPARAM, PHYMOD) solves
%   df_dp\f = delta_p -->  p'' = p' - delta_p
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2022, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Success
success = true;

%%
CONST = getConstants();

%%
iter_1 = 0;
omega = 1;
delta_p = zeros(size(GN.bus,1),1);
while 1
    iter_1 = iter_1 + 1;
    
    %% Calulation of nodal temperature
    if GN.isothermal ~= 1
        GN = get_T_loop(GN, NUMPARAM, PHYMOD);
    end
    
    %% Update nodal equation
    GN = get_f_nodal_equation(GN, NUMPARAM, PHYMOD);
    
    %% Check convergence
    GN = set_convergence(GN, ['NR (',num2str(iter_1),')']);
    % disp({iter_1, norm(GN.bus.f), norm(delta_p), omega}) %- UNDER CONSTRUCTION
    if norm(GN.bus.f) < NUMPARAM.epsilon_NR_f
        if isfield(GN,'J')
            GN = rmfield(GN, 'J');
        end
        break
    elseif iter_1 >= NUMPARAM.maxIter
        error(['Newton_Raphson_method: Non-converging while-loop. Number of interation: ',num2str(iter_1)])
    end
    
    %% Jacobian Matrix
    if rem(iter_1-1, NUMPARAM.OPTION_get_J_iter) == 0
        GN = get_J(GN, NUMPARAM, PHYMOD);
    end
    
    %% Calculation of delta_p, solving linear system of equation
    delta_p(~GN.bus.p_bus) = GN.J\-GN.bus.f(~GN.bus.p_bus);
    
    if any(isnan(delta_p)) || any(isinf(delta_p))
        NUMPARAM_temp = NUMPARAM;
        NUMPARAM_temp.OPTION_get_J = 3;
        GN_temp = get_J(GN, NUMPARAM_temp, PHYMOD);
        delta_p_temp = zeros(size(GN.bus,1),1);
        delta_p_temp(~GN.bus.p_bus) = GN_temp.J\-GN.bus.f(~GN.bus.p_bus);
        delta_p(isnan(delta_p) | isinf(delta_p)) = delta_p_temp(isnan(delta_p) | isinf(delta_p));
    end
    
    
    %% Newton-Raphson Damping
    if NUMPARAM.OPTION_NR_damping
        omega = get_Omega_Newton_Raphson_Damping(GN, delta_p, NUMPARAM, PHYMOD);
    else
        omega = 1;
    end
    
    %% Calculate p_i
    GN.bus.p_i(~GN.bus.p_bus) ...
        = GN.bus.p_i(~GN.bus.p_bus) + omega * delta_p(~GN.bus.p_bus);
    
    if any(GN.bus.p_i <= CONST.p_n)
        warning(['Newton_Raphson_method: Nodal pressure became less than ',num2str(CONST.p_n),' Pa. min(p_i) = ',num2str(min(GN.bus.p_i)),' Pa'])
        success = false;
        return
    elseif any(isnan(GN.bus.p_i) | isinf(GN.bus.p_i))
        error('Newton_Raphson_method: Nodal pressure became NaN or Inf')
    end
    
    % Update p_i dependent quantities
    if rem(iter_1-1, NUMPARAM.OPTION_update_p_i_dependent_quantities_iter) == 0
        GN = update_p_i_dependent_quantities(GN, PHYMOD);
    end
    
    %% Update nodal equation - UNDER CONSTRUCTION
    if GN.isothermal == 0
        GN = get_f_nodal_equation(GN, NUMPARAM, PHYMOD);
    end
    
end
end

