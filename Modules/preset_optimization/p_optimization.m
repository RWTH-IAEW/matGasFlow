function [GN] = p_optimization(GN, NUMPARAM, PHYMOD)
%UNTITLED Summary of this function goes here
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

%% Save Input
GN_input = GN;

%% Initialization
GN = init_rungf(GN, NUMPARAM, PHYMOD);

%% Equality constraint - INC
% Incidence Matrix including branches that are out of service
ii = [GN.branch.i_from_bus; GN.branch.i_to_bus];
jj = [1:size(GN.branch,1),1:size(GN.branch,1)];
vv = [...
     1 * ones(size(GN.branch,1),1); ...
    -1 * ones(size(GN.branch,1),1)];
nn = size(GN.bus,1);
mm = size(GN.branch,1);
INC_all_branches = sparse(ii, jj, vv, nn, mm);

%% Equality constraint - G_ij
% Initialize pressure and temperature
GN = init_p_i(GN);
GN = init_T_i(GN);
GN = get_T_ij(GN);

% Update p_i dependent quantities 
GN = update_p_i_dependent_quantities(GN, PHYMOD);

% G_ij
OPTION = 2;
GN.branch.V_dot_n_ij(GN.branch.pipe_branch) = GN.pipe.V_dot_n_ij(GN.branch.i_pipe(GN.branch.pipe_branch));
GN.branch.V_dot_n_ij(GN.branch.comp_branch) = GN.comp.V_dot_n_ij(GN.branch.i_comp(GN.branch.comp_branch));
GN.branch.V_dot_n_ij(GN.branch.prs_branch)  = GN.prs.V_dot_n_ij(GN.branch.i_prs(GN.branch.prs_branch));

GN = get_G_ij(GN, OPTION, NUMPARAM);
R_ij_branch = zeros(size(GN.branch,1),1);
R_ij_branch(GN.branch.pipe_branch & GN.branch.in_service) = 1./GN.pipe.G_ij(GN.branch.i_pipe(GN.branch.pipe_branch & GN.branch.in_service));
R_ij_MAT = sparse(1:size(GN.branch,1),1:size(GN.branch,1),1./R_ij_branch);

%% Equality constraint - INC_pipe_T
INC_pipe_T = INC_all_branches;
INC_pipe_T(:,~GN.branch.pipe_branch) = 0;
INC_pipe_T = INC_pipe_T';

%% Equality constraint - Aeq, beq
Aeq = INC_pipe_T;

beq = [-GN.bus.V_dot_n_i;...
        zeros(size(GN.branch,1),1)];

%% Inequality constraint - A, b: A * x <= b
INC_prs_T = INC_all_branches;
INC_prs_T(:,~GN.branch.prs_branch) = [];
INC_prs_T = INC_prs_T';
A = -[sparse(sum(GN.branch.prs_branch),size(GN.branch,1)), INC_prs_T];
b = -1 * 1e5 * ones(sum(GN.branch.prs_branch), 1);
    
%% Single inequality constraint
ub_branch   =  Inf(size(GN.branch,1),1);
lb_branch   = -Inf(size(GN.branch,1),1);
lb_branch(GN.branch.active_branch) = 0;
lb_branch(GN.branch.active_branch) = 0;

CONST = getConstants(); % Physical constants
ub_bus      = GN.bus.p_i_max__barg*1e5 + CONST.p_n;
lb_bus      = GN.bus.p_i_min__barg*1e5 + CONST.p_n;

ub = [ub_branch; ub_bus];
lb = [lb_branch; lb_bus];

%% Objective function
c_branch = NaN(size(GN.branch,1),1);
if isfield(GN,'pipe')
    c_pipe                      = GN.pipe.L_ij./GN.pipe.D_ij.^4;
    c_pipe(~GN.pipe.in_service) = max(c_pipe)*1e3;
    c_branch(GN.pipe.i_branch)         = c_pipe;
end
if isfield(GN, 'comp')
    c_comp                      = min(c_pipe)*1-3 * ones(size(GN.comp,1),1);
    c_comp(~GN.comp.in_service) = max(c_pipe)*1e3;
    c_branch(GN.comp.i_branch)         = c_comp;
end
if isfield(GN, 'prs')
    c_prs                       = min(c_pipe)*1-3 * ones(size(GN.prs,1),1);
    %     p_i__barg                       = GN.bus.p_i__barg(GN.branch.i_from_bus(GN.prs.i_branch(~GN.prs.in_service)));
    %     p_j__barg                       = GN.bus.p_i__barg(GN.branch.i_to_bus(GN.prs.i_branch(~GN.prs.in_service)));
    %     delta_p_bypass_prs              = p_j__barg - p_i__barg;
    %     delta_p_bypass_prs_max          = max(delta_p_bypass_prs);
    %     c_prs(~GN.prs.in_service)       = mean(c_pipe).*delta_p_bypass_prs/delta_p_bypass_prs_max;
    c_branch(GN.prs.i_branch)          = c_prs;
end
if isfield(GN,'valve')
    c_valve                     = min(c_pipe)*1-3 * ones(size(GN.valve,1),1);
    c_valve(~GN.valve.in_service)    = max(c_pipe)*1e3;
    c_branch(GN.valve.i_branch)        = c_valve;
end

c_bus = ones(size(GN.bus,1),1);
% i_from_bus_prs  = GN.branch.i_from_bus(GN.branch.prs_branch);
% i_to_bus_prs    = GN.branch.i_to_bus(GN.branch.prs_branch);
% i_only_from_bus_prs = i_from_bus_prs(~ismember(i_from_bus_prs,i_to_bus_prs));
% i_only_to_bus_prs   = i_to_bus_prs(~ismember(i_to_bus_prs,i_from_bus_prs));
% c_bus(i_only_from_bus_prs)  = -1;
% c_bus(i_only_to_bus_prs)    =  1;

c = [c_branch; c_bus];
vvv = c;
iii = 1:length(c);
jjj = iii;
H   = sparse(iii, jjj, vvv);

%% optimization
options             = [];
options.Diagnostics = 'on';
options.Display     = 'on';
[x,fval,exitflag,output,lambda] = quadprog(H, [], A, b, Aeq, beq, lb, [], [], options);

%% Apply result to branches
GN.branch.V_dot_n_ij        = x(1:size(GN.branch,1));
GN.branch.V_dot_n_ij_preset = x(1:size(GN.branch,1));

GN.branch.V_dot_n_ij_preset(~isnan(GN.branch.bypass_prs_ID)) = ...
    GN.branch.V_dot_n_ij_preset(~isnan(GN.branch.bypass_prs_ID)) ...
    - GN.branch.V_dot_n_ij_preset(GN.prs.i_branch(GN.branch.i_bypass_prs(~isnan(GN.branch.bypass_prs_ID))));

GN.branch.V_dot_n_ij_preset(~isnan(GN.branch.associate_prs_ID)) = ...
    GN.branch.V_dot_n_ij_preset(~isnan(GN.branch.associate_prs_ID)) ...
    - GN.branch.V_dot_n_ij_preset(GN.prs.i_branch(GN.branch.i_associate_prs(~isnan(GN.branch.associate_prs_ID))));

GN.branch.V_dot_n_ij_preset(GN.branch.V_dot_n_ij_preset < 0 & (~isnan(GN.branch.bypass_prs_ID) | ~isnan(GN.branch.associate_prs_ID))) = 0;

GN.bus.f = INC_all_branches * GN.branch.V_dot_n_ij_preset + GN.bus.V_dot_n_i;
if norm(GN.bus.f) > 1 % UNDER CONSTRUCTION
    error('...')
end
    
if isfield(GN, 'comp')
    GN.comp.V_dot_n_ij_preset                                   = GN.branch.V_dot_n_ij_preset(GN.comp.i_branch);
    % GN.comp.V_dot_n_ij_preset(GN.comp.V_dot_n_ij_preset<1e-12)  = 0;
    % GN.comp.in_service(GN.comp.V_dot_n_ij_preset==0)            = false;
end
if isfield(GN, 'prs')
    GN.prs.V_dot_n_ij_preset                                    = GN.branch.V_dot_n_ij_preset(GN.prs.i_branch);
    % GN.prs.V_dot_n_ij_preset(GN.prs.V_dot_n_ij_preset<1e-12)    = 0;
    GN.prs.in_service(GN.prs.V_dot_n_ij_preset ~= 0)            = true;
    GN.prs.in_service(GN.prs.V_dot_n_ij_preset == 0)            = false;
end

%% Apply result to busses
GN.bus.p_i = x(size(GN.branch,1)+1:end);
GN.bus.p_i__barg = (GN.bus.p_i - CONST.p_n) * 1e-5;

%% Check result - UNDER CONSTRUCTION: 
GN = check_and_init_GN(GN);
GN.branch.V_dot_n_ij = x(1:size(GN.branch,1));

%% Prepair results
% GN = get_GN_res(GN, GN_input, flag_remove_auxiliary_variables, NUMPARAM, PHYMOD);

end


