function GN2CSV(GN, FILENAME, directory)
%GN2CSV Saves gas network in CSV files
%   GN2CSV(GN, FILENAME, directory)
%   Input arguments:
%       GN(necessary)
%       FILENAME(optional)
%       directory(optional)
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
            FILENAME = GN.name;
        else
            error('Not enough input arguments. FILENAME or GN.name is missing.')
        end
    end
    
    % Use path to the current folder if directory is not part of the input arguments.
    directory = pwd;
end

if ~isfolder(directory)
    mkdir(directory)
    addpath(directory)
end

if iscell(FILENAME)
    FILENAME = char(FILENAME);
end

%% Erase file type extension 
FILENAME = erase(FILENAME,'.csv');
if any(cell2mat(strfind(FILENAME,'.')))
    error([FILENAME,' must not have any file extansion.'])
end

%% Delete all CSV
listing = dir(directory);
for ii = 1:size(listing,1)
    if any(strfind(listing(ii).name,'.csv')) && any(strfind(listing(ii).name,FILENAME))
        delete([directory,'\',listing(ii).name])
    end
end

%% Write CSV table
GN_cell = struct2cell(GN);
fields = fieldnames(GN,'-full');

for ii = 1:length(fields)
    if istable(GN_cell{ii})
        writetable(GN_cell{ii}, [directory,'\',FILENAME,'_',fields{ii},'.csv'],'Delimiter',';','QuoteStrings',true)
    elseif ischar(GN_cell{ii}) || isnumeric(GN_cell{ii})
        writematrix(GN_cell{ii}, [directory,'\',FILENAME,'_',fields{ii},'.csv'],'Delimiter',';','QuoteStrings',true)
    elseif isstruct(GN_cell{ii})
        writetable(struct2table(GN_cell{ii}),[directory,'\',FILENAME,'_',fields{ii},'.csv'],'Delimiter',';','QuoteStrings',true);
    end
end

%% Display message
if nargin < 3
    disp([FILENAME,' has been saved as CSV files at ',directory])
end

end

