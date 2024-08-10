function [GN] = get_H(GN, iter, NUMPARAM, PHYMOD)
%GET_H
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

GN = get_grad_g(GN, iter, NUMPARAM, PHYMOD);

i_bus = find(~GN.bus.slack_bus);
n_bus = length(i_bus);
H = zeros(n_bus, n_bus);
dp = 1e-6;

for ii = 1:n_bus
    GN_temp = GN;
    GN_temp.bus.p_i(i_bus(ii)) = GN_temp.bus.p_i(i_bus(ii)) + dp;
    GN_temp = get_grad_g(GN_temp, iter, NUMPARAM, PHYMOD);
    H(ii,:) = (GN_temp.grad_g-GN.grad_g)./dp;
end

GN.H = (H+H')./2;

end

