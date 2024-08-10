function [GN] = get_V_dot_n_ij_valves(GN, NUMPARAM)
%GET_V_DOT_N_IJ_VALVES Summary of this function goes here
%   [GN] = get_V_dot_n_ij_valves(GN)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2022, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~isfield(GN,'valve')
    return
end    
i_valve_bus =  unique([ ...
    GN.branch.i_from_bus(GN.branch.valve_branch & GN.branch.in_service); ...
    GN.branch.i_to_bus(GN.branch.valve_branch & GN.branch.in_service)]);

%% Solving system of linear equations
branch_in_service   = GN.branch(GN.branch.in_service,:);
idx_1               = ~branch_in_service.valve_branch; % | branch_in_service.connecting_branch;
b = - (...
    GN.bus.V_dot_n_i ...
    + GN.MAT.INC(:, idx_1) * branch_in_service.V_dot_n_ij(idx_1) ...
    );
b = b(i_valve_bus);

idx_2   = branch_in_service.valve_branch;% & ~branch_in_service.parallel_branch;
A       = GN.MAT.INC(i_valve_bus,idx_2);
branch_in_service.V_dot_n_ij(idx_2) = A\b;
if norm(abs(A * branch_in_service.V_dot_n_ij(idx_2) - b)) > 0.5 * NUMPARAM.epsilon_NR_f
    warning('...')
end
% branch_in_service.V_dot_n_ij(branch_in_service.parallel_branch) = 0;
GN.branch.V_dot_n_ij(GN.branch.in_service) = branch_in_service.V_dot_n_ij;

GN.bus.f = GN.MAT.INC * GN.branch.V_dot_n_ij(GN.branch.in_service) + GN.bus.V_dot_n_i;
if norm(GN.MAT.INC * GN.branch.V_dot_n_ij(GN.branch.in_service) + GN.bus.V_dot_n_i) > NUMPARAM.epsilon_NR_f
    error('Something went wrong.')
end

%% Nodal equation f
GN.bus.f = GN.MAT.INC * GN.branch.V_dot_n_ij(GN.branch.in_service) + GN.bus.V_dot_n_i;

end

