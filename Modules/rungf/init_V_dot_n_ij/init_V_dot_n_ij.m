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
<<<<<<< HEAD
%   Copyright (c) 2020-2022, High Voltage Equipment and Grids,
=======
%   Copyright (c) 2020-2021, High Voltage Equipment and Grids,
>>>>>>> Merge to public repo (#1)
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

<<<<<<< HEAD
%% Apply presets of active branches
if any(ismember(GN.branch.Properties.VariableNames, 'P_th_ij_preset__MW'))
    GN.branch.V_dot_n_ij(GN.branch.connecting_branch & GN.branch.preset) = ...
        GN.branch.P_th_ij_preset__MW(GN.branch.connecting_branch & GN.branch.preset) ...
        * 1e6 / GN.gasMixProp.H_s_n_avg; % [MW]*1e6/[Ws/m^3] = [m^3/s]
    
elseif any(ismember(GN.branch.Properties.VariableNames, 'P_th_ij_preset'))
    GN.branch.V_dot_n_ij(GN.branch.connecting_branch & GN.branch.preset) = ...
        GN.branch.P_th_ij_preset(GN.branch.connecting_branch & GN.branch.preset) ...
        / GN.gasMixProp.H_s_n_avg; % [W]/[Ws/m^3] = [m^3/s]
    
elseif any(ismember(GN.branch.Properties.VariableNames, 'V_dot_n_ij_preset__m3_per_day'))
    GN.branch.V_dot_n_ij(GN.branch.connecting_branch & GN.branch.preset) = ...
        GN.branch.V_dot_n_ij_preset__m3_per_day(GN.branch.connecting_branch & GN.branch.preset) ...
        / (60 * 60 * 24);
    
elseif any(ismember(GN.branch.Properties.VariableNames, 'V_dot_n_ij_preset__m3_per_h'))
    GN.branch.V_dot_n_ij(GN.branch.connecting_branch & GN.branch.preset) = ...
        GN.branch.V_dot_n_ij_preset__m3_per_day(GN.branch.connecting_branch & GN.branch.preset) ...
        * 60 * 60;
    
elseif any(ismember(GN.branch.Properties.VariableNames, 'm_dot_ij_preset__kg_per_s'))
    GN.branch.V_dot_n_ij(GN.branch.connecting_branch & GN.branch.preset) = ...
        GN.branch.m_dot_ij_preset__kg_per_s(GN.branch.connecting_branch & GN.branch.preset) ...
        / GN.gasMixProp.rho_n_avg; % [kg/s]/[kg/m^3] = [m^3/s]
    
elseif any(ismember(GN.branch.Properties.VariableNames, 'V_dot_n_ij_preset'))
    GN.branch.V_dot_n_ij(GN.branch.connecting_branch & GN.branch.preset) = ...
        GN.branch.V_dot_n_ij_preset(GN.branch.connecting_branch & GN.branch.preset);
    
end

%% Heuristic initialization of connecting branches with no presets
GN.branch.V_dot_n_ij(GN.branch.connecting_branch & ~GN.branch.preset) = mean(abs(GN.bus.V_dot_n_i)) * (0.9:0.2/(sum(GN.branch.connecting_branch & ~GN.branch.preset)-1):1.1)*0.5;
=======
%% Heuristical initialization of V_dot_n_ij
GN.branch.V_dot_n_ij = zeros(size(GN.branch,1),1);
GN.branch.V_dot_n_ij(GN.branch.connecting_branch) = mean(abs(GN.bus.V_dot_n_i)) * (0.9:0.2/(sum(GN.branch.connecting_branch)-1):1.1);
>>>>>>> Merge to public repo (#1)

%% Solving system of linear equations
GN = get_V_dot_n_ij_radialGN(GN);

end

