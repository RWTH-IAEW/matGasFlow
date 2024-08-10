function [GN] = load_GN(FILENAME, temp_model, create_log_file)
%load_GN Loads gas network model.
%   
%   GN = load_GN(FILENAME) loads a gas network (GN) model with the name
%   'FILENAME'. 'FILENAME' must not include any file extension. The
%   complete gas network model is assembled from several CSV files. Theses
%   files starts with 'FILENAME' and ends with '_name.csv', '_bus.csv',
%   '_pipe.csv', '_comp.csv', '_prs.csv', '_valve.csv', '_gasMix.csv'
%   and/or '_T_env.csv'.
%
%   GN = load_GN(..., temp_model, create_log_file) specifies the
%   temperature model (temp_model) and wheather a log file shall be
%   created (create_log_file).
%
%   Availavle options for temp_model:
%   'isothermal'     -  It is assumed that the temperature at all busses
%                       and in all pipes is equal to the environmental
%                       temperature. 'isothermal' is used as default
%                       option.
%   'non-isothermal' -  Bus temperatures are calculated as a function of
%                       the changes of state
%
%   Availavle options for create_log_file:
%   0   -   No log file is created. 0 is used as default value.
%   1   -   If warning messages are issued when checking and initializing
%           the network model, they are saved in a log file.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Set default input arguments
if nargin < 3
    create_log_file = 0;
    
    if nargin < 2
        temp_model = 'isothermal';
    end
end

if ~(strcmp(temp_model,'isothermal') || strcmp(temp_model,'non-isothermal'))
    warning('temp_model must be ''isothermal'' or ''non-isothermal''. temp_model is set to ''isothermal''.')
end

if iscell(FILENAME)
    FILENAME = char(FILENAME);
end

%% Check file extension
if any(cell2mat(strfind(FILENAME,'.')))
    error('To import CSV files use ''import_GN(FILENAME)'' with no file extansion.')
end

%% Get directory path
directory = get_directory(FILENAME);
if isempty(directory)
    error(['''',FILENAME, ''' does not exist or folder is not added to path.'])
end

%% Convert CSV to GN
GN = CSV2GN(FILENAME, directory);

%% mode: non-isothermal or isothermal
if strcmp(temp_model, 'non-isothermal')
    GN.isothermal = 0;
elseif strcmp(temp_model, 'isothermal')
    GN.isothermal = 1;
end

%% Plausibility check and initialization of the gas network
keep_slack_properties = true;
GN = check_and_init_GN(GN, keep_slack_properties, create_log_file);

%% Reset p_i__barg
% if any(~isnan(GN.bus.p_i__barg(~GN.bus.slack_bus)))
%     GN.bus.p_i__barg(~GN.bus.slack_bus) = NaN;
%     warning('GN.bus: All pressure values p_i__barg at ~GN.bus.slack_bus have been reset to NaN.')
% end

end

