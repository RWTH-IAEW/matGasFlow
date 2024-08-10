function [GN] = getGNcomp(val,GN, AdditionalParameters)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

GN.comp = table;

%% comp_ID
%% index
try readtable(val.x_object.pump.x_object.stanet_nr)
    warning ('GN.comp: Indexes of compes have been predefined.')
catch
    
end

for ii=1:(height(val.x_object.pump.x_object))
    try
        if ~isnan(val.x_object.pump.x_object.stanet_nr(ii))
            GN.comp.comp_ID(ii)=round(val.x_object.pump.x_object.stanet_nr(ii));
        else
            GN.comp.comp_ID(ii) = max(GN.comp.comp_ID)+1;
        end
        
    catch
        try
            if max(round(val.x_object.pump.x_object.stanet_nr))> 1
                GN.comp.comp_ID = max(round(val.x_object.pump.x_object.stanet_nr))+ii;
            end
        catch
            GN.comp.comp_ID(ii) = ii;
        end
    end
end

%% comp_name
try
    temp= string(val.x_object.pump.x_object.name);
    
    if any(~strcmp(temp,'None'))
        warning ('GN.comp: Names have been defined')
    end
    
    for ii=1:length(temp)
        if ~(strcmp(temp(ii),'None'))
            GN.comp.comp_name(ii) = temp(ii);
        else
            GN.comp.comp_name(ii)= 'NaN';
        end
    end
catch
end

%% from_bus_ID
for ii=1:length(GN.comp.comp_ID)
    GN.comp.from_bus_ID(ii)= double(val.x_object.pump.x_object.from_junction(ii))+1;
end

%% to_bus_ID

for ii=1:length(GN.comp.comp_ID)
    GN.comp.to_bus_ID(ii)= double(val.x_object.pump.x_object.to_junction(ii))+1;
end

%% in_service
temp_2 = strcmp(val.x_object.pump.x_object.in_service,'true');
GN.comp.in_service = temp_2;

%% p_out
try
    GN.comp.p_out=double(val.x_object.pump.x_object.ps_stanet);
catch
    GN.comp.p_out(:)=GN.bus.p_i(GN.bus.slack_bus);
    warning('GN.comp: Missing information for pressure regulation. Output pressure was set to slack pressure.')
end

%% gas_powered
%default
GN.comp.gas_powered(:) = logical(false);

%% eta_s
%default
GN.comp.eta_s(:)= 0.65;

%% eta_drive
%default
GN.comp.eta_drive(:)= 0.34;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Additional Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if AdditionalParameters == 1
    GN = getAdditionalPumpParameters(val,GN);
end