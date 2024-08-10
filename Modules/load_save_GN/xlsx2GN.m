function [GN] = xlsx2GN(FILENAME, directory)
%READ_GN_EXCEL
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

%% directory_file
directory_file = [directory,'\',FILENAME]; % Works only on Windows systems

%% Sheets
sheets = sheetnames(directory_file);

%% Name
GN.name = erase(FILENAME,'.xlsx');

%% BUS
if any(cell2mat(strfind(sheets,'bus')))
    GN.bus = readtable(directory_file,'Sheet','bus');
else
    error('xlsx2GN: xlsx file has no ''bus'' sheet.')
end

%% PIPE
if any(strcmp(sheets,'pipe'))
    GN.pipe = readtable(directory_file,'Sheet','pipe');
    if isempty(GN.pipe)
        GN = rmfield(GN,'pipe');
    end
end

%% COMPRESSOR STATION (comp)
if any(strcmp(sheets,'comp'))
    GN.comp = readtable(directory_file,'Sheet','comp');
    if isempty(GN.comp)
        GN = rmfield(GN,'comp');
    end
end

%% PRESSURE REGULATOR STATION (prs)
if any(strcmp(sheets,'prs'))
    GN.prs = readtable(directory_file,'Sheet','prs');
    if isempty(GN.prs)
        GN = rmfield(GN,'prs');
    end
end

%% VALVE (valve)
if any(strcmp(sheets,'valve'))
    GN.valve = readtable(directory_file,'Sheet','valve');
    if isempty(GN.valve)
        GN = rmfield(GN,'valve');
    end
end

%% GASMIX (gasMix)
if any(strcmp(sheets,'gasMix'))
    [~,txt] = xlsread(directory_file,'gasMix','A1');
    if ~isempty(txt)
        GN.gasMix = txt{1};
    end
end

%% ENVIRONMENTAL TEMPERATURE (T_env)
if any(strcmp(sheets,'T_env'))
    GN.T_env = xlsread(directory_file,'T_env','A1');
    if isempty(GN.T_env)
        GN = rmfield(GN,'T_env');
    end
end

%% TIME SERIES
if any(strcmp(sheets,'time_series'))
    GN.time_series = readtable(directory_file,'Sheet','time_series');
    if isempty(GN.time_series)
        GN = rmfield(GN,'time_series');
    end
end

end

