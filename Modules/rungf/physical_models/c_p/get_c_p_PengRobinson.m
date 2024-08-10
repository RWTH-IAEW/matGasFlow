function [GN] = get_c_p_PengRobinson(GN, PHYMOD)
%GET_C_P_PENGROBINSON
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
M_avg   = GN.gasMixProp.M_avg;
CONST   = getConstants;
R_m     = CONST.R_m;

%% bus
T   = GN.bus.T_i;
V_m = GN.bus.Z_i.*R_m.*T./GN.bus.p_i;
[GN.bus.c_p_i, GN.bus.c_p_0_i] = calculate_c_p_PengRobinson(V_m, T, M_avg, GN.gasMixAndCompoProp, PHYMOD);

%% non-isothermal
if ~GN.isothermal
    
    %% Source bus
    if ismember('source_bus', GN.bus.Properties.VariableNames)
        T   = GN.bus.T_i(GN.bus.source_bus);
        V_m = GN.bus.Z_i_source(GN.bus.source_bus).*R_m.*T./GN.bus.p_i(GN.bus.source_bus);
        [GN.bus.c_p_i_source(GN.bus.source_bus), GN.bus.c_p_0_i_source(GN.bus.source_bus)] = calculate_c_p_PengRobinson(V_m, T, M_avg, GN.gasMixAndCompoProp, PHYMOD);
    end
    
    %% pipe
    if isfield(GN, 'pipe')
        T   = GN.pipe.T_ij;
        V_m = GN.pipe.Z_ij.*R_m.*T./GN.pipe.p_ij;
        [GN.pipe.c_p_ij, GN.pipe.c_p_0_ij] = calculate_c_p_PengRobinson(V_m, T, M_avg, GN.gasMixAndCompoProp, PHYMOD);
    end
    
    %% Branch output
    if isfield(GN, 'branch')
        i_bus_out = GN.branch.i_to_bus;
        i_bus_out(GN.branch.V_dot_n_ij < 0) = GN.branch.i_from_bus(GN.branch.V_dot_n_ij < 0);
        T   = GN.branch.T_ij_out;
        V_m = GN.branch.Z_ij_out.*R_m.*T./GN.bus.p_i(i_bus_out);
        [GN.branch.c_p_ij_out, GN.branch.c_p_0_ij_out] = calculate_c_p_PengRobinson(V_m, T, M_avg, GN.gasMixAndCompoProp, PHYMOD);
    end
    
    %% comp
    if isfield(GN, 'comp')
        T   = GN.comp.T_ij_mid;
        V_m = GN.comp.Z_ij_mid.*R_m.*T./GN.comp.p_ij_mid;
        [GN.comp.c_p_ij_mid, GN.comp.c_p_0_ij_mid] = calculate_c_p_PengRobinson(V_m, T, M_avg, GN.gasMixAndCompoProp, PHYMOD);
    end
    
    %% prs
    if isfield(GN, 'prs')
        T   = GN.prs.T_ij_mid;
        V_m = GN.prs.Z_ij_mid.*R_m.*T./GN.prs.p_ij_mid;
        [GN.prs.c_p_ij_mid, GN.prs.c_p_0_ij_mid] = calculate_c_p_PengRobinson(V_m, T, M_avg, GN.gasMixAndCompoProp, PHYMOD);
    end
    
end

end



