function[GN] = get_Q_dot_comp_multiStage(GN,PHYMOD)
%GET_Q_DOT_COMP_V3 Calculation of heat exange for compressor branches
%   [GN] = get_Q_dot_comp_v3(GN, PHYMOD)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Indicies and Parameter
is_T_controlled = GN.comp.T_controlled;

%% Quantities
V_dot_n_ij      = GN.branch.V_dot_n_ij(GN.comp.i_branch);
rho_n_avg       = GN.gasMixProp.rho_n_avg;

%% Save input values (T and c_p at mid point and outflow)
T_ij_out_save   = GN.branch.T_ij_out(GN.comp.i_branch);
T_ij_mid_save   = GN.comp.T_ij_mid;
Delta_T         = GN.comp.T_ij_mid - GN.branch.T_ij_out(GN.comp.i_branch);
c_p_ij_out_save = GN.branch.c_p_ij_out(GN.comp.i_branch);
c_p_ij_mid_save = GN.comp.c_p_ij_mid;

%% Q_dot_cooler
Q_dot_cooler    = 0;

for ii= 1:PHYMOD.comp_cooler_stages
    
    GN.comp.T_ij_mid = ...
        T_ij_mid_save - (ii-1)*Delta_T/PHYMOD.comp_cooler_stages;
    GN.branch.T_ij_out(GN.comp.i_branch) = ...
        T_ij_mid_save -   ii  *Delta_T/PHYMOD.comp_cooler_stages;
    
    % c_p
    GN      = set_convergence(GN, ['get_Q_dot_comp_multiStage, (',num2str(ii),')']);
    GN      = get_Z(GN,PHYMOD,{'branch','comp'});
    GN      = get_c_p(GN, PHYMOD);
    c_p_avg = (GN.comp.c_p_ij_mid + GN.branch.c_p_ij_out(GN.comp.i_branch))/2;
    
    % Q_dot_cooler
    Q_dot_cooler = Q_dot_cooler ...
        - V_dot_n_ij .* rho_n_avg ...
        .* c_p_avg .* (GN.branch.T_ij_out(GN.comp.i_branch) - GN.comp.T_ij_mid);
    
    if PHYMOD.comp_cooler_stages == 1
        break
    end    
end

GN.comp.Q_dot_cooler_multiStage(is_T_controlled) = Q_dot_cooler;
GN.comp.Q_dot_cooler_multiStage(is_T_controlled & GN.comp.Q_dot_cooler<0) = 0;

%% Reset T and c_p at mid point and outflow
GN.branch.T_ij_out(GN.comp.i_branch)    = T_ij_out_save;
GN.comp.T_ij_mid                        = T_ij_mid_save;
GN.branch.c_p_ij_out(GN.comp.i_branch)  = c_p_ij_out_save;
GN.comp.c_p_ij_mid                      = c_p_ij_mid_save;

end

