function update_pure_gas_properties()
%UNTITLED
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

if ~isempty(which('pure_gas_properties.xlsx'))
    % xlsx2csv
    pure_gas_properties = readtable('pure_gas_properties.xlsx','Sheet','Sheet1');
    directory = fileparts(which('pure_gas_properties.xlsx'));
    writetable(pure_gas_properties,[directory,'\pure_gas_properties.csv'],'Delimiter',';','QuoteStrings',true)
    clear pure_gas_properties
elseif ~isempty(which('pure_gas_properties.csv'))
    % csv2xlsx
    pure_gas_properties = readtable('pure_gas_properties.csv');
    directory = fileparts(which('pure_gas_properties.csv'));
    writetable(pure_gas_properties,[directory,'\pure_gas_properties.xlsx']);
    clear pure_gas_properties
else
    error('pure_gas_properties.csv is missing.')
end
end

