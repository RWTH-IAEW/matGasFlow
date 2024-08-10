function [GN] = getAdditionalJunctionParameters(val,GN)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% net
try   
        GN.bus.net= val.x_object.junction.x_object.net; 
        warning ('GN.bus:  A network name has been defined by pandapipes.')
catch 
end 

%% pn_initial

try 
        GN.bus.pn_initial= val.x_object.junction.x_object.pn_bar; 
        warning ('GN.bus: Initial pressure values have been defined by pandapipes.')
catch 
end 

%% in_service

try 
    temp_4= (val.x_object.junction.x_object.in_service);    
    for ii= 1:length(temp_4)
        
    if strcmp (temp_4(ii), 'true')
        temp_4(ii)=logical(true); 
    else
        temp_4(ii)=logical(false);
    end 
    end 
    GN.bus.in_service=temp_4; 
    warning ("GN.bus: 'In Service'- Informations are given by pandapipes.")
catch 
    end 

%% type 

try 
    GN.bus.type= string(val.x_object.junction.x_object.type); 
    warning ("GN.bus: Types have been defined by pandapipes.")
catch 
end 

%% kwargs

try 
    GN.bus.kwargs = string(val.x_object.junction.x_object.kwargs); 
    warning ("GN.bus: Keywords have been defined by pandapipes.") 
catch 
end 
end 