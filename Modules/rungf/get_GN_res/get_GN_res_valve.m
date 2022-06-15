function GN = get_GN_res_valve(GN)
%GET_GN_RES_VALVE Summary of this function goes here
%   Detailed explanation goes here
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2022, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% 
% GN = reset_valves(GN,GN_input);
% GN = get_p_T_valve(GN);
GN = get_V_dot_n_ij_valves(GN);

%% Apply results from branch to pipe
i_valve = GN.branch.i_valve(GN.branch.valve_branch);
GN.valve.V_dot_n_ij(i_valve) = ...
    GN.branch.V_dot_n_ij(GN.branch.valve_branch);

%% Calculate additional results
% Calculate P_th_ij__MW, P_th_ij, V_dot_n_ij__m3_per_day, V_dot_n_ij__m3_per_h or m_dot_ij__kg_per_s
if ismember('P_th_i__MW',GN.bus.Properties.VariableNames)
    GN.valve.P_th_ij__MW                = GN.valve.V_dot_n_ij * 1e-6 * GN.gasMixProp.H_s_n_avg;
    % GN.valve.V_dot_n_ij                 = [];
    
elseif ismember('P_th_i',GN.bus.Properties.VariableNames)
    GN.valve.P_th_ij                    = GN.valve.V_dot_n_ij * GN.gasMixProp.H_s_n_avg;
    % GN.valve.V_dot_n_ij                 = [];
    
elseif ismember('V_dot_n_i__m3_per_day',GN.bus.Properties.VariableNames)
    GN.valve.V_dot_n_ij__m3_per_day     = GN.valve.V_dot_n_ij * 60 * 60 * 24;
    % GN.valve.V_dot_n_ij                 = [];
    
elseif ismember('V_dot_n_i__m3_per_h',GN.bus.Properties.VariableNames)
    GN.valve.V_dot_n_ij__m3_per_h       = GN.valve.V_dot_n_ij * 60 * 60;
    % GN.valve.V_dot_n_ij                 = [];
    
elseif ismember('m_dot_i__kg_per_s',GN.bus.Properties.VariableNames)
    GN.valve.m_dot_ij__kg_per_s         = GN.valve.V_dot_n_ij * GN.gasMixProp.rho_n_avg;
    % GN.valve.V_dot_n_ij                 = [];
    
end
end

