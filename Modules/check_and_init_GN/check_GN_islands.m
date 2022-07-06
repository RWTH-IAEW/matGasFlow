function [GN] = check_GN_islands(GN)
%CHECK_GN_ISLANDS Check if the gas network is seperated in two or more parts
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2022, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Unsupplied busses
% Set area_ID of unsupplied bussus to NaN
GN_temp = GN;
GN_temp.branch(~GN_temp.branch.in_service,:) = [];
GN.bus.supplied = (ismember(1:size(GN_temp.bus,1),[GN_temp.branch.i_from_bus;GN_temp.branch.i_to_bus]))';
% UNDER CONSTRUCTION
if ...
        (ismember('P_th_i__MW',GN.bus.Properties.VariableNames)              && any(GN.bus.P_th_i__MW(~GN.bus.supplied) ~= 0)) || ...
        (ismember('P_th_i',GN.bus.Properties.VariableNames)                  && any(GN.bus.P_th_i(~GN.bus.supplied) ~= 0)) || ...
        (ismember('V_dot_n_i__m3_per_day',GN.bus.Properties.VariableNames)   && any(GN.bus.V_dot_n_i__m3_per_day(~GN.bus.supplied) ~= 0)) || ...
        (ismember('V_dot_n_i__m3_per_h',GN.bus.Properties.VariableNames)     && any(GN.bus.V_dot_n_i__m3_per_h(~GN.bus.supplied) ~= 0)) || ...
        (ismember('m_dot_i__kg_per_s',GN.bus.Properties.VariableNames)       && any(GN.bus.m_dot_i__kg_per_s(~GN.bus.supplied) ~= 0)) || ...
        (ismember('V_dot_n_i',GN.bus.Properties.VariableNames)               && any(GN.bus.V_dot_n_i(~GN.bus.supplied) ~= 0))
    
    warning(['GN.bus: bus_ID of unsupplied sinks/sources: ',num2str(GN.bus.bus_ID(~GN.bus.supplied)')])
    
elseif any(~GN.bus.supplied)
    warning(['GN.bus: Unsupplied busses (bus_ID): ',num2str(GN.bus.bus_ID(~GN.bus.supplied)')])
    
end

%%
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

