function [GN] = check_and_init_V_bus(GN)
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

%% Init V_bus
if ~ismember('V_bus',GN.bus.Properties.VariableNames)
    GN.bus.V_bus = ~GN.bus.slack_bus;
end

n_unkowns   = sum(~GN.bus.slack_bus)+sum(~GN.bus.V_bus)+sum(GN.branch.active_branch & ~GN.branch.preset);
n_equations = sum(GN.bus.supplied);
if n_unkowns > n_equations
    i_reset_V_bus = find(GN.bus.slack_bus, n_unkowns-n_equations);
    GN.bus.V_bus(i_reset_V_bus) = true;
end

if all(GN.bus.V_bus) && ( (isfield(GN,'comp') && any(GN.comp.gas_powered)) || (isfield(GN,'prs') && any(GN.prs.gas_powered_heater)))
    i_reset_V_bus = find(GN.bus.slack_bus, 1);
    GN.bus.V_bus(i_reset_V_bus) = false;
end

% if (~isfield(GN,'comp') || (isfield(GN,'comp') && all(~GN.comp.gas_powered))) && (~isfield(GN,'prs') || (isfield(GN,'prs') && any(GN.prs.gas_powered_heater)))
%     GN.bus.V_bus(:) = true;
% end

end

