function [GN] = JSON2GN(fname, keepAllInformation)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 2
    keepAllInformation = true;
end

%% pandapipes json to Matlab struct
fid = fopen(fname);
raw = fread(fid,inf);
str = char(raw');
fclose(fid);
val = jsondecode(str);

val.x_object.junction.x_object          = jsonTable2table(val.x_object.junction.x_object);
val.x_object.junction_geodata.x_object  = jsonTable2table(val.x_object.junction_geodata.x_object);
val.x_object.pipe.x_object              = jsonTable2table(val.x_object.pipe.x_object);
val.x_object.pipe_geodata.x_object      = jsonTable2table(val.x_object.pipe_geodata.x_object);
val.x_object.ext_grid.x_object          = jsonTable2table(val.x_object.ext_grid.x_object);
val.x_object.sink.x_object              = jsonTable2table(val.x_object.sink.x_object);
if isfield(val.x_object,'source')
    val.x_object.source.x_object            = jsonTable2table(val.x_object.source.x_object);
end
val.x_object.controller.x_object        = jsonTable2table(val.x_object.controller.x_object);
if isfield(val.x_object, 'pump')
    val.x_object.pump.x_object              = jsonTable2table(val.x_object.pump.x_object);
end
val.x_object.fluid.x_object             = jsonTable2table_fluid(val.x_object.fluid.x_object);

%% Matlab struct to GN
GN = struct;

%% GN.gasMix
GN = getGasType(val,GN);

%% GN.bus
GN = getGNbus(val,GN,keepAllInformation);

%% GN.pipe
if isfield(val.x_object, 'pipe')
    GN = getGNpipe(val,GN,keepAllInformation);
end

%% TODO
% %% GN.heater - TODO heat_exchanger
% if isfield(val.x_object,'pipe')
%     if isfield(val.x_object.pipe.x_object, 'x_object')
%         readtable(val.x_object.pipe.x_object.qext_w)
%         GN =getHeater(GN,val);
%     end
% end
% 
% %% GN.comp
% if isfield(val.x_object, 'pump')
%     GN = getGNcomp(val,GN, keepAllInformation);
% end
% %% GN.prs
% if isfield(val.x_object, 'valve')
%     GN = getGNcomp(val,GN, keepAllInformation);
% end
% GN.getGNprs(val,GN);

GN.isothermal = false;
GN = check_and_init_GN(GN);

if ~ismember('V_dot_n_i',GN.bus.Properties.VariableNames)
    GN = get_V_dot_n_i(GN);
end
GN = get_V_dot_n_slack(GN, 'GN');

%% Calculate P_th_i__MW, P_th_i, V_dot_n_i__m3_per_day, V_dot_n_i__m3_per_h or m_dot_i__kg_per_s
if ismember('P_th_i__MW',GN.bus.Properties.VariableNames)
    GN.bus.P_th_i__MW               = convert_gas_flow_quantity(GN.bus.V_dot_n_i, 'm3_per_s', 'MW',         GN.gasMixProp);
    GN.bus.V_dot_n_i = [];    
elseif ismember('P_th_i',GN.bus.Properties.VariableNames)
    GN.bus.P_th_i                   = convert_gas_flow_quantity(GN.bus.V_dot_n_i, 'm3_per_s', 'W',          GN.gasMixProp);
    GN.bus.V_dot_n_i = [];    
elseif ismember('V_dot_n_i__m3_per_day',GN.bus.Properties.VariableNames)
    GN.bus.V_dot_n_i__m3_per_day    = convert_gas_flow_quantity(GN.bus.V_dot_n_i, 'm3_per_s', 'm3_per_day', GN.gasMixProp);
    GN.bus.V_dot_n_i = [];   
elseif ismember('V_dot_n_i__m3_per_h',GN.bus.Properties.VariableNames)
    GN.bus.V_dot_n_i__m3_per_h      = convert_gas_flow_quantity(GN.bus.V_dot_n_i, 'm3_per_s', 'm3_per_h',   GN.gasMixProp);
    GN.bus.V_dot_n_i = [];    
elseif ismember('m_dot_i__kg_per_s',GN.bus.Properties.VariableNames)
    GN.bus.m_dot_i__kg_per_s        = convert_gas_flow_quantity(GN.bus.V_dot_n_i, 'm3_per_s', 'kg_per_s',   GN.gasMixProp);
    GN.bus.V_dot_n_i = [];
end

end