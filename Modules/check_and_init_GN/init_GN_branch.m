function [GN] = init_GN_branch(GN)
%INIT_GN_BRANCH
<<<<<<< HEAD
%   Initialize GN.branch by merging branch information from pipe, comp, prs
%   and valve.
%   GN = init_GN_branch(GN)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2022, High Voltage Equipment and Grids,
=======
%   GN = init_GN_branch(GN)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2021, High Voltage Equipment and Grids,
>>>>>>> Merge to public repo (#1)
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

<<<<<<< HEAD
if ~any(isfield(GN, {'pipe','comp','prs','valve'})) % UNDER CONSTRUCTION
    error('The gas network has no branch.')
end

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
=======
%% Outer Join pipe, comp and prs
branch_ID_max = 0;
GN.branch = table([]);
if isfield(GN,'pipe')
    GN.pipe.branch_ID = (branch_ID_max+1 : branch_ID_max+size(GN.pipe,1))';
    branch_ID_max = branch_ID_max + size(GN.pipe,1);
>>>>>>> Merge to public repo (#1)
    GN.pipe = movevars(GN.pipe,'branch_ID','Before',1);
    GN.pipe = movevars(GN.pipe,'from_bus_ID','After','branch_ID');
    GN.pipe = movevars(GN.pipe,'to_bus_ID','After','from_bus_ID');
    GN.pipe = movevars(GN.pipe,'in_service','After','to_bus_ID');
    pipe_to_branch = GN.pipe(:,{'branch_ID', 'from_bus_ID', 'to_bus_ID', 'in_service', 'pipe_ID'});
    GN.branch = pipe_to_branch;
end

if isfield(GN,'comp')
<<<<<<< HEAD
    max_branch_ID = get_max_branch_ID(GN);
    if ~ismember('branch_ID', GN.comp.Properties.VariableNames)
        GN.comp.branch_ID = (max_branch_ID+1 : max_branch_ID+size(GN.comp,1))';
    elseif any(isnan(GN.comp.branch_ID))
        i_nan = isnan(GN.comp.branch_ID);
        GN.comp.branch_ID(i_nan) = (max_branch_ID+1 : max_branch_ID+sum(i_nan))';
    end
=======
    GN.comp.branch_ID = (branch_ID_max+1 : branch_ID_max+size(GN.comp,1))';
    branch_ID_max = branch_ID_max + size(GN.comp,1);
>>>>>>> Merge to public repo (#1)
    GN.comp = movevars(GN.comp,'branch_ID','Before',1);
    GN.comp = movevars(GN.comp,'from_bus_ID','After','branch_ID');
    GN.comp = movevars(GN.comp,'to_bus_ID','After','from_bus_ID');
    GN.comp = movevars(GN.comp,'in_service','After','to_bus_ID');
<<<<<<< HEAD
    if any(ismember(GN.comp.Properties.VariableNames,'P_th_ij_preset__MW'))
        comp_to_branch = GN.comp(:,{'branch_ID', 'from_bus_ID', 'to_bus_ID', 'in_service', 'slack_branch', 'comp_ID', 'P_th_ij_preset__MW', 'preset'});
        
    elseif any(ismember(GN.comp.Properties.VariableNames,'P_th_ij_preset'))
        comp_to_branch = GN.comp(:,{'branch_ID', 'from_bus_ID', 'to_bus_ID', 'in_service', 'slack_branch', 'comp_ID', 'P_th_ij_preset', 'preset'});
        
    elseif any(ismember(GN.comp.Properties.VariableNames,'V_dot_n_ij_preset__m3_per_day'))
        comp_to_branch = GN.comp(:,{'branch_ID', 'from_bus_ID', 'to_bus_ID', 'in_service', 'slack_branch', 'comp_ID', 'V_dot_n_ij_preset__m3_per_day', 'preset'});
        
    elseif any(ismember(GN.comp.Properties.VariableNames,'V_dot_n_ij_preset__m3_per_h'))
        comp_to_branch = GN.comp(:,{'branch_ID', 'from_bus_ID', 'to_bus_ID', 'in_service', 'slack_branch', 'comp_ID', 'V_dot_n_ij_preset__m3_per_h', 'preset'});
        
    elseif any(ismember(GN.comp.Properties.VariableNames,'m_dot_ij_preset__kg_per_s'))
        comp_to_branch = GN.comp(:,{'branch_ID', 'from_bus_ID', 'to_bus_ID', 'in_service', 'slack_branch', 'comp_ID', 'm_dot_ij_preset__kg_per_s', 'preset'});
        
    elseif any(ismember(GN.comp.Properties.VariableNames,'V_dot_n_ij_preset'))
        comp_to_branch = GN.comp(:,{'branch_ID', 'from_bus_ID', 'to_bus_ID', 'in_service', 'slack_branch', 'comp_ID', 'V_dot_n_ij_preset', 'preset'});
        
    else
        comp_to_branch = GN.comp(:,{'branch_ID', 'from_bus_ID', 'to_bus_ID', 'in_service', 'slack_branch', 'comp_ID'});
        
    end
=======
    comp_to_branch = GN.comp(:,{'branch_ID', 'from_bus_ID', 'to_bus_ID', 'in_service', 'comp_ID'});
>>>>>>> Merge to public repo (#1)
    if ~isempty(GN.branch)
        Var = intersect(GN.branch.Properties.VariableNames,GN.comp.Properties.VariableNames);
        GN.branch = outerjoin(GN.branch,comp_to_branch,'Keys',Var,'MergeKeys',true);
    else
        GN.branch = comp_to_branch;
    end
end

if isfield(GN,'prs')
<<<<<<< HEAD
    max_branch_ID = get_max_branch_ID(GN);
    if ~ismember('branch_ID', GN.prs.Properties.VariableNames)
        GN.prs.branch_ID = (max_branch_ID+1 : max_branch_ID+size(GN.prs,1))';
    elseif any(isnan(GN.prs.branch_ID))
        i_nan = isnan(GN.prs.branch_ID);
        GN.prs.branch_ID(i_nan) = (max_branch_ID+1 : max_branch_ID+sum(i_nan))';
    end
=======
    GN.prs.branch_ID = (branch_ID_max+1 : branch_ID_max+size(GN.prs,1))';
    branch_ID_max = branch_ID_max + size(GN.prs,1);
>>>>>>> Merge to public repo (#1)
    GN.prs = movevars(GN.prs,'branch_ID','Before',1);
    GN.prs = movevars(GN.prs,'from_bus_ID','After','branch_ID');
    GN.prs = movevars(GN.prs,'to_bus_ID','After','from_bus_ID');
    GN.prs = movevars(GN.prs,'in_service','After','to_bus_ID');
<<<<<<< HEAD
    if any(ismember(GN.prs.Properties.VariableNames,'P_th_ij_preset__MW'))
        prs_to_branch = GN.prs(:,{'branch_ID', 'from_bus_ID', 'to_bus_ID', 'in_service', 'slack_branch', 'prs_ID', 'P_th_ij_preset__MW', 'preset'});
        
    elseif any(ismember(GN.prs.Properties.VariableNames,'P_th_ij_preset'))
        prs_to_branch = GN.prs(:,{'branch_ID', 'from_bus_ID', 'to_bus_ID', 'in_service', 'slack_branch', 'prs_ID', 'P_th_ij_preset', 'preset'});
        
    elseif any(ismember(GN.prs.Properties.VariableNames,'V_dot_n_ij_preset__m3_per_day'))
        prs_to_branch = GN.prs(:,{'branch_ID', 'from_bus_ID', 'to_bus_ID', 'in_service', 'slack_branch', 'prs_ID', 'V_dot_n_ij_preset__m3_per_day', 'preset'});
        
    elseif any(ismember(GN.prs.Properties.VariableNames,'V_dot_n_ij_preset__m3_per_h'))
        prs_to_branch = GN.prs(:,{'branch_ID', 'from_bus_ID', 'to_bus_ID', 'in_service', 'slack_branch', 'prs_ID', 'V_dot_n_ij_preset__m3_per_h', 'preset'});
        
    elseif any(ismember(GN.prs.Properties.VariableNames,'m_dot_ij_preset__kg_per_s'))
        prs_to_branch = GN.prs(:,{'branch_ID', 'from_bus_ID', 'to_bus_ID', 'in_service', 'slack_branch', 'prs_ID', 'm_dot_ij_preset__kg_per_s', 'preset'});
        
    elseif any(ismember(GN.prs.Properties.VariableNames,'V_dot_n_ij_preset'))
        prs_to_branch = GN.prs(:,{'branch_ID', 'from_bus_ID', 'to_bus_ID', 'in_service', 'slack_branch', 'prs_ID', 'V_dot_n_ij_preset', 'preset'});
        
    else
        prs_to_branch = GN.prs(:,{'branch_ID', 'from_bus_ID', 'to_bus_ID', 'in_service', 'slack_branch', 'prs_ID'});
        
    end
=======
    prs_to_branch = GN.prs(:,{'branch_ID', 'from_bus_ID', 'to_bus_ID', 'in_service', 'prs_ID'});
>>>>>>> Merge to public repo (#1)
    if ~isempty(GN.branch)
        Var = intersect(GN.branch.Properties.VariableNames,GN.prs.Properties.VariableNames);
        GN.branch = outerjoin(GN.branch,prs_to_branch,'Keys',Var,'MergeKeys',true);
    else
        GN.branch = prs_to_branch;
    end
end

if isfield(GN,'valve')
<<<<<<< HEAD
    max_branch_ID = get_max_branch_ID(GN);
    if ~ismember('branch_ID', GN.valve.Properties.VariableNames)
        GN.valve.branch_ID = (max_branch_ID+1 : max_branch_ID+size(GN.valve,1))';
    elseif any(isnan(GN.valve.branch_ID))
        i_nan = isnan(GN.valve.branch_ID);
        GN.valve.branch_ID(i_nan) = (max_branch_ID+1 : max_branch_ID+sum(i_nan))';
    end
=======
    GN.valve.branch_ID = (branch_ID_max+1 : branch_ID_max+size(GN.valve,1))';
%     branch_ID_max = branch_ID_max + size(GN.valve,1);
>>>>>>> Merge to public repo (#1)
    GN.valve = movevars(GN.valve,'branch_ID','Before',1);
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

<<<<<<< HEAD
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
    GN.branch.V_dot_n_ij_preset(isnan(GN.branch.V_dot_n_ij_preset)) = 0;
else
    GN.branch.V_dot_n_ij_preset(:) = 0;
end

%% Initialize preset
if ~ismember(GN.branch.Properties.VariableNames, 'preset')
    GN.branch.preset(:) = false;
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

=======
if ~isfield(GN, {'pipe','comp','prs','valve'})
    error('The gas network has no branch.')
end

>>>>>>> Merge to public repo (#1)
end

