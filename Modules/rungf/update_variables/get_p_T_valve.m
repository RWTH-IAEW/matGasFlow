function [GN] = get_p_T_valve(GN)
%GET_P_T_VALVE
%
%   Update p_i and T_i at valve output with p_i and T_i at valve input.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2022, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
if ~isfield(GN,'valve')
    return
end


%% Itentify valve groups and reduce valve station to one bus
valveStation_IDs = unique(GN.branch.valveStation_ID(GN.branch.valve_branch & GN.branch.in_service));

for ii = 1:length(valveStation_IDs)
    valveStation_ID = valveStation_IDs(ii);
    
    % get center and non-center bussus of valve station
    is_branch_valveStation      = GN.branch.valveStation_ID == valveStation_ID & GN.branch.in_service;
    i_bus_valveStation          = unique( [ GN.branch.i_from_bus(is_branch_valveStation); GN.branch.i_to_bus(is_branch_valveStation) ] );
    i_bus_valveStation_center   = i_bus_valveStation(1);
    i_bus_delete                = i_bus_valveStation(2:end);
    
    % apply quantities and porperties to deleted bus
    white_list  = {'p_i__barg', 'T_i', 'Z_i', 'c_p_i', 'c_p_0_i', 'kappa_i', 'rho_i'};
    i_column    = ismember(GN.bus.Properties.VariableNames, white_list);
    GN.bus(i_bus_delete, i_column)      = GN.bus(ones(size(i_bus_delete))*i_bus_valveStation_center, i_column);
    GN.bus.slack_bus(   i_bus_delete)   = false;
    GN.bus.p_bus(       i_bus_delete)   = false;
    GN.bus.active_bus(  i_bus_delete)   = false;
    GN.bus.V_dot_n_i(   i_bus_delete)   = 0;
end

end

