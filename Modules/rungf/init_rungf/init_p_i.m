function [GN] = init_p_i(GN)
%INIT_P_I Initialize p_i
%   GN = init_p_i(GN)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2022, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Physical constants
CONST = getConstants();

% p_i [Pa]
GN.bus.p_i = GN.bus.p_i__barg*1e5 + CONST.p_n;
GN.bus = movevars(GN.bus, 'p_i', 'After', 'p_i__barg');

if any(isnan(GN.bus.p_i) | isinf(GN.bus.p_i) | GN.bus.p_i < 0)
    error(['Missing or invalid pressure values in theses areas: ', num2str(find(isnan(GN.bus.p_i) | isinf(GN.bus.p_i) | GN.bus.p_i < 0))'])
end

