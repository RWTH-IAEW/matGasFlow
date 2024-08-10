function [GN_1, GN_0, success] = secant_method_step(GN_1, GN_0)
%UNTITLED
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Success
success = true;

%% Constants
CONST = getConstants();

%% slack
is_slack_bus = GN_1.bus.slack_bus;

%% Calculate p_i_2
p_i_2 = (GN_0.bus.p_i .* GN_1.bus.f - GN_1.bus.p_i .* GN_0.bus.f) ./ (GN_1.bus.f - GN_0.bus.f);

%% Correction
p_i_2(is_slack_bus) = GN_1.bus.p_i(is_slack_bus);
if any(isnan(p_i_2) & ~is_slack_bus)
    p_i_2(isnan(p_i_2)) = mean([GN_0.bus.p_i(isnan(p_i_2)), GN_1.bus.p_i(isnan(p_i_2))],2);
end
if any(isinf(p_i_2) & ~is_slack_bus)
    p_i_2(isinf(p_i_2)) = mean([GN_0.bus.p_i(isinf(p_i_2)), GN_1.bus.p_i(isinf(p_i_2))],2);
end

%% p_0 becomes p_1
GN_0 = GN_1;

%% p_1 becomes p_2
GN_1.bus.p_i(~is_slack_bus) = p_i_2(~is_slack_bus);
 
%% check result
if any(GN_1.bus.p_i < CONST.p_n)
    success = false;
end

end

