function [GN] = check_and_init_p_i__barg(GN)
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

if all(~isnan(GN.bus.p_i__barg))
    return
end

%% p_i__barg
if all(ismember({'p_i_min__barg','p_i_max__barg'}, GN.bus.Properties.VariableNames))
    p_max = GN.bus.p_i_max__barg(isnan(GN.bus.p_i__barg));
    p_min = GN.bus.p_i_min__barg(isnan(GN.bus.p_i__barg));
    GN.bus.p_i__barg(isnan(GN.bus.p_i__barg)) = ...
        (p_max.^2 + p_max.*p_min + p_min.^2) ./ (1.5 * (p_max+p_min));
    
elseif ismember('p_i_max__barg', GN.bus.Properties.VariableNames)
    GN.bus.p_i__barg(isnan(GN.bus.p_i__barg)) = GN.bus.p_i_max__barg(isnan(GN.bus.p_i__barg));
    
elseif ismember('p_i_min__barg', GN.bus.Properties.VariableNames)
    GN.bus.p_i__barg(isnan(GN.bus.p_i__barg)) = GN.bus.p_i_min__barg(isnan(GN.bus.p_i__barg));
    
end

p_area__barg = GN.MAT.area_bus(:,GN.bus.slack_bus) * GN.bus.p_i__barg(GN.bus.slack_bus);

if any(isnan(p_area__barg))
    error(['Areas with no p_i__barg value: ', num2str(find(isnan(p_area__barg))')])
end

end

