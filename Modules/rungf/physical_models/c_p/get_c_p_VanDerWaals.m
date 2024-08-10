function [GN] = get_c_p_VanDerWaals(GN, PHYMOD)
%GET_C_P_VANDERWAALS Specific isobaric heat capacity c_p [J/(kg*K)] using
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

%% Physical constants
CONST = getConstants();

%% Quantities
M_avg   = GN.gasMixProp.M_avg;
R_m     = CONST.R_m;

%% bus
p   = GN.bus.p_i;
T   = GN.bus.T_i;
Z   = GN.bus.Z_i;
V_m = Z .* R_m .* T ./ p;
[GN.bus.c_p_i, GN.bus.c_p_0_i, GN.dp_dT, GN.dp_dV_m, GN.int_d2p_dT2] = calculate_c_p_VanDerWaals(V_m, T, M_avg, GN.gasMixAndCompoProp, PHYMOD);

%% non-isothermal
if ~GN.isothermal
    
    %% Source bus
    if ismember('source_bus', GN.bus.Properties.VariableNames)
        p   = GN.bus.p_i(GN.bus.source_bus);
        T   = GN.bus.T_i_source(GN.bus.source_bus);
        Z   = GN.bus.Z_i_source(GN.bus.source_bus);
        V_m = Z .* R_m .* T ./ p;
        [GN.bus.c_p_i_source(GN.bus.source_bus), GN.bus.c_p_0_i_source(GN.bus.source_bus)] = calculate_c_p_VanDerWaals(V_m, T, M_avg, GN.gasMixAndCompoProp, PHYMOD);
    end
    
    %% pipe
    if isfield(GN, 'pipe')
        p   = GN.pipe.p_ij;
        T   = GN.pipe.T_ij;
        Z   = GN.pipe.Z_ij;
        V_m = Z .* R_m .* T ./ p;
        [GN.pipe.c_p_ij, GN.pipe.c_p_0_ij]              = calculate_c_p_VanDerWaals(V_m, T, M_avg, GN.gasMixAndCompoProp, PHYMOD);
    end
    
    %% Branch output
    if isfield(GN, 'branch')
        i_bus_out = GN.branch.i_to_bus;
        i_bus_out(GN.branch.V_dot_n_ij < 0) = GN.branch.i_from_bus(GN.branch.V_dot_n_ij < 0);
        p   = GN.bus.p_i(i_bus_out);
        T   = GN.branch.T_ij_out;
        Z   = GN.branch.Z_ij_out;
        V_m = Z .* R_m .* T ./ p;
        [GN.branch.c_p_ij_out, GN.branch.c_p_0_ij_out]  = calculate_c_p_VanDerWaals(V_m, T, M_avg, GN.gasMixAndCompoProp, PHYMOD);
    end
    
    %% comp
    if isfield(GN, 'comp')
        p   = GN.comp.p_ij_mid;
        T   = GN.comp.T_ij_mid;
        Z   = GN.comp.Z_ij_mid;
        V_m = Z .* R_m .* T ./ p;
        [GN.comp.c_p_ij_mid, GN.comp.c_p_0_ij_mid]      = calculate_c_p_VanDerWaals(V_m, T, M_avg, GN.gasMixAndCompoProp, PHYMOD);
    end
    
    %% prs
    if isfield(GN, 'prs')
        p   = GN.prs.p_ij_mid;
        T   = GN.prs.T_ij_mid;
        Z   = GN.prs.Z_ij_mid;
        V_m = Z .* R_m .* T ./ p;
        [GN.prs.c_p_ij_mid, GN.prs.c_p_0_ij_mid]        = calculate_c_p_VanDerWaals(V_m, T, M_avg, GN.gasMixAndCompoProp, PHYMOD);
    end
    
end

end

