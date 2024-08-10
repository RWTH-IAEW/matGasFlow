function [GN_1, GN_0, success] = binary_secant_method_step(GN_1, GN_0, NUMPARAM, PHYMOD)
%BINARY_SECANT_METHOD_STEP
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

error('Sorry. This solver is not upto date.')

%% Success
success = true;

%% Constants
CONST = getConstants();

%% slack
is_slack_bus = GN_1.bus.slack_bus;

%% Calculate p_i_2
GN_2 = GN_1;
p_i_2 = (GN_0.bus.p_i .* GN_1.bus.f - GN_1.bus.p_i .* GN_0.bus.f) ./ (GN_1.bus.f - GN_0.bus.f);
p_i_2(p_i_2 <= CONST.p_n) = CONST.p_n;

% check p_i_2
if any(p_i_2 < CONST.p_n & ~is_slack_bus)
    warning(['Nodal pressure became less than ',num2str(CONST.p_n),' Pa. min(p_i) = ',num2str(min(GN.bus.p_i)),' Pa'])
    success = false;
    return
end
if any(isnan(p_i_2) & ~is_slack_bus)
    p_i_2(isnan(p_i_2)) = mean([GN_0.bus.p_i(isnan(p_i_2)), GN_1.bus.p_i(isnan(p_i_2))],2);
end
if any(isinf(p_i_2) & ~is_slack_bus)
    p_i_2(isinf(p_i_2)) = mean([GN_0.bus.p_i(isinf(p_i_2)), GN_1.bus.p_i(isinf(p_i_2))],2);
end

GN_2.bus.p_i(~is_slack_bus) = p_i_2(~is_slack_bus);

% Update p_i dependent quantities
GN_2 = update_p_i_dependent_quantities(GN_2, NUMPARAM, PHYMOD);

% Update nodal equation
GN_2 = get_f_nodal_equation(GN_2, NUMPARAM, PHYMOD);

%% Calculate p_i_02
GN_02 = GN_0;
p_i_02 = (GN_0.bus.p_i .* GN_2.bus.f - GN_2.bus.p_i .* GN_0.bus.f) ./ (GN_2.bus.f - GN_0.bus.f);
p_i_02(p_i_02 <= CONST.p_n) = CONST.p_n;

% check p_i_02
if any(p_i_02 < CONST.p_n & ~is_slack_bus)
    warning(['Nodal pressure became less than ',num2str(CONST.p_n),' Pa. min(p_i) = ',num2str(min(GN.bus.p_i)),' Pa'])
    success = false;
    return
end
if any(isnan(p_i_02) & ~is_slack_bus)
    p_i_02(isnan(p_i_02)) = mean([GN_0.bus.p_i(isnan(p_i_02)), GN_1.bus.p_i(isnan(p_i_02))],2);
end
if any(isinf(p_i_02) & ~is_slack_bus)
    p_i_02(isinf(p_i_02)) = mean([GN_0.bus.p_i(isinf(p_i_02)), GN_1.bus.p_i(isinf(p_i_02))],2);
end

GN_02.bus.p_i(~GN_02.bus.slack_bus) = p_i_02(~GN_02.bus.slack_bus);

% Update p_i dependent quantities
GN_02 = update_p_i_dependent_quantities(GN_02, NUMPARAM, PHYMOD);

% Update nodal equation
GN_02 = get_f_nodal_equation(GN_02, NUMPARAM, PHYMOD, 'bus');

%% Calculate p_i_12
GN_12 = GN_1;
p_i_12 = (GN_1.bus.p_i .* GN_2.bus.f - GN_2.bus.p_i .* GN_1.bus.f) ./ (GN_2.bus.f - GN_1.bus.f);
p_i_12(p_i_12 <= CONST.p_n) = CONST.p_n;

% check p_i_12
if any(p_i_12 < CONST.p_n & ~is_slack_bus)
    warning(['Nodal pressure became less than ',num2str(CONST.p_n),' Pa. min(p_i) = ',num2str(min(GN.bus.p_i)),' Pa'])
    success = false;
    return
end
if any(isnan(p_i_12) & ~is_slack_bus)
    p_i_12(isnan(p_i_12)) = mean([GN_0.bus.p_i(isnan(p_i_12)), GN_1.bus.p_i(isnan(p_i_12))],2);
end
if any(isinf(p_i_12) & ~is_slack_bus)
    p_i_12(isinf(p_i_12)) = mean([GN_0.bus.p_i(isinf(p_i_12)), GN_1.bus.p_i(isinf(p_i_12))],2);
end

GN_12.bus.p_i(~is_slack_bus) = p_i_12(~is_slack_bus);

% Update p_i dependent quantities
GN_12 = update_p_i_dependent_quantities(GN_12, NUMPARAM, PHYMOD);

% Update nodal equation
GN_12 = get_f_nodal_equation(GN_12, NUMPARAM, PHYMOD, 'bus');

%% Update GN_0, GN_1
if norm(GN_12.bus.f) < norm(GN_02.bus.f)
    GN_0 = GN_1;
    GN_1 = GN_12;
else
    GN_0 = GN_2;
    GN_1 = GN_02;
end


end

