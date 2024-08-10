function [GN, success] = Levenberg_Marquardt_step(GN, NUMPARAM, PHYMOD, iter, omega_LM)
%UNTITLED
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 4
    iter = 1;
end

%% Success
success = true;

%% Constants
CONST = getConstants();

%% Jacobian Matrix
if rem(iter-1, NUMPARAM.OPTION_get_J_iter) == 0
    GN = get_J(GN, NUMPARAM, PHYMOD);
end

%% Calculation of Delta_p, solving linear system of equation
Delta_x         = (GN.J' * GN.J + omega_LM*eye(size(GN.J,2))) \ -(GN.J' * GN.bus.f);

%% Update variables
i_non_slack_bus             = ~GN.bus.slack_bus;
i_non_V_bus                 = ~GN.bus.V_bus;
i_no_preset_active_branch   = GN.branch.active_branch & ~GN.branch.preset;

n_non_slack_bus             = sum(i_non_slack_bus);
n_non_V_bus                 = sum(i_non_V_bus);
n_no_preset_active_branch   = sum(i_no_preset_active_branch);

Delta_p                     = Delta_x(1:n_non_slack_bus);
Delta_V_dot_n_i             = Delta_x(n_non_slack_bus+1:n_non_slack_bus+n_non_V_bus);
Delta_V_dot_n_ij_a          = Delta_x(n_non_slack_bus+n_non_V_bus+1:n_non_slack_bus+n_non_V_bus+n_no_preset_active_branch);

GN.bus.p_i(i_non_slack_bus)                     = GN.bus.p_i(i_non_slack_bus) + Delta_p;
GN.bus.V_dot_n_i(i_non_V_bus)                   = GN.bus.V_dot_n_i(i_non_V_bus) + Delta_V_dot_n_i;
GN.branch.V_dot_n_ij(i_no_preset_active_branch) = GN.branch.V_dot_n_ij(i_no_preset_active_branch)+ Delta_V_dot_n_ij_a;

%% check result
if any(isnan(GN.bus.p_i) | isinf(GN.bus.p_i))
    error('Something went wrong. Nodal pressure became NaN or infinity.')
elseif any(GN.bus.p_i < CONST.p_n)
    success = false;
end

end

