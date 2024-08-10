function GN2xlsx(GN, FILENAME, directory)
%GN2XLSX
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
FILENAME = erase(FILENAME,'.xlsx');
if any(cell2mat(strfind(FILENAME,'.')))
    error([FILENAME,' must have either no file extension or the file extension ''.xlsx''.'])
end

%% Write Excel
GN_cell = struct2cell(GN);
fields = fieldnames(GN,'-full');
% fields_white_list =
% {'bus','pipe','comp','prs','valve','time_series','time_series_res','gasMix','T_env','isothermal','gasMixAndCompoProp'};
% UNDER CONSTRUCTION

for ii = 1:length(fields)
    if istable(GN_cell{ii})
        try
            oldTable = readtable([directory,'\',FILENAME,'.xlsx'], 'Sheet', fields{ii});
            oldTable = array2table(NaN(size(oldTable)), 'VariableNames', oldTable.Properties.VariableNames);
            writetable(oldTable, [directory,'\',FILENAME,'.xlsx'], 'Sheet', fields{ii})
        catch
        end
        writetable(GN_cell{ii}, [directory,'\',FILENAME,'.xlsx'],'Sheet',fields{ii},'WriteRowNames',true);
    elseif ischar(GN_cell{ii}) || isnumeric(GN_cell{ii})
        writematrix(GN_cell{ii}, [directory,'\',FILENAME,'.xlsx'],'Sheet',fields{ii});
    elseif isstruct(GN_cell{ii})
        try % UNDER CONSTRUCTION: Problems with GN.MAT
            writetable(struct2table(GN_cell{ii},'AsArray',true), [directory,'\',FILENAME,'.xlsx'],'Sheet',fields{ii});
        catch
        end
    end
end

%% Display message
if nargin < 3
    disp([FILENAME,' has been saved as Excel file at ',directory])
end

end