function[GN] = get_Q_dot_comp(GN, NUMPARAM,PHYMOD)
%GET_Q_DOT_COMP Calculation of heat exange for compressor branches
%   [GN] = get_Q_dot_comp(GN, PHYMOD)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

%% Indicies
T_controlled    = GN.comp.T_controlled;

%% Calculate T_ij_mid(T_ij_in)
GN              = get_T_ij_mid_comp(GN, NUMPARAM, PHYMOD);
T_mid           = GN.comp.T_ij_mid;

%% Quantities
T_out           = GN.branch.T_ij_out(GN.comp.i_branch);
V_dot_n_ij      = GN.branch.V_dot_n_ij(GN.comp.i_branch);
rho_n_avg       = GN.gasMixProp.rho_n_avg;

%% Q_dot_cooler(T_mid, T_out)
GN              = get_Z(GN,PHYMOD,{'branch','comp'});
GN              = get_c_p(GN,PHYMOD);
c_p_avg         = (GN.comp.c_p_ij_mid + GN.branch.c_p_ij_out(GN.comp.i_branch))/2;

Q_dot_cooler                        = - V_dot_n_ij .* rho_n_avg .* c_p_avg .* (T_out - T_mid);
GN.comp.Q_dot_cooler(T_controlled)  = Q_dot_cooler(T_controlled);
GN.comp.Q_dot_cooler(T_controlled & GN.comp.Q_dot_cooler<0) = 0;

%% model with multiple discretized stages
if PHYMOD.comp_cooler_stages > 1
    GN = get_Q_dot_comp_multiStage(GN,PHYMOD);
end

%% Set convergence
GN              = set_convergence(GN, 'get_Q_dot_comp');

end