function [GN, success, G] = gradient_descent_step(GN, G, NUMPARAM, PHYMOD, iter)
%UNTITLED
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

% if isempty(G)
%     G = zeros(sum(~GN.bus.slack_bus),1);
% end

%% Success
success = true;

%% Constants
CONST = getConstants();

%% grad(g) = grad(norm(f))
GN = get_grad_g(GN, iter, NUMPARAM, PHYMOD);

%% Calculation of Delta_x, solving linear system of equation
% g = norm(f)
% grad(g) = 1/2 * 1/norm(f)) *    [ d(f1^2)/dx1 + d(f2^2)/dx1 + ... ; ...
%                                   d(f1^2)/dx2 + d(f2^2)/dx2 + ...]
%         = 1/2 * 1/norm(f)) * 2 * [ f1*df1/dx1 + f2*df2/dx1 + ... ; ...
%                                   f1*df1/dx2 + f2*df2/dx2 + ...]
%         =       1/norm(f))   *   [ f1*df1/dx1 + f2*df2/dx1 + ... ; ...
%                                    f1*df1/dx2 + f2*df2/dx2 + ...]
% Delta_x + norm(f) ./ [d/dx(norm(f))] = 0;
% Delta_x' * grad(norm(f)) = -norm(f)
% g             = f1^2 + f2^2 + ...
% G             = norm(f) = sqrt(f1^2 + f2^2 + ...)
% dG/dx         = 1/2 * 1/norm(f) * dg/dx
% dg/dx         = [ d(f1^2)/dx1 + d(f2^2)/dx1 + ... ; ...
%                   d(f1^2)/dx2 + d(f2^2)/dx2 + ...]
% d(f1^2)/dx1   = 2*f1*df1/dx1
% dG/dx         = 1/norm(f) ...
%                   * [ f1*df1/dx1 + f2*df2/dx1 + ... ; ...
%                       f1*df1/dx2 + f2*df2/dx2 + ...]

G           = G + GN.grad_g.^2;
Delta_x     = - NUMPARAM.alpha_ADAGRAD * GN.grad_g./sqrt(G + NUMPARAM.epsilon_ADAGRAD);
 
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

