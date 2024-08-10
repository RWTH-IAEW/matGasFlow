function [GN, SUCCESS, model, result] = preset_optimization_MILP_LP(GN, opt_model, include_out_of_service_branches, keep_in_service_states, reduce_V_dot_n_ij_bounds, x_hint, x_start, solver, NUMPARAM)
%PRESET_OPTIMIZATION_PRESSURE_CONSTRAINTS Summary of this function goes here
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
if nargin < 9 || isempty(NUMPARAM)
    NUMPARAM = getDefaultNumericalParameters;
end
if nargin < 8 || isempty(solver)
    solver = 'gurobi'; % Options: 'gurobi', 'matlab'
end
if nargin < 7
    x_start = [];
end
if nargin < 6
    x_hint = [];
end
if nargin < 4 || isempty(reduce_V_dot_n_ij_bounds)
    reduce_V_dot_n_ij_bounds = false;
end
if nargin < 4 || isempty(keep_in_service_states)
    keep_in_service_states = false;
end
if nargin < 3 || isempty(include_out_of_service_branches)
    include_out_of_service_branches = true;
end
if nargin < 2 || isempty(opt_model)
    opt_model = 'MILP'; % Options: 'MILP', 'LP'
end

% %% Update p_i_max__barg
% GN.bus.p_i_max__barg = max([GN.bus.p_i_max__barg,GN.bus.p_i__barg],[],2);
if ~include_out_of_service_branches
    GN_input = GN;
end

%% get_preset_opt_model
if strcmp(opt_model,'MILP')
    [model, GN] = get_MILP_model(GN, include_out_of_service_branches, keep_in_service_states, reduce_V_dot_n_ij_bounds, NUMPARAM);
elseif strcmp(opt_model,'LP')
    [model, GN] = get_LP_model(GN, include_out_of_service_branches, reduce_V_dot_n_ij_bounds, NUMPARAM);
else
    error('opt_model must be ''MILP'' or ''LP''.')
end

%% intlinprog
if strcmp(solver,'matlab')
    options = optimoptions('Display','iter');
    [x,~,exitflag] = intlinprog(model.obj, model.i_x_b, model.A_mat, model.b_mat, model.Aeq_mat, model.beq_mat, model.lb, model.ub, [], options);
    
elseif strcmp(solver,'gurobi')
    if ~isempty(x_hint)
        model.varhintval        = x_hint;
    end
    if ~isempty(x_start)
        model.start             = x_start;
    end
    parmams = [];
    parmams.timelimit           = 300;
    parmams.SolutionLimit       = 100;
    
    result      = gurobi(model,parmams);
    %     result      = gurobi(model);
    disp(result);
    
    if ~isfield(result,'x') || isempty(result.x)
        exitflag = -1;
    elseif strcmp(result.status, 'OPTIMAL')
        x = result.x;
        exitflag = 1;
    elseif strcmp(result.status, 'TIME_LIMIT')
        x = result.x;
        exitflag = 2;
    elseif strcmp(result.status, 'SOLUTION_LIMIT')
        x = result.x;
        exitflag = 3;
    elseif isfield(result,'x') && ~isempty(result.x)
        x = result.x;
        exitflag = 0;
    else
        exitflag = -2;
    end
end

if exitflag < 0
    SUCCESS = false;
    warning('No success.')
    return
end

%% Check result
disp(['Equality constraint:    norm(Aeq*x-beq)      = ',num2str(norm(model.Aeq_mat * x - model.beq_mat))])
Axb = model.A_mat * x - model.b_mat;
Axb(Axb<0) = 0;
disp(['Inequality constraint:  norm(A*x-b, A*x-b>0) = ',num2str(norm(Axb))])
lbx = model.lb - x;
lbx(lbx<0) = 0;
disp(['Lower bound constraint: norm(lb-x, lb*x>0)   = ',num2str(norm(lbx))])
ubx = x - model.ub;
ubx(ubx<0) = 0;
disp(['Upper bound constraint: norm(x-ub, ub*x<0)   = ',num2str(norm(ubx))])
Delta_p_i = x(model.i_x_Delta_p);
result.Delta_p_i = Delta_p_i;
if any(Delta_p_i~=0)
    disp(['Number of Delta_p_i>0 : ',num2str(sum(Delta_p_i>0))])
    idx = find(Delta_p_i == min(Delta_p_i));
    idx = idx(1);
    disp(['min(Delta_p_i) = ',num2str(Delta_p_i(idx)),' barg (bus_ID: ',num2str(GN.bus.bus_ID(idx)),', area_ID: ',num2str(GN.bus.area_ID(idx)),')'])
    idx = find(Delta_p_i == max(Delta_p_i));
    idx = idx(1);
    disp(['max(Delta_p_i) = ',num2str(Delta_p_i(idx)),' barg (bus_ID: ',num2str(GN.bus.bus_ID(idx)),', area_ID: ',num2str(GN.bus.area_ID(idx)),')'])
end
%% Apply result
if strcmp(opt_model,'MILP')
    % GN.branch.in_service
    b           = x(model.i_x_b);
    b(b<0.5)    = 0;
    b(b>=0.5)   = 1;
    if keep_in_service_states
        result.bin_sitches = norm(b-model.x_start_hint(model.i_x_b))^2;
        disp(['Number of decision changes of binary variables: ',num2str(result.bin_sitches)])
    end
    
    M_1         = model.A_mat(1:model.n_comp+model.n_prs , model.n_branch+1:model.n_branch+model.n_active_branch_group);
    M_pos_neg   = M_1 * b;
    is_master   = model.is_master_prs_branch(GN.branch.active_branch) | model.is_master_comp_branch(GN.branch.active_branch);
    in_service  = NaN(sum(GN.branch.active_branch),1);
    in_service(M_pos_neg<0)                 = true;
    in_service(M_pos_neg==0 & is_master)    = false;
    in_service(M_pos_neg==0 & ~is_master)   = true;
    in_service(M_pos_neg>0)                 = false;
    
    in_service  = logical(in_service);
    GN.branch.in_service(GN.branch.active_branch) = in_service;
elseif strcmp(opt_model,'LP')
    GN.branch.G(:) = NaN;
    GN.branch.G(GN.branch.active_branch) = x(model.i_x_G);
end
    
% Correction of V_dot_n_ij
GN.branch.V_dot_n_ij                                = x(model.i_x_branch);
GN.branch.V_dot_n_ij(~GN.branch.in_service)         = 0;
% GN.branch.V_dot_n_ij(GN.branch.V_dot_n_ij<0 & GN.branch.active_branch) = 0;
% GN.branch.in_service(GN.branch.comp_branch)         = true;

% V_dot_n_ij_preset
GN.branch.V_dot_n_ij_preset                         = GN.branch.V_dot_n_ij;

if any(model.is_pipe_branch)
    GN.pipe.V_dot_n_ij          = GN.branch.V_dot_n_ij(GN.pipe.i_branch);
    GN.pipe.V_dot_n_ij_preset   = GN.pipe.V_dot_n_ij;
end
if any(model.is_comp_branch)
    GN.comp.V_dot_n_ij          = GN.branch.V_dot_n_ij(GN.comp.i_branch);
    GN.comp.V_dot_n_ij_preset   = GN.comp.V_dot_n_ij;
    GN.comp.in_service          = GN.branch.in_service(GN.comp.i_branch);
    % GN.comp.V_dot_n_ij(GN.comp.V_dot_n_ij>-1e-4 & GN.comp.V_dot_n_ij<0 & GN.comp.in_service) = 0; % UNDER CONSTRUCTION: Numerical tolerance
end
if any(model.is_prs_branch)
    GN.prs.V_dot_n_ij           = GN.branch.V_dot_n_ij(GN.prs.i_branch);
    GN.prs.V_dot_n_ij_preset    = GN.prs.V_dot_n_ij;
    GN.prs.in_service           = GN.branch.in_service(GN.prs.i_branch);
    % GN.prs.V_dot_n_ij(GN.prs.V_dot_n_ij>-1e-4 & GN.prs.V_dot_n_ij<0 & GN.prs.in_service) = 0; % UNDER CONSTRUCTION: Numerical tolerance
end

% p_i
GN.bus.p_i = x(model.i_x_p)*1e5;

if ~include_out_of_service_branches
    GN = merge_GN_into_GN_input(GN, GN_input);
end


%% Check result
GN = get_GN_res(GN);

%% Update p_i_max__barg
% GN.bus.p_i_max__barg = max([GN.bus.p_i_max__barg,GN.bus.p_i__barg],[],2);

%% SUCCESS
SUCCESS = true;

end

