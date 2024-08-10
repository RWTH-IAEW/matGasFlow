function GN = check_GN_pipe(GN)
%CHECK_GN_PIPE
%   GN = check_GN_pipe(GN)
%   Check and initialization of GN.pipe and its variables (pipe table)
%   list of variabels:
%       INPUT DATA
%           pipe_ID
%           from_bus_ID
%           to_bus_ID
%           L_ij
%           D_ij
%           k_ij
%           U_ij
%       INPUT DATA - OPTIONAL
%           in_service
%       INPUT DATA - OPTIONAL FOR NON-ISOTHERMAL SIMULATION
%           T_env_ij
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Check for pipes in GN
if ~isfield(GN,'pipe')
    return
elseif isempty(GN.pipe)
    GN = rmfield(GN, 'pipe');
    warning('GN.pipe is empty.')
    return
end

%% #######################################################################
%  I N P U T   D A T A   -   R E Q U I R E D
%  #######################################################################
%% pipe_ID
if ismember('pipe_ID',GN.pipe.Properties.VariableNames)
    if any(~isnumeric(GN.pipe.pipe_ID))
        error('GN.pipe: pipe_ID must be numeric.')
    elseif any(GN.pipe.pipe_ID <= 0 | round(GN.pipe.pipe_ID) ~= GN.pipe.pipe_ID | isinf(GN.pipe.pipe_ID))
        error('GN.pipe: pipe_ID must be positive integer.')
    elseif length(unique(GN.pipe.pipe_ID)) < length(GN.pipe.pipe_ID)
        pipe_ID = sort(GN.pipe.pipe_ID);
        pipe_ID_double = pipe_ID([diff(pipe_ID)==0;false]);
        error(['GN.pipe: Duplicate entries at pipe_ID: ',num2str(pipe_ID_double')])
    end
else
    error('GN.pipe: pipe_ID column is missing.')
end

%% from_bus_ID - (BRANCH VARIABLE)
if ismember('from_bus_ID',GN.pipe.Properties.VariableNames)
    if any(~isnumeric(GN.pipe.from_bus_ID))
        error('GN.pipe: from_bus_ID must be numeric.')
    end
    idx = ismember(GN.pipe.from_bus_ID, GN.bus.bus_ID);
    if ~all(idx)
        error(['GN.pipe: These from_bus_ID entries do not exists: ',num2str(GN.pipe.from_bus_ID(~idx)')])
    end
    GN.pipe.from_bus_ID = GN.pipe.from_bus_ID;
else
    error('GN.pipe: from_bus_ID column is missing.')
end

%% to_bus_ID - (BRANCH VARIABLE)
if ismember('to_bus_ID',GN.pipe.Properties.VariableNames)
    if any(~isnumeric(GN.pipe.to_bus_ID))
        error('GN.pipe: to_bus_ID must be numeric.')
    end
    idx = ismember(GN.pipe.to_bus_ID, GN.bus.bus_ID);
    if ~all(idx)
        error(['GN.pipe: These from_bus_ID entries do not exists: ',num2str(GN.pipe.to_bus_ID(~idx)')])
    end
    GN.pipe.to_bus_ID = GN.pipe.to_bus_ID;
else
    error('GN.pipe: to_bus_ID column is missing.')
end

%% from_bus_ID and to_bus_ID - (BRANCH VARIABLE)
if any(GN.pipe.from_bus_ID == GN.pipe.to_bus_ID)
    error(['GN.pipe: from_bus_ID and to_bus_ID must not be the same. Check entries at these pipe IDs: ',...
        num2str(GN.pipe.pipe_ID(GN.pipe.from_bus_ID == GN.pipe.to_bus_ID)')])
end

%% L_ij [m]
if ismember('L_ij',GN.pipe.Properties.VariableNames)
    if any(~isnumeric(GN.pipe.L_ij))
        error('GN.pipe: L_ij must be numeric.')
    elseif any(GN.pipe.L_ij <= 0 |  isinf(GN.pipe.L_ij) | isnan(GN.pipe.L_ij))
        error(['GN.pipe: L_ij must be positive. Set L_ij of non-pipes to NaN. Check entries at these pipe IDs: ',...
            num2str( GN.pipe.pipe_ID(GN.pipe.L_ij <= 0 |  isinf(GN.pipe.L_ij) | isnan(GN.pipe.L_ij))' )])
    end
else
    error('GN.pipe: L_ij column is missing.')
end

%% D_ij [m]
if ismember('D_ij',GN.pipe.Properties.VariableNames)
    if any(~isnumeric(GN.pipe.D_ij))
        error('GN.pipe: D_ij must be numeric.')
    elseif any(GN.pipe.D_ij <= 0 | isinf(GN.pipe.D_ij) | isnan(GN.pipe.D_ij))
        error(['GN.pipe: D_ij must be positive. Check entries at these pipe IDs: ',...
            num2str( GN.pipe.pipe_ID(GN.pipe.D_ij <= 0 | isinf(GN.pipe.D_ij) | isnan(GN.pipe.D_ij))' )])
    end
else
    error('GN.pipe: D_ij column is missing.')
end

%% k_ij [m]
if ismember('k_ij',GN.pipe.Properties.VariableNames)
    if any(~isnumeric(GN.pipe.k_ij))
        error('GN.pipe: k_ij must be numeric.')
    elseif any(GN.pipe.k_ij < 0 | isinf(GN.pipe.k_ij) | isnan(GN.pipe.k_ij))
        error(['GN.pipe: k_ij must be greater than or equal to zero. Check entries at these pipe IDs: ',...
            num2str( GN.pipe.pipe_ID(GN.pipe.k_ij < 0 | isinf(GN.pipe.k_ij) | isnan(GN.pipe.k_ij))' )])
    end
else
    error('GN.pipe: k_ij column is missing.')
end

%% #######################################################################
%  I N P U T   D A T A   -   O P T I O N A L
%  #######################################################################
%% in_service - (BRANCH VARIABLE)
if ismember('in_service',GN.pipe.Properties.VariableNames)
    if any(~islogical(GN.pipe.in_service) & ~isnumeric(GN.pipe.in_service))
        error('GN.pipe: in_service must be a logical value.')
    elseif any(GN.pipe.in_service ~= 0 & GN.pipe.in_service ~= 1 & ~isnan(GN.pipe.in_service))
        error(['GN.pipe: in_service must be ''1'' (true), ''0'' (false) or ''NaN''(false). Check entries at these pipe IDs: ',...
            num2str(...
            GN.pipe.pipe_ID(GN.pipe.in_service < 0 | GN.pipe.in_service > 1)' ...
            )])
    end
    GN.pipe.in_service(isnan(GN.pipe.in_service)) = false;
    GN.pipe.in_service(GN.pipe.in_service == 0) = false;
    GN.pipe.in_service(GN.pipe.in_service == 1) = true;
    GN.pipe.in_service = logical(GN.pipe.in_service);
else
    % Default setting
    GN.pipe.in_service(:) = true;
end

%% P_th_ij_preset__MW, P_th_ij_preset, V_dot_n_ij_preset__m3_per_day, V_dot_n_ij_preset__m3_per_h, m_dot_ij_preset__kg_per_s, V_dot_n_ij_preset
pipe_flow_type = {};

if ismember('P_th_ij_preset__MW',GN.pipe.Properties.VariableNames)
    if any(~isnumeric(GN.pipe.P_th_ij_preset__MW))
        error('GN.pipe: P_th_ij_preset__MW must be numeric.')
    elseif any(isinf(GN.pipe.P_th_ij_preset__MW))
        error('GN.pipe: P_th_ij_preset__MW must be a numeric value and must not be infinity.')
    end
    pipe_flow_type(end+1) = {'P_th_ij_preset__MW'};
end

if ismember('P_th_ij_preset',GN.pipe.Properties.VariableNames)
    if any(~isnumeric(GN.pipe.P_th_ij_preset))
        error('GN.pipe: P_th_ij_preset must be numeric.')
    elseif any(isinf(GN.pipe.P_th_ij_preset))
        error('GN.pipe: P_th_ij_preset must be a numeric value and must not be infinity.')
    end
    pipe_flow_type(end+1) = {'P_th_ij_preset'};
end

if ismember('V_dot_n_ij_preset__m3_per_day',GN.pipe.Properties.VariableNames)
    if any(~isnumeric(GN.pipe.V_dot_n_ij_preset__m3_per_day))
        error('GN.pipe: V_dot_n_ij_preset__m3_per_day must be numeric.')
    elseif any(isinf(GN.pipe.V_dot_n_ij_preset__m3_per_day))
        error('GN.pipe: V_dot_n_ij_preset__m3_per_day must be a numeric value and must not be infinity.')
    end
    pipe_flow_type(end+1) = {'V_dot_n_ij_preset__m3_per_day'};
end

if ismember('V_dot_n_ij_preset__m3_per_h',GN.pipe.Properties.VariableNames)
    if any(~isnumeric(GN.pipe.V_dot_n_ij_preset__m3_per_h))
        error('GN.pipe: V_dot_n_ij_preset__m3_per_h must be numeric.')
    elseif any(isinf(GN.pipe.V_dot_n_ij_preset__m3_per_h))
        error('GN.pipe: V_dot_n_ij_preset__m3_per_h must be a numeric value and must not be infinity.')
    end
    pipe_flow_type(end+1) = {'V_dot_n_ij_preset__m3_per_h'};
end

if ismember('m_dot_ij_preset__kg_per_s',GN.pipe.Properties.VariableNames)
    if any(~isnumeric(GN.pipe.m_dot_ij_preset__kg_per_s))
        error('GN.pipe: m_dot_ij_preset__kg_per_s must be numeric.')
    elseif any(isinf(GN.pipe.m_dot_ij_preset__kg_per_s))
        error('GN.pipe: m_dot_ij_preset__kg_per_s must be a numeric value and must not be infinity.')
    end
    pipe_flow_type(end+1) = {'m_dot_ij_preset__kg_per_s'};
end

if ismember('V_dot_n_ij_preset',GN.pipe.Properties.VariableNames)
    if any(~isnumeric(GN.pipe.V_dot_n_ij_preset))
        error('GN.pipe: V_dot_n_ij_preset must be numeric.')
    elseif any(isinf(GN.pipe.V_dot_n_ij_preset))
        error('GN.pipe: V_dot_n_ij_preset must be a numeric value and must not be infinity.')
    end
    pipe_flow_type(end+1) = {'V_dot_n_ij_preset'};
end

if length(pipe_flow_type) > 1
    temp_text = cell(1,length(pipe_flow_type)*2-1);
    temp_text(1:2:end) = pipe_flow_type;
    temp_text(2:2:end-3) = {', '};
    temp_text(end-1) = {' and '};
    warning(['GN.pipe: ',[temp_text{3:end}],' entries are ignored, as ',char(temp_text(1)),' is preferably used.'])
    GN.pipe(:,pipe_flow_type(2:end)) = [];
end

%% #######################################################################
%  I N P U T   D A T A   -
%  O P T I O N A L   F O R   N O N - I S O T H E R M A L   S I M U L A T I O N
%  #######################################################################
if ~GN.isothermal
    %% T_env_ij
    if ismember('T_env_ij',GN.pipe.Properties.VariableNames)
        if any(~isnumeric(GN.pipe.T_env_ij))
            error('GN.pipe: T_env_ij must be numeric.')
        elseif any(GN.pipe.T_env_ij < 0 | isinf(GN.pipe.T_env_ij))
            error('GN.pipe: T_env_ij must be a positive double value.')
        end
    elseif ~ismember('T_env_ij',GN.pipe.Properties.VariableNames) && isfield(GN,'T_env')
        GN.pipe.T_env_ij = GN.T_env * ones(size(GN.pipe,1),1);
        warning(['GN.pipe: T_env_ij column for non-isothermal simulation is missing. All T_env_ij entries are set to ' num2str(GN.T_env) ' K.'])
    else
        error('GN.pipe: T_env_ij column for non-isothermal simulation as well as GN.T_env are missing.')
    end
    
    %% U_ij [W/(m^2*K)] - heat transfer coefficient
    if ismember('U_ij',GN.pipe.Properties.VariableNames)
        if any(~isnumeric(GN.pipe.U_ij))
            error('GN.pipe: U_ij must be numeric.')
        elseif any(GN.pipe.U_ij < 0 | isinf(GN.pipe.U_ij) | isnan(GN.pipe.U_ij))
            error(['GN.pipe: U_ij must be greater than or equal to zero. Check entries at these pipe IDs: ',...
                num2str( GN.pipe.pipe_ID(GN.pipe.U_ij < 0 | isinf(GN.pipe.U_ij) | isnan(GN.pipe.U_ij))' )])
        end
    else
        % Default setting
        warning('GN.pipe: heat transfer coefficient U_ij is missing. Default value: 2 W/(m^2 K).')
        GN.pipe.U_ij(:) = 2;
    end
end


end

