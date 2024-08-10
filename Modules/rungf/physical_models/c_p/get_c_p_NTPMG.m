function [GN] = get_c_p_NTPMG(GN)
%GET_C_P_NTPMG
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

%% Quantities
M_avg = GN.gasMixProp.M_avg;

%% bus
T_r = GN.bus.T_i / GN.gasMixProp.T_pc;
p_r = GN.bus.p_i / GN.gasMixProp.p_pc;
GN.bus.c_p_i = calculate_c_p_NTPMG(p_r, T_r, M_avg);

%% non-isothermal
if ~GN.isothermal
    
    %% Source bus
    if ismember('source_bus', GN.bus.Properties.VariableNames)
        T_r = GN.bus.T_i_source(GN.bus.source_bus)  / GN.gasMixProp.T_pc;
        p_r = GN.bus.p_i(GN.bus.source_bus)         / GN.gasMixProp.p_pc;
        GN.bus.c_p_i_source(GN.bus.source_bus) = calculate_c_p_NTPMG(p_r, T_r, M_avg);
    end
    
    %% pipe
    if isfield(GN, 'pipe')
        T_r = GN.pipe.T_ij / GN.gasMixProp.T_pc;
        p_r = GN.pipe.p_ij / GN.gasMixProp.p_pc;
        GN.pipe.c_p_ij = calculate_c_p_NTPMG(p_r, T_r, M_avg);
    end
    
    %% Branch output
    if isfield(GN, 'branch')
        i_bus_out = GN.branch.i_to_bus;
        i_bus_out(GN.branch.V_dot_n_ij < 0) = GN.branch.i_from_bus(GN.branch.V_dot_n_ij < 0);
        T_r = GN.branch.T_ij_out    / GN.gasMixProp.T_pc;
        p_r = GN.bus.p_i(i_bus_out) / GN.gasMixProp.p_pc;
        GN.branch.c_p_ij_out = calculate_c_p_NTPMG(p_r, T_r, M_avg);
    end
    
    %% comp
    if isfield(GN, 'comp')
        T_r = GN.comp.T_ij_mid / GN.gasMixProp.T_pc;
        p_r = GN.comp.p_ij_mid / GN.gasMixProp.p_pc;
        GN.comp.c_p_ij_mid = calculate_c_p_NTPMG(p_r, T_r, M_avg);
    end
    
    %% prs
    if isfield(GN, 'prs')
        T_r = GN.prs.T_ij_mid / GN.gasMixProp.T_pc;
        p_r = GN.prs.p_ij_mid / GN.gasMixProp.p_pc;
        GN.prs.c_p_ij_mid = calculate_c_p_NTPMG(p_r, T_r, M_avg);
    end
    
end

end



