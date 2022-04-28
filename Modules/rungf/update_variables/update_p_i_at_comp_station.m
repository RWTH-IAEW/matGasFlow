function [GN] = update_p_i_at_comp_station(GN)
%UPDATE_P_I_AT_COMP_STATION Summary of this function goes here
%   Detailed explanation goes here
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2022, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Update p_i__barg
% comp station input: i_bus at prs output not connected to pipes, valves or comp outputs
i_prs_to_bus                = unique(GN.branch.i_to_bus(GN.branch.prs_branch & GN.branch.in_service));
i_pipe_valve_compOut_bus    = unique([...
    GN.branch.i_from_bus(~GN.branch.active_branch & GN.branch.in_service); ...
    GN.branch.i_to_bus(  ~GN.branch.active_branch & GN.branch.in_service); ...
    GN.branch.i_to_bus(   GN.branch.comp_branch   & GN.branch.in_service)]);
i_prs_to_bus                = i_prs_to_bus(~ismember(i_prs_to_bus, i_pipe_valve_compOut_bus));

for ii = 1:length(i_prs_to_bus)
    i_prs_from_bus_temp     = GN.branch.i_from_bus(...
        ismember(GN.branch.i_to_bus,i_prs_to_bus(ii))...
        & GN.branch.prs_branch ...
        & GN.branch.in_service);
    GN.bus.p_i__barg(i_prs_to_bus(ii))      = min(GN.bus.p_i__barg(i_prs_from_bus_temp));
    GN.bus.p_i_min__barg(i_prs_to_bus(ii))  = min(GN.bus.p_i_min__barg(i_prs_from_bus_temp));
    GN.bus.p_i_max__barg(i_prs_to_bus(ii))  = max(GN.bus.p_i_max__barg(i_prs_from_bus_temp));
end


% comp station output: i_bus at prs input not connected to pipes, valves or comp input
i_prs_from_bus              = unique(GN.branch.i_from_bus(GN.branch.prs_branch & GN.branch.in_service));
i_pipe_valve_compIn_bus     = unique([...
    GN.branch.i_from_bus(~GN.branch.active_branch & GN.branch.in_service); ...
    GN.branch.i_to_bus(  ~GN.branch.active_branch & GN.branch.in_service); ...
    GN.branch.i_from_bus(   GN.branch.comp_branch & GN.branch.in_service)]);
i_prs_from_bus              = i_prs_from_bus(~ismember(i_prs_from_bus, i_pipe_valve_compIn_bus));

for ii = 1:length(i_prs_from_bus)
    i_prs_to_bus_temp       = GN.branch.i_to_bus(...
        ismember(GN.branch.i_from_bus,i_prs_from_bus(ii)) ...
        & GN.branch.prs_branch ...
        & GN.branch.in_service);
    GN.bus.p_i__barg(i_prs_from_bus(ii))        = max(GN.bus.p_i__barg(i_prs_to_bus_temp));
    GN.bus.p_i_min__barg(i_prs_from_bus(ii))    = min(GN.bus.p_i_min__barg(i_prs_to_bus_temp));
    GN.bus.p_i_max__barg(i_prs_from_bus(ii))    = max(GN.bus.p_i_max__barg(i_prs_to_bus_temp));
end


end

