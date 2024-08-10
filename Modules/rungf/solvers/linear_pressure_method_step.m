function [GN, success] = linear_pressure_method_step(GN, NUMPARAM)
%LINEAR_PRESSURE_METHOD_STEP
%
%   Y * p_i = -V_dot_n_i
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
CONST = getConstants;

%% Quantities
n_branch        = size(GN.branch,1);
n_bus           = size(GN.bus,1);
INC             = GN.MAT.INC;
i_branch        = GN.pipe.i_branch;
is_slack_bus    = GN.bus.slack_bus;

%% G_ij, g_ij
if NUMPARAM.solver == 6
    % linear-pressure analog [Ayala, Leong; 2013]
    G_OPTION    = 1;
    g_OPTION    = 1;
    GN          = get_G_ij(GN, G_OPTION);
    g_ij        = get_g_ij(GN, g_OPTION);
elseif NUMPARAM.solver == 7
    G_OPTION    = 1;
    g_OPTION    = 2;
    GN          = get_G_ij(GN, G_OPTION);
    g_ij        = get_g_ij(GN, g_OPTION);
elseif NUMPARAM.solver == 8
    G_OPTION    = 2;
    GN          = get_G_ij(GN, G_OPTION);
    g_ij        = 1;
else
    error('Something went worng. NUMPARAM.solver must be 6, 7 or 8.')
end
g_ij(isnan(g_ij)) = 1;
G_ij            = GN.pipe.G_ij(GN.branch.i_pipe(GN.branch.pipe_branch));

%% Linear pressure method
% Admittance matrix
E_G         = sparse(i_branch,  i_branch, g_ij.*G_ij, n_branch, n_branch);
G           = INC * E_G * INC';

n_slack     = sum(is_slack_bus);
ii          = 1:n_slack;
jj          = find(GN.bus.slack_bus);
Y_2         = sparse(ii, jj, 1, n_slack, n_bus);
Y           = [G; Y_2];

% b - solution vector
V_n_ij_act  = GN.branch.V_dot_n_ij;
V_n_ij_act(~GN.branch.active_branch) = 0;
if NUMPARAM.solver == 6 || NUMPARAM.solver == 8
    b   = [-GN.bus.V_dot_n_i - INC * V_n_ij_act; GN.bus.p_i(is_slack_bus)];
    p_i = Y\b;
elseif NUMPARAM.solver == 7
    b   = [-GN.bus.V_dot_n_i - INC * V_n_ij_act; GN.bus.p_i(is_slack_bus).^2];
    p_i = sqrt(Y\b);
    if any(imag(p_i) ~= 0)
        p_i = real(p_i .* exp(1i.*angle(p_i)));
    end
end
GN.bus.p_i(~GN.bus.slack_bus) = p_i(~GN.bus.slack_bus);

%% check result
if any(isnan(GN.bus.p_i) | isinf(GN.bus.p_i))
    error('Something went wrong. Nodal pressure became NaN or infinity.')
elseif any(GN.bus.p_i < CONST.p_n)
    success = false;
end

end

