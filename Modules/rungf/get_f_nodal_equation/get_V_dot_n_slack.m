function [GN] = get_V_dot_n_slack(GN, f_mode, NUMPARAM)
%GET_V_DOT_N_SLACK Summary of this function goes here
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

if abs(sum(GN.bus.V_dot_n_i)) > NUMPARAM.numericalTolerance
    warning('Entries and exits are not balanced. V_dot_n_ij of the slack busses have been updated.')
end

if strcmp(f_mode,'GN')
    if any(GN.bus.V_dot_n_i(GN.bus.slack_bus) ~= 0)
        GN.bus.V_dot_n_i(GN.bus.slack_bus & GN.bus.V_dot_n_i ~= 0) = ...
            GN.bus.V_dot_n_i(GN.bus.slack_bus & GN.bus.V_dot_n_i ~= 0) ...
            - sum(GN.bus.V_dot_n_i)/sum(GN.bus.slack_bus & GN.bus.V_dot_n_i ~= 0);
    else
        GN.bus.V_dot_n_i(GN.bus.slack_bus) = ...
            GN.bus.V_dot_n_i(GN.bus.slack_bus) ...
            - sum(GN.bus.V_dot_n_i)/sum(GN.bus.slack_bus);
    end
    
elseif strcmp(f_mode,'area')
    GN.bus.f    = GN.INC * GN.branch.V_dot_n_ij + GN.bus.V_dot_n_i;
    f_area      = GN.MAT.area_bus * GN.bus.f;
    
    slack_bus_area_MAT                  = GN.MAT.area_bus(:,GN.bus.slack_bus)';
    GN.bus.V_dot_n_i(GN.bus.slack_bus)  = - slack_bus_area_MAT * f_area;
    
    V_dot_n_ij = GN.MAT.area_active_branch' * f_area;
    GN.branch.V_dot_n_ij(GN.branch.slack_branch) = GN.branch.V_dot_n_ij(GN.branch.slack_branch) + V_dot_n_ij(GN.branch.slack_branch);
    
elseif strcmp(f_mode,'bus')
    if any(GN.bus.V_dot_n_i(GN.bus.slack_bus) ~= 0)
        GN.bus.V_dot_n_i(GN.bus.slack_bus & GN.bus.V_dot_n_i ~= 0) = ...
            GN.bus.V_dot_n_i(GN.bus.slack_bus & GN.bus.V_dot_n_i ~= 0) ...
            - sum(GN.bus.V_dot_n_i)/sum(GN.bus.slack_bus & GN.bus.V_dot_n_i ~= 0);
    else
        GN.bus.V_dot_n_i(GN.bus.slack_bus) = ...
            GN.bus.V_dot_n_i(GN.bus.slack_bus) ...
            - sum(GN.bus.V_dot_n_i)/sum(GN.bus.slack_bus);
    end
    
else
    error('get_V_dot_n_slack: Choose ''area'' or ''bus'' for f_mode')
end

end

