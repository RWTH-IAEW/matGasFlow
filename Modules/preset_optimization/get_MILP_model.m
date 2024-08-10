function [model, GN] = get_MILP_model(GN, include_out_of_service_branches, keep_in_service_states, reduce_V_dot_n_ij_bounds, NUMPARAM)
%GET_MILP_MODEL
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 5 || isempty(NUMPARAM)
    NUMPARAM = getDefaultNumericalParameters;
end
if nargin < 4 || isempty(reduce_V_dot_n_ij_bounds)
    reduce_V_dot_n_ij_bounds = false;
end
if nargin < 3 || isempty(keep_in_service_states)
    keep_in_service_states = false;
end
if nargin < 2 || isempty(include_out_of_service_branches)
    include_out_of_service_branches = true;
end

%% Calculate V_dot_n_i [m^3/s]
GN = get_V_dot_n_i(GN);

%% Update slack busses
GN = get_V_dot_n_slack(GN, 'GN', NUMPARAM);

%% Delete P_th_i__MW, P_th_i, V_dot_n_i__m3_per_day, V_dot_n_i__m3_per_h or m_dot_i__kg_per_s - TODO
if ismember('P_th_i__MW',GN.bus.Properties.VariableNames)
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

%% Include branches that are out of service?
in_service_branch = GN.branch.in_service;

if include_out_of_service_branches
    % Set all branches in service
    if isfield(GN,'pipe')
        GN.pipe.in_service(:)   = true;
    end
    if isfield(GN,'comp')
        GN.comp.in_service(:)   = true;
    end
    if isfield(GN,'prs')
        GN.prs.in_service(:)    = true;
    end
    GN.branch.in_service(:)     = true;
    
    % Inititialize indecies
    GN = init_GN_indices(GN);
    
    % Check area restrictions
    GN = check_GN_area_restrictions(GN);
    
else
    % Remove branches that are out of service
    GN = remove_branches_out_of_service(GN);
end

%% Quantities
V_dot_n_i   = GN.bus.V_dot_n_i;

if ismember('V_dot_n_ij', GN.branch.Properties.VariableNames)
    V_dot_n_ij  = GN.branch.V_dot_n_ij;
else
    V_dot_n_ij  = zeros(size(GN.branch,1),1);
end

CONST           = getConstants;
p_i_min__bar    = GN.bus.p_i_min__barg + CONST.p_n*1e-5;
p_i_max__bar    = GN.bus.p_i_max__barg + CONST.p_n*1e-5;

%% Big M
M = max([V_dot_n_i*1e1; V_dot_n_ij*1e1; p_i_max__bar*1e1]);

%% Indices and number of elements
if isfield(GN, 'pipe')
    is_pipe_branch  = GN.branch.pipe_branch;
else
    is_pipe_branch  = false(size(GN.branch,1),1);
end

if isfield(GN, 'comp')
    is_comp_branch          = GN.branch.comp_branch;
    is_master_comp_branch   = GN.branch.comp_branch;
    
    if ismember('bypass_comp_ID', GN.branch.Properties.VariableNames)
        has_bypass_comp_branch  = ~isnan(GN.branch.bypass_comp_ID);
        bypass_comp_IDs_temp    = [GN.branch.comp_ID(has_bypass_comp_branch), GN.branch.bypass_comp_ID(has_bypass_comp_branch)];
        bypass_comp_IDs         = unique(sort(bypass_comp_IDs_temp,2),'rows');
        is_bypass_comp_branch   = ismember(GN.branch.comp_ID,bypass_comp_IDs(:,2));
    else
        is_bypass_comp_branch   = false(size(GN.branch,1),1);
    end
    
    is_master_comp_branch(is_bypass_comp_branch) = false;
    
else
    is_comp_branch          = false(size(GN.branch,1),1);
    is_master_comp_branch   = false(size(GN.branch,1),1);
    is_bypass_comp_branch   = false(size(GN.branch,1),1);
end

if isfield(GN, 'prs')
    is_prs_branch           = GN.branch.prs_branch;
    is_master_prs_branch    = GN.branch.prs_branch;
    
    if ismember('bypass_prs_ID', GN.branch.Properties.VariableNames)
        has_bypass_prs_branch   = ~isnan(GN.branch.bypass_prs_ID);
        bypass_prs_IDs_temp     = [GN.branch.prs_ID(has_bypass_prs_branch), GN.branch.bypass_prs_ID(has_bypass_prs_branch)];
        bypass_prs_IDs          = unique(sort(bypass_prs_IDs_temp,2),'rows');
        is_bypass_prs_branch    = ismember(GN.branch.prs_ID,bypass_prs_IDs(:,2));
    else
        is_bypass_prs_branch    = false(size(GN.branch,1),1);
    end
    
    if ismember('associate_prs_ID', GN.branch.Properties.VariableNames)
        has_associate_prs_branch    = ~isnan(GN.branch.associate_prs_ID);
        associate_prs_IDs_temp      = [GN.branch.prs_ID(has_associate_prs_branch), GN.branch.associate_prs_ID(has_associate_prs_branch)];
        associate_prs_IDs           = unique(sort(associate_prs_IDs_temp,2),'rows');
        is_associate_prs_branch     = ismember(GN.branch.prs_ID,associate_prs_IDs(:,2));
    else
        is_associate_prs_branch     = false(size(GN.branch,1),1);
    end
    
    is_master_prs_branch(is_bypass_prs_branch | is_associate_prs_branch) = false;
    
else
    is_prs_branch           = false(size(GN.branch,1),1);
    is_master_prs_branch    = false(size(GN.branch,1),1);
    is_bypass_prs_branch    = false(size(GN.branch,1),1);
    is_associate_prs_branch = false(size(GN.branch,1),1);
end

n_branch                    = size(GN.branch,1);
n_pipe                      = sum(is_pipe_branch);
n_comp                      = sum(is_comp_branch);
n_prs                       = sum(is_prs_branch);
n_active_branch             = sum(GN.branch.active_branch);
n_active_branch_group       = sum(is_master_comp_branch | is_master_prs_branch);
n_bus                       = size(GN.bus,1);

i_x_branch                  = 1 : n_branch;
i_x_b                       = n_branch+1 : n_branch+n_active_branch_group;
i_x_p                       = n_branch+n_active_branch_group+1 : n_branch+n_active_branch_group+n_bus;
i_x_Delta_p                 = n_branch+n_active_branch_group+n_bus+1 : n_branch+n_active_branch_group+2*n_bus;

%% lower and upper bound
lb_branch                       = NaN(n_branch,1);
if ~reduce_V_dot_n_ij_bounds
    lb_branch(is_pipe_branch)   = -Inf;
else
    lb_branch(is_pipe_branch & V_dot_n_ij==0)  = -Inf;
    lb_branch(is_pipe_branch & V_dot_n_ij>0)   = V_dot_n_ij(is_pipe_branch & V_dot_n_ij>0) * 0.1;
    lb_branch(is_pipe_branch & V_dot_n_ij<0)   = V_dot_n_ij(is_pipe_branch & V_dot_n_ij<0) * 1.9;
end
lb_branch(is_comp_branch)       = 0;
lb_branch(is_prs_branch)        = 0;
lb_b                            = zeros(n_active_branch_group,1);
lb_p                            = p_i_min__bar;
lb_Delta_p                      = zeros(n_bus,1);
lb                              = [lb_branch; lb_b; lb_p; lb_Delta_p];

ub_branch                       = Inf(n_branch,1);
if reduce_V_dot_n_ij_bounds
    ub_branch(is_pipe_branch & V_dot_n_ij>0)   = V_dot_n_ij(is_pipe_branch & V_dot_n_ij>0) * 1.9;
    ub_branch(is_pipe_branch & V_dot_n_ij<0)   = V_dot_n_ij(is_pipe_branch & V_dot_n_ij<0) * 0.1;
end
ub_b                            = ones(n_active_branch_group,1);
ub_p                            = Inf(n_bus,1);
ub_Delta_p                      = Inf(n_bus,1);
ub                              = [ub_branch; ub_b; ub_p; ub_Delta_p];

if reduce_V_dot_n_ij_bounds
    
    
end
%% Pipe quantities: g_ij and G_ij
if isfield(GN, 'pipe')
    % Initialize pressure and temperature
    GN = init_p_i(GN);
    GN = init_T_i(GN);
    GN = get_T_ij(GN);
    
    % Update p_i dependent quantities
    GN = update_p_i_dependent_quantities(GN, NUMPARAM, PHYMOD);
    
    if ismember('V_dot_n_ij', GN.branch.Properties.VariableNames)
        GN.branch.V_dot_n_ij(isnan(GN.branch.V_dot_n_ij)) = 0;
    end
    
    % g_ij*G_ij
    g_ij_0 = 5; % 1.925
    if ~ismember('V_dot_n_ij', GN.branch.Properties.VariableNames) || any(isnan(GN.branch.V_dot_n_ij)) || all(GN.branch.V_dot_n_ij==0)
        GN.branch.V_dot_n_ij(:) = max(GN.bus.V_dot_n_i(GN.bus.V_dot_n_i ~= 0));
        g_ij = g_ij_0;
    else
        OPTION = 1; % sqrt(p_i^2 - p_j^2) / (p_i - p_j) [-]; OPTION = 2; % sqrt(p_i^2 - p_j^2) / (p_i^2 - p_j^2) [1/Pa]
        g_ij = get_g_ij(GN, OPTION);
        g_ij(isnan(g_ij)) = 1; max(g_ij);
    end
    OPTION  = 1;
    GN      = get_G_ij(GN, OPTION);
    G_ij    = GN.pipe.G_ij(GN.branch.i_pipe(GN.branch.pipe_branch));
    G_ij    = G_ij*1e5;
else
    g_ij = [];
    G_ij = [];
end

%% Equality constraint
ii  = [GN.branch.i_from_bus; GN.branch.i_to_bus];
jj  = [1:n_branch, 1:n_branch];
vv  = [ones(n_branch,1); -ones(n_branch,1)];
INC =  sparse(ii, jj, vv, n_bus, n_branch);

ii  = [GN.branch.i_from_bus(is_pipe_branch); GN.branch.i_to_bus(is_pipe_branch)];
jj  = [1:n_pipe, 1:n_pipe];
vv  = [ones(n_pipe,1); -ones(n_pipe,1)];
INC_pipe = sparse(ii, jj, vv, n_bus, n_pipe);

ii      = 1:n_pipe;
jj      = find(is_pipe_branch);
vv      = 1;
E_pipe  = sparse(ii, jj, vv, n_pipe,    n_branch);

E_G     = sparse(1:n_pipe,  1:n_pipe,   g_ij.*G_ij(GN.branch.i_pipe(GN.branch.pipe_branch)));

Zeros_busXactBranchGroup    = sparse(n_bus,     n_active_branch_group);
Zeros_busXbus               = sparse(n_bus,     n_bus);
Zeros_pipeXbus              = sparse(n_pipe,    n_bus);
Zeros_pipeXactBranchGroup   = sparse(n_pipe,    n_active_branch_group);

Aeq = [ INC,                Zeros_busXactBranchGroup,   Zeros_busXbus,  Zeros_busXbus; ...
        E_pipe,             Zeros_pipeXactBranchGroup,  -E_G*INC_pipe', Zeros_pipeXbus];

beq = [ -V_dot_n_i;...
    zeros(n_pipe,1)];

%% Inequality constraint
E_branch                    = sparse(eye(n_branch, n_branch));
E_branch(is_pipe_branch,:)  = [];

i_master_comp = find(is_master_comp_branch);
i_bypass_comp = find(is_bypass_comp_branch);
if ismember('bypass_comp_ID', GN.branch.Properties.VariableNames)
    i_master_of_bypass_comp = GN.comp.i_branch(GN.branch.i_bypass_comp(is_bypass_comp_branch));
else
    i_master_of_bypass_comp = [];
end

i_master_prs = find(is_master_prs_branch);
i_bypass_prs = find(is_bypass_prs_branch);
if ismember('bypass_prs_ID', GN.branch.Properties.VariableNames)
    i_master_of_bypass_prs = GN.prs.i_branch(GN.branch.i_bypass_prs(is_bypass_prs_branch));
else
    i_master_of_bypass_prs = [];
end
i_associate_prs = find(is_associate_prs_branch);
if ismember('associate_prs_ID', GN.branch.Properties.VariableNames)
    i_master_of_associate_prs = GN.prs.i_branch(GN.branch.i_associate_prs(is_associate_prs_branch));
else
    i_master_of_associate_prs = [];
end

ii = [i_master_comp; ...
    i_bypass_comp; ...
    i_master_prs; ...
    i_bypass_prs; ...
    i_associate_prs];
jj = [i_master_comp; ...
    i_master_of_bypass_comp; ...
    i_master_prs; ...
    i_master_of_bypass_prs; ...
    i_master_of_associate_prs];
vv = [-M * ones(sum(is_master_comp_branch),1);...
    M * ones(sum(is_bypass_comp_branch),1);...
    -M * ones(sum(is_master_prs_branch),1);...
    M * ones(sum(is_bypass_prs_branch),1);...
    M * ones(sum(is_associate_prs_branch),1)];
M_1 = sparse(ii, jj, vv, n_branch, n_branch);
M_1(:,~is_master_comp_branch & ~is_master_prs_branch)   = [];
M_1(is_pipe_branch,:)                                   = [];

M_2 = -M_1;

ii = [GN.branch.i_from_bus(~is_pipe_branch); GN.branch.i_to_bus(~is_pipe_branch)];
jj = [1:n_comp+n_prs, 1:n_comp+n_prs];
vv = [ones(n_comp+n_prs,1); -ones(n_comp+n_prs,1)];
INC_act_branch = sparse(ii, jj, vv, n_bus, n_comp+n_prs);
INC_act_branch(:,is_prs_branch(GN.branch.active_branch)) = -INC_act_branch(:,is_prs_branch(GN.branch.active_branch));

E_bus = sparse(1:n_bus,   1:n_bus,    1);

Zeros_busXbranch        = sparse(n_bus,     n_branch);
Zeros_actBranchXbus     = sparse(n_comp+n_prs,  n_bus);
Zeros_actBranchXbranch  = sparse(n_comp+n_prs,  n_branch);

A = [E_branch,              M_1,                        Zeros_actBranchXbus,    Zeros_actBranchXbus;    ...
    Zeros_actBranchXbranch, M_2,                        INC_act_branch',        Zeros_actBranchXbus;    ...
    Zeros_busXbranch,       Zeros_busXactBranchGroup,   E_bus,                  -E_bus                  ];

b_1                             = NaN(n_branch,1);
b_1(is_master_comp_branch)      = 0;
b_1(is_bypass_comp_branch)      = M;
b_1(is_master_prs_branch)       = 0;
b_1(is_bypass_prs_branch)       = M;
b_1(is_associate_prs_branch)    = M;
b_1(is_pipe_branch)             = [];

epsilon_Delta_p                 = 0;
b_2                             = NaN(n_branch,1);
b_2(is_master_comp_branch)      = M - epsilon_Delta_p;
b_2(is_bypass_comp_branch)      =   - epsilon_Delta_p;
b_2(is_master_prs_branch)       = M - epsilon_Delta_p;
b_2(is_bypass_prs_branch)       =   - epsilon_Delta_p;
b_2(is_associate_prs_branch)    =   - epsilon_Delta_p;
b_2(is_pipe_branch)             = [];

b = [b_1;           ...
    b_2;
    p_i_max__bar    ];

%% x_start_hint
bin         = in_service_branch(is_master_comp_branch | is_master_prs_branch);
CONST       = getConstants;
p_i__bar    = GN.bus.p_i__barg + CONST.p_n;

Delta_p__bar    = GN.bus.p_i__barg - GN.bus.p_i_max__barg;
Delta_p__bar(Delta_p__bar < 0) = 0;

x_start_hint    = [V_dot_n_ij; bin; p_i__bar; Delta_p__bar];

%% Cost function
f_V                 = NaN(n_branch,1);
f_V(is_pipe_branch) = 0;
f_V(is_comp_branch) = 1;
f_V(is_prs_branch)  = 0;
f_b                 = zeros(n_active_branch_group,1);
i_active_branch     = find(GN.branch.active_branch);
[~,i_b_comp]        = ismember(i_master_comp,i_active_branch);
f_b(i_b_comp)       = -1;
if keep_in_service_states
    f_b(bin == 1)   = -1*1e5;
    f_b(bin == 0)   =  1*1e5;
end
f_p                 = zeros(n_bus,1);
f_p(GN.branch.i_from_bus(GN.branch.comp_branch))    = -1;
f_p(GN.branch.i_to_bus(GN.branch.comp_branch))      = -1;
f_Delta_p           = 1e4 * ones(n_bus,1);

f                   = [f_V; f_b; f_p; f_Delta_p];
% f                   = f .* (1+1e-3*rand(size(f))); % Noise

%% Model
model.obj                   = f;
model.lb                    = lb;
model.ub                    = ub;

% gurobi
model.A                     = [A; Aeq; -Aeq];
model.rhs                   = [b; beq; -beq];
FF_max                      = full(max(abs(model.A),[],2));
FF_max(FF_max == 0)         = 1;
FF_min                      = full(min(abs(model.A),[],2));
FF_min(FF_min == 0)         = 1;
model.FF                    = FF_min .* sqrt(FF_max./FF_min);
model.A                     = model.A./model.FF;
model.rhs                   = model.rhs./model.FF;
model.sense                 = repmat('=', 1, length(model.rhs));
model.sense(1:size(A,1))    = '<';
model.vtype                 = repmat('C', 1, length(f));
model.vtype(i_x_b)          = 'B';

% matlab
model.A_mat                 = A;
model.b_mat                 = b;
model.Aeq_mat               = Aeq;
model.beq_mat               = beq;

% x_start_hint
model.x_start_hint = x_start_hint;

% indices
model.i_x_branch            = i_x_branch;
model.i_x_b                 = i_x_b;
model.i_x_p                 = i_x_p;
model.i_x_Delta_p           = i_x_Delta_p;
model.n_branch              = n_branch;
model.n_pipe                = n_pipe;
model.n_comp                = n_comp;
model.n_prs                 = n_prs;
model.n_active_branch_group = n_active_branch_group;
model.n_bus                 = n_bus;
model.is_pipe_branch        = is_pipe_branch;
model.is_comp_branch        = is_comp_branch;
model.is_prs_branch         = is_prs_branch;
model.is_master_comp_branch = is_master_comp_branch;
model.is_master_prs_branch  = is_master_prs_branch;


% model.i_x_pipe              = i_x_pipe;
% model.i_x_comp_branch       = i_x_comp_branch;
model.n_active_branch       = n_active_branch;
% model.in_service_branch     = in_service_branch;

% Big M
model.M                     = M;

end

