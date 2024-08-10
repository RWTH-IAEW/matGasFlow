function [GN] = init_V_dot_n_ij(GN)
%INIT_V_DOT_N_IJ
%
%   [GN] = INIT_V_DOT_N_IJ(GN) Initialization of standard gas flow rate
%   V_dot_n_ij for meshed grids
%   
%   For n linearly independent meshes the standard volume flow rate
%   V_dot_n_ij of n branches is initialized heuristically. Afterwards
%   get_V_dot_n_ij_radialGN is called.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2022, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Apply presets of active branches
if ismember('P_th_ij_preset__MW', GN.branch.Properties.VariableNames)
    GN.branch.V_dot_n_ij(GN.branch.connecting_branch & GN.branch.preset) = ...
        GN.branch.P_th_ij_preset__MW(GN.branch.connecting_branch & GN.branch.preset) ...
        * 1e6 / GN.gasMixProp.H_s_n_avg; % [MW]*1e6/[Ws/m^3] = [m^3/s]
    
elseif ismember('P_th_ij_preset', GN.branch.Properties.VariableNames)
    GN.branch.V_dot_n_ij(GN.branch.connecting_branch & GN.branch.preset) = ...
        GN.branch.P_th_ij_preset(GN.branch.connecting_branch & GN.branch.preset) ...
        / GN.gasMixProp.H_s_n_avg; % [W]/[Ws/m^3] = [m^3/s]
    
elseif ismember('V_dot_n_ij_preset__m3_per_day', GN.branch.Properties.VariableNames)
    GN.branch.V_dot_n_ij(GN.branch.connecting_branch & GN.branch.preset) = ...
        GN.branch.V_dot_n_ij_preset__m3_per_day(GN.branch.connecting_branch & GN.branch.preset) ...
        / (60 * 60 * 24);
    
elseif ismember('V_dot_n_ij_preset__m3_per_h', GN.branch.Properties.VariableNames)
    GN.branch.V_dot_n_ij(GN.branch.connecting_branch & GN.branch.preset) = ...
        GN.branch.V_dot_n_ij_preset__m3_per_day(GN.branch.connecting_branch & GN.branch.preset) ...
        * 60 * 60;
    
elseif ismember('m_dot_ij_preset__kg_per_s', GN.branch.Properties.VariableNames)
    GN.branch.V_dot_n_ij(GN.branch.connecting_branch & GN.branch.preset) = ...
        GN.branch.m_dot_ij_preset__kg_per_s(GN.branch.connecting_branch & GN.branch.preset) ...
        / GN.gasMixProp.rho_n_avg; % [kg/s]/[kg/m^3] = [m^3/s]
    
elseif ismember('V_dot_n_ij_preset', GN.branch.Properties.VariableNames)
    GN.branch.V_dot_n_ij(GN.branch.connecting_branch & GN.branch.preset) = ...
        GN.branch.V_dot_n_ij_preset(GN.branch.connecting_branch & GN.branch.preset);
    
end

%% Heuristic initialization of connecting branches with no presets
% Parallel active branches need preset values
if any(GN.branch.connecting_branch & ~GN.branch.preset & GN.branch.active_branch)
    warning('rungf might fail due to missing presets.')
end
GN.branch.V_dot_n_ij(GN.branch.connecting_branch & ~GN.branch.preset) = mean(abs(GN.bus.V_dot_n_i)) * (0.9:0.2/(sum(GN.branch.connecting_branch & ~GN.branch.preset)-1):1.1)*0.5;

%% Solving system of linear equations
GN = get_V_dot_n_ij_radialGN(GN);

end

