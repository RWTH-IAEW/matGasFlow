function [GN] = preset_optimization(GN, include_out_of_service, NUMPARAM)
%PRESET_OPTIMIZATION_V2 Summary of this function goes here
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
if nargin < 3
    NUMPARAM = getDefaultNumericalParameters;
    if nargin < 2
        include_out_of_service = false;
    end
end


%%
if include_out_of_service
    if isfield(GN,'pipe')
        GN.pipe.in_service(:) = true;
    end
    if isfield(GN,'comp')
        GN.comp.in_service(:) = true;
    end
    if isfield(GN,'prs')
        GN.prs.in_service(:) = true;
    end
    GN = check_and_init_GN(GN);
else
    GN_input = GN;
    GN = init_rungf(GN);
end

%% Calculate V_dot_n_i [m^3/s]
GN = get_V_dot_n_i(GN);

%% Delete P_th_i__MW, P_th_i, V_dot_n_i__m3_per_day, V_dot_n_i__m3_per_h or m_dot_i__kg_per_s
if ismember('P_th_i__MW',GN.bus.Properties.VariableNames)
    if abs(sum(GN.bus.P_th_i__MW))/max(abs(GN.bus.P_th_i__MW)) > 1e-2
        error(['Preset optimiziation: The sum of the supply task must be zero for steady-state simulations. sum(GN.bus.P_th_i__MW) = ',...
            num2str(sum(GN.bus.V_dot_n_i))])
    end
    GN.bus.P_th_i__MW = [];
end
if ismember('P_th_i',GN.bus.Properties.VariableNames)
    GN.bus.P_th_i = [];
end
if ismember('V_dot_n_i__m3_per_day',GN.bus.Properties.VariableNames)
    GN.bus.V_dot_n_i__m3_per_day = [];
end
if ismember('V_dot_n_i__m3_per_h',GN.bus.Properties.VariableNames)
    GN.bus.V_dot_n_i__m3_per_h = [];
end
if ismember('m_dot_i__kg_per_s',GN.bus.Properties.VariableNames)
    GN.bus.m_dot_i__kg_per_s = [];
end

%% Update slack busses
GN.bus.V_dot_n_i(GN.bus.slack_bus & GN.bus.V_dot_n_i ~= 0) = GN.bus.V_dot_n_i(GN.bus.slack_bus & GN.bus.V_dot_n_i ~= 0) - sum(GN.bus.V_dot_n_i)/sum(GN.bus.slack_bus & GN.bus.V_dot_n_i ~= 0);

%% Equality constraint
ii = [GN.branch.i_from_bus; GN.branch.i_to_bus];
jj = [1:size(GN.branch,1),1:size(GN.branch,1)];
vv = [...
    1 * ones(size(GN.branch,1),1); ...
    -1 * ones(size(GN.branch,1),1)];
nn = size(GN.bus,1);
mm = size(GN.branch,1);
Aeq = sparse(ii, jj, vv, nn, mm);
beq = -GN.bus.V_dot_n_i;

%% Single inequality constraint
ub = Inf(size(GN.branch,1),1);
lb = -Inf(size(GN.branch,1),1);
lb(GN.branch.active_branch) = 0;

%% Objective function
c = NaN(size(GN.branch,1),1);

if isfield(GN,'pipe')
    c_pipe                      = GN.pipe.L_ij./GN.pipe.D_ij.^5;
    c_pipe(~GN.pipe.in_service) = max(c_pipe)*1e3;
    c(GN.pipe.i_branch)         = c_pipe;
else
    c_pipe = 1;
end

if isfield(GN, 'comp')
    c_comp                      = 0;
    c_comp(~GN.comp.in_service) = max(c_pipe);
    c(GN.comp.i_branch)         = c_comp;
end

if isfield(GN, 'prs')
    c_prs                       = min(c_pipe) * ones(size(GN.prs,1),1);
    c_prs(~GN.prs.in_service)   = max(c_pipe);
    c(GN.prs.i_branch)          = c_prs;
end

if isfield(GN,'valve')
    c_valve                         = 0;
    c_valve(~GN.valve.in_service)   = max(c_pipe);
    c(GN.valve.i_branch)            = c_valve;
end

vvv = c;
iii = 1:length(c);
jjj = iii;
H   = sparse(iii, jjj, vvv);

%% optimization
options             = [];
options.Diagnostics = 'off';
options.Display     = 'off';
options.ConstraintTolerance = 1e-9;

[x,~,exitflag] = quadprog(H, [], [], [], Aeq, beq, lb, [], [], options);
if exitflag < 0 % UNDER CONSTRUCTION
    error('Something went wrong.')
end

%% Apply result
%  ------------

%% Check V_dot_n_ij
GN.branch.V_dot_n_ij = x;
if any(GN.branch.V_dot_n_ij(GN.branch.active_branch) < -options.ConstraintTolerance)
    error('Constraint tolerance is not satified.')
end
GN.bus.f = Aeq * GN.branch.V_dot_n_ij + GN.bus.V_dot_n_i;
if norm(GN.bus.f) > 1 % UNDER CONSTRUCTION
    %     area_ID = unique(GN.bus.area_ID);
    %     area_load = GN.MAT.area_bus * GN.bus.V_dot_n_i;
    %     exit_area_unsupplied    = find(~ismember(area_ID(area_load>0),unique(GN.bus.area_ID(GN.branch.i_to_bus(GN.branch.active_branch & GN.branch.in_service)))));
    %     entry_area_unsupplied   = find(~ismember(area_ID(area_load<0),unique(GN.bus.area_ID(GN.branch.i_from_bus(GN.branch.active_branch & GN.branch.in_service)))));
    error('Something went wrong.')
end

%% Apply V_dot_n_ij_preset
GN.branch.V_dot_n_ij_preset = GN.branch.V_dot_n_ij;

GN.branch.V_dot_n_ij_preset(~isnan(GN.branch.bypass_prs_ID)) = ...
    GN.branch.V_dot_n_ij_preset(~isnan(GN.branch.bypass_prs_ID)) ...
    - GN.branch.V_dot_n_ij_preset(GN.prs.i_branch(GN.branch.i_bypass_prs(~isnan(GN.branch.bypass_prs_ID))));

GN.branch.V_dot_n_ij_preset(~isnan(GN.branch.associate_prs_ID)) = ...
    GN.branch.V_dot_n_ij_preset(~isnan(GN.branch.associate_prs_ID)) ...
    - GN.branch.V_dot_n_ij_preset(GN.prs.i_branch(GN.branch.i_associate_prs(~isnan(GN.branch.associate_prs_ID))));

GN.branch.V_dot_n_ij_preset(GN.branch.V_dot_n_ij_preset < 0 & (~isnan(GN.branch.bypass_prs_ID) | ~isnan(GN.branch.associate_prs_ID))) = 0;

% Update V_dot_n_ij
GN.branch.V_dot_n_ij(~isnan(GN.branch.V_dot_n_ij_preset)) = GN.branch.V_dot_n_ij_preset(~isnan(GN.branch.V_dot_n_ij_preset));

%% in_service
GN.branch.in_service(:) = true;
GN.branch.in_service(GN.branch.V_dot_n_ij_preset == 0 & (~isnan(GN.branch.bypass_prs_ID) | ~isnan(GN.branch.associate_prs_ID)))   = false;
[~,i_associate_prs] = ismember(GN.branch.associate_prs_ID(~isnan(GN.branch.associate_prs_ID)), GN.branch.prs_ID);
if any(GN.branch.in_service(~isnan(GN.branch.associate_prs_ID)) & GN.branch.in_service(i_associate_prs))
    error('Something went wrong.')
end
[~,i_bypass_prs] = ismember(GN.branch.bypass_prs_ID(~isnan(GN.branch.bypass_prs_ID)), GN.branch.prs_ID);
if any(GN.branch.in_service(~isnan(GN.branch.bypass_prs_ID)) & GN.branch.in_service(i_bypass_prs))
    error('Something went wrong.')
end

%% Apply presets and in_service results
if isfield(GN, 'pipe')
    GN.pipe.V_dot_n_ij_preset   = GN.branch.V_dot_n_ij_preset(GN.pipe.i_branch);
end
if isfield(GN, 'comp')
    GN.comp.V_dot_n_ij_preset   = GN.branch.V_dot_n_ij_preset(GN.comp.i_branch);
    GN.comp.in_service          = GN.branch.in_service(GN.comp.i_branch);
end
if isfield(GN, 'prs')
    GN.prs.V_dot_n_ij_preset   = GN.branch.V_dot_n_ij_preset(GN.prs.i_branch);
    GN.prs.in_service          = GN.branch.in_service(GN.prs.i_branch);
end

%% Merge GN and GN_Input
if ~include_out_of_service
    GN = merge_GN_into_GN_input(GN, GN_input);
end

%% Check result - UNDER CONSTRUCTION:
GN = check_and_init_GN(GN);
end

