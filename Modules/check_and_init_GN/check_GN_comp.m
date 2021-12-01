function GN = check_GN_comp(GN)
%CHECKGN_COMP Summary of this function goes here
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
if isfield(GN,'comp')
    if isempty(GN.comp)
        error('GN.comp is empty.')
    end
    
    %% comp_ID
    if any(strcmp('comp_ID',GN.comp.Properties.VariableNames))
        if any(~isnumeric(GN.comp.comp_ID))
            error('GN.comp: comp_ID must be numeric.')
        elseif any(GN.comp.comp_ID <= 0 | round(GN.comp.comp_ID) ~= GN.comp.comp_ID | isinf(GN.comp.comp_ID))
            error('GN.comp: comp_ID must be positive integer.')
        elseif length(unique(GN.comp.comp_ID)) < length(GN.comp.comp_ID)
            comp_ID = sort(GN.comp.comp_ID);
            comp_ID_double = comp_ID([diff(comp_ID)==0;false]);
            error(['GN.comp: Duplicate entries at comp_ID: ',num2str(comp_ID_double')])
        end
    else
        error('GN.comp: comp_ID column is missing.')
    end
    
    %% #######################################################################
    %  B R A N C H   V A R I A B L E S
    %  #######################################################################
    %% from_bus_ID
    if any(strcmp('from_bus_ID',GN.comp.Properties.VariableNames))
        if any(~isnumeric(GN.comp.from_bus_ID))
            error('GN.comp: from_bus_ID must be numeric.')
        end
        idx = ismember(GN.comp.from_bus_ID, GN.bus.bus_ID);
        if ~all(idx)
            error(['GN.comp: These from_bus_ID entries do not exists: ',num2str(GN.comp.from_bus_ID(~idx)')])
        end
        GN.comp.from_bus_ID = GN.comp.from_bus_ID;
    else
        error('GN.comp: from_bus_ID column is missing.')
    end
    
    %% to_bus_ID
    if any(strcmp('to_bus_ID',GN.comp.Properties.VariableNames))
        if any(~isnumeric(GN.comp.to_bus_ID))
            error('GN.comp: to_bus_ID must be numeric.')
        end
        idx = ismember(GN.comp.to_bus_ID, GN.bus.bus_ID);
        if ~all(idx)
            error(['GN.comp: These from_bus_ID entries do not exists: ',num2str(GN.comp.to_bus_ID(~idx)')])
        end
        GN.comp.to_bus_ID = GN.comp.to_bus_ID;
    else
        error('GN.comp: to_bus_ID column is missing.')
    end
    
    %% to_bus_ID and from_bus_ID
    if any(GN.comp.from_bus_ID == GN.comp.to_bus_ID)
        error(['GN.comp: from_bus_ID and to_bus_ID must not be the same. Check these comp IDs: ',...
        num2str(GN.comp.comp_ID(GN.comp.from_bus_ID == GN.comp.to_bus_ID)')])
    end
    
    %% in_service
    if any(strcmp('in_service',GN.comp.Properties.VariableNames))
        if any(~islogical(GN.comp.in_service) & ~isnumeric(GN.comp.in_service))
            error('GN.comp: in_service must be a logical value.')
        elseif any(GN.comp.in_service ~= 0 & GN.comp.in_service ~= 1 & ~isnan(GN.comp.in_service))
            error(['GN.comp: in_service must be ''1'' (true), ''0'' (false) or ''NaN''(false). Check entries at these comp IDs: ',...
                num2str(...
                GN.comp.comp_ID(GN.comp.in_service < 0 | GN.comp.in_service > 1)' ...
                )])
        end
        GN.comp.in_service(isnan(GN.comp.in_service)) = false;
        GN.comp.in_service(GN.comp.in_service == 0) = false;
        GN.comp.in_service(GN.comp.in_service == 1) = true;
        GN.comp.in_service = logical(GN.comp.in_service);
    else
        % No error message necessary
        GN.comp.in_service = true(size(GN.comp,1),1);
    end
    
    %% #######################################################################
    %  C O M P   V A R I A B L E S
    %  #######################################################################
    %% p_out__barg
    if any(strcmp('p_out__barg',GN.comp.Properties.VariableNames))
        if any(~isnumeric(GN.comp.p_out__barg))
            error('GN.comp: p_out__barg must be numeric.')
        elseif any(GN.comp.p_out__barg <= 0 | isinf(GN.comp.p_out__barg))
            error('GN.comp: The pressure p_out__barg must be positive double values.')
        end
        
        if any(strcmp('p_i',GN.comp.Properties.VariableNames))
            warning('GN.comp: p_i entries are ignored, as p_out__barg entries are preferably used.')
        end
    else
        error('GN.comp: p_out__barg column is missing.')
    end
    
    %% gas_powered
    if any(strcmp('gas_powered',GN.comp.Properties.VariableNames))
        if any(~islogical(GN.comp.gas_powered) & ~isnumeric(GN.comp.gas_powered))
            error('GN.comp: gas_powered must be a logical value.')
        elseif any(GN.comp.gas_powered ~= 0 & GN.comp.gas_powered ~= 1 & ~isnan(GN.comp.gas_powered))
            error('GN.comp: gas_powered must be ''1'' (true), ''0'' (false) or ''NaN''(false).')
        end
        GN.comp.gas_powered(isnan(GN.comp.gas_powered)) = false;
        GN.comp.gas_powered(GN.comp.gas_powered == 0) = false;
        GN.comp.gas_powered(GN.comp.gas_powered== 1) = true;
        GN.comp.gas_powered = logical(GN.comp.gas_powered);
    else
        GN.comp.gas_powered = false(size(GN.comp,1),1);
        warning('GN.comp: gas_powered column is missing. All compressor stations are assumed to have electrical drives.')
    end
    
    %% eta_s
    if any(strcmp('eta_s',GN.comp.Properties.VariableNames))
        if any(~isnumeric(GN.comp.eta_s))
            error('GN.comp: eta_s must be numeric.')
        elseif any(GN.comp.eta_s <= 0 | GN.comp.eta_s > 1 | isnan(GN.comp.eta_s))
            error(['GN.comp: eta_s must be larger than zero and less than or equal to one. Check entries at these compressor IDs: ',...
                num2str( GN.comp.comp_ID(GN.comp.eta_s <= 0 | GN.comp.eta_s > 1 | isnan(GN.comp.eta_s))' )])
        end
    else
        error('GN.comp: eta_s column is missing.')
    end
    
    %% eta_drive
    if any(strcmp('eta_drive',GN.comp.Properties.VariableNames))
        if any(~isnumeric(GN.comp.eta_drive))
            error('GN.comp: eta_drive must be numeric.')
        elseif any(GN.comp.eta_drive < 0 | GN.comp.eta_drive > 1 | isnan(GN.comp.eta_drive))
            error(['GN.comp: eta_drive must be larger than zero and less than or equal to one. Check entries at these compressor IDs: ',...
                num2str( GN.comp.comp_ID(GN.comp.eta_drive < 0 | GN.comp.eta_drive > 1 | isnan(GN.comp.eta_drive))' )])
        end
    else
        error('GN.comp: eta_drive column is missing.')
    end
    
    %% #######################################################################
    %  N O N - I S O T H E R M A L   P R O P E R T I E S
    %  #######################################################################
    if GN.isothermal == 0        
        %% T_controlled
        if any(strcmp('T_controlled',GN.comp.Properties.VariableNames))
            if any(~islogical(GN.comp.T_controlled) & ~isnumeric(GN.comp.T_controlled))
                error('GN.comp: T_controlled must be a logical value.')
            elseif any(GN.comp.T_controlled ~= 0 & GN.comp.T_controlled ~= 1 & ~isnan(GN.comp.T_controlled))
                error(['GN.comp: T_controlled must be ''1'' (true), ''0'' (false) or ''NaN''(false). Check entries at these comp IDs: ',...
                    num2str(...
                    GN.comp.comp_ID(GN.comp.T_controlled ~= 0 & GN.comp.T_controlled ~= 1 & ~isnan(GN.comp.T_controlled))' ...
                    )])
            end
            GN.comp.T_controlled(isnan(GN.comp.T_controlled)) = false;
            GN.comp.T_controlled(GN.comp.T_controlled == 0) = false;
            GN.comp.T_controlled(GN.comp.T_controlled == 1) = true;
            GN.comp.T_controlled = logical(GN.comp.T_controlled);
        else
            GN.comp.T_controlled = false(size(GN.comp,1),1);
        end
        
        %% T_to_bus
        if any(strcmp('T_to_bus',GN.comp.Properties.VariableNames))
            if any(~isnumeric(GN.comp.T_to_bus))
                error('GN.comp: T_to_bus must be numeric.')
            elseif any(GN.comp.T_to_bus < 0 | isinf(GN.comp.T_to_bus))
                error('GN.comp: T_to_bus must be a positive numeric value or NaN.')
            elseif any(GN.comp.T_controlled & isnan(GN.comp.T_to_bus))
                error('GN.comp: T_controlled compressor stations need T_to_bus values.')
            end
            if any(~GN.comp.T_controlled & ~isnan(GN.comp.T_to_bus))
                GN.comp.T_to_bus(~GN.comp.T_controlled & ~isnan(GN.comp.T_to_bus)) = NaN;
                warning('GN.comp: T_to_bus entries have been reset to NaN for all GN.comp.T_controlled = false.')
            end
        elseif any(GN.comp.T_controlled)
            error('GN.comp: T_controlled column missing. Temperature controlled compressor stations need T_to_bus values.')
        end
    end
end
end
