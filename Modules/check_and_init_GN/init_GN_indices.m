function [GN] = init_GN_indices(GN)
%INIT_GN_INDICES
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2022, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Get numerical tolerance
NUMPARAM = getDefaultNumericalParameters;

%% Initialize active_bus
GN.bus.active_bus(:)            = false;
GN.bus.active_bus = logical(GN.bus.active_bus);
GN.bus = movevars(GN.bus,'active_bus','After','slack_bus');

%% branch
% from/to
[~,GN.branch.i_from_bus] = ismember(GN.branch.from_bus_ID,GN.bus.bus_ID);
[~,GN.branch.i_to_bus]   = ismember(GN.branch.to_bus_ID,GN.bus.bus_ID);
GN.branch = movevars(GN.branch,'i_from_bus','After','to_bus_ID');
GN.branch = movevars(GN.branch,'i_to_bus','After','i_from_bus');

% Initialize active_branch
GN.branch.active_branch(:) = false;

%% pipe
if isfield(GN,'pipe')
    [GN.branch.pipe_branch, GN.branch.i_pipe]   = ismember(GN.branch.branch_ID,GN.pipe.branch_ID);
    GN.branch.i_pipe(~GN.branch.pipe_branch)    = NaN;
    [~,                     GN.pipe.i_branch]   = ismember(GN.pipe.branch_ID,GN.branch.branch_ID);
else
    % Initialize pipe_branch, if GN has no pipe;
    GN.branch.pipe_branch = false(size(GN.branch,1),1);
end

%% comp
if isfield(GN,'comp')
    [GN.branch.comp_branch,     GN.branch.i_comp]   = ismember(GN.branch.branch_ID,GN.comp.branch_ID);
    GN.branch.i_comp(~GN.branch.comp_branch)        = NaN;
    [~,                         GN.comp.i_branch]   = ismember(GN.comp.branch_ID,GN.branch.branch_ID);
    
    % active_branch
    GN.branch.active_branch = GN.branch.active_branch | GN.branch.comp_branch;
    
    % T_i - UNDER CONSTRCUTION
    if GN.isothermal == 0 && any(GN.comp.T_controlled) && any(isnan(GN.bus.T_i(GN.comp.i_out_bus(GN.comp.T_controlled))))
        i_branch = GN.branch.comp_branch & GN.comp.T_controlled(GN.branch.i_comp(GN.branch.comp_branch));
        GN.bus.T_i(GN.branch.i_to_bus(i_branch)) = GN.comp.T_ij_out(GN.comp.T_controlled);
    end
end

%% prs
if isfield(GN,'prs')
    [GN.branch.prs_branch,      GN.branch.i_prs]    = ismember(GN.branch.branch_ID,GN.prs.branch_ID);
    GN.branch.i_prs(~GN.branch.prs_branch)          = NaN;
    [~,                         GN.prs.i_branch]    = ismember(GN.prs.branch_ID,GN.branch.branch_ID);
        
    % active_branch
    GN.branch.active_branch = GN.branch.active_branch | GN.branch.prs_branch;
    
    % T_i - UNDER CONSTRCUTION
    if GN.isothermal == 0 && any(GN.prs.T_controlled) && any(isnan(GN.bus.T_i(GN.prs.i_out_bus(GN.prs.T_controlled))))
        i_branch = GN.branch.prs_branch & GN.prs.T_controlled(GN.branch.i_prs(GN.branch.prs_branch));
        GN.bus.T_i(GN.branch.i_to_bus(i_branch)) = GN.prs.T_ij_out(GN.prs.T_controlled);
    end
end

%% valve
if isfield(GN,'valve')
    [GN.branch.valve_branch,        GN.branch.i_valve]  = ismember(GN.branch.branch_ID,GN.valve.branch_ID);
    GN.branch.i_valve(~GN.branch.valve_branch)          = NaN;
    [~,                         GN.valve.i_branch]      = ismember(GN.valve.branch_ID,GN.branch.branch_ID);
end

%% Parallel branches
GN = get_parallel_branch(GN);

%% Bypass valves and bypass prs
if isfield(GN,'valve') && isfield(GN,'prs') && ismember('bypass_valve_ID',GN.prs.Properties.VariableNames) && ismember('bypass_prs_ID', GN.valve.Properties.VariableNames)
    GN.branch.bypass_prs_ID(:)      = NaN;
    GN.branch.i_bypass_prs(:)       = NaN;
    has_bypass_prs                  = false(size(GN.valve,1),1);
    has_bypass_prs(GN.valve.i_branch(~isnan(GN.valve.bypass_prs_ID))) = true;
    bypass_prs_ID                   = GN.valve.bypass_prs_ID(GN.branch.i_valve(has_bypass_prs));
    [idx,i_bypass_prs]              = ismember(bypass_prs_ID, GN.prs.prs_ID);
    if any(i_bypass_prs)
        i_has_bypass_prs            = find(has_bypass_prs);
        GN.branch.bypass_prs_ID(i_has_bypass_prs(idx))      = bypass_prs_ID(idx);
        GN.branch.i_bypass_prs(i_has_bypass_prs(idx))       = i_bypass_prs(idx);
    end
    
    GN.branch.bypass_valve_ID(:)    = NaN;
    GN.branch.i_bypass_valve(:)     = NaN;
    has_bypass_valve                = false(size(GN.prs,1),1);
    has_bypass_valve(GN.prs.i_branch(~isnan(GN.prs.bypass_valve_ID))) = true;
    bypass_valve_ID                 = GN.prs.bypass_valve_ID(GN.branch.i_prs(has_bypass_valve));
    [idx,i_bypass_valve]            = ismember(bypass_valve_ID, GN.valve.valve_ID);
    if any(i_bypass_valve)
        i_has_bypass_valve          = find(has_bypass_valve);
        GN.branch.bypass_valve_ID(i_has_bypass_valve(idx))  = bypass_valve_ID(idx);
        GN.branch.i_bypass_valve(i_has_bypass_valve(idx))   = i_bypass_valve(idx);
    end
end

%% Bypass prs
if isfield(GN,'prs') && ismember('bypass_prs_ID', GN.prs.Properties.VariableNames)
    GN.branch.bypass_prs_ID(:)      = NaN;
    GN.branch.i_bypass_prs(:)       = NaN;
    has_bypass_prs                  = false(size(GN.prs,1),1);
    has_bypass_prs(GN.prs.i_branch(~isnan(GN.prs.bypass_prs_ID))) = true;
    bypass_prs_ID                   = GN.prs.bypass_prs_ID(GN.branch.i_prs(has_bypass_prs));
    [idx,i_bypass_prs]              = ismember(bypass_prs_ID, GN.prs.prs_ID);
    if any(i_bypass_prs)
        i_has_bypass_prs            = find(has_bypass_prs);
        GN.branch.bypass_prs_ID(i_has_bypass_prs(idx))      = bypass_prs_ID(idx);
        GN.branch.i_bypass_prs(i_has_bypass_prs(idx))       = i_bypass_prs(idx);
    end
end

%% Associate bypass prs
if isfield(GN,'prs') && ismember('associate_prs_ID', GN.prs.Properties.VariableNames)
    GN.branch.associate_prs_ID(:)  = NaN;
    GN.branch.i_associate_prs(:)   = NaN;
    has_associate_prs              = false(size(GN.prs,1),1);
    has_associate_prs(GN.prs.i_branch(~isnan(GN.prs.associate_prs_ID))) = true;
    associate_prs_ID               = GN.prs.associate_prs_ID(GN.branch.i_prs(has_associate_prs));
    [idx,i_associate_prs]          = ismember(associate_prs_ID, GN.prs.prs_ID);
    if any(i_associate_prs)
        i_has_associate_prs        = find(has_associate_prs);
        GN.branch.associate_prs_ID(i_has_associate_prs(idx))  = associate_prs_ID(idx);
        GN.branch.i_associate_prs(i_has_associate_prs(idx))   = i_associate_prs(idx);
    end
end

end

