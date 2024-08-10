function [GN, success] = Gauss_Newton_step(GN, NUMPARAM, PHYMOD, iter)
%GAUSS_NEWTON_STEP
%
%   x_{k+1} = x_k - alpha_k (J' * J)^{-1} J' f
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
Delta_p = zeros(size(GN.bus,1),1);
Delta_p(~GN.bus.slack_bus) = -(GN.J'*GN.J)\(GN.J'*GN.bus.f);

%% Calculate p_i
GN.bus.p_i  = GN.bus.p_i + Delta_p;

%% check result
if any(isnan(GN.bus.p_i) | isinf(GN.bus.p_i))
    error('Something went wrong. Nodal pressure became NaN or infinity.')
elseif any(GN.bus.p_i < CONST.p_n)
    success = false;
end

end

