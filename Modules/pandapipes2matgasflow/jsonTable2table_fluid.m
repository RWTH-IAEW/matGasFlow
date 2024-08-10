function [object] = jsonTable2table_fluid(object)
%JSONTABLE2TABLE_FLUID
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
object = erase(object,'{');
object = erase(object,'}');
object = regexp(object, '[,;:\n]', 'split');
object = cell2table(object);
object(:,7:end)=[];

for ii = 1:3   
    temp(1,ii)=convertCharsToStrings(object(1,ii*2-1));
    temp(2,ii)=convertCharsToStrings(object(1,ii*2));
end
name = table2array(temp(1,2)); 
fluid_type =table2array(temp(2,2)); 
is_gas = table2array(temp(2,3)); 

temp_2 = table ([name],[fluid_type],[is_gas]); 
object = temp_2;

end

