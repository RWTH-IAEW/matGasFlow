function [GN] = get_V_dot_n_slack(GN, f_mode, NUMPARAM, noWarning)
%GET_V_DOT_N_SLACK
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

if nargin < 4
    noWarning = false;
end
if nargin < 3
    NUMPARAM = getDefaultNumericalParameters;
end

%%
has_dynamic_busses = false;
if isfield(GN,'comp') && ismember('V_dot_n_i_comp', GN.comp.Properties.VariableNames)
    has_dynamic_busses = has_dynamic_busses | any(GN.comp.V_dot_n_i_comp ~= 0);
end
if isfield(GN,'prs') && ismember('V_dot_n_i_prs', GN.prs.Properties.VariableNames)
    has_dynamic_busses = has_dynamic_busses | any(GN.prs.V_dot_n_i_prs ~= 0);
end
    
if strcmp(f_mode,'GN')
    % Devide missing demand/feed-in among all busses with demand/feed-in ~= 0
    
    % TODO
    %     if ~noWarning && abs(sum(GN.bus.V_dot_n_i)) > NUMPARAM.epsilon_norm_f && ~has_dynamic_busses
    %         warning('Entries and exits are not balanced. V_dot_n_i of the slack busses have been updated.')
    %     end
       
    if any(GN.bus.V_dot_n_i(GN.bus.slack_bus) ~= 0)
        GN.bus.V_dot_n_i(GN.bus.slack_bus & GN.bus.V_dot_n_i ~= 0) = ...
            GN.bus.V_dot_n_i(GN.bus.slack_bus & GN.bus.V_dot_n_i ~= 0) ...
            - sum(GN.bus.V_dot_n_i)/sum(GN.bus.slack_bus & GN.bus.V_dot_n_i ~= 0);
    else
        GN.bus.V_dot_n_i(GN.bus.slack_bus) = ...
            GN.bus.V_dot_n_i(GN.bus.slack_bus) ...
            - sum(GN.bus.V_dot_n_i)/sum(GN.bus.slack_bus);
    end
    
elseif strcmp(f_mode,'area')
    % TODO: Describtion
    
    if ~noWarning && abs(sum(GN.bus.V_dot_n_i)) > NUMPARAM.epsilon_norm_f && ~has_dynamic_busses
        warning('Entries and exits are not balanced. V_dot_n_i of the slack busses have been updated.')
    end
    
    area_with_feeding_slack_branch = unique(GN.bus.area_ID(GN.branch.i_to_bus(GN.branch.active_branch)));
    area_with_feeding_slack_bus    = find(~ismember(1:max(GN.bus.area_ID), area_with_feeding_slack_branch));
    
    GN.bus.f    = GN.MAT.INC * GN.branch.V_dot_n_ij + GN.bus.V_dot_n_i;
    
    is_master_slack_bus = GN.bus.slack_bus & ismember(GN.bus.area_ID,area_with_feeding_slack_bus);
    GN.bus.V_dot_n_i(is_master_slack_bus) = ...
        GN.bus.V_dot_n_i(is_master_slack_bus) - sum(GN.bus.f)/sum(is_master_slack_bus);
    
    GN.bus.f    = GN.MAT.INC * GN.branch.V_dot_n_ij + GN.bus.V_dot_n_i;
    f_area      = GN.MAT.area_bus * GN.bus.f;
    
    Delta_V_dot_n_slack_branch = - GN.MAT.area_active_branch(:,GN.branch.slack_branch) \ f_area;
    GN.branch.V_dot_n_ij(GN.branch.slack_branch) = GN.branch.V_dot_n_ij(GN.branch.slack_branch) + Delta_V_dot_n_slack_branch;
    
elseif strcmp(f_mode,'bus')
    % Update V_dot_n_i at salck bus to get f=0 at slack bus
    GN.bus.f    = GN.MAT.INC * GN.branch.V_dot_n_ij + GN.bus.V_dot_n_i;
    
    if any(GN.branch.slack_branch)
        GN.branch.V_dot_n_ij(GN.branch.slack_branch) = ...
            GN.branch.V_dot_n_ij(GN.branch.slack_branch) + GN.bus.f(GN.branch.i_to_bus(GN.branch.slack_branch));
        
        GN.bus.f    = GN.MAT.INC * GN.branch.V_dot_n_ij + GN.bus.V_dot_n_i;
    end
    
    is_slack_bus = GN.bus.slack_bus;
    GN.bus.V_dot_n_i(is_slack_bus) = GN.bus.V_dot_n_i(is_slack_bus) - GN.bus.f(is_slack_bus);
    
else
    error('get_V_dot_n_slack: Choose ''area'' or ''bus'' for f_mode')
end

end

