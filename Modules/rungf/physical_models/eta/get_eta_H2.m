function [GN] = get_eta_H2(GN)
%GET_ETA_H2
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

%% Hydrogen
load('fluid_data_H2', 'fluid_data_H2')

% Physical constants
CONST = getConstants();

% Quantities
p_ij__bar   = GN.pipe.p_ij*1e-5;
T_ij        = GN.pipe.T_ij;
t_ij        = T_ij-CONST.T_n; % [°C]

% eta
eta = table2array(fluid_data_H2.eta);
GN.pipe.eta_ij = interp2(fluid_data_H2.grid_points_T, fluid_data_H2.grid_points_p, eta', t_ij, p_ij__bar).*1e-6;

end

