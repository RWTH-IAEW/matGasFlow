function [GN] = init_GN_branch(GN)
%INIT_GN_BRANCH
%   Initialize GN.branch by merging branch information from pipe, comp, prs
%   and valve.
%   GN = init_GN_branch(GN)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2022, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Outer Join pipe, comp and prs
GN.branch = table([]);
if isfield(GN,'pipe')
    max_branch_ID = get_max_branch_ID(GN);
    if ~ismember('branch_ID', GN.pipe.Properties.VariableNames)
        GN.pipe.branch_ID = (max_branch_ID+1 : max_branch_ID+size(GN.pipe,1))';
    elseif any(isnan(GN.pipe.branch_ID))
        i_nan = isnan(GN.pipe.branch_ID);
        GN.pipe.branch_ID(i_nan) = (max_branch_ID+1 : max_branch_ID+sum(i_nan))';
    end
    GN.pipe = movevars(GN.pipe,'branch_ID','After','pipe_ID');
    GN.pipe = movevars(GN.pipe,'from_bus_ID','After','branch_ID');
    GN.pipe = movevars(GN.pipe,'to_bus_ID','After','from_bus_ID');
    GN.pipe = movevars(GN.pipe,'in_service','After','to_bus_ID');
    if any(ismember(GN.pipe.Properties.VariableNames,'P_th_ij_preset__MW'))
        pipe_to_branch = GN.pipe(:,{'branch_ID', 'from_bus_ID', 'to_bus_ID', 'in_service', 'pipe_ID', 'P_th_ij_preset__MW'});
        
    elseif any(ismember(GN.pipe.Properties.VariableNames,'P_th_ij_preset'))
        pipe_to_branch = GN.pipe(:,{'branch_ID', 'from_bus_ID', 'to_bus_ID', 'in_service', 'pipe_ID', 'P_th_ij_preset'});
        
    elseif any(ismember(GN.pipe.Properties.VariableNames,'V_dot_n_ij_preset__m3_per_day'))
        pipe_to_branch = GN.pipe(:,{'branch_ID', 'from_bus_ID', 'to_bus_ID', 'in_service', 'pipe_ID', 'V_dot_n_ij_preset__m3_per_day'});
        
    elseif any(ismember(GN.pipe.Properties.VariableNames,'V_dot_n_ij_preset__m3_per_h'))
        pipe_to_branch = GN.pipe(:,{'branch_ID', 'from_bus_ID', 'to_bus_ID', 'in_service', 'pipe_ID', 'V_dot_n_ij_preset__m3_per_h'});
        
    elseif any(ismember(GN.pipe.Properties.VariableNames,'m_dot_ij_preset__kg_per_s'))
        pipe_to_branch = GN.pipe(:,{'branch_ID', 'from_bus_ID', 'to_bus_ID', 'in_service', 'pipe_ID', 'm_dot_ij_preset__kg_per_s'});
        
    elseif any(ismember(GN.pipe.Properties.VariableNames,'V_dot_n_ij_preset'))
        pipe_to_branch = GN.pipe(:,{'branch_ID', 'from_bus_ID', 'to_bus_ID', 'in_service', 'pipe_ID', 'V_dot_n_ij_preset'});
        
    else
        pipe_to_branch = GN.pipe(:,{'branch_ID', 'from_bus_ID', 'to_bus_ID', 'in_service', 'pipe_ID'});
        
    end
    % pipe_to_branch = GN.pipe(:,{'branch_ID', 'from_bus_ID', 'to_bus_ID', 'in_service', 'pipe_ID'});
    GN.branch = pipe_to_branch;
end

if isfield(GN,'comp')
    max_branch_ID = get_max_branch_ID(GN);
    
    if ~ismember('branch_ID', GN.comp.Properties.VariableNames)
        GN.comp.branch_ID = (max_branch_ID+1 : max_branch_ID+size(GN.comp,1))';
    elseif ismember('branch_ID', GN.comp.Properties.VariableNames)
        if ismember('branch_ID', GN.branch.Properties.VariableNames) && any(ismember(GN.comp.branch_ID, GN.branch.branch_ID))
            warning('GN.comp: Some branch_IDs already exist. GN.comp.branch_ID is initialized again.')
            GN.comp.branch_ID = (max_branch_ID+1 : max_branch_ID+size(GN.comp,1))';
        elseif any(isnan(GN.comp.branch_ID))
            i_nan = isnan(GN.comp.branch_ID);
            GN.comp.branch_ID(i_nan) = (max_branch_ID+1 : max_branch_ID+sum(i_nan))';
        end
    end
    
    GN.comp = movevars(GN.comp,'branch_ID','After','comp_ID');
    GN.comp = movevars(GN.comp,'from_bus_ID','After','branch_ID');
    GN.comp = movevars(GN.comp,'to_bus_ID','After','from_bus_ID');
    GN.comp = movevars(GN.comp,'in_service','After','to_bus_ID');
    if any(ismember(GN.comp.Properties.VariableNames,'P_th_ij_preset__MW'))
        comp_to_branch = GN.comp(:,{'branch_ID', 'from_bus_ID', 'to_bus_ID', 'in_service', 'slack_branch', 'comp_ID', 'P_th_ij_preset__MW'});
        
    elseif any(ismember(GN.comp.Properties.VariableNames,'P_th_ij_preset'))
        comp_to_branch = GN.comp(:,{'branch_ID', 'from_bus_ID', 'to_bus_ID', 'in_service', 'slack_branch', 'comp_ID', 'P_th_ij_preset'});
        
    elseif any(ismember(GN.comp.Properties.VariableNames,'V_dot_n_ij_preset__m3_per_day'))
        comp_to_branch = GN.comp(:,{'branch_ID', 'from_bus_ID', 'to_bus_ID', 'in_service', 'slack_branch', 'comp_ID', 'V_dot_n_ij_preset__m3_per_day'});
        
    elseif any(ismember(GN.comp.Properties.VariableNames,'V_dot_n_ij_preset__m3_per_h'))
        comp_to_branch = GN.comp(:,{'branch_ID', 'from_bus_ID', 'to_bus_ID', 'in_service', 'slack_branch', 'comp_ID', 'V_dot_n_ij_preset__m3_per_h'});
        
    elseif any(ismember(GN.comp.Properties.VariableNames,'m_dot_ij_preset__kg_per_s'))
        comp_to_branch = GN.comp(:,{'branch_ID', 'from_bus_ID', 'to_bus_ID', 'in_service', 'slack_branch', 'comp_ID', 'm_dot_ij_preset__kg_per_s'});
        
    elseif any(ismember(GN.comp.Properties.VariableNames,'V_dot_n_ij_preset'))
        comp_to_branch = GN.comp(:,{'branch_ID', 'from_bus_ID', 'to_bus_ID', 'in_service', 'slack_branch', 'comp_ID', 'V_dot_n_ij_preset'});
        
    else
        comp_to_branch = GN.comp(:,{'branch_ID', 'from_bus_ID', 'to_bus_ID', 'in_service', 'slack_branch', 'comp_ID'});
        
    end
    if ~isempty(GN.branch)
        Var = intersect(GN.branch.Properties.VariableNames,GN.comp.Properties.VariableNames);
        GN.branch = outerjoin(GN.branch,comp_to_branch,'Keys',Var,'MergeKeys',true);
    else
        GN.branch = comp_to_branch;
    end
end

if isfield(GN,'prs')
    max_branch_ID = get_max_branch_ID(GN);
    
    if ~ismember('branch_ID', GN.prs.Properties.VariableNames)
        GN.prs.branch_ID = (max_branch_ID+1 : max_branch_ID+size(GN.prs,1))';
    elseif ismember('branch_ID', GN.prs.Properties.VariableNames)
        if ismember('branch_ID', GN.branch.Properties.VariableNames) && any(ismember(GN.prs.branch_ID, GN.branch.branch_ID))
            warning('GN.prs: Some branch_IDs already exist. GN.prs.branch_ID is initialized again.')
            GN.prs.branch_ID = (max_branch_ID+1 : max_branch_ID+size(GN.prs,1))';
        elseif any(isnan(GN.prs.branch_ID))
            i_nan = isnan(GN.prs.branch_ID);
            GN.prs.branch_ID(i_nan) = (max_branch_ID+1 : max_branch_ID+sum(i_nan))';
        end
    end
    
    GN.prs = movevars(GN.prs,'branch_ID','After','prs_ID');
    GN.prs = movevars(GN.prs,'from_bus_ID','After','branch_ID');
    GN.prs = movevars(GN.prs,'to_bus_ID','After','from_bus_ID');
    GN.prs = movevars(GN.prs,'in_service','After','to_bus_ID');
    if any(ismember(GN.prs.Properties.VariableNames,'P_th_ij_preset__MW'))
        prs_to_branch = GN.prs(:,{'branch_ID', 'from_bus_ID', 'to_bus_ID', 'in_service', 'slack_branch', 'prs_ID', 'P_th_ij_preset__MW'});
        
    elseif any(ismember(GN.prs.Properties.VariableNames,'P_th_ij_preset'))
        prs_to_branch = GN.prs(:,{'branch_ID', 'from_bus_ID', 'to_bus_ID', 'in_service', 'slack_branch', 'prs_ID', 'P_th_ij_preset'});
        
    elseif any(ismember(GN.prs.Properties.VariableNames,'V_dot_n_ij_preset__m3_per_day'))
        prs_to_branch = GN.prs(:,{'branch_ID', 'from_bus_ID', 'to_bus_ID', 'in_service', 'slack_branch', 'prs_ID', 'V_dot_n_ij_preset__m3_per_day'});
        
    elseif any(ismember(GN.prs.Properties.VariableNames,'V_dot_n_ij_preset__m3_per_h'))
        prs_to_branch = GN.prs(:,{'branch_ID', 'from_bus_ID', 'to_bus_ID', 'in_service', 'slack_branch', 'prs_ID', 'V_dot_n_ij_preset__m3_per_h'});
        
    elseif any(ismember(GN.prs.Properties.VariableNames,'m_dot_ij_preset__kg_per_s'))
        prs_to_branch = GN.prs(:,{'branch_ID', 'from_bus_ID', 'to_bus_ID', 'in_service', 'slack_branch', 'prs_ID', 'm_dot_ij_preset__kg_per_s'});
        
    elseif any(ismember(GN.prs.Properties.VariableNames,'V_dot_n_ij_preset'))
        prs_to_branch = GN.prs(:,{'branch_ID', 'from_bus_ID', 'to_bus_ID', 'in_service', 'slack_branch', 'prs_ID', 'V_dot_n_ij_preset'});
        
    else
        prs_to_branch = GN.prs(:,{'branch_ID', 'from_bus_ID', 'to_bus_ID', 'in_service', 'slack_branch', 'prs_ID'});
        
    end
    if ~isempty(GN.branch)
        Var = intersect(GN.branch.Properties.VariableNames,GN.prs.Properties.VariableNames);
        GN.branch = outerjoin(GN.branch,prs_to_branch,'Keys',Var,'MergeKeys',true);
    else
        GN.branch = prs_to_branch;
    end
end

if isfield(GN,'valve')
    max_branch_ID = get_max_branch_ID(GN);
    
    if ~ismember('branch_ID', GN.valve.Properties.VariableNames)
        GN.valve.branch_ID = (max_branch_ID+1 : max_branch_ID+size(GN.valve,1))';
    elseif ismember('branch_ID', GN.valve.Properties.VariableNames)
        if ismember('branch_ID', GN.branch.Properties.VariableNames) && any(ismember(GN.valve.branch_ID, GN.branch.branch_ID))
            warning('GN.valve: Some branch_IDs already exist. GN.valve.branch_ID is initialized again.')
            GN.valve.branch_ID = (max_branch_ID+1 : max_branch_ID+size(GN.valve,1))';
        elseif any(isnan(GN.valve.branch_ID))
            i_nan = isnan(GN.valve.branch_ID);
            GN.valve.branch_ID(i_nan) = (max_branch_ID+1 : max_branch_ID+sum(i_nan))';
        end
    end
    
    GN.valve = movevars(GN.valve,'branch_ID','After','valve_ID');
    GN.valve = movevars(GN.valve,'from_bus_ID','After','branch_ID');
    GN.valve = movevars(GN.valve,'to_bus_ID','After','from_bus_ID');
    GN.valve = movevars(GN.valve,'in_service','After','to_bus_ID');
    valve_to_branch = GN.valve(:,{'branch_ID', 'from_bus_ID', 'to_bus_ID', 'in_service', 'valve_ID'});
    if ~isempty(GN.branch)
        Var = intersect(GN.branch.Properties.VariableNames,GN.valve.Properties.VariableNames);
        GN.branch = outerjoin(GN.branch,valve_to_branch,'Keys',Var,'MergeKeys',true);
    else
        GN.branch = valve_to_branch;
    end
end

%% Initialize preset
if ~ismember(GN.branch.Properties.VariableNames, 'preset')
    GN.branch.preset(:) = false;
end

%% Set NaN preset values to zero
if any(ismember(GN.branch.Properties.VariableNames,'P_th_ij_preset__MW'))
    GN.branch.P_th_ij_preset__MW(isnan(GN.branch.P_th_ij_preset__MW)) = 0;
elseif any(ismember(GN.branch.Properties.VariableNames,'P_th_ij_preset'))
    GN.branch.P_th_ij_preset(isnan(GN.branch.P_th_ij_preset)) = 0;
elseif any(ismember(GN.branch.Properties.VariableNames,'V_dot_n_ij_preset__m3_per_day'))
    GN.branch.V_dot_n_ij_preset__m3_per_day(isnan(GN.branch.V_dot_n_ij_preset__m3_per_day)) = 0;
elseif any(ismember(GN.branch.Properties.VariableNames,'V_dot_n_ij_preset__m3_per_h'))
    GN.branch.V_dot_n_ij_preset__m3_per_h(isnan(GN.branch.V_dot_n_ij_preset__m3_per_h)) = 0;
elseif any(ismember(GN.branch.Properties.VariableNames,'m_dot_ij_preset__kg_per_s'))
    GN.branch.m_dot_ij_preset__kg_per_s(isnan(GN.branch.m_dot_ij_preset__kg_per_s)) = 0;
elseif any(ismember(GN.branch.Properties.VariableNames,'V_dot_n_ij_preset'))
%     if isfield(GN,'pipe')
%         GN.branch.V_dot_n_ij_preset(~isnan(GN.branch.pipe_ID)) = NaN;
%     end
%     if isfield(GN,'valve')
%         GN.branch.V_dot_n_ij_preset(~isnan(GN.branch.valve_ID)) = NaN;
%     end
    % GN.branch.V_dot_n_ij_preset(isnan(GN.branch.V_dot_n_ij_preset)) = 0;
    GN.branch.preset(~isnan(GN.branch.V_dot_n_ij_preset))   = true;
    GN.branch.preset(isnan(GN.branch.V_dot_n_ij_preset))    = false;
else
    GN.branch.V_dot_n_ij_preset(:) = NaN;
end

%% Initialze slack_branch if not existing
if ~ismember(GN.branch.Properties.VariableNames, 'slack_branch')
    GN.branch.slack_branch(:) = false;
end

%% Check branch_ID
if length(unique(GN.branch.branch_ID)) ~= size(GN.branch,1)
    error('Something went wrong.')
end

%% Sort rows
GN.branch = sortrows(GN.branch,'branch_ID','ascend');

end

