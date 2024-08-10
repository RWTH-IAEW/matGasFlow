function[GN] = get_Z_H2(GN)
%GET_Z_H2
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

error
%% Interpolation of c_p for the branch and bus values of T and p from table data
load('fluid_data_H2.mat','fluid_data_H2')
if isfield(GN, 'pipe')
    p_ij        = GN.pipe.p_ij;
    theta_ij    = GN.pipe.T_ij - 273.15; % the table values are given in °C
end
p_i         = GN.bus.p_i;
theta_i     = GN.bus.T_i - 273.15; % the table values are given in °C

Z = table2array(fluid_data_H2.Z);

GN.bus.Z_i  = interp2(fluid_data_H2.grid_points_T,fluid_data_H2.grid_points_p,Z',theta_i,p_i*1e-5); %[J/g K]
GN.bus.K_i = GN.bus.Z_i / GN.gasMixProp.Z_n_avg;

if isfield (GN,'pipe')
    GN.pipe.Z_ij = interp2(fluid_data_H2.grid_points_T,fluid_data_H2.grid_points_p,Z',theta_ij,p_ij*1e-5); %[J/g K]
    GN.pipe.K_ij = GN.pipe.Z_ij / GN.gasMixProp.Z_n_avg;
end 

end