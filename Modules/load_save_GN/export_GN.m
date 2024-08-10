function export_GN(GN, FILENAME, directory, OPTION)
%EXPORT_GN
%
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
if nargin < 4
    OPTION = 'all';
    
    if nargin < 3
        if nargin < 2
            if isfield(GN,'name')
                FILENAME = [GN.name,'_EXPORT'];
            else
                error('Not enough input arguments. FILENAME or GN.name is missing.')
            end
        end
        
        directory = get_directory(erase(FILENAME,'_EXPORT'));
        if ~isunix
            directory = [directory,'\',FILENAME];
        else
            directory = [directory,'/',FILENAME];
        end
    end
end
if ~isfolder(directory)
    mkdir(directory)
    addpath(directory)
end

%% Delete auxiliary variables from GN initialization
GN = remove_auxiliary_variables(GN);

%% Export to shape files
if any(ismember({'all','shape'},OPTION))
    if any(strcmp('x_coord',GN.bus.Properties.VariableNames)) && any(strcmp('y_coord',GN.bus.Properties.VariableNames))
        GN2shp(GN, FILENAME, directory)
        
        % Display message
        if nargin < 3
            disp([FILENAME,' has been saved as shape files (.shp, .shx, .dbf) at ',directory])
        end
    else
        disp([FILENAME,' cannot be saved as shape file, because geo-information is missing (x_coord, y_coord).'])
    end
end

%% Export GN to Excel file
if any(ismember({'all','Excel','xlsx'},OPTION))
    GN2xlsx(GN, FILENAME, directory);
    disp([FILENAME,' has been saved as Excel file at ',directory])
end

%% Export GN to CSV files
if any(ismember({'all','CSV','csv'},OPTION))
    GN2CSV(GN, FILENAME, directory)
    disp([FILENAME,' has been saved as CSV files at ',directory])
end

end
