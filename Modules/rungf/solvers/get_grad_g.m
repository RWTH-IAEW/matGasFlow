function [GN] = get_grad_g(GN, iter, NUMPARAM, PHYMOD)
%GET_GRAD_G
%   g = norm(f)
%   grad(g) = grad(norm(f))
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Jacobian Matrix
if rem(iter-1, NUMPARAM.OPTION_get_J_iter) == 0
    i_branch    = GN.bus.p_i(GN.branch.i_from_bus) == GN.bus.p_i(GN.branch.i_to_bus);
    i_bus       = unique([GN.branch.i_from_bus(i_branch);GN.branch.i_to_bus(i_branch)]);
    if ~isempty(i_bus)
        i_bus(GN.bus.slack_bus(i_bus)) = [];       
        GN.bus.p_i(i_bus) = GN.bus.p_i(i_bus) - 0.5e-9 + 1e-9 * rand(length(i_bus),1);
    end
    GN = get_J(GN, NUMPARAM, PHYMOD);
end

%% grad_g
f           = GN.bus.f;
GN.grad_g   = 1/norm(f) * GN.J' * f;


end

