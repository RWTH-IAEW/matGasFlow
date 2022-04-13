function [GN] = get_time_series_res(GN, time_series_res_options)
%GET_TIME_SERIES_RES Summary of this function goes here
%   Detailed explanation goes here
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2021, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

time_series_ID  = [];
object          = cell(0,0);
object_ID       = [];
object_name     = [];
object_quantity = [];

objects = fieldnames(GN.time_series_res_struct);
for ii = length(objects)
    object_quantities = fieldnames(GN.time_series_res_struct.(objects{ii}));
    for jj = 1:length(object_quantities)
        n_objects = size(GN.time_series_res_struct.(objects{ii}).(object_quantities{jj}),1);
        object_temp = cell(n_objects,1);
        object_temp(:) = objects(ii);
        object = [object;object_temp];
        object_ID
    end
end

%% Size - number of time_series elements
n_bus = size(GN.bus,1);

if isfield(GN,'pipe')
    n_pipe = size(GN.pipe,1);
else
    n_pipe = 0;
end

if isfield(GN,'comp')
    n_comp = size(GN.comp,1);
else
    n_comp = 0;
end

if isfield(GN,'prs')
    n_prs = size(GN.prs,1);
else
    n_prs = 0;
end

if isfield(GN,'valve')
    n_valve = size(GN.valve,1);
else
    n_valve = 0;
end

%% Initialize GN.time_series_res
if ~isfield(GN,'time_series_res')
    %% Initialize time_series_res
    
    id = 'MATLAB:table:PreallocateCharWarning';
    warning('off', id); % UNDER CONSTRUCTION: Might be avoidable
    GN.time_series_res = table(...
        'Size',[n_bus+n_pipe+n_comp+n_prs+n_valve 4],...
        'VariableTypes',{'double','char','double','char'},...
        'VariableNames',{'time_series_res_ID','object','object_ID','object_quantity'});
    warning('on', id);
    
    GN.time_series_res.time_series_res_ID         = (1:n_bus+n_pipe+n_comp+n_prs+n_valve)';
    
    idx = 1;
    GN.time_series_res.object(idx:idx-1+n_bus) = {'bus'};
    GN.time_series_res.object_ID(idx:idx-1+n_bus) = GN.bus.bus_ID;
    GN.time_series_res.object_quantity(idx:idx-1+n_bus) = {'p_i'};
    
    if isfield(GN,'pipe')
        idx = idx + n_bus;
        GN.time_series_res.object(idx:idx-1+n_pipe) = {'pipe'};
        GN.time_series_res.object_ID(idx:idx-1+n_pipe) = GN.pipe.pipe_ID;
        GN.time_series_res.object_quantity(n_bus+1:end) = {'V_dot_n_i'};
    end
    
    if isfield(GN,'comp')
        idx = idx + n_pipe;
        GN.time_series_res.object(idx:idx-1+n_comp) = {'comp'};
        GN.time_series_res.object_ID(idx:idx-1+n_comp) = GN.comp.comp_ID;
    end
    
    if isfield(GN,'prs')
        idx = idx + n_comp;
        GN.time_series_res.object(idx:idx-1+n_prs) = {'prs'};
        GN.time_series_res.object_ID(idx:idx-1+n_prs) = GN.prs.prs_ID;
    end
    
    if isfield(GN,'valve')
        idx = idx + n_prs;
        GN.time_series_res.object(idx:idx-1+n_valve) = {'valve'};
        GN.time_series_res.object_ID(idx:idx-1+n_valve) = GN.valve.valve_ID;
    end
end

%% Write results to table
field_names = fieldnames(GN.time_series_res);
if strcmp('object_quantity',field_names{end})
    GN.time_series_res.('t1') = NaN(n_bus+n_pipe+n_comp+n_prs+n_valve,1);
else
    f_start = find(strcmp(field_names, 'object_quantity'));
    f_end = size(field_names,1) - 3;
    time_step = f_end - f_start + 1;
    GN.time_series_res.(['t',num2str(time_step)]) = NaN(n_bus+n_pipe+n_comp+n_prs+n_valve,1);
end

idx = 1;
GN.time_series_res(idx:idx-1+n_bus,end) = num2cell(GN.bus.p_i__barg);

if isfield(GN,'pipe')
    idx = idx + n_bus;
    GN.time_series_res(idx:idx-1+n_pipe,end) = num2cell(GN.pipe.V_dot_n_ij);
end

if isfield(GN,'comp')
    idx = idx + n_pipe;
    GN.time_series_res(idx:idx-1+n_comp,end) = num2cell(GN.comp.V_dot_n_ij);
end

if isfield(GN,'prs')
    idx = idx + n_comp;
    GN.time_series_res(idx:idx-1+n_prs,end) = num2cell(GN.prs.V_dot_n_ij);
end

if isfield(GN,'valve')
    idx = idx + n_prs;
    GN.time_series_res(idx:idx-1+n_valve,end) = num2cell(GN.valve.V_dot_n_ij);
end
end

