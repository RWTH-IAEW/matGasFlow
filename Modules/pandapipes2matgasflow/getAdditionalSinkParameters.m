function [GN] = getAdditionalSinkParameters(val,GN)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if isfield(val.x_object,'sink')
    
idx_junction = round(val.x_object.sink.x_object.junction)+1; 
idx_sink = transpose(1:length(idx_junction)); 

GN.sink_info = table; 

%% sink_ID 
GN.sink_info.sink_ID = idx_sink; 

%% bus_ID
GN.sink_info.bus_ID = idx_junction; 

%% type

try
    test_1 = val.x_object.sink.x_object.junctions(~isnan(val.x_object.sink.x_object.type));
    warning ('Sink:  Types have been predefined by pandapipes.')
catch
end 

for ii=1:length(idx_junction)
    try
        temp = convertCharsToStrings(val.x_object.sink.x_object.type(ii));
        GN.sink_info.type(ii)=temp;
    catch
    end
end 

%% in_service

try
    test_2 = (strcmp(val.x_object.sink.x_object.in_service,"true"));
    if any(~test_2)
        warning ('Sink:  "In-Service"-Informations are given by pandapipes. Some sinks are not in service.')
    end
catch
end

try
    GN.sink_info.in_service_sink = test_2;
catch
end


%% kwards_sink 
% Under construction 

try
    readtable(val.x_object.sink.x_object.kwards);
    warning ('Sink:  Keywords are given by pandapipes.')
catch
end 

for ii=1:length(idx_junction)
    try
        temp = convertCharsToStrings(val.x_object.sink.x_object.kwards(ii));
        GN.sink_info.kwards_sink(ii)=temp;
    catch
    end
end 
    
%% scaling 

try
    test_4 = (~isnan(val.x_object.sink.x_object.scaling));
    if any(abs(test_4-1)>0)
    warning ('Sink:  Scaling different from 1 is given by pandapipes.')
    end 
catch
end 

for ii=1:length(idx_junction)
    try
        GN.sink_info.scaling_sink(ii)= ...
            double(val.x_object.sink.x_object.scaling(ii));
    catch
    end
end 

end 
end 

    


