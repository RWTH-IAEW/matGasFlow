function [GN] = init_GN_branch(GN)
%INIT_GN_BRANCH Summary of this function goes here
%   Detailed explanation goes here
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2021, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Outer Join pipe, comp and prs
branch_ID_max = 0;
GN.branch = table([]);
if isfield(GN,'pipe')
    GN.pipe.branch_ID = (branch_ID_max+1 : branch_ID_max+size(GN.pipe,1))';
    branch_ID_max = branch_ID_max + size(GN.pipe,1);
    GN.pipe = movevars(GN.pipe,'branch_ID','Before',1);
    GN.pipe = movevars(GN.pipe,'from_bus_ID','After','branch_ID');
    GN.pipe = movevars(GN.pipe,'to_bus_ID','After','from_bus_ID');
    GN.pipe = movevars(GN.pipe,'in_service','After','to_bus_ID');
    pipe_to_branch = GN.pipe(:,{'branch_ID', 'from_bus_ID', 'to_bus_ID', 'in_service', 'pipe_ID'});
    GN.branch = pipe_to_branch;
end

if isfield(GN,'comp')
    GN.comp.branch_ID = (branch_ID_max+1 : branch_ID_max+size(GN.comp,1))';
    branch_ID_max = branch_ID_max + size(GN.comp,1);
    GN.comp = movevars(GN.comp,'branch_ID','Before',1);
    GN.comp = movevars(GN.comp,'from_bus_ID','After','branch_ID');
    GN.comp = movevars(GN.comp,'to_bus_ID','After','from_bus_ID');
    GN.comp = movevars(GN.comp,'in_service','After','to_bus_ID');
    comp_to_branch = GN.comp(:,{'branch_ID', 'from_bus_ID', 'to_bus_ID', 'in_service', 'comp_ID'});
    if ~isempty(GN.branch)
        Var = intersect(GN.branch.Properties.VariableNames,GN.comp.Properties.VariableNames);
        GN.branch = outerjoin(GN.branch,comp_to_branch,'Keys',Var,'MergeKeys',true);
    else
        GN.branch = comp_to_branch;
    end
end

if isfield(GN,'prs')
    GN.prs.branch_ID = (branch_ID_max+1 : branch_ID_max+size(GN.prs,1))';
    branch_ID_max = branch_ID_max + size(GN.prs,1);
    GN.prs = movevars(GN.prs,'branch_ID','Before',1);
    GN.prs = movevars(GN.prs,'from_bus_ID','After','branch_ID');
    GN.prs = movevars(GN.prs,'to_bus_ID','After','from_bus_ID');
    GN.prs = movevars(GN.prs,'in_service','After','to_bus_ID');
    prs_to_branch = GN.prs(:,{'branch_ID', 'from_bus_ID', 'to_bus_ID', 'in_service', 'prs_ID'});
    if ~isempty(GN.branch)
        Var = intersect(GN.branch.Properties.VariableNames,GN.prs.Properties.VariableNames);
        GN.branch = outerjoin(GN.branch,prs_to_branch,'Keys',Var,'MergeKeys',true);
    else
        GN.branch = prs_to_branch;
    end
end

if isfield(GN,'valve')
    GN.valve.branch_ID = (branch_ID_max+1 : branch_ID_max+size(GN.valve,1))';
%     branch_ID_max = branch_ID_max + size(GN.valve,1);
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

if ~isfield(GN, {'pipe','comp','prs','valve'})
    error('The gas network has no branch.')
end

end

