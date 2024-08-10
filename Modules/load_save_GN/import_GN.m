function [GN] = import_GN(FILENAME, temp_model, create_log_file)
%import_GN imports gas network model.
%
%   GN = import_GN(FILENAME) loads a gas network (GN) model with the name
%   'FILENAME'. 'FILENAME' must not include any file extension. The
%   complete gas network model is assembled from several CSV files. Theses
%   files starts with 'FILENAME' and ends with '_name.csv', '_bus.csv',
%   '_pipe.csv', '_comp.csv', '_prs.csv', '_valve.csv', '_gasMix.csv'
%   and/or '_T_env.csv'.
%
%   GN = import_GN(..., temp_model, create_log_file) specifies the
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
%   false   -   No log file is created. false is used as default value.
%   true    -   If warning messages are issued when checking and initializing
%               the network model, they are saved in a log file.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
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

%%
if endsWith(FILENAME,'.xlsx')
    %% Check for Unix system
    if isunix
        error('Impossible to import Excel files on Unix systems. Try to import CSV files.')
    end
    
    %% Get directory path
    directory = get_directory(FILENAME);
    if ~isempty(directory)
        %% if xlsx file exists
        % Convert Excel to GN
        GN = xlsx2GN(FILENAME, directory);
        
        % Export GN to CSV for
        FILENAME_temp = erase(FILENAME,'.xlsx');
        GN2CSV(GN, FILENAME_temp, directory);
        
        % mode: non-isothermal or isothermal
        if strcmp(temp_model, 'non-isothermal')
            GN.isothermal = 0;
        elseif strcmp(temp_model, 'isothermal')
            GN.isothermal = 1;
        end
        
        % Plausibility check and initialization of the gas network
        keep_bus_properties = true;
        GN = check_and_init_GN(GN, keep_bus_properties, create_log_file);
        
    else
        %% if xlsx file does not exist
        warning(['''',FILENAME, ''' does not exist or folder is not added to path. An attempt is made to open ',FILENAME(1:end-5),' CSV data.'])
        FILENAME = erase(FILENAME,'.xlsx');
        GN = load_GN(FILENAME, temp_model, create_log_file);
        disp(['Import of CSV files with FILENAME ',FILENAME, ' was successful.'])
        
        if ~isunix
            directory = get_directory(FILENAME);
            listing = dir(directory);
            if ~any(strfind([listing.name],[FILENAME,'.xlsx']))
                GN2xlsx(GN, FILENAME, directory);
                disp([FILENAME,' has been saved as Excel file at ',directory])
            end
        end
    end
else
    %% Check file extension
    if any(strfind(FILENAME,'.'))
        error([FILENAME,' might have a wrong file extansion. To import Excel files, FILENAME must have the file extansion ''.xlsx''. To import CSV files, FILENAME must not have any file extansion.'])
    end

    %% Import CSV files
    GN = load_GN(FILENAME, temp_model, create_log_file);
    
    %% Convert GN to Excel if Excel file does not exist
    if ~isunix
        directory = get_directory(FILENAME);
        listing = dir(directory);
        if ~any(strfind([listing.name],[FILENAME,'.xlsx']))
            GN2xlsx(GN, FILENAME, directory);
            disp([FILENAME,' has been saved as Excel file at ',directory])
        end
    end
end
end