function [GN] = init_GN_NR(GN)
%INIT_GN_NR Summary of this function goes here
%   Detailed explanation goes here
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2021, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

GN_NR = GN;
i_columns = find(~GN.bus.p_bus);
if isempty(i_columns)
    return
end

GN_NR.bus = repmat(GN_NR.bus,length(i_columns),1);
max_bus_ID = max(GN_NR.bus.bus_ID);
shift_ID = reshape( ones(size(GN.bus,1),1) * (1:length(i_columns)) ,[],1);
shift_ID = shift_ID*max_bus_ID;
GN_NR.bus.bus_ID = GN_NR.bus.bus_ID + shift_ID;

if isfield(GN_NR,'pipe')
    GN_NR.pipe = repmat(GN_NR.pipe,length(i_columns),1);
    shift_ID = reshape( ones(size(GN.pipe,1),1) * (1:length(i_columns)) ,[],1);
    shift_ID = shift_ID*max_bus_ID;
    GN_NR.pipe.from_bus_ID = GN_NR.pipe.from_bus_ID + shift_ID;
    GN_NR.pipe.to_bus_ID = GN_NR.pipe.to_bus_ID + shift_ID;
end
if isfield(GN_NR,'comp')
    GN_NR.comp = repmat(GN_NR.comp,length(i_columns),1);
    shift_ID = reshape( ones(size(GN.comp,1),1) * (1:length(i_columns)) ,[],1);
    shift_ID = shift_ID*max_bus_ID;
    GN_NR.comp.from_bus_ID = GN_NR.comp.from_bus_ID + shift_ID;
    GN_NR.comp.to_bus_ID = GN_NR.comp.to_bus_ID + shift_ID;
end
if isfield(GN_NR,'prs')
    GN_NR.prs = repmat(GN_NR.prs,length(i_columns),1);
    shift_ID = reshape( ones(size(GN.prs,1),1) * (1:length(i_columns)) ,[],1);
    shift_ID = shift_ID*max_bus_ID;
    GN_NR.prs.from_bus_ID = GN_NR.prs.from_bus_ID + shift_ID;
    GN_NR.prs.to_bus_ID = GN_NR.prs.to_bus_ID + shift_ID;
end
if isfield(GN_NR,'valve')
    GN_NR.valve = repmat(GN_NR.valve,length(i_columns),1);
    shift_ID = reshape( ones(size(GN.valve,1),1) * (1:length(i_columns)) ,[],1);
    shift_ID = shift_ID*max_bus_ID;
    GN_NR.valve.from_bus_ID = GN_NR.valve.from_bus_ID + shift_ID;
    GN_NR.valve.to_bus_ID = GN_NR.valve.to_bus_ID + shift_ID;
end

% Inititalize GN.branch
GN_NR = init_GN_branch(GN_NR);

% Inititialize indices
GN_NR = init_GN_indices(GN_NR);

% Inititialize incidence matrix
GN_NR.INC = get_INC(GN_NR);

% Return GN.GN_NR
GN.GN_NR = GN_NR;

end

