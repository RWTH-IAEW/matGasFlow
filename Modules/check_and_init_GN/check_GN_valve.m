function GN = check_GN_valve(GN)
%CHECK_GN_VALVE Summary of this function goes here
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

%%
if isfield(GN,'valve')
    if isempty(GN.valve)
        error('GN.valve is empty.')
    end
    
    %% valve_ID
    if any(strcmp('valve_ID',GN.valve.Properties.VariableNames))
        if any(~isnumeric(GN.valve.valve_ID))
            error('GN.valve: valve_ID must be numeric.')
        elseif any(GN.valve.valve_ID <= 0 | round(GN.valve.valve_ID) ~= GN.valve.valve_ID | isinf(GN.valve.valve_ID))
            error('GN.bus: valve_ID must be positive integer.')
        elseif length(unique(GN.valve.valve_ID)) < length(GN.valve.valve_ID)
            valve_ID = sort(GN.valve.valve_ID);
            valve_ID_double = valve_ID([diff(valve_ID)==0;false]);
            error(['GN.valve: Double entries at valve_ID: ',num2str(valve_ID_double')])
        end
    else
        error('GN.valve: valve_ID column is missing.')
    end
    
    %% from_bus_ID
    if any(strcmp('from_bus_ID',GN.valve.Properties.VariableNames))
        if any(~isnumeric(GN.valve.from_bus_ID))
            error('GN.valve: from_bus_ID must be numeric.')
        end
        idx = ismember(GN.valve.from_bus_ID, GN.bus.bus_ID);
        if ~all(idx)
            error(['GN.valve: These from_bus_ID entries do not exists: ',num2str(GN.valve.from_bus_ID(~idx)')])
        end
        GN.valve.from_bus_ID = GN.valve.from_bus_ID;
    else
        error('GN.valve: from_bus_ID column is missing.')
    end
    
    %% to_bus_ID
    if any(strcmp('to_bus_ID',GN.valve.Properties.VariableNames))
        if any(~isnumeric(GN.valve.to_bus_ID))
            error('GN.valve: to_bus_ID must be numeric.')
        end
        idx = ismember(GN.valve.to_bus_ID, GN.bus.bus_ID);
        if ~all(idx)
            error(['GN.valve: These from_bus_ID entries do not exists: ',num2str(GN.valve.to_bus_ID(~idx)')])
        end
        GN.valve.to_bus_ID = GN.valve.to_bus_ID;
    else
        error('GN.valve: to_bus_ID column is missing.')
    end
    
    %% to_bus_ID and from_bus_ID
    if any(GN.valve.from_bus_ID == GN.valve.to_bus_ID)
        error(['GN.valve: from_bus_ID and to_bus_ID must not be the same. Check these valve IDs: ',...
        num2str(GN.valve.valve_ID(GN.valve.from_bus_ID == GN.valve.to_bus_ID)')])
    end
    
    %% in_service
    if any(strcmp('in_service',GN.valve.Properties.VariableNames))
        if any(~islogical(GN.valve.in_service) & ~isnumeric(GN.valve.in_service))
            error('GN.valve: in_service must be a logical value.')
        elseif any(GN.valve.in_service ~= 0 & GN.valve.in_service ~= 1 & ~isnan(GN.valve.in_service))
            error(['GN.valve: in_service must be ''1'' (true), ''0'' (false) or ''NaN''(false). Check entries at these valve IDs: ',...
                num2str(...
                GN.valve.valve_ID(GN.valve.in_service < 0 | GN.valve.in_service > 1)' ...
                )])
        end
        GN.valve.in_service(isnan(GN.valve.in_service)) = false;
        GN.valve.in_service(GN.valve.in_service == 0) = false;
        GN.valve.in_service(GN.valve.in_service == 1) = true;
        GN.valve.in_service = logical(GN.valve.in_service);
    else
        % No error message necessary
        GN.valve.in_service = true(size(GN.valve,1),1);
    end
    
end
end

