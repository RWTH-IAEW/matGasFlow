function GN = check_GN_comp(GN)
%CHECK_GN_COMP
%   GN = check_GN_comp(GN)
%   Check and initialization of GN.comp and its variables (comp table)
%   list of variabels:
%       INPUT DATA
%           comp_ID
%           from_bus_ID
%           to_bus_ID
%       INPUT DATA - OPTIONAL FOR NON-ISOTHERMAL SIMULATION
%           T_controlled
%           T_ij_out
%           Q_dot_cooler
%           eta_cooler
%       INPUT DATA - OPTIONAL
%           in_service
%           slack_branch
%           gas_powered
%           eta_s
%           eta_drive
%           P_th_ij_preset__MW, P_th_ij_preset, V_dot_n_ij_preset__m3_per_day,
%               V_dot_n_ij_preset__m3_per_h, m_dot_ij_preset__kg_per_s,
%               V_dot_n_ij_preset
%           preset
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2022, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Check for comp in GN
if ~isfield(GN,'comp')
    return
elseif isempty(GN.comp)
    GN = rmfield(GN, 'comp');
    warning('GN.comp is empty.')
    return
end

%% #######################################################################
%  I N P U T   D A T A   -   R E Q U I R E D
%  #######################################################################
%% comp_ID
if ismember('comp_ID',GN.comp.Properties.VariableNames)
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

%% from_bus_ID - (BRANCH VARIABLE)
if ismember('from_bus_ID',GN.comp.Properties.VariableNames)
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

%% to_bus_ID - (BRANCH VARIABLE)
if ismember('to_bus_ID',GN.comp.Properties.VariableNames)
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

%% to_bus_ID and from_bus_ID - (BRANCH VARIABLE)
if any(GN.comp.from_bus_ID == GN.comp.to_bus_ID)
    error(['GN.comp: from_bus_ID and to_bus_ID must not be the same. Check these comp IDs: ',...
        num2str(GN.comp.comp_ID(GN.comp.from_bus_ID == GN.comp.to_bus_ID)')])
end

%% #######################################################################
%  I N P U T   D A T A   -
%  O P T I O N A L   F O R   N O N - I S O T H E R M A L   S I M U L A T I O N
%  #######################################################################
if ~GN.isothermal
    %% T_controlled
    if ismember('T_controlled',GN.comp.Properties.VariableNames)
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
        % Set default parameter
        GN.comp.T_controlled(:) = false;
    end
    
    %% T_ij_out
    if ismember('T_ij_out',GN.comp.Properties.VariableNames)
        if any(~isnumeric(GN.comp.T_ij_out))
            error('GN.comp: T_ij_out must be numeric.')
        elseif any(GN.comp.T_ij_out < 0 | isinf(GN.comp.T_ij_out))
            error('GN.comp: T_ij_out must be a positive numeric value or NaN.')
        end
    else
        GN.comp.T_ij_out(:) = NaN;
    end
    % Set default parameter
    GN.comp.T_ij_out(isnan(GN.comp.T_ij_out) & GN.comp.T_controlled) = GN.T_env;
    
    %% Q_dot_cooler
    if ismember('Q_dot_cooler',GN.comp.Properties.VariableNames)
        if any(~isnumeric(GN.comp.Q_dot_cooler))
            error('GN.comp: Q_dot_cooler must be numeric.')
        elseif any(isinf(GN.comp.Q_dot_cooler))
            error('GN.comp: Q_dot_cooler must be a numeric value or NaN.')
        end
    else
        GN.comp.Q_dot_cooler(:) = NaN;
    end
    % Set default parameter
    GN.comp.Q_dot_cooler(isnan(GN.comp.Q_dot_cooler) & ~GN.comp.T_controlled) = 0;
    
    %% eta_cooler
    if ismember('eta_cooler',GN.comp.Properties.VariableNames)
        if any(~isnumeric(GN.comp.eta_cooler))
            error('GN.comp: eta_cooler must be numeric.')
        elseif any(GN.comp.eta_cooler < 0 | GN.comp.eta_cooler > 1 | isnan(GN.comp.eta_cooler))
            error(['GN.comp: eta_cooler must be larger than zero and less than or equal to one. Check entries at these compressor IDs: ',...
                num2str( GN.comp.comp_ID(GN.comp.eta_cooler < 0 | GN.comp.eta_cooler > 1 | isnan(GN.comp.eta_cooler))' )])
        end
    else
        % Set default parameter
        GN.comp.eta_cooler(:) = 1;
    end
end

%% #######################################################################
%  I N P U T   D A T A   -   O P T I O N A L
%  #######################################################################
%% in_service - (BRANCH VARIABLE)
if ismember('in_service',GN.comp.Properties.VariableNames)
    if any(~islogical(GN.comp.in_service) & ~isnumeric(GN.comp.in_service))
        error('GN.comp: in_service must be a logical value.')
    elseif any(GN.comp.in_service ~= 0 & GN.comp.in_service ~= 1 & ~isnan(GN.comp.in_service))
        error(['GN.comp: in_service must be ''1'' (true), ''0'' (false) or ''NaN''(false). Check entries at these comp IDs: ',...
            num2str(...
            GN.comp.comp_ID(GN.comp.in_service < 0 | GN.comp.in_service > 1)' ...
            )])
    end
    GN.comp.in_service(isnan(GN.comp.in_service))   = false;
    GN.comp.in_service(GN.comp.in_service == 0)     = false;
    GN.comp.in_service(GN.comp.in_service == 1)     = true;
    GN.comp.in_service = logical(GN.comp.in_service);
else
    % Set default parameter
    GN.comp.in_service(:) = true;
end

%% slack_branch - (BRANCH VARIABLE)
if ismember('slack_branch',GN.comp.Properties.VariableNames)
    if any(~islogical(GN.comp.slack_branch) & ~isnumeric(GN.comp.slack_branch))
        error('GN.comp: slack_branch must be a logical value.')
    elseif any(GN.comp.slack_branch ~= 0 & GN.comp.slack_branch ~= 1 & ~isnan(GN.comp.slack_branch))
        error(['GN.comp: slack_branch must be ''1'' (true), ''0'' (false) or ''NaN''(false). Check entries at these comp IDs: ',...
            num2str(...
            GN.comp.comp_ID(GN.comp.slack_branch < 0 | GN.comp.slack_branch > 1)' ...
            )])
    end
    GN.comp.slack_branch(isnan(GN.comp.slack_branch))   = false;
    GN.comp.slack_branch(GN.comp.slack_branch == 0)     = false;
    GN.comp.slack_branch(GN.comp.slack_branch == 1)     = true;
    GN.comp.slack_branch = logical(GN.comp.slack_branch);
else
    % Set default parameter
    GN.comp.slack_branch(:) = false;
end

%% gas_powered
if ismember('gas_powered',GN.comp.Properties.VariableNames)
    if any(~islogical(GN.comp.gas_powered) & ~isnumeric(GN.comp.gas_powered))
        error('GN.comp: gas_powered must be a logical value.')
    elseif any(GN.comp.gas_powered ~= 0 & GN.comp.gas_powered ~= 1 & ~isnan(GN.comp.gas_powered))
        error('GN.comp: gas_powered must be ''1'' (true), ''0'' (false) or ''NaN''(false).')
    end
    GN.comp.gas_powered(isnan(GN.comp.gas_powered)) = false;
    GN.comp.gas_powered(GN.comp.gas_powered == 0) = false;
    GN.comp.gas_powered(GN.comp.gas_powered == 1) = true;
    GN.comp.gas_powered = logical(GN.comp.gas_powered);
else
    % Set default parameter
    GN.comp.gas_powered(:) = false;
end

%% eta_s
if ismember('eta_s',GN.comp.Properties.VariableNames)
    if any(~isnumeric(GN.comp.eta_s))
        error('GN.comp: eta_s must be numeric.')
    elseif any(GN.comp.eta_s <= 0 | GN.comp.eta_s > 1 | isnan(GN.comp.eta_s))
        error(['GN.comp: eta_s must be larger than zero and less than or equal to one. Check entries at these compressor IDs: ',...
            num2str( GN.comp.comp_ID(GN.comp.eta_s <= 0 | GN.comp.eta_s > 1 | isnan(GN.comp.eta_s))' )])
    end
else
    % Set default parameter
    GN.comp.eta_s(:) = 1;
end

%% eta_drive
if ismember('eta_drive',GN.comp.Properties.VariableNames)
    if any(~isnumeric(GN.comp.eta_drive))
        error('GN.comp: eta_drive must be numeric.')
    elseif any(GN.comp.eta_drive < 0 | GN.comp.eta_drive > 1 | isnan(GN.comp.eta_drive))
        error(['GN.comp: eta_drive must be larger than zero and less than or equal to one. Check entries at these compressor IDs: ',...
            num2str( GN.comp.comp_ID(GN.comp.eta_drive < 0 | GN.comp.eta_drive > 1 | isnan(GN.comp.eta_drive))' )])
    end
else
    % Set default parameter
    GN.comp.eta_drive(:) = 1;
end

%% P_th_ij_preset__MW, P_th_ij_preset, V_dot_n_ij_preset__m3_per_day, V_dot_n_ij_preset__m3_per_h, m_dot_ij_preset__kg_per_s, V_dot_n_ij_preset
comp_flow_type = {};

if ismember('P_th_ij_preset__MW',GN.comp.Properties.VariableNames)
    if any(~isnumeric(GN.comp.P_th_ij_preset__MW))
        error('GN.comp: P_th_ij_preset__MW must be numeric.')
    elseif any(isinf(GN.comp.P_th_ij_preset__MW))
        error('GN.comp: P_th_ij_preset__MW must be a numeric value and must not be infinity.')
    end
    comp_flow_type(end+1) = {'P_th_ij_preset__MW'};
end

if ismember('P_th_ij_preset',GN.comp.Properties.VariableNames)
    if any(~isnumeric(GN.comp.P_th_ij_preset))
        error('GN.comp: P_th_ij_preset must be numeric.')
    elseif any(isinf(GN.comp.P_th_ij_preset))
        error('GN.comp: P_th_ij_preset must be a numeric value and must not be infinity.')
    end
    comp_flow_type(end+1) = {'P_th_ij_preset'};
end

if ismember('V_dot_n_ij_preset__m3_per_day',GN.comp.Properties.VariableNames)
    if any(~isnumeric(GN.comp.V_dot_n_ij_preset__m3_per_day))
        error('GN.comp: V_dot_n_ij_preset__m3_per_day must be numeric.')
    elseif any(isinf(GN.comp.V_dot_n_ij_preset__m3_per_day))
        error('GN.comp: V_dot_n_ij_preset__m3_per_day must be a numeric value and must not be infinity.')
    end
    comp_flow_type(end+1) = {'V_dot_n_ij_preset__m3_per_day'};
end

if ismember('V_dot_n_ij_preset__m3_per_h',GN.comp.Properties.VariableNames)
    if any(~isnumeric(GN.comp.V_dot_n_ij_preset__m3_per_h))
        error('GN.comp: V_dot_n_ij_preset__m3_per_h must be numeric.')
    elseif any(isinf(GN.comp.V_dot_n_ij_preset__m3_per_h))
        error('GN.comp: V_dot_n_ij_preset__m3_per_h must be a numeric value and must not be infinity.')
    end
    comp_flow_type(end+1) = {'V_dot_n_ij_preset__m3_per_h'};
end

if ismember('m_dot_ij_preset__kg_per_s',GN.comp.Properties.VariableNames)
    if any(~isnumeric(GN.comp.m_dot_ij_preset__kg_per_s))
        error('GN.comp: m_dot_ij_preset__kg_per_s must be numeric.')
    elseif any(isinf(GN.comp.m_dot_ij_preset__kg_per_s))
        error('GN.comp: m_dot_ij_preset__kg_per_s must be a numeric value and must not be infinity.')
    end
    comp_flow_type(end+1) = {'m_dot_ij_preset__kg_per_s'};
end

if ismember('V_dot_n_ij_preset',GN.comp.Properties.VariableNames)
    if any(~isnumeric(GN.comp.V_dot_n_ij_preset))
        error('GN.comp: V_dot_n_ij_preset must be numeric.')
    elseif any(isinf(GN.comp.V_dot_n_ij_preset))
        error('GN.comp: V_dot_n_ij_preset must be a numeric value and must not be infinity.')
    end
    comp_flow_type(end+1) = {'V_dot_n_ij_preset'};
end

if length(comp_flow_type) > 1
    temp_text = cell(1,length(comp_flow_type)*2-1);
    temp_text(1:2:end) = comp_flow_type;
    temp_text(2:2:end-3) = {', '};
    temp_text(end-1) = {' and '};
    warning(['GN.comp: ',[temp_text{3:end}],' entries are ignored, as ',char(temp_text(1)),' is preferably used.'])
    GN.comp(:,comp_flow_type(2:end)) = [];
end

time_series_comp_flow = false; % UNDER CONSTRUCTION
if isfield(GN,'time_series')
    white_list = {'P_th_ij_preset__MW', 'P_th_ij_preset', 'V_dot_n_ij_preset__m3_per_day', 'V_dot_n_ij_preset__m3_per_h', 'm_dot_ij_preset__kg_per_s', 'V_dot_n_ij_preset'};
    comp_object_quantities = unique(GN.time_series.object_quantity);
    time_series_comp_flow = any(ismember(comp_object_quantities, white_list));
end

if isempty(comp_flow_type) && ~time_series_comp_flow
    % UNDER CONSTRUCTION: No presets necessary
    %         error(['GN.comp: information about comp flow is missing. GN.comp or GN.times_series must have at least one of these colums: ',...
    %             'P_th_ij_preset__MW, P_th_ij_preset, V_dot_n_ij_preset__m3_per_day, V_dot_n_ij_preset__m3_per_h, m_dot_ij_preset__kg_per_s or V_dot_n_ij_preset.'])
end

end