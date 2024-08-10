function GN2shp(GN, FILENAME, directory)
%GN2SHAPE
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

%% Erase file type extension 
FILENAME = erase(FILENAME,'.xlsx');
FILENAME = erase(FILENAME,'.csv');
FILENAME = erase(FILENAME,'.shp');

%% Delete all shape files
listing = dir(directory);
for ii = 1:size(listing,1)
    if any(strfind(listing(ii).name,'.shp'))
        delete([directory,'\',listing(ii).name])
    elseif any(strfind(listing(ii).name,'.dbf'))
        delete([directory,'\',listing(ii).name])
    elseif any(strfind(listing(ii).name,'.shx'))
        delete([directory,'\',listing(ii).name])
    end
end

%% Bus
if isfield(GN,'bus')
    bus = GN.bus;
    bus.Geometry = repmat({'Point'}, size(bus,1), 1);
    
    bus.Properties.VariableNames{'x_coord'} = 'Lon';
    bus.Properties.VariableNames{'y_coord'} = 'Lat';
    
    % delete unnecessary variables
    varNames = {'literature', 'p_min_Quali', 'p_max_Quali'};
    idx = ismember(GN.bus.Properties.VariableNames,varNames);
    GN.bus(:,idx) = [];
    
    % convert logical to double
    bus = logical2integer(bus);
    
    % reduce numer of variable characters
    bus.Properties.VariableNames = erase(bus.Properties.VariableNames,'_i');
    bus.Properties.VariableNames = erase(bus.Properties.VariableNames,'_dot');
    
    % convert table to struct
    bus = table2struct(bus);
    
    % create shape file
    shapewrite(bus,  [directory,'\',FILENAME,'_bus.shp'])
end

%% Pipe
if isfield(GN,'pipe')
    
    % lambda_ij might be infinit
    GN.pipe.lambda_ij(isinf(GN.pipe.lambda_ij)) = 1e42;
    
    pipe = GN.pipe;
    pipe.Geometry = repmat({'PolyLine'}, size(pipe,1), 1);
    
    % Bounding Box for PolyLine: [xmin,ymin;xmax,ymax]
    [~,i_from_bus]  = ismember(GN.pipe.from_bus_ID,GN.bus.bus_ID);
    [~,i_to_bus]    = ismember(GN.pipe.to_bus_ID,GN.bus.bus_ID);
    xmin = GN.bus.x_coord(i_from_bus);
    xmax = GN.bus.x_coord(i_to_bus);
    ymin = GN.bus.y_coord(i_from_bus);
    ymax = GN.bus.y_coord(i_to_bus);
    pipe.Lon = num2cell([xmin,xmax],2);
    pipe.Lat = num2cell([ymin,ymax],2);
    
    % delete unnecessary variables
    varNames = {'literature', 'Ltg_Nr', 'L_Quali', 'DN_Quali', 'DP_Quali'};
    idx = ismember(GN.pipe.Properties.VariableNames,varNames);
    GN.pipe(:,idx) = [];
    
    % convert logical to double
    pipe = logical2integer(pipe);
    
    % reduce numer of variable characters
    pipe.Properties.VariableNames = erase(pipe.Properties.VariableNames,'_ij');
    pipe.Properties.VariableNames = erase(pipe.Properties.VariableNames,'_dot');
    pipe.Properties.VariableNames = erase(pipe.Properties.VariableNames,'_n');
    pipe.Properties.VariableNames = erase(pipe.Properties.VariableNames,'__bar');
    try
        pipe.V__m3_per_s = pipe.V;
        pipe = movevars(pipe,'V__m3_per_s','After','V__m3_per_h');
        pipe.V = [];
    catch
    end
    
    % convert table to struct
    pipe = table2struct(pipe);
    
    % create shape file
    shapewrite(pipe, [directory,'\',FILENAME,'_pipe.shp'])
end

%% Comp
if isfield(GN,'comp')
    comp = GN.comp;
    comp.Geometry = repmat({'PolyLine'}, size(comp,1), 1);
    
    % Bounding Box for PolyLine: [xmin,ymin;xmax,ymax]
    [~,i_from_bus]  = ismember(GN.comp.from_bus_ID,GN.bus.bus_ID);
    [~,i_to_bus]    = ismember(GN.comp.to_bus_ID,GN.bus.bus_ID);
    xmin = GN.bus.x_coord(i_from_bus);
    xmax = GN.bus.x_coord(i_to_bus);
    ymin = GN.bus.y_coord(i_from_bus);
    ymax = GN.bus.y_coord(i_to_bus);
    comp.Lon = num2cell([xmin,xmax],2);
    comp.Lat = num2cell([ymin,ymax],2);
    
    % convert logical to double
    comp = logical2integer(comp);
    
    % reduce numer of variable characters
    comp.Properties.VariableNames = erase(comp.Properties.VariableNames,'_ij');
    comp.Properties.VariableNames = erase(comp.Properties.VariableNames,'_dot');
    comp.Properties.VariableNames = erase(comp.Properties.VariableNames,'_n');
    comp.Properties.VariableNames = erase(comp.Properties.VariableNames,'__bar');
    try
        comp.V__m3_per_s = comp.V;
        comp = movevars(comp,'V__m3_per_s','After','V__m3_per_h');
        comp.V = [];
    catch
    end
    
    % convert table to struct
    comp = table2struct(comp);
    
    % create shape file
    shapewrite(comp, [directory,'\',FILENAME,'_comp.shp'])
end

%% PRS
if isfield(GN,'prs')
    prs = GN.prs;
    prs.Geometry = repmat({'PolyLine'}, size(prs,1), 1);
    
    % Bounding Box for PolyLine: [xmin,ymin;xmax,ymax]
    [~,i_from_bus]  = ismember(GN.prs.from_bus_ID,GN.bus.bus_ID);
    [~,i_to_bus]    = ismember(GN.prs.to_bus_ID,GN.bus.bus_ID);
    xmin = GN.bus.x_coord(i_from_bus);
    xmax = GN.bus.x_coord(i_to_bus);
    ymin = GN.bus.y_coord(i_from_bus);
    ymax = GN.bus.y_coord(i_to_bus);
    prs.Lon = num2cell([xmin,xmax],2);
    prs.Lat = num2cell([ymin,ymax],2);
    
    % convert logical to double
    prs = logical2integer(prs);
    
    % reduce numer of variable characters
    prs.Properties.VariableNames = erase(prs.Properties.VariableNames,'_ij');
    prs.Properties.VariableNames = erase(prs.Properties.VariableNames,'_dot');
    prs.Properties.VariableNames = erase(prs.Properties.VariableNames,'_n');
    prs.Properties.VariableNames = erase(prs.Properties.VariableNames,'__bar');
    try
        prs.V__m3_per_s = prs.V;
        prs = movevars(prs,'V__m3_per_s','After','V__m3_per_h');
        prs.V = [];
    catch
    end
    
    % convert table to struct
    prs = table2struct(prs);
    
    % create shape file
    shapewrite(prs, [directory,'\',FILENAME,'_prs.shp'])
end

%% VALVE
if isfield(GN,'valve')
    valve = GN.valve;
    valve.Geometry = repmat({'PolyLine'}, size(valve,1), 1);
    
    % Bounding Box for PolyLine: [xmin,ymin;xmax,ymax]
    [~,i_from_bus]  = ismember(GN.valve.from_bus_ID,GN.bus.bus_ID);
    [~,i_to_bus]    = ismember(GN.valve.to_bus_ID,GN.bus.bus_ID);
    xmin = GN.bus.x_coord(i_from_bus);
    xmax = GN.bus.x_coord(i_to_bus);
    ymin = GN.bus.y_coord(i_from_bus);
    ymax = GN.bus.y_coord(i_to_bus);
    valve.Lon = num2cell([xmin,xmax],2);
    valve.Lat = num2cell([ymin,ymax],2);
    
    % convert logical to double
    valve = logical2integer(valve);
    
    % reduce numer of variable characters
    valve.Properties.VariableNames = erase(valve.Properties.VariableNames,'_ij');
    valve.Properties.VariableNames = erase(valve.Properties.VariableNames,'_dot');
    valve.Properties.VariableNames = erase(valve.Properties.VariableNames,'_n');
    try
        valve.V__m3_per_s = valve.V;
        valve = movevars(valve,'V__m3_per_s','After','V__m3_per_h');
        valve.V = [];
    catch
    end
    
    % convert table to struct
    valve = table2struct(valve);
    
    % create shape file
    shapewrite(valve, [directory,'\',FILENAME,'_valve.shp'])
end

%% Display message
if nargin < 3
    disp([FILENAME,' has been saved as shape files (.shp, .shx, .dbf) at ',directory])
end

end

