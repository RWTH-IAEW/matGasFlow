function update_gasMix_library()
%UPDATE_GASMIX_LIBRARY Summary of this function goes here
%   Detailed explanation goes here
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2022, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~isempty(which('gasMix_library.xlsx'))
    % xlsx2csv
    gasMix_library = readtable('gasMix_library.xlsx','Sheet','x_mol');
    directory = fileparts(which('gasMix_library.xlsx'));
    writetable(gasMix_library,[directory,'\gasMix_library.csv'],'Delimiter',';','QuoteStrings',true)
elseif ~isempty(which('gasMix_library.csv'))
    % csv2xlsx
    gasMix_library = readtable('gasMix_library.csv');
    directory = fileparts(which('gasMix_library.csv'));
    writetable(gasMix_library,[directory,'\gasMix_library.xlsx'],'Sheet','x_mol','WriteRowNames',true);
else
    error('gasMix_library.csv is missing.')
end
end

