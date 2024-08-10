function [GN] = getAdditionalSourceParameters(val,GN)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if isfield(val.x_object,'source')
    
idx_junction = round(val.x_object.source.x_object.junction)+1; 
idx_source = transpose(1:length(idx_junction)); 

GN.source_info = table; 

%% source_ID 
GN.source_info.source_ID = idx_source; 

%% bus_ID
GN.source_info.bus_ID = idx_junction; 

%% type

try
    test_1 = val.x_object.source.x_object.junctions(~isnan(val.x_object.source.x_object.type));
    warning ('Source:  Types have been predefined by pandapipes.')
catch
end 

for ii=1:length(idx_junction)
    try
        temp = convertCharsToStrings(val.x_object.source.x_object.type(ii));
        GN.source_info.type(ii)=temp;
    catch
    end
end 

%% in_service

try
    test_2 = (strcmp(val.x_object.source.x_object.in_service,"true"));
    if any(~test_2)
        warning ('Source:  "In-Service"-Informations are given by pandapipes. Some sources are not in service.')
    end
catch
end

try
    GN.source_info.in_service_source = test_2;
catch
end


%% kwards_source 
% Under construction 

try
    readtable(val.x_object.source.x_object.kwards);
    warning ('Source:  Keywords are given by pandapipes.')
catch
end 

for ii=1:length(idx_junction)
    try
        temp = convertCharsToStrings(val.x_object.source.x_object.kwards(ii));
        GN.source_info.kwards_source(ii)=temp;
    catch
    end
end 
    
%% scaling 

try
    test_4 = (~isnan(val.x_object.source.x_object.scaling));
    if any(abs(test_4-1)>0)
    warning ('Source:  Scaling different from 1 is given by pandapipes.')
    end 
catch
end 

for ii=1:length(idx_junction)
    try
        GN.source_info.scaling_source(ii)= ...
            double(val.x_object.source.x_object.scaling(ii));
    catch
    end
end 

end 
end 


