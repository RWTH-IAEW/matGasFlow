function [GN] = init_p_i(GN)
%INIT_P_I Initialize p_i
%   GN = init_p_i(GN)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Physical constants
CONST = getConstants();

%% p_i: Covert pressure values, bar_g --> Pa
GN.bus.p_i = GN.bus.p_i__barg*1e5 + CONST.p_n;

%% Check slack bus
if ismember('slack_bus',GN.bus.Properties.VariableNames) && any(isnan(GN.bus.p_i) & GN.bus.slack_bus)
    error('Slack bus has no pressure value p_i__barg.')
end

%% Initialize p_i values if missing
if any(isnan(GN.bus.p_i))
    area_IDs = unique(GN.bus.area_ID(isnan(GN.bus.p_i)));
    for ii = 1:length(area_IDs)
        GN.bus.p_i(isnan(GN.bus.p_i) & GN.bus.area_ID == area_IDs(ii)) = ...
            mean(GN.bus.p_i(~isnan(GN.bus.p_i) & GN.bus.area_ID == area_IDs(ii)));
    end
end

%% Check output
if any(isnan(GN.bus.p_i) | isinf(GN.bus.p_i) | GN.bus.p_i < 0)
    warning(['Missing or invalid pressure values in theses areas: ', num2str(find(isnan(GN.bus.p_i) | isinf(GN.bus.p_i) | GN.bus.p_i < 0)')])
end

end

