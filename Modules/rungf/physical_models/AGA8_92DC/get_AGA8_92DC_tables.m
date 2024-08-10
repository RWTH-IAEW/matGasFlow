function [GN] = get_AGA8_92DC_tables(GN)
%GET_AGA8_92DC_TABLES
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% TODO --> Update CSV in 'setup'

% directory_file
if ~isfield(GN,'AGA8_92DC_tables')
    FILENAME = 'AGA8_92DC_tables.xlsx';
    directory = get_directory(FILENAME);

    if ~isempty(directory)
        % Sheets
        directory_file = [directory,'\',FILENAME]; % Works only on Windows systems
        sheets = sheetnames(directory_file);

        % nParameters
        if any(cell2mat(strfind(sheets,'nParameters')))
            GN.AGA8_92DC_tables.nParameters = readtable(directory_file,'Sheet','nParameters');
        else
            error(['AGA8_92DC: ',FILENAME,' file has no ''nParameters'' sheet.'])
        end

        % gasProp
        if any(cell2mat(strfind(sheets,'gasProp')))
            GN.AGA8_92DC_tables.gasProp = readtable(directory_file,'Sheet','gasProp');
        else
            error(['AGA8_92DC: ',FILENAME,' file has no ''gasProp'' sheet.'])
        end

        % E_ij
        if any(cell2mat(strfind(sheets,'E_ij')))
            GN.AGA8_92DC_tables.E_ij = readmatrix(directory_file,'Sheet','E_ij');
        else
            error(['AGA8_92DC: ',FILENAME,' file has no ''E_ij'' sheet.'])
        end

        % U_ij
        if any(cell2mat(strfind(sheets,'U_ij')))
            GN.AGA8_92DC_tables.U_ij = readmatrix(directory_file,'Sheet','U_ij');
        else
            error(['AGA8_92DC: ',FILENAME,' file has no ''U_ij'' sheet.'])
        end

        % K_ij
        if any(cell2mat(strfind(sheets,'K_ij')))
            GN.AGA8_92DC_tables.K_ij = readmatrix(directory_file,'Sheet','K_ij');
        else
            error(['AGA8_92DC: ',FILENAME,' file has no ''K_ij'' sheet.'])
        end

        % G_ij
        if any(cell2mat(strfind(sheets,'G_ij')))
            GN.AGA8_92DC_tables.G_ij = readmatrix(directory_file,'Sheet','G_ij');
        else
            error(['AGA8_92DC: ',FILENAME,' file has no ''G_ij'' sheet.'])
        end

    else
        % nParameters
        GN.AGA8_92DC_tables.nParameters = readtable([directory,'\AGA8_92DC_nParameters.CSV']);

        % gasProp
        GN.AGA8_92DC_tables.gasProp = readtable([directory,'\AGA8_92DC_gasProp.CSV']);

        % E_ij
        GN.AGA8_92DC_tables.E_ij = readmatrix([directory,'\AGA8_92DC_E_ij.CSV']);

        % U_ij
        GN.AGA8_92DC_tables.U_ij = readmatrix([directory,'\AGA8_92DC_U_ij.CSV']);

        % K_ij
        GN.AGA8_92DC_tables.K_ij = readmatrix([directory,'\AGA8_92DC_K_ij.CSV']);

        % G_ij
        GN.AGA8_92DC_tables.G_ij = readmatrix([directory,'\AGA8_92DC_G_ij.CSV']);

    end
end

%% x_mol_i dependent parameters
[temp,i_idx]                        = ismember(GN.AGA8_92DC_tables.gasProp.formula,GN.gasMixAndCompoProp.gas);
GN.AGA8_92DC_tables.x_mol_i         = zeros(size(GN.AGA8_92DC_tables.gasProp,1),1);
GN.AGA8_92DC_tables.x_mol_i(temp)   = GN.gasMixAndCompoProp.x_mol(i_idx(temp));

[...
    GN.AGA8_92DC_tables.B_n, ...
    GN.AGA8_92DC_tables.K, ...
    GN.AGA8_92DC_tables.G, ...
    GN.AGA8_92DC_tables.Q, ...
    GN.AGA8_92DC_tables.F, ...
    GN.AGA8_92DC_tables.U, ...
    GN.AGA8_92DC_tables.x_mol_i, ...
    GN.AGA8_92DC_tables.M_avg_kmol] = get_AGA8_92DC_parameters(GN.AGA8_92DC_tables);

end

