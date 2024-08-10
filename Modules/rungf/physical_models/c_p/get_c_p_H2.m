function [GN] = get_c_p_H2(GN)
%GET_C_P_H2
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


load('fluid_data_H2', 'fluid_data_H2')
T_row       = fluid_data_H2.grid_points_T;
p_column    = fluid_data_H2.grid_points_p;
c_p_matrix  = table2array(fluid_data_H2.c_p_matrix)';

% Physical constants
CONST = getConstants();

%% bus
p__bar          = GN.bus.p_i * 1e-5;
theta           = GN.bus.T_i - CONST.T_n; % [°C]
GN.bus.c_p_i    = interp2(T_row, p_column, c_p_matrix', theta, p__bar) * 1e3; % [J/kg K]

%% non-isothermal
if ~GN.isothermal
    
    %% Source bus
    if ismember('source_bus', GN.bus.Properties.VariableNames)
        p__bar          = GN.bus.p_i(GN.bus.source_bus) * 1e-5;
        theta           = GN.bus.T_i_source(GN.bus.source_bus) - CONST.T_n; % [°C]
        GN.bus.c_p_i    = interp2(T_row, p_column, c_p_matrix', theta, p__bar) * 1e3; % [J/kg K]
    end
    
    %% pipe
    if isfield(GN, 'pipe')
        p__bar          = GN.pipe.p_ij * 1e-5;
        theta           = GN.pipe.T_ij - CONST.T_n; % [°C]
        GN.bus.c_p_i    = interp2(T_row, p_column, c_p_matrix', theta, p__bar) * 1e3; % [J/kg K]
    end
    
    %% Branch output
    if isfield(GN, 'branch')
        i_bus_out = GN.branch.i_to_bus;
        i_bus_out(GN.branch.V_dot_n_ij < 0) = GN.branch.i_from_bus(GN.branch.V_dot_n_ij < 0);
        p__bar          = GN.bus.p_i(i_bus_out) * 1e-5;
        theta           = GN.branch.T_ij_out - CONST.T_n; % [°C]
        GN.bus.c_p_i    = interp2(T_row, p_column, c_p_matrix', theta, p__bar) * 1e3; % [J/kg K]
    end
    
    %% comp
    if isfield(GN, 'comp')
        p__bar          = GN.comp.p_ij_mid * 1e-5;
        theta           = GN.comp.T_ij_mid - CONST.T_n; % [°C]
        GN.bus.c_p_i    = interp2(T_row, p_column, c_p_matrix', theta, p__bar) * 1e3; % [J/kg K]
    end
    
    %% prs
    if isfield(GN, 'prs')
        p__bar          = GN.prs.p_ij_mid * 1e-5;
        theta           = GN.prs.T_ij_mid - CONST.T_n; % [°C]
        GN.bus.c_p_i    = interp2(T_row, p_column, c_p_matrix', theta, p__bar) * 1e3; % [J/kg K]
    end
    
end

end



