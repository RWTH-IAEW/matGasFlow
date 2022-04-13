function [GN] = remove_valves(GN)
%REMOVE_VALVES Summary of this function goes here
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

% UNDER COSNTRUCTION: Es werden unnötigerweise warnings aufgegeben, wenn
% area_IDs angepasst werden.

if ~isfield(GN,'valve')
    return
end

if any(~ismember(GN.bus.bus_ID,[GN.branch.from_bus_ID;GN.branch.to_bus_ID]))
    error('Something went wrong: Some busses are not part of any branch.')
end
    
    
%% Itentify valve groups and reduce valve station to one bus
valveStation_IDs = unique(GN.branch.valveStation_ID(GN.branch.valve_branch & ~isnan(GN.branch.valveStation_ID)));

for ii = 1:length(valveStation_IDs)
    
    valveStation_ID = valveStation_IDs(ii);
    
    % get center and non-center bussus of valve station
    is_branch_valveStation      = GN.branch.valveStation_ID == valveStation_ID;
    i_bus_valveStation          = unique( [ GN.branch.i_from_bus(is_branch_valveStation); GN.branch.i_to_bus(is_branch_valveStation) ] );
    i_bus_valveStation_center   = i_bus_valveStation(1);
    i_bus_delete                = i_bus_valveStation(2:end);
    
    % apply quantities and porperties to center bus
    GN.bus.V_dot_n_i(   i_bus_valveStation_center)  = sum(GN.bus.V_dot_n_i( i_bus_valveStation));
    GN.bus.slack_bus(   i_bus_valveStation_center)  = any(GN.bus.slack_bus( i_bus_valveStation));
    GN.bus.p_bus(       i_bus_valveStation_center)  = any(GN.bus.p_bus(     i_bus_valveStation));
    GN.bus.active_bus(  i_bus_valveStation_center)  = any(GN.bus.active_bus(i_bus_valveStation));
    GN.bus.T_i(         i_bus_valveStation_center)  = mean(GN.bus.T_i(      i_bus_valveStation)); % UNDER CONSTRCUTION: Maybe something is missing
    
    % change from_bus_ID and to_bus_ID in pipe, comp and prs
    center_bus_IDs = GN.bus.bus_ID(i_bus_valveStation_center);
    deleted_bus_IDs = GN.bus.bus_ID(i_bus_delete);
%     GN.branch.from_bus_ID(ismember(GN.branch.from_bus_ID, deleted_bus_IDs))   = center_bus_IDs;
%     GN.branch.to_bus_ID(ismember(GN.branch.to_bus_ID, deleted_bus_IDs))       = center_bus_IDs;
    if isfield(GN,'pipe')
        GN.pipe.from_bus_ID(ismember(GN.pipe.from_bus_ID, deleted_bus_IDs))   = center_bus_IDs;
        GN.pipe.to_bus_ID(ismember(GN.pipe.to_bus_ID, deleted_bus_IDs))       = center_bus_IDs;
    end
    if isfield(GN,'comp')
        GN.comp.from_bus_ID(ismember(GN.comp.from_bus_ID, deleted_bus_IDs))   = center_bus_IDs;
        GN.comp.to_bus_ID(ismember(GN.comp.to_bus_ID, deleted_bus_IDs))       = center_bus_IDs;
    end
    if isfield(GN,'prs')
        GN.prs.from_bus_ID(ismember(GN.prs.from_bus_ID, deleted_bus_IDs))     = center_bus_IDs;
        GN.prs.to_bus_ID(ismember(GN.prs.to_bus_ID, deleted_bus_IDs))         = center_bus_IDs;
    end
end
    
% delete valve
GN = rmfield(GN,'valve');

% initialize branch
GN = init_GN_branch(GN);

% delete busses
GN.bus(~ismember(GN.bus.bus_ID,[GN.branch.from_bus_ID;GN.branch.to_bus_ID]), :) = [];

% Parts of check_and_init_GN
GN = init_GN_indices(GN); % UNDER CONSTRUCTION: Hier werden viele Sachen unnötig neu erzeugt (z.B. p_bus...)
GN = check_GN_area_restrictions(GN); % UNDER CONSTRCUTION: Unneccessary!? Maybe yes (slack_bus ...)
GN = get_GN_MAT(GN);

end

