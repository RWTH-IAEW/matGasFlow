function [GN] = add_bypass_valve(GN, branch_type_to_be_bypassed, object_ID_to_be_bypassed, bypass_type, apply_check_and_init_GN)
%ADD_BYPASS_VALVE Summary of this function goes here
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

if ~strcmp('prs',branch_type_to_be_bypassed)
    error('So far only prs can be bypassed.')
end

if ~all(ismember(object_ID_to_be_bypassed,GN.prs.prs_ID))
    error('Some branch_object_ID_to_be_bypassed do not exist.')
end
    
% add valves
i_object_to_be_bypassed = ismember(GN.prs.prs_ID, object_ID_to_be_bypassed);
valve_ID        = GN.prs.prs_ID(i_object_to_be_bypassed);
from_bus_ID     = GN.prs.to_bus_ID(i_object_to_be_bypassed);    % switch direction
to_bus_ID       = GN.prs.from_bus_ID(i_object_to_be_bypassed);  % switch direction
in_service      = false(size(valve_ID));
bypass_prs_ID   = GN.prs.prs_ID(i_object_to_be_bypassed);

valve_temp  = table(valve_ID, from_bus_ID, to_bus_ID, in_service);
if isfield(GN, 'valve')
    if any(ismember(GN.valve.valve_ID,valve_ID))
        valve_temp.valve_ID = max(GN.valve.valve_ID)+1 : max(GN.valve.valve_ID)+1+size(valve_temp,1);
    end
    missing_column  = GN.valve.Properties.VariableNames(~ismember(GN.valve.Properties.VariableNames, valve_temp.Properties.VariableNames));
    table_temp      = array2table(NaN(size(valve_temp,1),length(missing_column)),"VariableNames",missing_column);
    valve_temp      = [valve_temp, table_temp];
    [~,i_column]    = ismember(GN.valve.Properties.VariableNames, valve_temp.Properties.VariableNames);
    GN.valve        = [GN.valve;valve_temp(:,i_column)];
    if ~ismember('bypass_prs_ID', GN.valve.Properties.VariableNames)
        GN.valve.bypass_prs_ID(:) = NaN;
    end
    GN.valve.bypass_prs_ID(end-size(valve_temp,1)+1:end) = bypass_prs_ID;
else
    GN.valve    = table(valve_ID, from_bus_ID, to_bus_ID, in_service, bypass_prs_ID);
end

if ~ismember('bypass_valve_ID', GN.prs.Properties.VariableNames)
    GN.prs.bypass_valve_ID(:) = NaN;
end
[has_bypass_prs,i_valve] = ismember(GN.prs.prs_ID(i_object_to_be_bypassed),GN.valve.bypass_prs_ID);
GN.prs.bypass_valve_ID(i_object_to_be_bypassed) = GN.valve.valve_ID(i_valve(has_bypass_prs));

if apply_check_and_init_GN
    % Check prs
    GN = check_GN_prs(GN);
    
    % Check valve
    GN = check_GN_valve(GN);
    
    % Inititalize GN.branch
    GN = init_GN_branch(GN);
    
    % Inititialize indecies
    GN = init_GN_indices(GN);
    
    % Check area restrictions
    keep_bus_properties = true;
    GN = check_GN_area_restrictions(GN,keep_bus_properties);
end

end

