function [GN] = preset_optimization(GN, apply_c_delta_p)
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
if nargin < 2
    apply_c_delta_p = false;
end

%% Calculate V_dot_n_i [m^3/s]
GN = get_V_dot_n_i(GN);

%% Delete P_th_i__MW, P_th_i, V_dot_n_i__m3_per_day, V_dot_n_i__m3_per_h or m_dot_i__kg_per_s
if any(strcmp('P_th_i__MW',GN.bus.Properties.VariableNames))
    if abs(sum(GN.bus.P_th_i__MW))/max(abs(GN.bus.P_th_i__MW)) > 1e-2
        error(['Preset optimiziation: The sum of the supply task must be zero for steady-state simulations. sum(GN.bus.P_th_i__MW) = ',...
            num2str(sum(GN.bus.V_dot_n_i))])
    end
    GN.bus.P_th_i__MW = [];
end
if any(strcmp('P_th_i',GN.bus.Properties.VariableNames))
    GN.bus.P_th_i = [];
end
if any(strcmp('V_dot_n_i__m3_per_day',GN.bus.Properties.VariableNames))
    GN.bus.V_dot_n_i__m3_per_day = [];
end
if any(strcmp('V_dot_n_i__m3_per_h',GN.bus.Properties.VariableNames))
    GN.bus.V_dot_n_i__m3_per_h = [];
end
if any(strcmp('m_dot_i__kg_per_s',GN.bus.Properties.VariableNames))
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
    
    p_violation = max([GN.bus.p_i__barg(GN.branch.i_from_bus(GN.branch.pipe_branch))  - GN.bus.p_i_max__barg(GN.branch.i_from_bus(GN.branch.pipe_branch)), ...
        GN.bus.p_i__barg(GN.branch.i_to_bus(GN.branch.pipe_branch))    - GN.bus.p_i_max__barg(GN.branch.i_to_bus(GN.branch.pipe_branch))],[],2);
    p_violation(p_violation < 0) = 0;
    if any(p_violation > 0)
        factor = 1 + 2 .* p_violation/max(p_violation);
        correction_c_pipe = factor(GN.branch.i_pipe(GN.branch.pipe_branch));
        c_pipe = c_pipe .* correction_c_pipe;
    end

    c(GN.pipe.i_branch)         = c_pipe;
end
if isfield(GN, 'comp')
    c_comp                      = min(c_pipe) * ones(size(GN.comp,1),1);
    c_comp(~GN.comp.in_service) = max(c_pipe)*1e3;
    c(GN.comp.i_branch)         = c_comp;
end
if isfield(GN, 'prs')
    if apply_c_delta_p
        delta_p_branch      = GN.bus.p_i__barg(GN.branch.i_from_bus) - GN.bus.p_i__barg(GN.branch.i_to_bus);
        GN.prs.delta_p(GN.branch.i_prs(GN.branch.prs_branch)) = delta_p_branch(GN.branch.prs_branch);
        c_prs               = GN.prs.delta_p;
        c_prs               = c_prs .* max(c_pipe)/max(c_prs); % ????? Warum nicht mean?!
        c_prs(c_prs < 0)    = min(c_pipe);
    else
        c_prs               = min(c_pipe)*1-3 * ones(size(GN.prs,1),1);
    end
    
    %     p_i__barg                       = GN.bus.p_i__barg(GN.branch.i_from_bus(GN.prs.i_branch(~GN.prs.in_service)));
    %     p_j__barg                       = GN.bus.p_i__barg(GN.branch.i_to_bus(GN.prs.i_branch(~GN.prs.in_service)));
    %     delta_p_bypass_prs              = p_j__barg - p_i__barg;
    %     delta_p_bypass_prs_max          = max(delta_p_bypass_prs);
    %     c_prs(~GN.prs.in_service)       = mean(c_pipe).*delta_p_bypass_prs/delta_p_bypass_prs_max;
    c(GN.prs.i_branch)          = c_prs;
end
if isfield(GN,'valve')
    c_valve                     = min(c_pipe)*1-3 * ones(size(GN.valve,1),1);
    c_valve(~GN.valve.in_service)    = max(c_pipe)*1e3;
    c(GN.valve.i_branch)        = c_valve;
end

vvv = c;
iii = 1:length(c);
jjj = iii;
H   = sparse(iii, jjj, vvv);

%% optimization
options             = [];
options.Diagnostics = 'off';
options.Display     = 'off';
x = quadprog(H, [], [], [], Aeq, beq, lb, [], [], options);

%% Apply result
GN.branch.V_dot_n_ij        = x;
GN.branch.V_dot_n_ij_preset = x;

GN.branch.V_dot_n_ij_preset(~isnan(GN.branch.bypass_prs_ID)) = ...
    GN.branch.V_dot_n_ij_preset(~isnan(GN.branch.bypass_prs_ID)) ...
    - GN.branch.V_dot_n_ij_preset(GN.prs.i_branch(GN.branch.i_bypass_prs(~isnan(GN.branch.bypass_prs_ID))));

GN.branch.V_dot_n_ij_preset(~isnan(GN.branch.associate_prs_ID)) = ...
    GN.branch.V_dot_n_ij_preset(~isnan(GN.branch.associate_prs_ID)) ...
    - GN.branch.V_dot_n_ij_preset(GN.prs.i_branch(GN.branch.i_associate_prs(~isnan(GN.branch.associate_prs_ID))));

GN.branch.V_dot_n_ij_preset(GN.branch.V_dot_n_ij_preset < 0 & (~isnan(GN.branch.bypass_prs_ID) | ~isnan(GN.branch.associate_prs_ID))) = 0;

GN.bus.f = Aeq * GN.branch.V_dot_n_ij_preset + GN.bus.V_dot_n_i;
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

%% Check result - UNDER CONSTRUCTION: 
GN = check_and_init_GN(GN);
GN.branch.V_dot_n_ij = x;

end

