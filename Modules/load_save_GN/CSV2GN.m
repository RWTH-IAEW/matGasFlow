function [GN] = CSV2GN(FILENAME, directory)
%CSV2GN Loads gas network from CSV files
%   GN = CSV2GN(FILENAME, directory)
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
if ~isunix
    directory_file = [directory,'\',FILENAME];
else
    directory_file = [directory,'/',FILENAME];
end

%% List of Files
listing = dir(directory);

%% NAME
GN.name = FILENAME;

%% BUS
GN.bus = readtable([directory_file,'_bus.csv']);

%% PIPE
if any(strfind([listing.name],'_pipe.csv'))
    GN.pipe   = readtable([directory_file,'_pipe.csv']);
    if isempty(GN.pipe)
        GN = rmfield(GN,'pipe');
        delete([directory_file,'_pipe.csv'])
    end
end

%% COMPRESSOR STATION (comp)
if any(strfind([listing.name],'_comp.csv'))
    GN.comp = readtable([directory_file,'_comp.csv']);
    if isempty(GN.comp)
        GN = rmfield(GN,'comp');
        delete([directory_file,'_comp.csv'])
    end
end

%% PRESSURE REGULATOR STATION (prs)
if any(strfind([listing.name],'_prs.csv'))
    GN.prs = readtable([directory_file,'_prs.csv']);
    if isempty(GN.prs)
        GN = rmfield(GN,'prs');
        delete([directory_file,'_prs.csv'])
    end
end

%% VALVE (valve)
if any(strfind([listing.name],'_valve.csv'))
    GN.valve = readtable([directory_file,'_valve.csv']);
    if isempty(GN.valve)
        GN = rmfield(GN,'valve');
        delete([directory_file,'_valve.csv'])
    end
end

%% ISOTHERMAL
if any(strfind([listing.name],'_isothermal.csv'))
    GN.T_env = readmatrix([directory_file,'_isothermal.csv']);
    if isempty(GN.isothermal)
        GN = rmfield(GN,'isothermal');
        delete([directory_file,'_isothermal.csv'])
    end
end

%% T_ENV
if any(strfind([listing.name],'_T_env.csv'))
    GN.T_env = readmatrix([directory_file,'_T_env.csv']);
    if isempty(GN.T_env)
        GN = rmfield(GN,'T_env');
        delete([directory_file,'_T_env.csv'])
    end
end

%% GASMIX
if any(strfind([listing.name],'_gasMix.csv'))
    % Setup the Import Options and import the data
    opts = delimitedTextImportOptions("NumVariables", 1);
    opts.DataLines = [1, Inf];
    opts.Delimiter = ",";
    opts.VariableTypes = "string";
    opts.ExtraColumnsRule = "ignore";
    opts.EmptyLineRule = "read";
    
    % Import the data
    gasMix = readtable([directory_file,'_gasMix.csv'], opts);
    gasMix = table2cell(gasMix);
    if ~isempty(gasMix)
        GN.gasMix = convertStringsToChars(gasMix{1});
    else
        delete([directory_file,'_gasMix.csv'])
    end
end

%% TIME_SERIES
if any(strfind([listing.name],'_time_series.csv'))
    GN.time_series = readtable([directory_file,'_time_series.csv']);
    if isempty(GN.time_series)
        GN = rmfield(GN,'time_series');
        delete([directory_file,'_time_series.csv'])
    end
end
end

