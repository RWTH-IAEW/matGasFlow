function [GN] = Newton_Raphson_method(GN, NUMPARAM, PHYMOD)
%NEWTON_RAPHSON_METHOD Newton Raphson method
%   GN = Newton_Raphson_method(GN, NUMPARAM, PHYMOD) solves
%   df_dp\f = delta_p -->  p'' = p' - delta_p
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2021, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
CONST = getConstants();

%%
iter_1 = 0;
while 1
    iter_1 = iter_1 + 1;
    
    %% Calulation of nodal temperature
    if GN.isothermal ~= 1
        GN = get_T_loop(GN, NUMPARAM, PHYMOD);
    end
    
    %% Update nodal equation
    GN = get_f_nodal_equation(GN, NUMPARAM, PHYMOD, 1);
    
    %% Check convergence
    GN = set_convergence(GN, ['NR (',num2str(iter_1),')']);
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
    delta_p = GN.J\-(GN.bus.f(~GN.bus.f_0_bus));
    
    %% Newton-Raphson Damping
    
    % Determination of damping factor omega
    if NUMPARAM.OPTION_NR_damping == 1
        omega = get_Omega_Newton_Raphson_Damping(GN, delta_p, NUMPARAM, PHYMOD);
    else
        omega = 1;
    end
    
    % Calculate p_i
    GN.bus.p_i(~GN.bus.p_bus) ...
        = GN.bus.p_i(~GN.bus.p_bus) + omega * delta_p;
    
    if any(GN.bus.p_i <= CONST.p_n)
        error(['Newton_Raphson_method: Nodal pressure became less than ',num2str(CONST.p_n),' Pa. min(p_i) = ',num2str(min(GN.bus.p_i)),' Pa'])
    end
    
    %% Update nodal equation
    if GN.isothermal == 0
        GN = get_f_nodal_equation(GN, NUMPARAM, PHYMOD, 1);
    end
    
    %% Update p_i dependent quantities 
    % Update p_i at valve output
    GN = get_p_T_valve(GN);
    
    % Update p_ij
    GN = get_p_ij(GN);
    
    % Compressibility factor
    GN = get_Z(GN, PHYMOD);
    
    % Dynamic viscosity eta_ij(T,rho)
    GN = get_eta(GN,PHYMOD);
    
end
end

