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
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Initialize V_dot_n_ij
if ~ismember('V_dot_n_ij',GN.branch.Properties.VariableNames)
    GN.branch.V_dot_n_ij(:) = 0;
end
GN.branch.V_dot_n_ij(isnan(GN.branch.V_dot_n_ij)) = 0;

%% Apply presets of active branches
if ismember('P_th_ij_preset__MW', GN.branch.Properties.VariableNames)
    V_dot_n_ij_preset = convert_gas_flow_quantity(GN.branch.P_th_ij_preset__MW,              'MW',           'm3_per_s', GN.gasMixProp);
    
elseif ismember('P_th_ij_preset', GN.branch.Properties.VariableNames)
    V_dot_n_ij_preset = convert_gas_flow_quantity(GN.branch.P_th_ij_preset,                  'W',            'm3_per_s', GN.gasMixProp);
    
elseif ismember('V_dot_n_ij_preset__m3_per_day', GN.branch.Properties.VariableNames)
    V_dot_n_ij_preset = convert_gas_flow_quantity(GN.branch.V_dot_n_ij_preset__m3_per_day,   'm3_per_day',   'm3_per_s', GN.gasMixProp);
    
elseif ismember('V_dot_n_ij_preset__m3_per_h', GN.branch.Properties.VariableNames)
    V_dot_n_ij_preset = convert_gas_flow_quantity(GN.branch.V_dot_n_ij_preset__m3_per_h,     'm3_per_h',     'm3_per_s', GN.gasMixProp);
    
elseif ismember('m_dot_ij_preset__kg_per_s', GN.branch.Properties.VariableNames)
    V_dot_n_ij_preset = convert_gas_flow_quantity(GN.branch.m_dot_ij_preset__kg_per_s,       'kg_per_s',     'm3_per_s', GN.gasMixProp);
    
elseif ismember('V_dot_n_ij_preset', GN.branch.Properties.VariableNames)
    V_dot_n_ij_preset = GN.branch.V_dot_n_ij_preset;
    
end
if any(GN.branch.preset) % TODO: changed from "connecting_branch & preset" to "preset"
    GN.branch.V_dot_n_ij(GN.branch.preset) = V_dot_n_ij_preset(GN.branch.preset);
end

%% Heuristic initialization of connecting branches with no presets
% Parallel active branches need preset values
if any(GN.branch.connecting_branch & ~GN.branch.preset & GN.branch.active_branch)
    warning('rungf might fail due to missing presets.')
end

end


