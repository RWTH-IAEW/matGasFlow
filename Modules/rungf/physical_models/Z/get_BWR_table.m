function [GN] = get_BWR_table(GN)
%UNTITLED
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
FILENAME = 'BWR_table.xlsx';
directory = get_directory(FILENAME);
directory_file = [directory,'\',FILENAME]; % Works only on Windows systems

% Table
GN.BWR_table = readtable(directory_file);

end

% x_mol_i
[temp,i_idx]                 = ismember(GN.BWR_table.formula,GN.gasMixAndCompoProp.gas);
GN.BWR_table.x_mol_i         = zeros(size(GN.BWR_table,1),1);
GN.BWR_table.x_mol_i(temp)   = GN.gasMixAndCompoProp.x_mol(i_idx(temp));

end

