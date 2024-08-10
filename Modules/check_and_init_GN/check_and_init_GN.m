function [GN] = check_and_init_GN(GN, keep_slack_properties, create_log_file, PHYMOD)
%CHECK_AND_INIT_GN
%   [GN] = check_and_init_GN(GN, create_log_file)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 4
    PHYMOD = getDefaultPhysicalModels;
end

%% Set default input arguments
if nargin < 3
    create_log_file = false;
    
    if nargin < 2
        keep_slack_properties = true;
        
    end
end

%% Diary
if create_log_file
    if isfield(GN,'name')
        LOG_FILENAME = [datestr(datetime('now'),'yyyymmddTHHMMSS'),'_',GN.name];
    else
        LOG_FILENAME = datestr(datetime('now'),'yyyymmddTHHMMSS');
    end
    currentFolder = pwd;
    if ~isfolder('log')
        mkdir log
    end
    disp(['log file saved at ', currentFolder, '\log\', LOG_FILENAME, '.log'])
    diary([currentFolder,'\log\',LOG_FILENAME,'.log'])
end

%% Check GN.name
GN = check_GN_name(GN);

%% Check GN.isothermal
GN = check_GN_isothermal(GN);

%% Check GN.T_env
GN = check_GN_T_env(GN);

%% Check GN.gasMix
GN = check_GN_gasMix(GN);

%% Check GN.bus
GN = check_GN_bus(GN);

%% Check GN.pipe
GN = check_GN_pipe(GN);

%% Check GN.comp
GN = check_GN_comp(GN);

%% Check GN.prs
GN = check_GN_prs(GN);

%% Check GN.valve
GN = check_GN_valve(GN);

%% Gas Composition Properties
if isfield(GN,'gasMix')
    GN = get_gasMixAndCompoProp(GN, GN.gasMix, PHYMOD);
elseif ~isfield(GN,'gasMixAndCompoProp')
    error('GN.gasMix is missing. Call ''help get_gasMixAndCompoProp'' for information about the gasMix options')
end

%% Check GN.time_series
if isfield(GN, 'time_series')
    GN = check_GN_time_series(GN);
end

%% Branches
if any(isfield(GN, {'pipe','comp','prs','valve'}))
    %% Inititalize GN.branch
    GN = init_GN_branch(GN);
    
    %% Inititialize indecies
    GN = init_GN_indices(GN);
    
    %% Check area restrictions
    GN = check_GN_area_restrictions(GN,keep_slack_properties);
    
end

%% Diary off
if create_log_file
    diary off
end
end

