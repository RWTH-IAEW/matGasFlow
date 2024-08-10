function [GN] = getAdditionalPipeParameters(GN,val)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

idx_pipe = GN.pipe.pipe_ID;

%% net 
try
    test_1 = val.x_object.pipe.x_object.net;
    warning ('Pipe:  Networks have been defined by pandapipes.')
catch
end

for ii=1:length(idx_pipe)
    try
        GN.pipe.net(ii)= val.x_object.pipe.x_object.net(ii);
    catch
    end 
end


%% loss_coefficient

try
    test_2 = val.x_object.pipe.x_object.loss_coefficient;
    warning ('Pipe:  Loss coefficients have been defined by pandapipes.')
catch
end

for ii=1:length(idx_pipe)
    try
        GN.pipe.loss_coefficient(ii)= val.x_object.pipe.x_object.loss_coefficient(ii);
    catch  
    end
end

%% sections

try
    test_3 = val.x_object.pipe.x_object.sections;
    warning ('Pipe:  Sections have been defined by pandapipes.')
catch
end

for ii=1:length(idx_pipe)
    try
        GN.pipe.sections(ii)= val.x_object.pipe.x_object.sections(ii);
    catch  
    end
end

%% geodata

if isfield(val.x_object,'pipe_geodata')
    try readtable(val.x_object.pipe_geodata.x_object.x);
        GN.pipe.geodata_x_coord = double(val.x_object.pipe_geodata.x_object.x);
    catch
    end
    try readtable(val.x_object.pipe_geodata.x_object.y);
        GN.pipe.geodata_y_coord = double(val.x_object.pipe_geodata.x_object.y);
    catch
    end
end

%% type

try
    test_5 = val.x_object.pipe.x_object.type;
    warning ('Pipe:  Types have been defined by pandapipes.')
catch
end

for ii=1:length(idx_pipe)
    try
        GN.pipe.type(ii)= string(val.x_object.pipe.x_object.type(ii));
    catch  
    end
end


%% kwards
% Under construction 

try
    readtable(val.x_object.sink.x_object.kwards);
    warning ('Sink:  Keywords are given by pandapipes.')
catch
end 

for ii=1:length(idx_pipe)
    try
        temp = convertCharsToStrings(val.x_object.pipe.x_object.kwards(ii));
        GN.pipe.kwards(ii)=temp;
    catch
    end
end 
end 
