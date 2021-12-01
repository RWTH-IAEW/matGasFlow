function [Omega] = get_Omega_Newton_Raphson_Damping(GN, delta_p, NUMPARAM, PHYMOD)
%GET_OMEGA_NEWTON_RAPHSON_DAMPING Summary of this function goes here
%   Detailed explanation goes here
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2021, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Damping paramter
Omega = 1; 

while 1
    %% Update p_i
    GN_damp = GN;
    GN_damp.bus.p_i(~GN.bus.p_bus) ...
        = GN.bus.p_i(~GN.bus.p_bus) + Omega * delta_p;
 
    %% Update nodal equation
    GN_damp = get_f_nodal_equation(GN_damp, NUMPARAM, PHYMOD, NUMPARAM.OPTION_get_f_nodal_equation);
    
    %% Check if f converges sufficiently
    C_omega = 1-Omega/4;
    
    % Use the euklidian norm (2-norm) for decision
    if norm(GN_damp.bus.f(~GN.bus.p_bus))...
            <= C_omega * norm(GN.bus.f(~GN.bus.p_bus))
        break
    end
    
    %% Adjust omega
    Omega = NUMPARAM.omega_adaption_NR * Omega;
    
    if Omega < NUMPARAM.omega_NR_min
        warning(['Newton-Raphson: The damping parameter has been reduced to omega = ',num2str(Omega)])
        Omega = 1;
        return
    end
end

end

