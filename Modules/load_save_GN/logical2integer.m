function [TABLE] = logical2integer(TABLE)
%LOGICAL2INTEGER
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

varNames = TABLE.Properties.VariableNames;

logicalVars = find(varfun(@islogical, TABLE, 'output', 'uniform'));

for ii = 1:length(logicalVars)
    TABLE.(varNames{logicalVars(ii)}) = double(TABLE.(varNames{logicalVars(ii)}));
end

end

