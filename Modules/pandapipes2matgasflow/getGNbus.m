function [GN] = getGNbus(val,GN)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

GN.bus = val.x_object.junction.x_object;

GN.bus.p_i__barg        = GN.bus.pn_bar;
GN.bus.pn_bar           = [];
GN.bus.T_i              = GN.bus.tfluid_k;
GN.bus.T_source(:)      = GN.bus.T_i;
GN.bus.tfluid_k         = [];
if isfield(GN.bus, 'index')
    GN.bus.bus_ID       = GN.bus.index;
    GN.bus.index        = [];
    warning('GN.bus.index has been deleted.')
else
    GN.bus.bus_ID       = (0:height(GN.bus)-1)';
end

GN.bus.slack_bus(:)     = false;
[~,idx]                 = ismember(val.x_object.ext_grid.x_object.junction, GN.bus.bus_ID);
GN.bus.slack_bus(idx)   = true;
GN.bus.p_i__barg(idx)   = val.x_object.ext_grid.x_object.p_bar;
GN.bus.T_source(idx)    = val.x_object.ext_grid.x_object.t_k;

if isfield(val.x_object, 'sink')
    [~,idx] = ismember(val.x_object.sink.x_object.junction, GN.bus.bus_ID);
    if length(unique(idx)) < length(idx)
        idx_sink = unique([val.x_object.sink.x_object.junction]);
        for i_idx = idx_sink
            idx_pos         = [val.x_object.sink.x_object.junction] == i_idx;
            mdot_kg_per_s   = sum([val.x_object.sink.x_object.mdot_kg_per_s(idx_pos)]);
            val.x_object.sink.x_object.mdot_kg_per_s(idx_pos(1)) = mdot_kg_per_s;
            idx_pos         = find(idx_pos);
            val.x_object.sink.x_object([idx_pos(2:end)],:) = [];
        end
    end
    GN.bus.m_dot_i__kg_per_s(idx) = val.x_object.sink.x_object.mdot_kg_per_s;
    GN.bus.demand_m3_per_a(idx) = val.x_object.sink.x_object.mdot_kg_per_s;
    GN.bus.sink_name(idx) = val.x_object.sink.x_object.name;
    GN.bus.sink_scaling(idx) = val.x_object.sink.x_object.scaling;
    GN.bus.sink_type(idx) = val.x_object.sink.x_object.type;
    GN.bus.sink_profile_id(idx) = val.x_object.sink.x_object.profile_id;
end

if isfield(val.x_object, 'source')
    [~,idx] = ismember(val.x_object.source.x_object.junction, GN.bus.bus_ID);
    if length(unique(idx)) < length(idx)
        error('length(unique(idx)) < length(idx) (-->TODO)')
    end
    GN.bus.m_dot_i__kg_per_s(idx) = -val.x_object.source.x_object.mdot_kg_per_s;
end

%% x_coord, y_coord
if isfield(val.x_object,'junction_geodata')
    GN.bus.x_coord = val.x_object.junction_geodata.x_object.x;
    GN.bus.y_coord = val.x_object.junction_geodata.x_object.y;
end

end
