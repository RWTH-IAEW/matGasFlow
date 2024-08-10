function [model, GN] = get_LP_model(GN, include_out_of_service_branches, reduce_V_dot_n_ij_bounds, NUMPARAM)
%GET_LP_MODEL Summary of this function goes here
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

if nargin < 4 || isempty(NUMPARAM)
    NUMPARAM = getDefaultNumericalParameters;
end
if nargin < 3 || isempty(reduce_V_dot_n_ij_bounds)
    reduce_V_dot_n_ij_bounds = false;
end
if nargin < 2 || isempty(include_out_of_service_branches)
    include_out_of_service_branches = true;
end

%% Calculate V_dot_n_i [m^3/s]
GN = get_V_dot_n_i(GN);

%% Update slack busses
GN = get_V_dot_n_slack(GN, 'GN', NUMPARAM);

%% Delete P_th_i__MW, P_th_i, V_dot_n_i__m3_per_day, V_dot_n_i__m3_per_h or m_dot_i__kg_per_s - UNDER CONSTRUCTION
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
	
else
    % Remove branches that are out of service
    GN = remove_branches_out_of_service(GN);
end

% Merge bypass_comp/bypass_prs to bidir_comp/bidir_prs
GN = convert_bypass2bidir(GN);

%% Quantities
V_dot_n_i   = GN.bus.V_dot_n_i;
numtol = 1e-3;
if ismember('V_dot_n_ij_preset', GN.branch.Properties.VariableNames)
    V_dot_n_ij                                      = GN.branch.V_dot_n_ij_preset;
    V_dot_n_ij(isnan(V_dot_n_ij))                   = 0;
%     V_dot_n_ij(V_dot_n_ij == 0)                     = numtol;
%     V_dot_n_ij(abs(V_dot_n_ij) < numtol)            = sign(V_dot_n_ij(abs(V_dot_n_ij) < numtol)) * numtol;
    GN.branch.V_dot_n_ij                            = V_dot_n_ij;
else
    error('This model needs V_dot_n_ij_preset values.')
end

CONST           = getConstants;
p_i__bar        = GN.bus.p_i__barg + CONST.p_n*1e-5;
p_i_min__bar    = GN.bus.p_i_min__barg + CONST.p_n*1e-5;
p_i_max__bar    = GN.bus.p_i_max__barg + CONST.p_n*1e-5;
Delta_p_ij      = p_i__bar(GN.branch.i_from_bus) - p_i__bar(GN.branch.i_to_bus);
Delta_p_ij(isnan(Delta_p_ij))           = 0;
% Delta_p_ij(Delta_p_ij == 0)             = numtol;
% Delta_p_ij(abs(Delta_p_ij) < numtol)    = sign(Delta_p_ij(abs(Delta_p_ij) < numtol)) * numtol;

%% Indices and number of elements
if isfield(GN, 'pipe')
    is_pipe_branch  = GN.branch.pipe_branch;
    i_x_pipe        = find(is_pipe_branch);
else
    is_pipe_branch  = false(size(GN.branch,1),1);
    i_x_pipe        = [];
end

if isfield(GN, 'comp')
    is_comp_branch          = GN.branch.comp_branch;
    is_unidir_comp_branch   = GN.branch.comp_branch & ~GN.branch.bidir_active_branch;
    is_bidir_comp_branch    = GN.branch.comp_branch & GN.branch.bidir_active_branch;
    i_x_comp_branch         = find(is_comp_branch);
    i_x_bidir_comp_branch   = find(is_unidir_comp_branch);
    i_x_unidir_comp_branch  = find(is_bidir_comp_branch);
else
    is_comp_branch          = false(size(GN.branch,1),1);
    is_unidir_comp_branch   = false(size(GN.branch,1),1);
    is_bidir_comp_branch    = false(size(GN.branch,1),1);
    i_x_comp_branch         = [];
    i_x_bidir_comp_branch   = [];
    i_x_unidir_comp_branch  = [];
end

if isfield(GN, 'prs')
    is_prs_branch           = GN.branch.prs_branch;
    is_unidir_prs_branch    = GN.branch.prs_branch & ~GN.branch.bidir_active_branch;
    is_bidir_prs_branch     = GN.branch.prs_branch & GN.branch.bidir_active_branch;
    i_x_prs_branch          = find(is_prs_branch);
    i_x_bidir_prs_branch    = find(is_unidir_prs_branch);
    i_x_unidir_prs_branch   = find(is_bidir_prs_branch);
else
    is_prs_branch           = false(size(GN.branch,1),1);
    is_unidir_prs_branch    = false(size(GN.branch,1),1);
    is_bidir_prs_branch     = false(size(GN.branch,1),1);
    i_x_prs_branch          = [];
    i_x_bidir_prs_branch    = [];
    i_x_unidir_prs_branch   = [];
end

n_branch                = size(GN.branch,1);
n_active_branch         = sum(GN.branch.active_branch);
n_pipe                  = sum(is_pipe_branch);
n_comp                  = sum(is_comp_branch);
n_prs                   = sum(is_prs_branch);
n_bus                   = size(GN.bus,1);

i_x_branch  = 1                                 : n_branch;
i_x_G       = n_branch+1                        : n_branch+n_active_branch;
i_x_p       = n_branch+n_active_branch+1        : n_branch+n_active_branch+n_bus;
i_x_Delta_p = n_branch+n_active_branch+n_bus+1  : n_branch+n_active_branch+2*n_bus;

%% lower and upper bound
lb_branch                           = -Inf(n_branch,1);
lb_branch(is_unidir_comp_branch)    = 0;
lb_branch(is_unidir_prs_branch)     = 0;
lb_G                                = zeros(n_branch,1);
lb_G(is_unidir_prs_branch)          = -1e12;
lb_G(is_pipe_branch)                = [];
lb_p                                = p_i_min__bar;
lb_Delta_p                          = zeros(n_bus,1);
lb                                  = [lb_branch; lb_G; lb_p; lb_Delta_p];

ub_branch                           = Inf(n_branch,1);
ub_G                                = 1e12 * ones(n_active_branch,1);
ub_p                                = Inf(n_bus,1);
ub_Delta_p                          = Inf(n_bus,1);
ub                                  = [ub_branch; ub_G; ub_p; ub_Delta_p];

%% G_ij
% V_dot_n_ij_pipe = G_ij * sqrt(p_i__bar^2 - p_j__bar^2)
if isfield(GN, 'pipe')
    % Initialize pressure and temperature
    GN = init_p_i(GN);
    GN = init_T_i(GN);
    GN = get_T_ij(GN);
    
    % Update p_i dependent quantities
    GN = update_p_i_dependent_quantities(GN);
    
    % G_ij_pipe
    OPTION      = 1;
    GN          = get_G_ij(GN, OPTION);
    G_ij_pipe   = GN.pipe.G_ij(GN.branch.i_pipe(GN.branch.pipe_branch));
    G_ij_pipe   = G_ij_pipe*1e5;
%     G_ij_pipe(G_ij_pipe < numtol) = numtol;
    OPTION      = 1;
    g_ij        = get_g_ij(GN,OPTION);
    g_ij(isnan(g_ij)) = 1;
else
    G_ij_pipe   = [];
    g_ij        = [];
end

if isfield(GN, 'comp')
    V_dot_n_ij
    G_ij_comp = -V_dot_n_ij(GN.comp.i_branch)./Delta_p_ij(GN.comp.i_branch);
    G_ij_comp(isinf(G_ij_comp) = 
%     G_ij_comp(G_ij_comp <= numtol) = numtol; %mean(G_ij_comp(G_ij_comp > 0));
else
    G_ij_comp = [];
end

if isfield(GN, 'prs')
    G_ij_prs = V_dot_n_ij(GN.prs.i_branch)./Delta_p_ij(GN.prs.i_branch);
%     G_ij_prs(G_ij_prs <= numtol) = numtol; %mean(G_ij_prs(G_ij_prs > 0));
else
    G_ij_prs = [];
end

%% Equality constraint
ii  = [GN.branch.i_from_bus; GN.branch.i_to_bus];
jj  = [1:n_branch, 1:n_branch];
vv  = [ones(n_branch,1); -ones(n_branch,1)];
INC =  sparse(ii, jj, vv, n_bus, n_branch);

ii  = GN.branch.i_from_bus;
jj  = 1:n_branch;
vv  = 1;
INC_pos = sparse(ii, jj, vv, n_bus, n_branch);

ii  = GN.branch.i_to_bus;
jj  = 1:n_branch;
vv  = 1;
INC_neg = sparse(ii, jj, vv, n_bus, n_branch);

ii                  = 1:n_branch;
jj                  = 1:n_branch;
vv                  = ones(n_branch,1);
% vv(is_pipe_branch)  = 2*abs(V_dot_n_ij(is_pipe_branch));
E_branch            = sparse(ii, jj, vv, n_branch,    n_branch);

ii                  = [i_x_comp_branch; i_x_prs_branch];
jj                  = 1:n_active_branch;
vv                  = [Delta_p_ij(i_x_comp_branch); -Delta_p_ij(i_x_prs_branch)];
E_Delta_p_ij        = sparse(ii, jj, vv, n_branch, n_active_branch);

ii                  = 1:n_branch;
jj                  = 1:n_branch;
vv                  = zeros(n_branch,1);
vv(is_pipe_branch)  = -2 * G_ij_pipe(GN.branch.i_pipe(is_pipe_branch)).^2 .* p_i__bar(GN.branch.i_from_bus(GN.pipe.i_branch));
G_pipe_i            = sparse(ii, jj, vv, n_branch, n_branch);

ii                  = 1:n_branch;
jj                  = 1:n_branch;
vv                  = zeros(n_branch,1);
vv(is_pipe_branch)  = 2 * G_ij_pipe(GN.branch.i_pipe(is_pipe_branch)).^2 .* p_i__bar(GN.branch.i_to_bus(GN.pipe.i_branch));
G_pipe_j            = sparse(ii, jj, vv, n_branch, n_branch);

ii                  = 1:n_branch;
jj                  = 1:n_branch;
vv                  = zeros(n_branch,1);
vv(is_pipe_branch)  = -g_ij(GN.branch.i_pipe(is_pipe_branch)) .* G_ij_pipe(GN.branch.i_pipe(is_pipe_branch));
G_pipe              = sparse(ii, jj, vv, n_branch, n_branch);

ii                  = 1:n_branch;
jj                  = 1:n_branch;
vv                  = zeros(n_branch,1);
vv(is_comp_branch)  = G_ij_comp(GN.branch.i_comp(is_comp_branch));
G_comp              = sparse(ii, jj, vv, n_branch, n_branch);


ii                  = 1:n_branch;
jj                  = 1:n_branch;
vv                  = zeros(n_branch,1);
if isfield(GN,'prs')
    vv(is_prs_branch)   = G_ij_prs(GN.branch.i_prs(is_prs_branch));
end
G_prs               = sparse(ii, jj, vv, n_branch, n_branch);

% G = ...
%     G_pipe_i * INC_pos' ...
%     + G_pipe_j * INC_neg' ...
%     + G_comp * INC' ...
%     + G_prs * INC';

G = ...
    G_pipe * INC' ...
    + G_comp * INC' ...
    + G_prs * INC';

Zeros_busXactBranchp        = sparse(n_bus,     n_active_branch);
Zeros_busXbus               = sparse(n_bus,     n_bus);
Zeros_branchXbus            = sparse(n_branch,  n_bus);

Aeq = [ INC,        Zeros_busXactBranchp,   Zeros_busXbus,  Zeros_busXbus; ...
        E_branch,   E_Delta_p_ij,           G,              Zeros_branchXbus];

beq_bus     = -V_dot_n_i;
beq_branch  = NaN(n_branch,1);
beq_branch(is_pipe_branch) = 0;
% beq_branch(is_pipe_branch) = ...
%     abs(V_dot_n_ij(is_pipe_branch)) .* V_dot_n_ij(is_pipe_branch) ...
%     - G_ij_pipe(GN.branch.i_pipe(is_pipe_branch)).^2 ...
%     .* (p_i__bar(GN.branch.i_from_bus(GN.pipe.i_branch)).^2 - p_i__bar(GN.branch.i_to_bus(GN.pipe.i_branch)).^2);

beq_branch(is_comp_branch) = ...
    G_ij_comp(GN.branch.i_comp(is_comp_branch)) .* Delta_p_ij(is_comp_branch);
if isfield(GN,'prs')
    beq_branch(is_prs_branch) = ...
        G_ij_prs(GN.branch.i_prs(is_prs_branch)) .* Delta_p_ij(is_prs_branch);
end

beq = [ beq_bus; beq_branch];

%% Inequality constraint
E_bus                   = sparse(1:n_bus,   1:n_bus,    1);
Zeros_busXbranch        = sparse(n_bus,     n_branch);
Zeros_busXactBranch     = sparse(n_bus,     n_active_branch);

A = [Zeros_busXbranch, Zeros_busXactBranch, E_bus, -E_bus];
b = p_i_max__bar;

%% Cost function
f_V                                                 = zeros(n_branch,1);
f_V(is_comp_branch)                                 = 1;
f_V(is_unidir_prs_branch)                           = 1;
f_G                                                 = zeros(n_active_branch,1);
f_p                                                 = zeros(n_bus,1);
% f_p(GN.branch.i_from_bus(GN.branch.comp_branch))    = -1;
f_p(GN.branch.i_to_bus(GN.branch.comp_branch))      = 1;
% f_p                                                 = -1*ones(n_bus,1);
f_Delta_p                                           = 1e6 * ones(n_bus,1);

f = [f_V; f_G; f_p; f_Delta_p];

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

% matlab
model.A_mat                 = A;
model.b_mat                 = b;
model.Aeq_mat               = Aeq;
model.beq_mat               = beq;

% x_start_hint
% model.x_start_hint = x_start_hint;

% indices
model.i_x_branch            = i_x_branch;
model.i_x_pipe              = i_x_pipe;
model.i_x_comp_branch       = i_x_comp_branch;
model.i_x_bidir_comp_branch = i_x_bidir_comp_branch;
model.i_x_unidir_comp_branch= i_x_unidir_comp_branch;
model.i_x_prs_branch        = i_x_prs_branch;
model.i_x_bidir_prs_branch  = i_x_bidir_prs_branch;
model.i_x_unidir_prs_branch = i_x_unidir_prs_branch;
model.i_x_G                 = i_x_G;
model.i_x_p                 = i_x_p;
model.i_x_Delta_p           = i_x_Delta_p;
model.n_branch              = n_branch;
model.n_pipe                = n_pipe;
model.n_comp                = n_comp;
model.n_prs                 = n_prs;
model.n_active_branch       = n_active_branch;
model.n_bus                 = n_bus;
model.is_pipe_branch        = is_pipe_branch;
model.is_comp_branch        = is_comp_branch;
model.is_unidir_comp_branch = is_unidir_comp_branch;
model.is_bidir_comp_branch  = is_bidir_comp_branch;
model.is_prs_branch         = is_prs_branch;
model.is_unidir_prs_branch  = is_unidir_prs_branch;
model.is_bidir_prs_branch   = is_bidir_prs_branch;
model.in_service_branch     = in_service_branch;

end

