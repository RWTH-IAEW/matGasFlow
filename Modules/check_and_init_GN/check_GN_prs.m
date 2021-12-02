function GN = check_GN_prs(GN)
%CHECKGN_PRS Summary of this function goes here
%   Detailed explanation goes here
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
<<<<<<< HEAD
%   Copyright (c) 2020-2022, High Voltage Equipment and Grids,
=======
%   Copyright (c) 2020-2021, High Voltage Equipment and Grids,
>>>>>>> Merge to public repo (#1)
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

<<<<<<< HEAD
%% Check for prs in GN
if ~isfield(GN,'prs')
    return
elseif isempty(GN.prs)
    GN = rmfield(GN, 'prs');
    warning('GN.prs is empty.')
    return
end

%% #######################################################################
%  R E Q U I R E D
%  #######################################################################
%% prs_ID
if any(strcmp('prs_ID',GN.prs.Properties.VariableNames))
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

%% #######################################################################
%  B R A N C H   V A R I A B L E S
%  #######################################################################
%% from_bus_ID
if any(strcmp('from_bus_ID',GN.prs.Properties.VariableNames))
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

%% to_bus_ID
if any(strcmp('to_bus_ID',GN.prs.Properties.VariableNames))
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

%% to_bus_ID and from_bus_ID
if any(GN.prs.from_bus_ID == GN.prs.to_bus_ID)
    error(['GN.prs: from_bus_ID and to_bus_ID must not be the same. Check these prs IDs: ',...
        num2str(GN.prs.prs_ID(GN.prs.from_bus_ID == GN.prs.to_bus_ID)')])
end

%% in_service
if any(strcmp('in_service',GN.prs.Properties.VariableNames))
    if any(~islogical(GN.prs.in_service) & ~isnumeric(GN.prs.in_service))
        error('GN.prs: in_service must be a logical value.')
    elseif any(GN.prs.in_service ~= 0 & GN.prs.in_service ~= 1 & ~isnan(GN.prs.in_service))
        error(['GN.prs: in_service must be ''1'' (true), ''0'' (false) or ''NaN''(false). Check entries at these prs IDs: ',...
            num2str(...
            GN.prs.prs_ID(GN.prs.in_service < 0 | GN.prs.in_service > 1)' ...
            )])
    end
    GN.prs.in_service(isnan(GN.prs.in_service)) = false;
    GN.prs.in_service(GN.prs.in_service == 0) = false;
    GN.prs.in_service(GN.prs.in_service == 1) = true;
    GN.prs.in_service = logical(GN.prs.in_service);
else
    % No error message necessary
    GN.prs.in_service = true(size(GN.prs,1),1);
end

%% slack_branch
if any(strcmp('slack_branch',GN.prs.Properties.VariableNames))
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
    GN.prs.slack_branch = false(size(GN.prs,1),1);
end

%% #######################################################################
%  P R S   V A R I A B L E S
%  #######################################################################
%% p_out__barg
if any(strcmp('p_out__barg',GN.prs.Properties.VariableNames))
    if any(~isnumeric(GN.prs.p_out__barg))
        error('GN.prs: p_out__barg must be numeric.')
    elseif any(GN.prs.p_out__barg <= 0 | isinf(GN.prs.p_out__barg))
        error('GN.prs: The pressure p_out__barg must be positive double values.')
    end
    
    if any(strcmp('p_i',GN.prs.Properties.VariableNames))
        warning('GN.prs: p_i entries are ignored, as p_out__barg entries are preferably used.')
    end
end

%% P_th_ij_preset__MW, P_th_ij_preset, V_dot_n_ij_preset__m3_per_day, V_dot_n_ij_preset__m3_per_h, m_dot_ij_preset__kg_per_s, V_dot_n_ij_preset
prs_flow_type = {};

if any(strcmp('P_th_ij_preset__MW',GN.prs.Properties.VariableNames))
    if any(~isnumeric(GN.prs.P_th_ij_preset__MW))
        error('GN.prs: P_th_ij_preset__MW must be numeric.')
    elseif any(isinf(GN.prs.P_th_ij_preset__MW))
        error('GN.prs: P_th_ij_preset__MW must be a numeric value and must not be infinity.')
    end
    prs_flow_type(end+1) = {'P_th_ij_preset__MW'};
end

if any(strcmp('P_th_ij_preset',GN.prs.Properties.VariableNames))
    if any(~isnumeric(GN.prs.P_th_ij_preset))
        error('GN.prs: P_th_ij_preset must be numeric.')
    elseif any(isinf(GN.prs.P_th_ij_preset))
        error('GN.prs: P_th_ij_preset must be a numeric value and must not be infinity.')
    end
    prs_flow_type(end+1) = {'P_th_ij_preset'};
end

if any(strcmp('V_dot_n_ij_preset__m3_per_day',GN.prs.Properties.VariableNames))
    if any(~isnumeric(GN.prs.V_dot_n_ij_preset__m3_per_day))
        error('GN.prs: V_dot_n_ij_preset__m3_per_day must be numeric.')
    elseif any(isinf(GN.prs.V_dot_n_ij_preset__m3_per_day))
        error('GN.prs: V_dot_n_ij_preset__m3_per_day must be a numeric value and must not be infinity.')
    end
    prs_flow_type(end+1) = {'V_dot_n_ij_preset__m3_per_day'};
end

if any(strcmp('V_dot_n_ij_preset__m3_per_h',GN.prs.Properties.VariableNames))
    if any(~isnumeric(GN.prs.V_dot_n_ij_preset__m3_per_h))
        error('GN.prs: V_dot_n_ij_preset__m3_per_h must be numeric.')
    elseif any(isinf(GN.prs.V_dot_n_ij_preset__m3_per_h))
        error('GN.prs: V_dot_n_ij_preset__m3_per_h must be a numeric value and must not be infinity.')
    end
    prs_flow_type(end+1) = {'V_dot_n_ij_preset__m3_per_h'};
end

if any(strcmp('m_dot_ij_preset__kg_per_s',GN.prs.Properties.VariableNames))
    if any(~isnumeric(GN.prs.m_dot_ij_preset__kg_per_s))
        error('GN.prs: m_dot_ij_preset__kg_per_s must be numeric.')
    elseif any(isinf(GN.prs.m_dot_ij_preset__kg_per_s))
        error('GN.prs: m_dot_ij_preset__kg_per_s must be a numeric value and must not be infinity.')
    end
    prs_flow_type(end+1) = {'m_dot_ij_preset__kg_per_s'};
end

if any(strcmp('V_dot_n_ij_preset',GN.prs.Properties.VariableNames))
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

time_series_prs_flow = false;
if isfield(GN,'time_series')
    white_list = {'P_th_ij_preset__MW', 'P_th_ij_preset', 'V_dot_n_ij_preset__m3_per_day', 'V_dot_n_ij_preset__m3_per_h', 'm_dot_ij_preset__kg_per_s', 'V_dot_n_ij_preset'};
    prs_object_quantities = unique(GN.time_series.object_quantity);
    time_series_prs_flow = any(ismember(prs_object_quantities, white_list));
end

if isempty(prs_flow_type) && ~time_series_prs_flow
    % UNDER CONSTRCUTION: No presets necessary
    %         error(['GN.prs: information about prs flow is missing. GN.prs or GN.times_series must have at least one of these colums: ',...
    %             'P_th_ij_preset__MW, P_th_ij_preset, V_dot_n_ij_preset__m3_per_day, V_dot_n_ij_preset__m3_per_h, m_dot_ij_preset__kg_per_s or V_dot_n_ij_preset.'])
end

%% preset
if any(strcmp('preset',GN.prs.Properties.VariableNames))
    if any(~islogical(GN.prs.preset) & ~isnumeric(GN.prs.preset))
        error('GN.prs: preset must be a logical value.')
    elseif any(GN.prs.preset ~= 0 & GN.prs.preset ~= 1 & ~isnan(GN.prs.preset))
        error(['GN.prs: preset must be ''1'' (true), ''0'' (false) or ''NaN''(false). Check entries at these prs IDs: ',...
            num2str(...
            GN.prs.prs_ID(GN.prs.preset < 0 | GN.prs.preset > 1)' ...
            )])
    end
    GN.prs.preset(isnan(GN.prs.preset)) = false;
    GN.prs.preset(GN.prs.preset == 0) = false;
    GN.prs.preset(GN.prs.preset == 1) = true;
    GN.prs.preset = logical(GN.prs.preset);
elseif ~isempty(prs_flow_type)
    GN.prs.preset(:) = false;
    GN.prs.preset(~isnan(table2array(GN.prs(:,prs_flow_type(1))))) = true;
end

%% exp_turbine
if any(strcmp('exp_turbine',GN.prs.Properties.VariableNames))
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
    % No error message necessary
    GN.prs.exp_turbine = false(size(GN.prs,1),1);
end

%% eta_s
if any(strcmp('eta_s',GN.prs.Properties.VariableNames))
    if any(~isnumeric(GN.prs.eta_s))
        error('GN.prs: eta_s must be numeric.')
    elseif any(GN.prs.eta_s < 0 | GN.prs.eta_s > 1)
        error('GN.eta_s: eta_s must be larger than zero and less than or equal to one.')
    end
elseif any(GN.prs.exp_turbine)
    error('GN.prs: eta_s column is missing.')
end

%% eta_drive
if any(strcmp('eta_drive',GN.prs.Properties.VariableNames))
    if any(~isnumeric(GN.prs.eta_drive))
        error('GN.prs: eta_drive must be numeric.')
    elseif any(GN.prs.eta_drive < 0 | GN.prs.eta_drive > 1)
        error('GN.eta_s: eta_drive must be larger than zero and less than or equal to one.')
    end
elseif any(GN.prs.exp_turbine)
    error('GN.prs: eta_drive column is missing.')
end

%% #######################################################################
%  N O N - I S O T H E R M A L   P R O P E R T I E S
%  #######################################################################
if GN.isothermal == 0
    %% T_controlled
    if any(strcmp('T_controlled',GN.prs.Properties.VariableNames))
        if any(GN.prs.T_controlled ~= 0 & GN.prs.T_controlled ~= 1 & ~isnan(GN.prs.T_controlled))
            error(['GN.prs: T_controlled must be ''1'' (true), ''0'' (false) or ''NaN''(false). Check entries at these prs IDs: ',...
                num2str(...
                GN.prs.prs_ID(GN.prs.T_controlled ~= 0 & GN.prs.T_controlled ~= 1 & ~isnan(GN.prs.T_controlled))' ...
                )])
        end
        GN.prs.T_controlled(isnan(GN.prs.T_controlled)) = false;
        GN.prs.T_controlled(GN.prs.T_controlled == 0) = false;
        GN.prs.T_controlled(GN.prs.T_controlled == 1) = true;
        GN.prs.T_controlled = logical(GN.prs.T_controlled);
    else
        error('GN.prs: T_controlled column is missing.')
    end
    
    %% Q_dot_heater
    if any(strcmp('Q_dot_heater',GN.prs.Properties.VariableNames))
        if any(~isnumeric(GN.prs.Q_dot_heater))
            error('GN.prs: Q_dot_heater must be numeric.')
        elseif any(isinf(GN.prs.Q_dot_heater))
            error('GN.prs: Q_dot_heater must be a numeric value or NaN.')
        end
        GN.prs.Q_dot_heater(~GN.prs.T_controlled & isnan(GN.prs.T_controlled)) = 0;
    else
        GN.prs.Q_dot_heater = NaN(size(GN.prs,1),1);
        GN.prs.Q_dot_heater(GN.prs.T_controlled == 0) = 0;
        % No error or warning message necessary.
    end
    
    %% T_to_bus
    if any(strcmp('T_to_bus',GN.prs.Properties.VariableNames))
        if any(~isnumeric(GN.prs.T_to_bus))
            error('GN.prs: T_to_bus must be numeric.')
        elseif any(GN.prs.T_to_bus < 0 | isinf(GN.prs.T_to_bus))
            error('GN.prs: T_to_bus must be a positive numeric value or NaN.')
        elseif any(GN.prs.T_controlled & isnan(GN.prs.T_to_bus))
            error('GN.prs: T_controlled pressure regulator stations need T_to_bus values.')
        end
        if any(~GN.prs.T_controlled & ~isnan(GN.prs.T_to_bus))
            GN.prs.T_to_bus(~GN.prs.T_controlled & ~isnan(GN.prs.T_to_bus)) = NaN;
            warning('GN.prs: T_to_bus entries have been reset to NaN for all GN.prs.T_controlled = false.')
        end
    elseif any(GN.prs.T_controlled)
        error('GN.prs: T_controlled column missing. Temperature controlled pressure regulator stations need T_to_bus values.')
    end
    
    %% gas_powered_heater
    if any(strcmp('gas_powered_heater',GN.prs.Properties.VariableNames))
        if any(~islogical(GN.prs.gas_powered_heater) & ~isnumeric(GN.prs.gas_powered_heater))
            error('GN.prs: gas_powered_heater must be a logical value.')
        elseif any(GN.prs.gas_powered_heater ~= 0 & GN.prs.gas_powered_heater ~= 1 & ~isnan(GN.prs.gas_powered_heater))
            error('GN.prs: gas_powered_heater must be ''1'' (true), ''0'' (false) or ''NaN''(false).')
        end
        GN.prs.gas_powered_heater(isnan(GN.prs.gas_powered_heater)) = false;
        GN.prs.gas_powered_heater(GN.prs.gas_powered_heater == 0) = false;
        GN.prs.gas_powered_heater(GN.prs.gas_powered_heater==1) = true;
        GN.prs.gas_powered_heater = logical(GN.prs.gas_powered_heater);
    end
    %% eta_heat
    if any(strcmp('eta_heat',GN.prs.Properties.VariableNames))
        if any(~isnumeric(GN.prs.eta_heat))
            error('GN.prs: eta_heat must be numeric.')
        elseif any(GN.prs.eta_heat < 0 | GN.prs.eta_heat > 1 | isnan(GN.prs.eta_heat))
            error(['GN.prs: eta_heat must be larger than zero and less than or equal to one. Check entries at these prs IDs: ',...
                num2str( GN.prs.prs_ID(GN.prs.eta_heat < 0 | GN.prs.eta_heat > 1 | isnan(GN.prs.eta_heat))' )])
        end
    else
        warning('GN.prs: eta_heat column might be missing');
    end
    
    %% eta_cool
    if any(strcmp('eta_cool',GN.prs.Properties.VariableNames))
        if any(~isnumeric(GN.prs.eta_cool))
            error('GN.prs: eta_cool must be numeric.')
        elseif any(GN.prs.eta_cool < 0 | GN.prs.eta_cool > 1 | isnan(GN.prs.eta_cool))
            error(['GN.prs: eta_cool must be larger than zero and less than or equal to one. Check entries at these prs IDs: ',...
                num2str( GN.prs.prs_ID(GN.prs.eta_cool < 0 | GN.prs.eta_cool > 1 | isnan(GN.prs.eta_cool))' )])
        end
    else
        warning('GN.prs: eta_cool column might be missing');
    end
end
=======
%%
if isfield(GN,'prs')
    if isempty(GN.prs)
        error('GN.prs is empty.')
    end
    
    %% prs_ID
    if any(strcmp('prs_ID',GN.prs.Properties.VariableNames))
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
    
    %% #######################################################################
    %  B R A N C H   V A R I A B L E S
    %  #######################################################################
    %% from_bus_ID
    if any(strcmp('from_bus_ID',GN.prs.Properties.VariableNames))
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
    
    %% to_bus_ID
    if any(strcmp('to_bus_ID',GN.prs.Properties.VariableNames))
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
    
    %% to_bus_ID and from_bus_ID
    if any(GN.prs.from_bus_ID == GN.prs.to_bus_ID)
        error(['GN.prs: from_bus_ID and to_bus_ID must not be the same. Check these prs IDs: ',...
        num2str(GN.prs.prs_ID(GN.prs.from_bus_ID == GN.prs.to_bus_ID)')])
    end
    
    %% in_service
    if any(strcmp('in_service',GN.prs.Properties.VariableNames))
        if any(~islogical(GN.prs.in_service) & ~isnumeric(GN.prs.in_service))
            error('GN.prs: in_service must be a logical value.')
        elseif any(GN.prs.in_service ~= 0 & GN.prs.in_service ~= 1 & ~isnan(GN.prs.in_service))
            error(['GN.prs: in_service must be ''1'' (true), ''0'' (false) or ''NaN''(false). Check entries at these prs IDs: ',...
                num2str(...
                GN.prs.prs_ID(GN.prs.in_service < 0 | GN.prs.in_service > 1)' ...
                )])
        end
        GN.prs.in_service(isnan(GN.prs.in_service)) = false;
        GN.prs.in_service(GN.prs.in_service == 0) = false;
        GN.prs.in_service(GN.prs.in_service == 1) = true;
        GN.prs.in_service = logical(GN.prs.in_service);
    else
        % No error message necessary
        GN.prs.in_service = true(size(GN.prs,1),1);
    end
    
    %% #######################################################################
    %  P R S   V A R I A B L E S
    %  #######################################################################
    %% p_out__barg
    if any(strcmp('p_out__barg',GN.prs.Properties.VariableNames))
        if any(~isnumeric(GN.prs.p_out__barg))
            error('GN.prs: p_out__barg must be numeric.')
        elseif any(GN.prs.p_out__barg <= 0 | isinf(GN.prs.p_out__barg))
            error('GN.prs: The pressure p_out__barg must be positive double values.')
        end
        
        if any(strcmp('p_i',GN.prs.Properties.VariableNames))
            warning('GN.prs: p_i entries are ignored, as p_out__barg entries are preferably used.')
        end
    else
        error('GN.prs: p_out__barg column is missing.')
    end
    
    %% exp_turbine
    if any(strcmp('exp_turbine',GN.prs.Properties.VariableNames))
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
        error('GN.prs: exp_turbine column is missing.')
    end
    
    %% eta_s
    if any(strcmp('eta_s',GN.prs.Properties.VariableNames))
        if any(~isnumeric(GN.prs.eta_s))
            error('GN.prs: eta_s must be numeric.')
        elseif any(GN.prs.eta_s < 0 | GN.prs.eta_s > 1)
            error('GN.eta_s: eta_s must be larger than zero and less than or equal to one.')
        end
    else
        error('GN.prs: eta_s column is missing.')
    end
    
    %% eta_drive
    if any(strcmp('eta_drive',GN.prs.Properties.VariableNames))
        if any(~isnumeric(GN.prs.eta_drive))
            error('GN.prs: eta_drive must be numeric.')
        elseif any(GN.prs.eta_drive < 0 | GN.prs.eta_drive > 1)
            error('GN.eta_s: eta_drive must be larger than zero and less than or equal to one.')
        end
    else
        error('GN.prs: eta_drive column is missing.')
    end
    
    %% #######################################################################
    %  N O N - I S O T H E R M A L   P R O P E R T I E S
    %  #######################################################################
    if GN.isothermal == 0
        %% T_controlled
        if any(strcmp('T_controlled',GN.prs.Properties.VariableNames))
            if any(GN.prs.T_controlled ~= 0 & GN.prs.T_controlled ~= 1 & ~isnan(GN.prs.T_controlled))
                error(['GN.prs: T_controlled must be ''1'' (true), ''0'' (false) or ''NaN''(false). Check entries at these prs IDs: ',...
                    num2str(...
                    GN.prs.prs_ID(GN.prs.T_controlled ~= 0 & GN.prs.T_controlled ~= 1 & ~isnan(GN.prs.T_controlled))' ...
                    )])
            end
            GN.prs.T_controlled(isnan(GN.prs.T_controlled)) = false;
            GN.prs.T_controlled(GN.prs.T_controlled == 0) = false;
            GN.prs.T_controlled(GN.prs.T_controlled == 1) = true;
            GN.prs.T_controlled = logical(GN.prs.T_controlled);
        else
            error('GN.prs: T_controlled column is missing.')
        end
        
        %% Q_dot_heater
        if any(strcmp('Q_dot_heater',GN.prs.Properties.VariableNames))
            if any(~isnumeric(GN.prs.Q_dot_heater))
                error('GN.prs: Q_dot_heater must be numeric.')
            elseif any(isinf(GN.prs.Q_dot_heater))
                error('GN.prs: Q_dot_heater must be a numeric value or NaN.')
            end
            GN.prs.Q_dot_heater(~GN.prs.T_controlled & isnan(GN.prs.T_controlled)) = 0;
        else
            GN.prs.Q_dot_heater = NaN(size(GN.prs,1),1);
            GN.prs.Q_dot_heater(GN.prs.T_controlled == 0) = 0;
            % No error or warning message necessary.
        end
        
        %% T_to_bus
        if any(strcmp('T_to_bus',GN.prs.Properties.VariableNames))
            if any(~isnumeric(GN.prs.T_to_bus))
                error('GN.prs: T_to_bus must be numeric.')
            elseif any(GN.prs.T_to_bus < 0 | isinf(GN.prs.T_to_bus))
                error('GN.prs: T_to_bus must be a positive numeric value or NaN.')
            elseif any(GN.prs.T_controlled & isnan(GN.prs.T_to_bus))
                error('GN.prs: T_controlled pressure regulator stations need T_to_bus values.')
            end
            if any(~GN.prs.T_controlled & ~isnan(GN.prs.T_to_bus))
                GN.prs.T_to_bus(~GN.prs.T_controlled & ~isnan(GN.prs.T_to_bus)) = NaN;
                warning('GN.prs: T_to_bus entries have been reset to NaN for all GN.prs.T_controlled = false.')
            end
        elseif any(GN.prs.T_controlled)
            error('GN.prs: T_controlled column missing. Temperature controlled pressure regulator stations need T_to_bus values.')
        end
        
        %% gas_powered_heater
        if any(strcmp('gas_powered_heater',GN.prs.Properties.VariableNames))
            if any(~islogical(GN.prs.gas_powered_heater) & ~isnumeric(GN.prs.gas_powered_heater))
                error('GN.prs: gas_powered_heater must be a logical value.')
            elseif any(GN.prs.gas_powered_heater ~= 0 & GN.prs.gas_powered_heater ~= 1 & ~isnan(GN.prs.gas_powered_heater))
                error('GN.prs: gas_powered_heater must be ''1'' (true), ''0'' (false) or ''NaN''(false).')
            end
            GN.prs.gas_powered_heater(isnan(GN.prs.gas_powered_heater)) = false;
            GN.prs.gas_powered_heater(GN.prs.gas_powered_heater == 0) = false;
            GN.prs.gas_powered_heater(GN.prs.gas_powered_heater==1) = true;
            GN.prs.gas_powered_heater = logical(GN.prs.gas_powered_heater);
        end
    end
end
end
>>>>>>> Merge to public repo (#1)

