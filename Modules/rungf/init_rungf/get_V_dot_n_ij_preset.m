function [GN] = get_V_dot_n_ij_preset(GN)
%GET_V_DOT_N_IJ_PRESET Summary of this function goes here
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


if ismember('P_th_ij_preset__MW',GN.branch.Properties.VariableNames)
    GN.branch.V_dot_n_ij_preset(~isnan(GN.branch.P_th_ij_preset__MW))             = GN.branch.P_th_ij_preset__MW(~isnan(GN.branch.P_th_ij_preset__MW)) * 1e6 / GN.gasMixProp.H_s_n_avg; % [MW]*1e6/[Ws/m^3] = [m^3/s]
    
elseif ismember('P_th_ij_preset',GN.branch.Properties.VariableNames)
    GN.branch.V_dot_n_ij_preset(~isnan(GN.branch.P_th_ij_preset))                 = GN.branch.P_th_ij_preset(~isnan(GN.branch.P_th_ij_preset)) / GN.gasMixProp.H_s_n_avg; % [W]/[Ws/m^3] = [m^3/s]
    
elseif ismember('V_dot_n_ij_preset__m3_per_day',GN.branch.Properties.VariableNames)
    GN.branch.V_dot_n_ij_preset(~isnan(GN.branch.V_dot_n_ij_preset__m3_per_day))  = GN.branch.V_dot_n_ij_preset__m3_per_day(~isnan(GN.branch.V_dot_n_ij_preset__m3_per_day)) / (60 * 60 * 24);
    
elseif ismember('V_dot_n_ij_preset__m3_per_h',GN.branch.Properties.VariableNames)
    GN.branch.V_dot_n_ij_preset(~isnan(GN.branch.V_dot_n_ij_preset__m3_per_h))    = GN.branch.V_dot_n_ij_preset__m3_per_h(~isnan(GN.branch.V_dot_n_ij_preset__m3_per_h)) * 60 * 60;
    
elseif ismember('m_dot_ij_preset__kg_per_s',GN.branch.Properties.VariableNames)
    GN.branch.V_dot_n_ij_preset(~isnan(GN.branch.m_dot_ij_preset__kg_per_s))      = GN.branch.m_dot_ij_preset__kg_per_s(~isnan(GN.branch.m_dot_ij_preset__kg_per_s)) / GN.gasMixProp.rho_n_avg; % [kg/s]/[kg/m^3] = [m^3/s]
    
end

end

