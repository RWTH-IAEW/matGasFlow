function [GN] = get_c_p_AGA8_92DC(GN)
%GET_C_P_AGA8_92DC
%   the Van der Waals equation
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Read AGA8_92DC_tables.xlsx
if ~isfield(GN,'AGA8_92DC_tables')
    GN = get_AGA8_92DC_tables(GN);
end

%% bus
p   = GN.bus.p_i;
T   = GN.bus.T_i;
Z   = GN.bus.Z_i;
[~, GN.bus.c_p_i] = calculate_AGA8_92DC(p, T, Z, GN.AGA8_92DC_tables);

%% non-isothermal
if ~GN.isothermal
    
    %% Source bus
    if ismember('source_bus', GN.bus.Properties.VariableNames)
        p   = GN.bus.p_i(GN.bus.source_bus);
        T   = GN.bus.T_i_source(GN.bus.source_bus);
        Z   = GN.bus.Z_i_source(GN.bus.source_bus);
        [~, GN.bus.c_p_i_source(GN.bus.source_bus)] = calculate_AGA8_92DC(p, T, Z, GN.AGA8_92DC_tables);
    end
    
    %% pipe
    if isfield(GN, 'pipe')
        p   = GN.pipe.p_ij;
        T   = GN.pipe.T_ij;
        Z   = GN.pipe.Z_ij;
        [~, GN.pipe.c_p_ij] = calculate_AGA8_92DC(p, T, Z, GN.AGA8_92DC_tables);
    end
    
    %% Branch output
    if isfield(GN, 'branch')
        i_bus_out = GN.branch.i_to_bus;
        i_bus_out(GN.branch.V_dot_n_ij < 0) = GN.branch.i_from_bus(GN.branch.V_dot_n_ij < 0);
        p   = GN.bus.p_i(i_bus_out);
        T   = GN.branch.T_ij_out;
        Z   = GN.branch.Z_ij_out;
        [~, GN.branch.c_p_ij_out] = calculate_AGA8_92DC(p, T, Z, GN.AGA8_92DC_tables);
    end
    
    %% comp
    if isfield(GN, 'comp')
        p   = GN.comp.p_ij_mid;
        T   = GN.comp.T_ij_mid;
        Z   = GN.comp.Z_ij_mid;
        [~, GN.comp.c_p_ij_mid] = calculate_AGA8_92DC(p, T, Z, GN.AGA8_92DC_tables);
    end
    
    %% prs
    if isfield(GN, 'prs')
        p   = GN.prs.p_ij_mid;
        T   = GN.prs.T_ij_mid;
        Z   = GN.prs.Z_ij_mid;
        [~, GN.prs.c_p_ij_mid] = calculate_AGA8_92DC(p, T, Z, GN.AGA8_92DC_tables);
    end
    
end

end

