function [GN] = init_GN_indices(GN)
%INIT_GN_INDICES
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2021, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Get numerical tolerance
NUMPARAM = getDefaultNumericalParameters;

%% bus
% Reset
if any(strcmp('p_bus',GN.bus.Properties.VariableNames))
    GN.bus.p_bus(~GN.bus.slack_bus) = false;
end
if any(strcmp('f_0_bus',GN.bus.Properties.VariableNames))
    GN.bus.f_0_bus(~GN.bus.slack_bus) = false;
end

if ~any(strcmp('T_i',GN.bus.Properties.VariableNames))
    GN.bus.T_i = NaN(size(GN.bus,1),1);
    GN.bus = movevars(GN.bus,'T_i','After','p_i__barg');
end

%% branch
% from/to
[~,GN.branch.i_from_bus] = ismember(GN.branch.from_bus_ID,GN.bus.bus_ID);
[~,GN.branch.i_to_bus]   = ismember(GN.branch.to_bus_ID,GN.bus.bus_ID);
GN.branch = movevars(GN.branch,'i_from_bus','After','to_bus_ID');
GN.branch = movevars(GN.branch,'i_to_bus','After','i_from_bus');

% Connecting branches (if-query necessary for NUMPARAM.OPTION_get_J = 2)
if sum(GN.bus.slack_bus) == 1 && ~any(strcmp('connecting_branch',GN.branch.Properties.VariableNames))
    GN = get_connecting_branch(GN);
end

% Parallel branches
GN = get_parallel_branch(GN);

%% pipe
if isfield(GN,'pipe')
    [GN.branch.pipe_branch, GN.branch.i_pipe] = ismember(GN.branch.branch_ID,GN.pipe.branch_ID);
    GN.branch.i_pipe(~GN.branch.pipe_branch) = NaN;
    GN.branch = movevars(GN.branch,'pipe_branch','After','in_service');
    GN.branch = movevars(GN.branch,'i_pipe','After','pipe_branch');
    
    % i_branch
    [~, GN.pipe.i_branch] = ismember(GN.pipe.branch_ID,GN.branch.branch_ID);
    GN.pipe = movevars(GN.pipe,'i_branch','After','branch_ID');
    
    % section_ID
    max_bus_ID = max(GN.pipe.from_bus_ID,GN.pipe.to_bus_ID);
    min_bus_ID = min(GN.pipe.from_bus_ID,GN.pipe.to_bus_ID);
    [~,~,GN.pipe.section_ID] = unique([max_bus_ID,min_bus_ID],'rows');
else
    % Initialize pipe_branch, if GN has no pipe;
    GN.branch.pipe_branch = false(size(GN.branch,1),1);
end


%% comp
if isfield(GN,'comp')
    [GN.branch.comp_branch,     GN.branch.i_comp]   = ismember(GN.branch.branch_ID,GN.comp.branch_ID);
    GN.branch.i_comp(~GN.branch.comp_branch)        = NaN;
    [~,                         GN.comp.i_branch]   = ismember(GN.comp.branch_ID,GN.branch.branch_ID);
    [~,                         GN.comp.i_out_bus]  = ismember(GN.branch.to_bus_ID(GN.comp.i_branch),GN.bus.bus_ID);
    [GN.bus.comp_out_bus,       GN.bus.i_comp_out]  = ismember(GN.bus.bus_ID,GN.branch.to_bus_ID(GN.branch.comp_branch));
    
    if isfield(GN,'pipe')
        GN.branch = movevars(GN.branch,'comp_branch','After','i_pipe');
    else
        GN.branch = movevars(GN.branch,'comp_branch','After','in_service');
    end
    GN.branch = movevars(GN.branch,'i_comp','After','comp_branch');
    
    % p_bus, f_0_bus
    GN.bus.p_bus = GN.bus.p_bus | GN.bus.comp_out_bus;
    GN.bus.f_0_bus = GN.bus.f_0_bus | GN.bus.comp_out_bus;
    
    % Set p_i at comp output and
    p_i__barg_comp_out = GN.comp.p_out__barg;
    p_i__barg_bus = GN.bus.p_i__barg(GN.comp.i_out_bus);
    GN.bus.p_i__barg( GN.comp.i_out_bus(isnan(p_i__barg_bus)) ) = GN.comp.p_out__barg(isnan(p_i__barg_bus));
    
    % check for conflicts between GN.bus.p_i__barg and GN.comp.p_out__barg
    p_conflict = (GN.bus.p_i__barg(GN.comp.i_out_bus) - p_i__barg_comp_out) > NUMPARAM.numericalTolerance;
    if any( p_conflict)
        GN.bus.p_i__barg(GN.comp.i_out_bus) = GN.comp.p_out__barg;
        warning(['Conflict between pressure values of GN.bus.p_i__barg and GN.comp.p_out__barg. The latter is preverably used. Check bus_IDs: ',num2str(GN.comp.i_out_bus(p_conflict))])
    end
    
    % T_i
    if GN.isothermal == 0 && any(GN.comp.T_controlled) && any(isnan(GN.bus.T_i(GN.comp.i_out_bus(GN.comp.T_controlled))))
        GN.bus.T_i(GN.comp.i_out_bus(GN.comp.T_controlled)) = GN.comp.T_to_bus(GN.comp.T_controlled);
    end
    
    % i_branch
    [~, GN.comp.i_branch] = ismember(GN.comp.branch_ID,GN.branch.branch_ID);
    GN.comp = movevars(GN.comp,'i_branch','After','branch_ID');
end

%% prs
if isfield(GN,'prs')
    [GN.branch.prs_branch,      GN.branch.i_prs]    = ismember(GN.branch.branch_ID,GN.prs.branch_ID);
    GN.branch.i_prs(~GN.branch.prs_branch)          = NaN;
    [~,                         GN.prs.i_branch]    = ismember(GN.prs.branch_ID,GN.branch.branch_ID);
    [~,                         GN.prs.i_out_bus]   = ismember(GN.branch.to_bus_ID(GN.prs.i_branch),GN.bus.bus_ID);
    [GN.bus.prs_out_bus,        GN.bus.i_prs_out]   = ismember(GN.bus.bus_ID,GN.branch.to_bus_ID(GN.branch.prs_branch));
    
    if isfield(GN,'pipe')
        GN.branch = movevars(GN.branch,'prs_branch','After','i_pipe');
    elseif isfield(GN,'comp')
        GN.branch = movevars(GN.branch,'prs_branch','After','i_comp');
    else
        GN.branch = movevars(GN.branch,'prs_branch','After','in_service');
    end
    GN.branch = movevars(GN.branch,'i_prs','After','prs_branch');
    
    % p_bus, f_0_bus
    GN.bus.p_bus = GN.bus.p_bus | GN.bus.prs_out_bus;
    GN.bus.f_0_bus = GN.bus.f_0_bus | GN.bus.prs_out_bus;
    
    % Set p_i at comp output and
    p_i__barg_prs_out = GN.prs.p_out__barg;
    p_i__barg_bus = GN.bus.p_i__barg(GN.prs.i_out_bus);
    GN.bus.p_i__barg( GN.prs.i_out_bus(isnan(p_i__barg_bus)) ) = GN.prs.p_out__barg(isnan(p_i__barg_bus));
    
    % check for conflicts between GN.bus.p_i__barg and GN.prs.p_out__barg
    p_conflict = (GN.bus.p_i__barg(GN.prs.i_out_bus) - p_i__barg_prs_out) > NUMPARAM.numericalTolerance;
    if any( p_conflict)
        GN.bus.p_i__barg(GN.prs.i_out_bus) = GN.prs.p_out__barg;
        warning(['Conflict between pressure values of GN.bus.p_i__barg and GN.prs.p_out__barg. The latter is preverably used. Check bus_IDs: ',num2str(GN.comp.i_out_bus(p_conflict))])
    end
    
    % T_i
    if GN.isothermal == 0 && any(isnan(GN.bus.T_i(GN.prs.i_out_bus(GN.prs.T_controlled))))
        GN.bus.T_i(GN.prs.i_out_bus(GN.prs.T_controlled)) = GN.prs.T_to_bus(GN.prs.T_controlled);
    end
    
    % i_branch
    [~, GN.prs.i_branch] = ismember(GN.prs.branch_ID,GN.branch.branch_ID);
    GN.prs = movevars(GN.prs,'i_branch','After','branch_ID');
end

%% valve
if isfield(GN,'valve')
    [GN.branch.valve_branch,        GN.branch.i_valve]  = ismember(GN.branch.branch_ID,GN.valve.branch_ID);
    GN.branch.i_valve(~GN.branch.valve_branch)          = NaN;
    [~,                             GN.valve.i_branch]  = ismember(GN.valve.branch_ID,GN.branch.branch_ID);
    [~,                             GN.valve.i_out_bus] = ismember(GN.branch.to_bus_ID(GN.valve.i_branch),GN.bus.bus_ID);
    [GN.bus.valve_out_bus,          GN.bus.i_valve_out] = ismember(GN.bus.bus_ID,GN.branch.to_bus_ID(GN.branch.valve_branch));
    
    if isfield(GN,'pipe')
        GN.branch = movevars(GN.branch,'valve_branch','After','i_pipe');
    elseif isfield(GN,'comp')
        GN.branch = movevars(GN.branch,'valve_branch','After','i_comp');
    else
        GN.branch = movevars(GN.branch,'valve_branch','After','in_service');
    end
    GN.branch = movevars(GN.branch,'i_valve','After','valve_branch');
    
    % p_bus, f_0_bus
    GN.bus.p_bus = GN.bus.p_bus | GN.bus.valve_out_bus;
    GN.bus.f_0_bus = GN.bus.f_0_bus | GN.bus.valve_out_bus;
    
    % i_branch
    [~, GN.valve.i_branch] = ismember(GN.valve.branch_ID,GN.branch.branch_ID);
    GN.valve = movevars(GN.valve,'i_branch','After','branch_ID');
end
end

