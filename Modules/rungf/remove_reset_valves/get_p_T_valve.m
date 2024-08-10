function [GN] = get_p_T_valve(GN)
%UNTITLED
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

if ~isfield(GN,'valve')
    return
end

if any(~ismember(GN.bus.bus_ID,[GN.branch.from_bus_ID;GN.branch.to_bus_ID]))
    error('Something went wrong: Some busses are not part of any branch.')
end

%% Itentify valve groups and reduce valve station to one bus
valve_group_IDs = unique(GN.branch.valve_group_ID(GN.branch.valve_branch & ~isnan(GN.branch.valve_group_ID)));

for ii = 1:length(valve_group_IDs)
    
    valve_group_ID = valve_group_IDs(ii);
    
    % get center and non-center bussus of valve station
    is_branch_valveStation      = GN.branch.valve_group_ID == valve_group_ID;
    i_bus_valveStation          = unique( [ GN.branch.i_from_bus(is_branch_valveStation); GN.branch.i_to_bus(is_branch_valveStation) ] );
    i_bus_valveStation_center   = i_bus_valveStation(1);
    i_bus_valveStation_noCenter = i_bus_valveStation(2:end);
    
    % apply quantities of center bus to non-center busses
    GN.bus.p_i__barg(i_bus_valveStation_noCenter)   = GN.bus.p_i__barg(i_bus_valveStation_center);
    GN.bus.p_i(i_bus_valveStation_noCenter)         = GN.bus.p_i(i_bus_valveStation_center);
    GN.bus.T_i(i_bus_valveStation_noCenter)         = GN.bus.T_i(i_bus_valveStation_center);
    GN.bus.Z_i(i_bus_valveStation_noCenter)         = GN.bus.Z_i(i_bus_valveStation_center);
    GN.bus.rho_i(i_bus_valveStation_noCenter)       = GN.bus.rho_i(i_bus_valveStation_center);
    GN.bus.f(i_bus_valveStation_noCenter)           = 0;
    GN.bus.rho_i(i_bus_valveStation_noCenter)       = GN.bus.rho_i(i_bus_valveStation_center);
    GN.bus.c_p_i(i_bus_valveStation_noCenter)       = GN.bus.c_p_i(i_bus_valveStation_center);
    GN.bus.c_p_0_i(i_bus_valveStation_noCenter)     = GN.bus.c_p_0_i(i_bus_valveStation_center);
    GN.bus.kappa_i(i_bus_valveStation_noCenter)     = GN.bus.kappa_i(i_bus_valveStation_center);
end


end

