function [GN] = check_and_bypass_prs(GN)
%CHECK_AND_BYPASS_PRS Summary of this function goes here
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
% baypass prs if V_dot_n_ij < 0 | p_i(from_bus) < p_i(to_bus)
is_prs_branch_to_be_bypassed = ...
    GN.bus.p_i__barg(GN.branch.i_from_bus) < GN.bus.p_i__barg(GN.branch.i_to_bus) ...
    & GN.branch.prs_branch ...
    & GN.branch.in_service;

% UNDER CONSTRUCTION
% [GN.bus.p_i__barg(GN.branch.i_from_bus(is_prs_branch_with_higher_pressure_output)), GN.bus.p_i__barg(GN.branch.i_to_bus(is_prs_branch_with_higher_pressure_output))]
if any(is_prs_branch_to_be_bypassed & ~isnan(GN.branch.associate_prs_ID))
    error('Something went wrong. associate prs cannot be a bypass prs.')
end

if ismember('V_dot_n_ij',GN.branch.Properties.VariableNames) % UNDER CONSTRUCTION: Reihenfolge wählen
    is_prs_branch_to_be_bypassed = is_prs_branch_to_be_bypassed & GN.branch.V_dot_n_ij > 0;
elseif ismember('V_dot_n_ij_preset',GN.branch.Properties.VariableNames)
    is_prs_branch_to_be_bypassed = is_prs_branch_to_be_bypassed & GN.branch.V_dot_n_ij_preset > 0;
end

idx = find(is_prs_branch_to_be_bypassed);
delta_p = GN.bus.p_i__barg(GN.branch.i_to_bus(idx)) - GN.bus.p_i__barg(GN.branch.i_from_bus(idx));
idx_min_p = idx(delta_p == min(delta_p));
is_prs_branch_to_be_bypassed = idx_min_p;

if any(is_prs_branch_to_be_bypassed)
    branch_type_to_be_bypassed      = 'prs';
    object_ID_to_be_bypassed        = GN.prs.prs_ID(GN.branch.i_prs(is_prs_branch_to_be_bypassed));
    apply_check_and_init_GN         = false;
    bypass_type                     = 'valve';
    GN = add_bypass_valve(GN, branch_type_to_be_bypassed, object_ID_to_be_bypassed, bypass_type, apply_check_and_init_GN);
    % Check prs
    GN = check_GN_prs(GN);
    
    % Check valve
    GN = check_GN_valve(GN);
    
    % Inititalize GN.branch
    GN = init_GN_branch(GN);
    
    % Inititialize indecies
    GN = init_GN_indices(GN);
    
    % Update in_service setting for prs and valve
    GN.prs.in_service(GN.branch.i_prs(is_prs_branch_to_be_bypassed)) = false;
    GN.valve.in_service(GN.branch.i_bypass_valve(is_prs_branch_to_be_bypassed)) = true;
    
    % Check prs
    GN = check_GN_prs(GN);
    
    % Check valve
    GN = check_GN_valve(GN);
    
    % Inititalize GN.branch
    GN = init_GN_branch(GN);
    
    % Inititialize indecies
    GN = init_GN_indices(GN);
    
    % Check area restrictions
    keep_slack_properties = true;
    GN = check_GN_area_restrictions(GN,keep_slack_properties);
end

%% Check output
% is_prs_branch_to_be_bypassed_output = ...
%     GN.bus.p_i__barg(GN.branch.i_from_bus) < GN.bus.p_i__barg(GN.branch.i_to_bus) ...
%     & GN.branch.prs_branch ...
%     & GN.branch.in_service;
% if any(is_prs_branch_to_be_bypassed_output)
%     error('GN.bus.p_i__barg(GN.branch.i_from_bus) < GN.bus.p_i__barg(GN.branch.i_to_bus) & GN.branch.prs_branch')
% end

end
