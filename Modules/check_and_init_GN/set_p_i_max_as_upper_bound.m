function [GN] = set_p_i_max_as_upper_bound(GN, GN_res, area_IDs)
%UNTITLED Summary of this function goes here
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

if nargin < 3
    area_IDs = unique(GN_res.bus.area_ID(GN_res.bus.p_i__barg > GN.bus.p_i_max__barg));
end

for jj = 1:length(area_IDs)
    i_bus_res               = find(GN_res.bus.area_ID == area_IDs(jj));
    p_geo_diff              = GN_res.bus.p_i__barg(i_bus_res).^2 - GN_res.bus.p_i_max__barg(i_bus_res).^2;
    i_new_slack_bus_res     = i_bus_res(p_geo_diff == max(p_geo_diff));
    
    [~,i_bus]               = ismember(GN_res.bus.bus_ID(i_bus_res), GN.bus.bus_ID);
    [~,i_new_slack_bus]     = ismember(GN_res.bus.bus_ID(i_new_slack_bus_res), GN.bus.bus_ID);
    GN.bus.slack_bus(i_bus) = false;
    GN.bus.slack_bus(i_new_slack_bus(1))    = true;
    % GN.bus.p_i__barg(i_new_slack_bus(1))    = GN.bus.p_i_min__barg(i_new_slack_bus(1));
    GN.bus.p_i__barg(i_bus) = GN.bus.p_i_max__barg(i_new_slack_bus(1));
    % UNDER CONSTRUCTION: Reset slack_branch?!
end

GN = check_and_init_GN(GN);
end

