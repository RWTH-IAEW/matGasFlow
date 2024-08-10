function [GN,success] = rungf_meshed_GN(GN, NUMPARAM, PHYMOD)
%RUNGF_MESHED_GN Summary of this function goes here
%   Detailed explanation goes here
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2022, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% V_dot_n_ij start solution
GN = init_V_dot_n_ij(GN);

% p_i start solution
[GN, success] = get_p_i(GN, NUMPARAM, PHYMOD);
if ~success
    GN.success = success;
    return
end

% Newton Raphson
[GN, success] = Newton_Raphson_method(GN, NUMPARAM, PHYMOD);
% [GN,success] = Secant_method(GN, NUMPARAM, PHYMOD);
% [GN,success] = Levenberg_Marquardt_method(GN, NUMPARAM, PHYMOD);

end

