function [object] = jsonTable2table(object)
%JSONTABLE2TABLE
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

object = erase(object,'"');
object = erase(object,'columns');
object = erase(object,'{');
object = erase(object,'}');
object = erase(object,':');
temp_1 = strfind(object,'index');
temp_2 = strfind(object,']');
temp_2 = temp_2(temp_2>temp_1);
temp_2 = temp_2(1);
object(temp_1:temp_2+1) = [];
object = erase(object,'data[');
object(end) = [];
object = strrep(object,'],[',newline);
object = erase(object,']');
object = erase(object,'[');
dlmwrite('object.csv',object,'delimiter','')
object = readtable('object.csv');
delete('object.csv')
end

