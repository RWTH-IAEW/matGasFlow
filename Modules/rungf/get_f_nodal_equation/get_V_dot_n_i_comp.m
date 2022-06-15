function [ GN ] = get_V_dot_n_i_comp(GN, PHYMOD)
%GET_V_dot_N_I_COMP Compressor fuel gas demand
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2022, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~ismember('comp_branch',GN.branch.Properties.VariableNames)
    return
end
if ~any(GN.comp.gas_powered)
    return
end

%% Indices
i_comp = GN.branch.i_comp(GN.branch.comp_branch);
i_from_bus = GN.branch.i_from_bus(GN.branch.comp_branch);
i_from_bus = i_from_bus(i_comp);

%% Power of compressor drive [W]
GN = get_P_drive_comp(GN, PHYMOD);

%% V_dot_n_i_comp for gas-powered compressors [m^3/s] - UNDER CONSTRUCTION
if ~ismember('V_dot_n_i_comp', GN.comp.Properties.VariableNames)
    GN.comp.V_dot_n_i_comp(:) = NaN;
end
GN.comp.V_dot_n_i_comp(isnan(GN.comp.V_dot_n_i_comp)) = 0;

GN.bus.V_dot_n_i(i_from_bus) = GN.bus.V_dot_n_i(i_from_bus) - GN.comp.V_dot_n_i_comp;

GN.comp.V_dot_n_i_comp(GN.comp.gas_powered) = GN.comp.P_drive(GN.comp.gas_powered) / GN.gasMixProp.H_s_n_avg; % [W]/[Ws/m^3]=[m^3/s]

GN.bus.V_dot_n_i(i_from_bus) = GN.bus.V_dot_n_i(i_from_bus) + GN.comp.V_dot_n_i_comp;

%% Update of the slack bus: flow rate balance to(+)/from(-) the slack node
% GN = get_V_dot_n_i_slack_bus(GN);

end