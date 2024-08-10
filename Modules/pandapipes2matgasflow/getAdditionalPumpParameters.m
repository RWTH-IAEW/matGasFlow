function [GN] = getAdditionalPumpParameters(val,GN)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

idx_comp = GN.comp.comp_ID;

%% net 
try
    GN.comp.net = double(val.x_object.pump.x_object.net);
    warning ('Comp:  Networks have been defined by pandapipes.')
catch
end

%% std_type

for ii=1:length(idx_comp)
    try
        temp = convertCharsToStrings(val.x_object.pump.x_object.std_type(ii));
        GN.comp.std_type(ii)=temp;
    catch
    end
end 
try
    test=(val.x_object.pump.x_object.std_type);
    warning ('Comp:  Standard Types have been defined by pandapipes.')
catch
end

%% kwargs
for ii=1:length(idx_comp)
    try
        temp_2 = convertCharsToStrings(val.x_object.pump.x_object.kwargs(ii));
        GN.comp.kwargs(ii)=temp_2;
    catch
    end
end 
try
    test=(val.x_object.pump.x_object.kwargs);
    warning ('Comp:  Keywords have been defined by pandapipes.')
catch
end

%% type
try
    GN.comp.type= string(val.x_object.pump.x_object.type); 
    warning ('Comp: Types have been defined by pandapipes.')
catch
end 

%% stanet_ID
try
    GN.comp.stanet_ID= string(val.x_object.pump.x_object.stanet_id); 
    warning ('Comp: Stanet IDs have been defined by pandapipes.')
catch
end

end 