function [directory] = get_directory(FILENAME)
%GET_DIRECTORY
%   directory = get_directory(FILENAME)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2022, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


if endsWith(FILENAME,'.xlsx')
    directory_file = which(FILENAME,'-all');
else
    directory_file = which([FILENAME,'_bus.csv'],'-all');
end

if size(directory_file,1) > 1
    size_directory = size(directory_file,1);
    directory_file = directory_file{1,:};
    warning([FILENAME, ' has ', num2str(size_directory), ' different directory pathes. Selected directory path: ',directory_file])
    directory = fileparts(directory_file);
elseif ~isempty(directory_file)
    directory_file = directory_file{1,:};
    directory = fileparts(directory_file);
elseif isempty(directory_file)
    directory = [];
end


end

