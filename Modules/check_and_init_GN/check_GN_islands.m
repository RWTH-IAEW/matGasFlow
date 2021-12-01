function [GN] = check_GN_islands(GN)
%CHECK_GN_ISLANDS_AREA_ID Summary of this function goes here
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

GN_temp = GN;
GN_temp.branch(~GN_temp.branch.in_service,:) = [];
GN_temp.bus(~GN_temp.bus.supplied,:) = [];
[~,i_from_bus] = ismember(GN_temp.branch.from_bus_ID,GN_temp.bus.bus_ID);
[~,i_to_bus]   = ismember(GN_temp.branch.to_bus_ID,GN_temp.bus.bus_ID);
g = graph(i_from_bus,i_to_bus);
islands = conncomp(g);
if any(islands ~= 1)
    error(['The gas network is seperated in ',num2str(max(islands)),' gas networks. The gas network must be a connected graph.'])
end
end

