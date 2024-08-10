function [ GN ] = get_V_dot_n_i_prs(GN, NUMPARAM, PHYMOD)
%GET_V_dot_N_I_PRS Pressure regulator fuel gas demand
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if GN.isothermal || ~isfield(GN,'prs') || all(~GN.prs.gas_powered_heater)
    return
end

%% Calulate Q_dot_heater for "gas_powered_heater & T_controlled"
GN = get_Q_dot_prs(GN, NUMPARAM, PHYMOD);

%% Indices
i_from_bus  = GN.branch.i_from_bus(GN.prs.i_branch);
gas_powered = GN.prs.gas_powered_heater;

%% Initialize V_dot_n_i_prs
if ~ismember('V_dot_n_i_prs', GN.prs.Properties.VariableNames)
    GN.prs.V_dot_n_i_prs(:) = NaN;
end
GN.prs.V_dot_n_i_prs(isnan(GN.prs.V_dot_n_i_prs)) = 0;

%% Subtract previous value of V_dot_n_i_prs from V_dot_n_i value at input bus
GN.bus.V_dot_n_i(i_from_bus) = GN.bus.V_dot_n_i(i_from_bus) - GN.prs.V_dot_n_i_prs; 

%% Calculate V_dot_n_i_prs
GN.prs.V_dot_n_i_prs(gas_powered)               = GN.prs.Q_dot_heater(gas_powered) / GN.gasMixProp.H_s_n_avg(gas_powered) ./ GN.prs.eta_heater; % [W]/[Ws/m^3]=[m^3/s]
GN.prs.V_dot_n_i_prs(GN.prs.V_dot_n_i_prs<0)    = 0;

%% Add new value of V_dot_n_i_prs to V_dot_n_i value at input bus
GN.bus.V_dot_n_i(i_from_bus) = GN.bus.V_dot_n_i(i_from_bus) + GN.prs.V_dot_n_i_prs;

end

