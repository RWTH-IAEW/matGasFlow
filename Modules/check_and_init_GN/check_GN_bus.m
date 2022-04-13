function GN = check_GN_bus(GN)
%CHECK_GN_BUS Check bus table (GN.bus)
%   GN = check_GN_bus(GN)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2022, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Check for busses in GN
if ~isfield(GN,'bus')
    error('GN has no bus field.')
elseif isempty(GN.bus)
    error('GN.bus is empty.')
end

%% #######################################################################
%  R E Q U I R E D
%  #######################################################################
%% bus_ID
if ismember('bus_ID',GN.bus.Properties.VariableNames)
    if any(~isnumeric(GN.bus.bus_ID))
        error('GN.bus: bus_ID must be numeric.')
    elseif any(GN.bus.bus_ID < 0 | round(GN.bus.bus_ID) ~= GN.bus.bus_ID | isinf(GN.bus.bus_ID))
        error('GN.bus: bus_ID must be positive integer.')
    elseif length(unique(GN.bus.bus_ID)) < length(GN.bus.bus_ID)
        bus_ID = sort(GN.bus.bus_ID);
        bus_ID_double = bus_ID([diff(bus_ID)==0;false]);
        error(['GN.bus: Duplicate entries at bus_ID: ',num2str(bus_ID_double')])
    end
else
    error('GN.bus: bus_ID column is missing.')
end

%% p_i__barg
if ismember('p_i__barg',GN.bus.Properties.VariableNames)
    if any(~isnumeric(GN.bus.p_i__barg))
        error('GN.bus: p_i__barg must be numeric.')
    elseif any(GN.bus.p_i__barg < 0 | isinf(GN.bus.p_i__barg))
        error('GN.bus: Pressure values p_i__barg must be positive numeric value.')
    end
else
    error('GN.bus: p_i__barg column is missing.')
end

%% p_i_min__barg
if ismember('p_i_min__barg',GN.bus.Properties.VariableNames)
    if any(~isnumeric(GN.bus.p_i_min__barg))
        error('GN.bus: p_i_min__barg must be numeric.')
    elseif any(GN.bus.p_i_min__barg < 0 | isinf(GN.bus.p_i_min__barg))
        error('GN.bus: Pressure values p_i_min__barg must be positive numeric value.')
    elseif any(isnan(GN.bus.p_i_min__barg))
        error('GN.bus: If any p_i_min__barg values are available, all busses need p_i_min__barg values.')
    end
elseif any(ismember({'p_i_0__barg','p_i_max__barg'},GN.bus.Properties.VariableNames))
    error('GN.bus: p_i_0__barg and p_i_max__barg values are available but p_i_min__barg values are missing.')
end

%% p_i_max__barg
if ismember('p_i_max__barg',GN.bus.Properties.VariableNames)
    if any(~isnumeric(GN.bus.p_i_max__barg))
        error('GN.bus: p_i_max__barg must be numeric.')
    elseif any(GN.bus.p_i_max__barg < 0 | isinf(GN.bus.p_i_max__barg))
        error('GN.bus: Pressure values p_i_max__barg must be positive numeric value.')
    elseif any(isnan(GN.bus.p_i_max__barg))
        error('GN.bus: If any p_i_max__barg values are available, all busses need p_i_max__barg values.')
    end
elseif any(ismember({'p_i_min__barg','p_i_0__barg'},GN.bus.Properties.VariableNames))
    error('GN.bus: p_i_min__barg and p_i_0__barg values are available but p_i_max__barg values are missing.')
end

%% p_i_min__barg and p_i_max__barg
if all(ismember({'p_i_min__barg','p_i_max__barg'},GN.bus.Properties.VariableNames))
    if any(GN.bus.p_i_min__barg > GN.bus.p_i_max__barg)
        error('GN.bus: All p_i_min__barg values must be less than or equal to p_i_max__barg.')
    end
end

%% slack_bus
if ismember('slack_bus',GN.bus.Properties.VariableNames)
    if any(~islogical(GN.bus.slack_bus) & ~isnumeric(GN.bus.slack_bus))
        error('GN.bus: slack_bus must be a logical value.')
    elseif any(GN.bus.slack_bus ~= 0 & GN.bus.slack_bus ~= 1 & ~isnan(GN.bus.slack_bus))
        error('GN.bus: slack_bus must be ''1'' (true), ''0'' (false) or ''NaN''(false).')
    end
    GN.bus.slack_bus(isnan(GN.bus.slack_bus)) = false;
    GN.bus.slack_bus(GN.bus.slack_bus == 0) = false;
    GN.bus.slack_bus(GN.bus.slack_bus == 1) = true;
    GN.bus.slack_bus = logical(GN.bus.slack_bus);
    if ~any(GN.bus.slack_bus) && any(isnan(GN.bus.p_i__barg)) && all(~isnan(GN.bus.p_i__barg))
        GN.bus.slack_bus(~isnan(GN.bus.p_i__barg)) = true;
        warning('GN.bus: There must be at least one slack bus. All busses with p_i__barg values have been choosen to be slack busses.')
    end
    if any(GN.bus.slack_bus & isnan(GN.bus.p_i__barg))
        error(['GN.bus: p_i__barg entries at slack busses are missing. Check theses bus_IDs: ',...
            num2str(find(GN.bus.slack_bus & isnan(GN.bus.p_i__barg))')])
    end
else
    % Initialize slack_bus if not existing
    GN.bus.slack_bus(:) = false;
    GN.bus.slack_bus(~isnan(GN.bus.p_i__barg)) = true;
    GN.bus = movevars(GN.bus,'slack_bus','Before','p_i__barg');
end

%% P_th_i__MW, P_th_i, V_dot_n_i__m3_per_day, V_dot_n_i__m3_per_h, m_dot_i__kg_per_s, V_dot_n_i
bus_demand_feed_in = {};

if ismember('P_th_i__MW',GN.bus.Properties.VariableNames)
    if any(~isnumeric(GN.bus.P_th_i__MW))
        error('GN.bus: P_th_i__MW must be numeric.')
    elseif any(isinf(GN.bus.P_th_i__MW))
        error('GN.bus: P_th_i__MW must be a numeric value and must not be infinity.')
    end
    GN.bus.P_th_i__MW(isnan(GN.bus.P_th_i__MW)) = 0;
    bus_demand_feed_in(end+1) = {'P_th_i__MW'};
end

if ismember('P_th_i',GN.bus.Properties.VariableNames)
    if any(~isnumeric(GN.bus.P_th_i))
        error('GN.bus: P_th_i must be numeric.')
    elseif any(isinf(GN.bus.P_th_i))
        error('GN.bus: P_th_i must be a numeric value and must not be infinity.')
    end
    GN.bus.P_th_i(isnan(GN.bus.P_th_i)) = 0;
    bus_demand_feed_in(end+1) = {'P_th_i'};
end

if ismember('V_dot_n_i__m3_per_day',GN.bus.Properties.VariableNames)
    if any(~isnumeric(GN.bus.V_dot_n_i__m3_per_day))
        error('GN.bus: V_dot_n_i__m3_per_day must be numeric.')
    elseif any(isinf(GN.bus.V_dot_n_i__m3_per_day))
        error('GN.bus: V_dot_n_i__m3_per_day must be a numeric value and must not be infinity.')
    end
    GN.bus.V_dot_n_i__m3_per_day(isnan(GN.bus.V_dot_n_i__m3_per_day)) = 0;
    bus_demand_feed_in(end+1) = {'V_dot_n_i__m3_per_day'};
end

if ismember('V_dot_n_i__m3_per_h',GN.bus.Properties.VariableNames)
    if any(~isnumeric(GN.bus.V_dot_n_i__m3_per_h))
        error('GN.bus: V_dot_n_i__m3_per_h must be numeric.')
    elseif any(isinf(GN.bus.V_dot_n_i__m3_per_h))
        error('GN.bus: V_dot_n_i__m3_per_h must be a numeric value and must not be infinity.')
    end
    GN.bus.V_dot_n_i__m3_per_h(isnan(GN.bus.V_dot_n_i__m3_per_h)) = 0;
    bus_demand_feed_in(end+1) = {'V_dot_n_i__m3_per_h'};
end

if ismember('m_dot_i__kg_per_s',GN.bus.Properties.VariableNames)
    if any(~isnumeric(GN.bus.m_dot_i__kg_per_s))
        error('GN.bus: m_dot_i__kg_per_s must be numeric.')
    elseif any(isinf(GN.bus.m_dot_i__kg_per_s))
        error('GN.bus: m_dot_i__kg_per_s must be a numeric value and must not be infinity.')
    end
    GN.bus.m_dot_i__kg_per_s(isnan(GN.bus.m_dot_i__kg_per_s)) = 0;
    bus_demand_feed_in(end+1) = {'m_dot_i__kg_per_s'};
end

if ismember('V_dot_n_i',GN.bus.Properties.VariableNames)
    if any(~isnumeric(GN.bus.V_dot_n_i))
        error('GN.bus: V_dot_n_i must be numeric.')
    elseif any(isinf(GN.bus.V_dot_n_i))
        error('GN.bus: V_dot_n_i must be a numeric value and must not be infinity.')
    end
    GN.bus.V_dot_n_i(isnan(GN.bus.V_dot_n_i)) = 0;
    bus_demand_feed_in(end+1) = {'V_dot_n_i'};
end

if length(bus_demand_feed_in) > 1
    temp_text = cell(1,length(bus_demand_feed_in)*2-1);
    temp_text(1:2:end) = bus_demand_feed_in;
    temp_text(2:2:end-3) = {', '};
    temp_text(end-1) = {' and '};
    warning(['GN.bus: ',[temp_text{3:end}],' entries are ignored, as ',char(temp_text(1)),' is preferably used.'])
    GN.bus(:,bus_demand_feed_in(2:end)) = [];
end

time_series_bus_demand_feed_in = false;
if isfield(GN,'time_series')
    white_list = {'P_th_i__MW', 'P_th_i', 'V_dot_n_i__m3_per_day', 'V_dot_n_i__m3_per_h', 'm_dot_i__kg_per_s', 'V_dot_n_i'};
    bus_object_quantities = unique(GN.time_series.object_quantity);
    time_series_bus_demand_feed_in = any(ismember(bus_object_quantities, white_list));
end

if isempty(bus_demand_feed_in) && ~time_series_bus_demand_feed_in
    error(['GN.bus: information about bus demand or feed is missing. GN.bus or GN.times_series must have at least one of these colums: ',...
        'P_th_i__MW, P_th_i, V_dot_n_i__m3_per_day, V_dot_n_i__m3_per_h, m_dot_i__kg_per_s or V_dot_n_i.'])
end

%% T_i
if ismember('T_i',GN.bus.Properties.VariableNames)
    if any(~isnumeric(GN.bus.T_i))
        error('GN.bus: T_i must be numeric.')
    elseif any(GN.bus.T_i <= 0 | isinf(GN.bus.T_i))
        error('GN.bus: T_i [K] must be positive numeric value.')
    elseif all(isnan(GN.bus.T_i))
        GN.bus.T_i(isnan(GN.bus.T_i)) = GN.T_env;
    end
else
    GN.bus.T_i(:) = GN.T_env;
end

%% #######################################################################
%  A U X I L I A R Y   V A R I A B L E S
%  #######################################################################

%% source_bus
if GN.isothermal == 0
    %% source_bus
    if ismember('P_th_i__MW',GN.bus.Properties.VariableNames)
        GN.bus.source_bus = GN.bus.P_th_i__MW < 0;
    elseif ismember('P_th_i',GN.bus.Properties.VariableNames)
        GN.bus.source_bus = GN.bus.P_th_i < 0;
    elseif ismember('V_dot_n_i__m3_per_day',GN.bus.Properties.VariableNames)
        GN.bus.source_bus = GN.bus.V_dot_n_i__m3_per_day < 0;
    elseif ismember('V_dot_n_i__m3_per_h',GN.bus.Properties.VariableNames)
        GN.bus.source_bus = GN.bus.V_dot_n_i__m3_per_h < 0;
    elseif ismember('m_dot_i__kg_per_s',GN.bus.Properties.VariableNames)
        GN.bus.source_bus = GN.bus.m_dot_i__kg_per_s < 0;
    elseif ismember('V_dot_n_i',GN.bus.Properties.VariableNames)
        GN.bus.source_bus = GN.bus.V_dot_n_i < 0;
    end
    
    % slack_bus => source_bus
    GN.bus.source_bus(GN.bus.slack_bus) = true;
end

%% #######################################################################
%  R E Q U I R E D   F O R   N O N - I S O T H E R M A L   S I M U L A T I O N
%  #######################################################################
if GN.isothermal == 0
    %% T_i_source
    if ismember('T_i_source',GN.bus.Properties.VariableNames)
        if any(~isnumeric(GN.bus.T_i_source))
            error('GN.bus: T_i_source must be numeric.')
        elseif any(GN.bus.T_i_source < 0 | isinf(GN.bus.T_i_source))
            error('GN.bus: T_i_source entries are needed for all sources and must be double values greater than 0 Kelvin.')
        end
        if any(isnan(GN.bus.T_i_source(GN.bus.source_bus)))
            GN.bus.T_i_source(~GN.bus.slack_bus & (GN.bus.P_th_i < 0 | GN.bus.V_dot_n_i < 0) & isnan(GN.bus.T_i_source)) = GN.T_env;
            warning(['GN.bus: Some T_i_source entries at source busses for non-isothermal simulation are missing and are set to ' num2str(GN.T_env(1,1)) ' K.'])
        end
    else
        GN.bus.T_i_source(GN.bus.source_bus) = GN.T_env;
        warning(['GN.bus: T_i_source column for non-isothermal simulation is missing. All T_i_source entries are set to ' num2str(GN.T_env(1,1)) ' K.'])
    end
    % Initialize T_i - UNDER CONSTRUCTION
    GN.bus.T_i(~isnan(GN.bus.T_i_source)) = GN.bus.T_i_source(~isnan(GN.bus.T_i_source));
    
end

end
