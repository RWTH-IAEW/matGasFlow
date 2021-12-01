function [GN] = check_and_init_GN(GN, create_log_file)
%CHECK_AND_INIT_GN Summary of this function goes here
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

%% Set default input arguments
if nargin < 2
    create_log_file = 0;
end

if create_log_file ~= 0 && create_log_file ~= 1
    error('The variable create_log_file must be 0 or 1.')
end

%% Diary
if create_log_file == 1
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

%% Check GN.T_env
GN = check_GN_T_env(GN);

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

%% Check GN.gasMix
GN = check_GN_gasMix(GN);

%% Check GN.time_series
if isfield(GN, 'time_series')
    try
        GN = check_GN_time_series(GN);
    catch
        warning('Check of time_series not available in this matgasflow distribution.')
    end
end

%% Inititalize GN.branch
GN = init_GN_branch(GN);

%% Inititialize indecies
GN = init_GN_indices(GN);

%% Check area restrictions
GN = check_GN_area_restrictions(GN);

%% Gas Composition Properties
GN = get_gasMixAndCompoProp(GN);

%% Diary off
if create_log_file == 1
    diary off
end
end

