function [GN,success] = get_omega_DahmenReusken(GN, GN_0, NUMPARAM, PHYMOD)
%GET_OMEGA_DAHMENREUSKEN Damping factor for Newton Raphson algorithm
%   [omega] = get_omega_DahmenReusken(GN, Delta_p, NUMPARAM, PHYMOD)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

success = true;

%%
GN_temp_2   = GN;
Delta_x     = -GN.J\GN_0.bus.f;
norm_f_0    = norm(GN_0.bus.f);

%% Constants
CONST = getConstants();

%% Damping paramter
omega           = 1;
iter            = 0;
C_omega         = 1;

% Omega adaption factor for Dahmen-Reusken damping method
if isnumeric(NUMPARAM.omega_adaption_DR)
    omega_adaption = NUMPARAM.omega_adaption_DR;
elseif strcmp(NUMPARAM.omega_adaption_DR,'rand')
    omega_adaption = rand(1);
else
    error('Choose NUMPARAM.omega_adaption_DR to be a numeric value between 0 and 1, or to be ''rand''.')
end

%% Loop
while norm(GN.bus.f) > C_omega * norm_f_0
    iter    = iter + 1;
    GN      = set_convergence(GN, ['get_omega_DahmenReusken, (',num2str(iter),')']);

    %% omega
    omega = omega*omega_adaption;
    
    %% Update variables
    i_non_slack_bus             = ~GN_0.bus.slack_bus;
    i_non_V_bus                 = ~GN_0.bus.V_bus;
    i_no_preset_active_branch   = GN_0.branch.active_branch & ~GN_0.branch.preset;

    n_non_slack_bus             = sum(i_non_slack_bus);
    n_non_V_bus                 = sum(i_non_V_bus);
    n_no_preset_active_branch   = sum(i_no_preset_active_branch);

    Delta_p                     = omega*Delta_x(1:n_non_slack_bus);
    Delta_V_dot_n_i             = omega*Delta_x(n_non_slack_bus+1:n_non_slack_bus+n_non_V_bus);
    Delta_V_dot_n_ij_a          = omega*Delta_x(n_non_slack_bus+n_non_V_bus+1:n_non_slack_bus+n_non_V_bus+n_no_preset_active_branch);
    
    GN.bus.p_i(i_non_slack_bus)                     = GN_0.bus.p_i(i_non_slack_bus) + Delta_p;
    GN.bus.V_dot_n_i(i_non_V_bus)                   = GN_0.bus.V_dot_n_i(i_non_V_bus) + Delta_V_dot_n_i;
    GN.branch.V_dot_n_ij(i_no_preset_active_branch) = GN_0.branch.V_dot_n_ij(i_no_preset_active_branch) + Delta_V_dot_n_ij_a;
    
    %% Pressure correction
    if any(GN.bus.p_i < CONST.p_n)
        GN.bus.p_i(GN.bus.p_i < CONST.p_n) = CONST.p_n;
    end
    
    %% Update p_i dependent quantities and nodal equation
    GN = update_p_i_dependent_quantities(GN, NUMPARAM, PHYMOD);
    GN = get_f_nodal_equation(GN, NUMPARAM, PHYMOD, 'bus');
    
    %%
    if norm(GN.bus.f) <= C_omega * norm_f_0
        break
    end

    %% Check omega 
    if omega < NUMPARAM.omega_min
        success = false;
        if norm(GN.bus.f) > norm_f_0
            GN_temp_2.CONVERGENCE = GN.CONVERGENCE;
            GN = GN_temp_2;
        end
        break
    end
end

end

