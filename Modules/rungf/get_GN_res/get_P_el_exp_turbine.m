function [GN] = get_P_el_exp_turbine(GN, PHYMOD)
%GETV_P_EL_EXP_TURBINE Electrical power output of expansion turbines
%   GN = get_P_el_exp_turbine(GN, PHYMOD)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2022, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if all(~GN.prs.exp_turbine)
    return
end

%% Physical constants
CONST = getConstants();

%% Isentropic exponent f(c_p_i)
GN = get_kappa(GN, PHYMOD);
kappa_prs = GN.bus.kappa_i(GN.bus.prs_out_bus); % UNDER COINSTRCUTION

%% Indices
i_from_bus      = GN.branch.i_from_bus(GN.branch.prs_branch);
i_to_bus        = GN.branch.i_to_bus(GN.branch.prs_branch);

%% Expansionsturbine power [W]
P_el_exp_turbine = ...
    GN.branch.V_dot_n_ij(GN.branch.prs_branch) .* GN.gasMixProp.rho_n_avg ./ GN.prs.eta_s(GN.prs.exp_turbine)./ GN.prs.eta_drive(GN.prs.exp_turbine) .* (kappa_prs./(kappa_prs-1)) ...
    .* GN.bus.Z_i(i_from_bus) .* CONST.R_m .* GN.bus.T_i(i_from_bus) ...
    .* ( (GN.bus.p_i(i_to_bus)./GN.bus.p_i(i_from_bus)).^((kappa_prs-1)./kappa_prs) - 1);

GN.prs.P_el_exp_turbine(GN.prs.exp_turbine) = -P_el_exp_turbine(GN.prs.exp_turbine);

GN.prs.P_el_exp_turbine_isentrop(GN.prs.exp_turbine)= -P_el_exp_turbine(GN.prs.exp_turbine).*GN.prs.eta_s(GN.prs.exp_turbine).*GN.prs.eta_drive(GN.prs.exp_turbine);

end