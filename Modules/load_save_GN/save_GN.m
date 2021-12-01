function save_GN(GN, FILENAME, directory)
%SAVE_GN Summary of this function goes here
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
if ~isfolder(directory)
    mkdir(directory)
    addpath(directory)
end

%% Export GN to CSV files
GN2CSV(GN, FILENAME, directory)

%% Display message
if nargin < 3
    disp([FILENAME,' has been saved as CSV files at ',directory])
end

end

