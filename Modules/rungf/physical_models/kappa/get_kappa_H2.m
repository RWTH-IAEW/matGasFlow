function [GN] = get_kappa_H2(GN)
%GET_KAPPA_H2
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

error('...') % TODO

load('fluid_data_H2', 'fluid_data_H2')
interpolationTable = table2array(fluid_data_H2.del_Z_del_T_matrix);

% Physical constants
CONST = getConstants();

% Quantities
R_m         = CONST.R_m;
M_avg       = GN.gasMixProp.M_avg;
p_i__bar    = GN.bus.p_i*1e-5;
theta_i     = GN.bus.T_i - CONST.T_n; % [°C]

del_Z_del_T = interp2( ...
    fluid_data_H2.grid_points_T, ...
    fluid_data_H2.grid_points_p, ...
    interpolationTable', ...
    theta_i, ...
    p_i__bar); % [1/K]
GN.bus.kappa_i = (1-(R_m./(M_avg.*GN.bus.c_p_i).*(GN.bus.Z_i + GN.bus.T_i .* del_Z_del_T))).^-1;
end

