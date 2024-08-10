function [GN] = get_my_JT_H2(GN)
%UNTITLED
%
% the equation used for the computation of the JT-Coefficient can be found in [Ned17]
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

% Physical constants
CONST = getConstants();

% Quantities
R_m    = CONST.R_m;
p_i    = GN.bus.p_i;
T_i    = GN.bus.T_i;
c_p_i  = GN.bus.c_p_i;

% my_JT
load('fluid_data_H2', 'fluid_data_H2')
theta_i   = T_i - 273.15; % the table values are given in °C
del_Z_del_T_matrix  = table2array(fluid_data_H2.del_Z_del_T_matrix);
del_Z_del_T         = interp2(...
    fluid_data_H2.grid_points_T, ...
    fluid_data_H2.grid_points_p, ...
    del_Z_del_T_matrix', ...
    theta_i, ...
    p_i*1e-5); % [1/K]
GN.bus.my_JT_i = R_m .* T_i.^2 .* del_Z_del_T ./ p_i ./ c_p_i ./ GN.gasMixAndCompoProp.M('H2'); % [(K*m^2)/N]
end

