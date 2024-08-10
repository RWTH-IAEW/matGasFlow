function [GN] = get_P_el_exp_turbine(GN, PHYMOD)
%GETV_P_EL_EXP_TURBINE Electrical power output of expansion turbines
%   GN = get_P_el_exp_turbine(GN, PHYMOD)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if all(~GN.prs.exp_turbine)
    return
end

%% Physical constants
CONST = getConstants();

%% Indices
i_branch    = GN.prs.i_branch(GN.prs.exp_turbine);
i_to_bus    = GN.branch.i_to_bus(i_branch);
exp_turbine = GN.prs.exp_turbine;

%% Quantities
R_m         = CONST.R_m;
M_avg       = GN.gasMixProp.M_avg;
V_dot_n_ij  = GN.branch.V_dot_n_ij(i_branch);
rho_n_avg   = GN.gasMixProp.rho_n_avg;
eta_S       = GN.prs.eta_S(exp_turbine);
eta_mech    = GN.prs.eta_mech(exp_turbine);
eta_gen     = GN.prs.eta_gen(exp_turbine);
p_mid       = GN.prs.p_ij_mid(exp_turbine);
p_out       = GN.bus.p_i(i_to_bus);
T_mid       = GN.prs.T_ij_mid(exp_turbine);
Z_mid       = GN.prs.Z_ij_mid(exp_turbine);

%% Isentropic exponent f(c_p_i)
GN          = get_kappa(GN, PHYMOD);
kappa_mid   = GN.prs.kappa_ij_mid(GN.prs.exp_turbine);

%% Expansionsturbine power [W]
GN.prs.Delta_h_S(:)                     = NaN;
GN.prs.Delta_h(:)                       = NaN;
GN.prs.P_mech_exp_turbine(:)        	= NaN;
GN.prs.P_el_exp_turbine(:)              = NaN;
GN.prs.Delta_h_S(exp_turbine)           = kappa_mid./(kappa_mid-1) .* Z_mid .* T_mid * R_m/M_avg .* (1-(p_out./p_mid).^((kappa_mid-1)./kappa_mid));
GN.prs.Delta_h(exp_turbine)             = eta_S .* GN.prs.Delta_h_S;
GN.prs.P_mech_exp_turbine(exp_turbine)  = eta_mech .* GN.prs.Delta_h .* V_dot_n_ij * rho_n_avg;
GN.prs.P_el_exp_turbine(exp_turbine)    = eta_gen .* GN.prs.P_mech_exp_turbine;

%% alpha_exp
P_th = convert_gas_flow_quantity(V_dot_n_ij,'m3_per_s','W',GN.gasMixProp);
GN.prs.alpha_exp(:)                     = GN.prs.P_el_exp_turbine./P_th;

%% eta_tot
GN.prs.eta_tot(:)                           = NaN;
if any(GN.prs.gas_powered_heater)
    GN.prs.eta_tot(GN.prs.gas_powered_heater)   = GN.prs.P_el_exp_turbine./GN.prs.Q_dot_heater;
end
if any(~GN.prs.gas_powered_heater)
    GN.prs.eta_tot(~GN.prs.gas_powered_heater)  = GN.prs.P_el_exp_turbine./GN.prs.P_el_heater;
end

end

