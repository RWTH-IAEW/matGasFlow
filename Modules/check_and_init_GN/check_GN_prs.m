function GN = check_GN_prs(GN)
%CHECK_GN_PRS
%   GN = check_GN_prs(GN)
%   Check and initialization of GN.prs and its variables (prs table)
%   list of variabels:
%       INPUT DATA
%           prs_ID
%           from_bus_ID
%           to_bus_ID
%       INPUT DATA - OPTIONAL FOR NON-ISOTHERMAL SIMULATION
%           T_controlled
%           T_ij_out
%           Q_dot_heater_cooler
%           gas_powered_heater
%           eta_heater
%           eta_cooler
%       INPUT DATA - OPTIONAL
%           in_service
%           slack_branch
%           exp_turbine
%           eta_s
%           eta_drive
%           P_th_ij_preset__MW, P_th_ij_preset, V_dot_n_ij_preset__m3_per_day,
%               V_dot_n_ij_preset__m3_per_h, m_dot_ij_preset__kg_per_s,
%               V_dot_n_ij_preset
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2022, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Check for prs in GN
if ~isfield(GN,'prs')
    return
elseif isempty(GN.prs)
    GN = rmfield(GN, 'prs');
    warning('GN.prs is empty.')
    return
end

%% #######################################################################
%  I N P U T   D A T A   -   R E Q U I R E D
%  #######################################################################
%% prs_ID
if ismember('prs_ID',GN.prs.Properties.VariableNames)
    if any(~isnumeric(GN.prs.prs_ID))
        error('GN.prs: prs_ID must be numeric.')
    elseif any(GN.prs.prs_ID <= 0 | round(GN.prs.prs_ID) ~= GN.prs.prs_ID | isinf(GN.prs.prs_ID))
        error('GN.bus: prs_ID must be positive integer.')
    elseif length(unique(GN.prs.prs_ID)) < length(GN.prs.prs_ID)
        prs_ID = sort(GN.prs.prs_ID);
        prs_ID_double = prs_ID([diff(prs_ID)==0;false]);
        error(['GN.prs: Double entries at prs_ID: ',num2str(prs_ID_double')])
    end
else
    error('GN.prs: prs_ID column is missing.')
end

%% from_bus_ID - (BRANCH VARIABLE)
if ismember('from_bus_ID',GN.prs.Properties.VariableNames)
    if any(~isnumeric(GN.prs.from_bus_ID))
        error('GN.prs: from_bus_ID must be numeric.')
    end
    idx = ismember(GN.prs.from_bus_ID, GN.bus.bus_ID);
    if ~all(idx)
        error(['GN.prs: These from_bus_ID entries do not exists: ',num2str(GN.prs.from_bus_ID(~idx)')])
    end
    GN.prs.from_bus_ID = GN.prs.from_bus_ID;
else
    error('GN.prs: from_bus_ID column is missing.')
end

%% to_bus_ID - (BRANCH VARIABLE)
if ismember('to_bus_ID',GN.prs.Properties.VariableNames)
    if any(~isnumeric(GN.prs.to_bus_ID))
        error('GN.prs: to_bus_ID must be numeric.')
    end
    idx = ismember(GN.prs.to_bus_ID, GN.bus.bus_ID);
    if ~all(idx)
        error(['GN.prs: These from_bus_ID entries do not exists: ',num2str(GN.prs.to_bus_ID(~idx)')])
    end
    GN.prs.to_bus_ID = GN.prs.to_bus_ID;
else
    error('GN.prs: to_bus_ID column is missing.')
end

%% to_bus_ID and from_bus_ID - (BRANCH VARIABLE)
if any(GN.prs.from_bus_ID == GN.prs.to_bus_ID)
    error(['GN.prs: from_bus_ID and to_bus_ID must not be the same. Check these prs IDs: ',...
        num2str(GN.prs.prs_ID(GN.prs.from_bus_ID == GN.prs.to_bus_ID)')])
end

%% #######################################################################
%  I N P U T   D A T A   -
%  O P T I O N A L   F O R   N O N - I S O T H E R M A L   S I M U L A T I O N
%  #######################################################################
if ~GN.isothermal
    %% T_controlled
    if ismember('T_controlled',GN.prs.Properties.VariableNames)
        if any(GN.prs.T_controlled ~= 0 & GN.prs.T_controlled ~= 1 & ~isnan(GN.prs.T_controlled))
            error(['GN.prs: T_controlled must be ''1'' (true), ''0'' (false) or ''NaN''(false). Check entries at these prs IDs: ',...
                num2str(...
                GN.prs.prs_ID(GN.prs.T_controlled ~= 0 & GN.prs.T_controlled ~= 1 & ~isnan(GN.prs.T_controlled))' ...
                )])
        end
        GN.prs.T_controlled(isnan(GN.prs.T_controlled)) = false;
        GN.prs.T_controlled(GN.prs.T_controlled == 0)   = false;
        GN.prs.T_controlled(GN.prs.T_controlled == 1)   = true;
        GN.prs.T_controlled = logical(GN.prs.T_controlled);
    else
        % Set default parameter
        GN.prs.T_controlled(:) = false;
    end
    
    %% T_ij_out
    if ismember('T_ij_out',GN.prs.Properties.VariableNames)
        if any(~isnumeric(GN.prs.T_ij_out))
            error('GN.prs: T_ij_out must be numeric.')
        elseif any(GN.prs.T_ij_out < 0 | isinf(GN.prs.T_ij_out))
            error('GN.prs: T_ij_out must be a positive numeric value or NaN.')
        end
    else
        GN.prs.T_ij_out(:) = NaN;
    end
    % Set default parameter
    GN.prs.T_ij_out(isnan(GN.prs.T_ij_out) & GN.prs.T_controlled) = GN.T_env;
    
    %% Q_dot_heater_cooler
    if ismember('Q_dot_heater_cooler',GN.prs.Properties.VariableNames)
        if any(~isnumeric(GN.prs.Q_dot_heater_cooler))
            error('GN.prs: Q_dot_heater_cooler must be numeric.')
        elseif any(isinf(GN.prs.Q_dot_heater_cooler))
            error('GN.prs: Q_dot_heater_cooler must be a numeric value or NaN.')
        end
    else
        GN.prs.Q_dot_heater_cooler(:) = NaN;
    end
    % Set default parameter
    GN.prs.Q_dot_heater_cooler(isnan(GN.prs.Q_dot_heater_cooler) & ~GN.prs.T_controlled) = 0;
    
    %% gas_powered_heater
    if ismember('gas_powered_heater',GN.prs.Properties.VariableNames)
        if any(~islogical(GN.prs.gas_powered_heater) & ~isnumeric(GN.prs.gas_powered_heater))
            error('GN.prs: gas_powered_heater must be a logical value.')
        elseif any(GN.prs.gas_powered_heater ~= 0 & GN.prs.gas_powered_heater ~= 1 & ~isnan(GN.prs.gas_powered_heater))
            error('GN.prs: gas_powered_heater must be ''1'' (true), ''0'' (false) or ''NaN''(false).')
        end
        GN.prs.gas_powered_heater(isnan(GN.prs.gas_powered_heater)) = false;
        GN.prs.gas_powered_heater(GN.prs.gas_powered_heater == 0)   = false;
        GN.prs.gas_powered_heater(GN.prs.gas_powered_heater==1)     = true;
        GN.prs.gas_powered_heater = logical(GN.prs.gas_powered_heater);
    else
        % Set default parameter
        GN.prs.gas_powered_heater(:) = false;
    end
    
    %% eta_heater
    if ismember('eta_heater',GN.prs.Properties.VariableNames)
        if any(~isnumeric(GN.prs.eta_heater))
            error('GN.prs: eta_heater must be numeric.')
        elseif any(GN.prs.eta_heater < 0 | GN.prs.eta_heater > 1 | isnan(GN.prs.eta_heater))
            error(['GN.prs: eta_heater must be larger than zero and less than or equal to one. Check entries at these prs IDs: ',...
                num2str( GN.prs.prs_ID(GN.prs.eta_heater < 0 | GN.prs.eta_heater > 1 | isnan(GN.prs.eta_heater))' )])
        end
    else
        % Set default parameter
        GN.prs.eta_heater(:) = 1;
    end
    
    %% eta_cooler
    if ismember('eta_cooler',GN.prs.Properties.VariableNames)
        if any(~isnumeric(GN.prs.eta_cooler))
            error('GN.prs: eta_cooler must be numeric.')
        elseif any(GN.prs.eta_cooler < 0 | GN.prs.eta_cooler > 1 | isnan(GN.prs.eta_cooler))
            error(['GN.prs: eta_cooler must be larger than zero and less than or equal to one. Check entries at these prs IDs: ',...
                num2str( GN.prs.prs_ID(GN.prs.eta_cooler < 0 | GN.prs.eta_cooler > 1 | isnan(GN.prs.eta_cooler))' )])
        end
    else
        % Set default parameter
        GN.prs.eta_cooler(:) = 1;
    end
end

%% #######################################################################
%  I N P U T   D A T A   -   O P T I O N A L
%  #######################################################################
%% in_service - (BRANCH VARIABLE)
if ismember('in_service',GN.prs.Properties.VariableNames)
    if any(~islogical(GN.prs.in_service) & ~isnumeric(GN.prs.in_service))
        error('GN.prs: in_service must be a logical value.')
    elseif any(GN.prs.in_service ~= 0 & GN.prs.in_service ~= 1 & ~isnan(GN.prs.in_service))
        error(['GN.prs: in_service must be ''1'' (true), ''0'' (false) or ''NaN''(false). Check entries at these prs IDs: ',...
            num2str(...
            GN.prs.prs_ID(GN.prs.in_service < 0 | GN.prs.in_service > 1)' ...
            )])
    end
    GN.prs.in_service(isnan(GN.prs.in_service)) = false;
    GN.prs.in_service(GN.prs.in_service == 0)   = false;
    GN.prs.in_service(GN.prs.in_service == 1)   = true;
    GN.prs.in_service = logical(GN.prs.in_service);
else
    % Set default parameter
    GN.prs.in_service(:) = true;
end

%% slack_branch - (BRANCH VARIABLE)
if ismember('slack_branch',GN.prs.Properties.VariableNames)
    if any(~islogical(GN.prs.slack_branch) & ~isnumeric(GN.prs.slack_branch))
        error('GN.prs: slack_branch must be a logical value.')
    elseif any(GN.prs.slack_branch ~= 0 & GN.prs.slack_branch ~= 1 & ~isnan(GN.prs.slack_branch))
        error(['GN.prs: slack_branch must be ''1'' (true), ''0'' (false) or ''NaN''(false). Check entries at these prs IDs: ',...
            num2str(...
            GN.prs.prs_ID(GN.prs.slack_branch < 0 | GN.prs.slack_branch > 1)' ...
            )])
    end
    GN.prs.slack_branch(isnan(GN.prs.slack_branch)) = false;
    GN.prs.slack_branch(GN.prs.slack_branch == 0) = false;
    GN.prs.slack_branch(GN.prs.slack_branch == 1) = true;
    GN.prs.slack_branch = logical(GN.prs.slack_branch);
else
    % Initialize slack_bus if not existing
    GN.prs.slack_branch(:) = false;
end

%% exp_turbine
if ismember('exp_turbine',GN.prs.Properties.VariableNames)
    if any(~islogical(GN.prs.exp_turbine) & ~isnumeric(GN.prs.exp_turbine))
        error('GN.prs: exp_turbine must be a logical value.')
    elseif any(GN.prs.exp_turbine ~= 0 & GN.prs.exp_turbine ~= 1 & ~isnan(GN.prs.exp_turbine))
        error('GN.prs: exp_turbine must be ''1'' (true), ''0'' (false) or ''NaN''(false).')
    end
    GN.prs.exp_turbine(isnan(GN.prs.exp_turbine)) = false;
    GN.prs.exp_turbine(GN.prs.exp_turbine == 0) = false;
    GN.prs.exp_turbine(GN.prs.exp_turbine == 1) = true;
    GN.prs.exp_turbine = logical(GN.prs.exp_turbine);
else
    % Set default parameter
    GN.prs.exp_turbine(:) = false;
end

%% eta_s
if ismember('eta_s',GN.prs.Properties.VariableNames)
    if any(~isnumeric(GN.prs.eta_s))
        error('GN.prs: eta_s must be numeric.')
    elseif any(GN.prs.eta_s < 0 | GN.prs.eta_s > 1)
        error('GN.eta_s: eta_s must be larger than zero and less than or equal to one.')
    end
elseif any(GN.prs.exp_turbine)
    % Set default parameter
    GN.prs.eta_s(:) = 1;
end

%% eta_drive
if ismember('eta_drive',GN.prs.Properties.VariableNames)
    if any(~isnumeric(GN.prs.eta_drive))
        error('GN.prs: eta_drive must be numeric.')
    elseif any(GN.prs.eta_drive < 0 | GN.prs.eta_drive > 1)
        error('GN.eta_s: eta_drive must be larger than zero and less than or equal to one.')
    end
elseif any(GN.prs.exp_turbine)
    % Set default parameter
    GN.prs.eta_drive(:) = 1;
end

%% P_th_ij_preset__MW, P_th_ij_preset, V_dot_n_ij_preset__m3_per_day, V_dot_n_ij_preset__m3_per_h, m_dot_ij_preset__kg_per_s, V_dot_n_ij_preset
prs_flow_type = {};

if ismember('P_th_ij_preset__MW',GN.prs.Properties.VariableNames)
    if any(~isnumeric(GN.prs.P_th_ij_preset__MW))
        error('GN.prs: P_th_ij_preset__MW must be numeric.')
    elseif any(isinf(GN.prs.P_th_ij_preset__MW))
        error('GN.prs: P_th_ij_preset__MW must be a numeric value and must not be infinity.')
    end
    prs_flow_type(end+1) = {'P_th_ij_preset__MW'};
end

if ismember('P_th_ij_preset',GN.prs.Properties.VariableNames)
    if any(~isnumeric(GN.prs.P_th_ij_preset))
        error('GN.prs: P_th_ij_preset must be numeric.')
    elseif any(isinf(GN.prs.P_th_ij_preset))
        error('GN.prs: P_th_ij_preset must be a numeric value and must not be infinity.')
    end
    prs_flow_type(end+1) = {'P_th_ij_preset'};
end

if ismember('V_dot_n_ij_preset__m3_per_day',GN.prs.Properties.VariableNames)
    if any(~isnumeric(GN.prs.V_dot_n_ij_preset__m3_per_day))
        error('GN.prs: V_dot_n_ij_preset__m3_per_day must be numeric.')
    elseif any(isinf(GN.prs.V_dot_n_ij_preset__m3_per_day))
        error('GN.prs: V_dot_n_ij_preset__m3_per_day must be a numeric value and must not be infinity.')
    end
    prs_flow_type(end+1) = {'V_dot_n_ij_preset__m3_per_day'};
end

if ismember('V_dot_n_ij_preset__m3_per_h',GN.prs.Properties.VariableNames)
    if any(~isnumeric(GN.prs.V_dot_n_ij_preset__m3_per_h))
        error('GN.prs: V_dot_n_ij_preset__m3_per_h must be numeric.')
    elseif any(isinf(GN.prs.V_dot_n_ij_preset__m3_per_h))
        error('GN.prs: V_dot_n_ij_preset__m3_per_h must be a numeric value and must not be infinity.')
    end
    prs_flow_type(end+1) = {'V_dot_n_ij_preset__m3_per_h'};
end

if ismember('m_dot_ij_preset__kg_per_s',GN.prs.Properties.VariableNames)
    if any(~isnumeric(GN.prs.m_dot_ij_preset__kg_per_s))
        error('GN.prs: m_dot_ij_preset__kg_per_s must be numeric.')
    elseif any(isinf(GN.prs.m_dot_ij_preset__kg_per_s))
        error('GN.prs: m_dot_ij_preset__kg_per_s must be a numeric value and must not be infinity.')
    end
    prs_flow_type(end+1) = {'m_dot_ij_preset__kg_per_s'};
end

if ismember('V_dot_n_ij_preset',GN.prs.Properties.VariableNames)
    if any(~isnumeric(GN.prs.V_dot_n_ij_preset))
        error('GN.prs: V_dot_n_ij_preset must be numeric.')
    elseif any(isinf(GN.prs.V_dot_n_ij_preset))
        error('GN.prs: V_dot_n_ij_preset must be a numeric value and must not be infinity.')
    end
    prs_flow_type(end+1) = {'V_dot_n_ij_preset'};
end

if length(prs_flow_type) > 1
    temp_text = cell(1,length(prs_flow_type)*2-1);
    temp_text(1:2:end) = prs_flow_type;
    temp_text(2:2:end-3) = {', '};
    temp_text(end-1) = {' and '};
    warning(['GN.prs: ',[temp_text{3:end}],' entries are ignored, as ',char(temp_text(1)),' is preferably used.'])
    GN.prs(:,prs_flow_type(2:end)) = [];
end

time_series_prs_flow = false; % UNDER CONSTRUCTION
if isfield(GN,'time_series')
    white_list = {'P_th_ij_preset__MW', 'P_th_ij_preset', 'V_dot_n_ij_preset__m3_per_day', 'V_dot_n_ij_preset__m3_per_h', 'm_dot_ij_preset__kg_per_s', 'V_dot_n_ij_preset'};
    prs_object_quantities = unique(GN.time_series.object_quantity);
    time_series_prs_flow = any(ismember(prs_object_quantities, white_list));
end

if isempty(prs_flow_type) && ~time_series_prs_flow
    % UNDER CONSTRUCTION: No presets necessary
    %         error(['GN.prs: information about prs flow is missing. GN.prs or GN.times_series must have at least one of these colums: ',...
    %             'P_th_ij_preset__MW, P_th_ij_preset, V_dot_n_ij_preset__m3_per_day, V_dot_n_ij_preset__m3_per_h, m_dot_ij_preset__kg_per_s or V_dot_n_ij_preset.'])
end

end