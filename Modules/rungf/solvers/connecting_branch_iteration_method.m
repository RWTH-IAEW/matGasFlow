function [GN, success] = connecting_branch_iteration_method(GN, NUMPARAM, PHYMOD)
%CONNECTING_BRANCH_ITERATION_METHOD
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Quantities
INC         = GN.MAT.INC;
INC_noSlack = INC(~GN.bus.slack_bus,:);
INC_slack   = INC(GN.bus.slack_bus,:);

%% NUMPARAM
NUMPARAM.OPTION_get_p_i = 1;

%% Update nodal equation
GN = get_f_nodal_equation(GN, NUMPARAM, PHYMOD);

%% Check convergence
GN = get_G_ij(GN);

Delta_p     = INC'*GN.bus.p_i;
GN          = get_J(GN, NUMPARAM, PHYMOD);
V_dot_tree  = GN.branch.V_dot_n_ij(~GN.branch.connecting_branch(GN.pipe.i_branch));
G_tree      = GN.pipe.G_ij(~GN.branch.connecting_branch(GN.pipe.i_branch));
R_tree_inv  = diag(G_tree/2./abs(V_dot_tree));
V_dot       = GN.branch.V_dot_n_ij(GN.pipe.i_branch);
G           = GN.pipe.G_ij(GN.pipe.i_branch);
R_inv       = diag(G/2./abs(V_dot));
pi_i        = GN.bus.p_i.^2;

A = INC * R_inv * INC';
b = -INC * R_inv * (-INC_slack' * pi_i(GN.bus.slack_bus) + INC'*pi_i);
sqrt(A\b)

A_2 = sparse(1:sum(GN.bus.slack_bus),find(GN.bus.slack_bus),1, sum(GN.bus.slack_bus), size(GN.bus));

success = false;
while ~success
    GN_temp = GN;
    GN = get_V_dot_n_ij_radialGN(GN, NUMPARAM);
    [GN, success] = get_p_i(GN, NUMPARAM, PHYMOD);
    if ~success
        GN = GN_temp;
        GN.branch.V_dot_n_ij(GN.branch.connecting_branch) = rand(1) * GN.branch.V_dot_n_ij(GN.branch.connecting_branch);
    end
end

%% check result
if any(isnan(GN.bus.p_i) | isinf(GN.bus.p_i))
    error('Something went wrong. Nodal pressure became NaN or infinity.')
elseif any(GN.bus.p_i < CONST.p_n)
    success = false;
end

end