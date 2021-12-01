function GN = check_GN_pipe(GN)
%CHECKGN_PIPE Summary of this function goes here
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
if isfield(GN,'pipe')
    if isempty(GN.pipe)
        error('GN.pipe is empty.')
    end
    
    %% pipe_ID
    if any(strcmp('pipe_ID',GN.pipe.Properties.VariableNames))
        if any(~isnumeric(GN.pipe.pipe_ID))
            error('GN.pipe: pipe_ID must be numeric.')
        elseif any(GN.pipe.pipe_ID <= 0 | round(GN.pipe.pipe_ID) ~= GN.pipe.pipe_ID | isinf(GN.pipe.pipe_ID))
            error('GN.pipe: pipes_ID must be positive integer.')
        elseif length(unique(GN.pipe.pipe_ID)) < length(GN.pipe.pipe_ID)
            pipe_ID = sort(GN.pipe.pipe_ID);
            pipe_ID_double = pipe_ID([diff(pipe_ID)==0;false]);
            error(['GN.pipe: Duplicate entries at pipe_ID: ',num2str(pipe_ID_double')])
        end
    else
        error('GN.pipe: pipe_ID column is missing.')
    end
    
    %% #######################################################################
    %  B R A N C H   V A R I A B L E S
    %  #######################################################################
    %% from_bus_ID
    if any(strcmp('from_bus_ID',GN.pipe.Properties.VariableNames))
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
    
    %% to_bus_ID
    if any(strcmp('to_bus_ID',GN.pipe.Properties.VariableNames))
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
    
    %% to_bus_ID and from_bus_ID
    if any(GN.pipe.from_bus_ID == GN.pipe.to_bus_ID)
        error(['GN.pipe: from_bus_ID and to_bus_ID must not be the same. Check entries at these pipe IDs: ',...
        num2str(GN.pipe.pipe_ID(GN.pipe.from_bus_ID == GN.pipe.to_bus_ID)')])
    end
    
    %% in_service
    if any(strcmp('in_service',GN.pipe.Properties.VariableNames))
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
        % No error message necessary
        GN.pipe.in_service = true(size(GN.pipe,1),1);
    end
    
    %% #######################################################################
    %  P I P E   V A R I A B L E S
    %  #######################################################################
    %% L_ij
    if any(strcmp('L_ij',GN.pipe.Properties.VariableNames))
        if any(~isnumeric(GN.pipe.L_ij))
            error('GN.pipe: L_ij must be numeric.')
        elseif any(GN.pipe.L_ij <= 0 |  isinf(GN.pipe.L_ij) | isnan(GN.pipe.L_ij))
            error(['GN.pipe: L_ij must be positive. Set L_ij of non-pipes to NaN. Check entries at these pipe IDs: ',...
                num2str( GN.pipe.pipe_ID(GN.pipe.L_ij <= 0 |  isinf(GN.pipe.L_ij) | isnan(GN.pipe.L_ij))' )])
        end
    elseif any(GN.pipe.pipe_pipe)
        error('GN.pipe: L_ij column is missing. GN.pipe must have at least one pipe.')
    end
    
    %% D_ij
    if any(strcmp('D_ij',GN.pipe.Properties.VariableNames))
        if any(~isnumeric(GN.pipe.D_ij))
            error('GN.pipe: D_ij must be numeric.')
        elseif any(GN.pipe.D_ij <= 0 | isinf(GN.pipe.D_ij) | isnan(GN.pipe.D_ij))
            error(['GN.pipe: D_ij must be positive. Check entries at these pipe IDs: ',...
                num2str( GN.pipe.pipe_ID(GN.pipe.D_ij <= 0 | isinf(GN.pipe.D_ij) | isnan(GN.pipe.D_ij))' )])
        end
    elseif any(GN.pipe.pipe_pipe)
        error('GN.pipe: D_ij column is missing. GN.pipe must have at least one pipe.')
    end
    
    %% k_ij
    if any(strcmp('k_ij',GN.pipe.Properties.VariableNames))
        if any(~isnumeric(GN.pipe.k_ij))
            error('GN.pipe: k_ij must be numeric.')
        elseif any(GN.pipe.k_ij < 0 | isinf(GN.pipe.k_ij) | isnan(GN.pipe.k_ij))
            error(['GN.pipe: k_ij must be greater than or equal to zero. Check entries at these pipe IDs: ',...
                num2str( GN.pipe.pipe_ID(GN.pipe.k_ij < 0 | isinf(GN.pipe.k_ij) | isnan(GN.pipe.k_ij))' )])
        end
    elseif any(GN.pipe.pipe_pipe)
        error('GN.pipe: k_ij column is missing. GN.pipe must have at least one pipe.')
    end
    
    %% #######################################################################
    %  N O N - I S O T H E R M A L   P R O P E R T I E S
    %  #######################################################################
    if GN.isothermal == 0
        %% T_env_ij
        if any(strcmp('T_env_ij',GN.pipe.Properties.VariableNames))
            if any(~isnumeric(GN.pipe.T_env_ij))
                error('GN.pipe: T_env_ij must be numeric.')
            elseif any(GN.pipe.T_env_ij < 0 | isinf(GN.pipe.T_env_ij))
                error('GN.pipe: T_env_ij must be a positive double value.')
            end
        elseif ~any(strcmp('T_env_ij',GN.pipe.Properties.VariableNames)) && isfield(GN,'T_env')
            GN.pipe.T_env_ij = GN.T_env * ones(size(GN.pipe,1),1);
            warning(['GN.pipe: T_env_ij column for non-isothermal simulation is missing. All T_env_ij entries are set to ' num2str(GN.T_env(1,1)) '.'])
        else
            error('GN.pipe: T_env_ij column for non-isothermal simulation is missing.')
        end
    end
% else
%     error('GN has no pipe field.')
end
end

