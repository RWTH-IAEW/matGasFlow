function [GN] = get_P_drive_comp(GN, PHYMOD)
%GET_P_DRIVE_COMP
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~ismember('comp_branch',GN.branch.Properties.VariableNames)
    return
end

%% Physical constants
CONST = getConstants();

%% Indices
iF  = GN.branch.i_from_bus(GN.comp.i_branch);
iT  = GN.branch.i_to_bus(GN.comp.i_branch);

%% Option 1: Isentroper Vergleichsprozess
% Isentrope Vergleichsprozesse werden fuer ungeuehlte ein- und mehrstufige Turbo Verdichter,
% insbesondere mit maessigem Druckverhaeltnis, und ungekuehlte wie auch einstufige
% Verdraengungs Verdichter mit Mantelkuehlung

%% kappa - isentropic exponent:
if ~ismember('kappa_i',GN.bus.Properties.VariableNames)
    GN = get_Z(GN, PHYMOD, {'branch','comp','prs'});
    GN = get_c_p(GN, PHYMOD);
    GN = get_kappa(GN, PHYMOD);
end
kappa_i = GN.bus.kappa_i(iF);

%%
if PHYMOD.comp == 1
    %% Isentropic compression
    % Suitable for uncooled single- and multistage turbo compressors,
    % especially with moderate pressure ratio, and uncooled as well as
    % single-stage compressors with shell cooling.
    
    % specific isenthalpic (adiabatic) enthalpy Delta_h_S [J/kg]=[Ws/kg]
    GN.comp.Delta_h_S = ...
        GN.bus.Z_i(iF) .* GN.bus.T_i(iF) * CONST.R_m/GN.gasMixProp.M_avg ...
        .* (kappa_i./(kappa_i-1)) ...
        .* ( (GN.bus.p_i(iT)./GN.bus.p_i(iF)).^((kappa_i-1)./kappa_i) - 1);
    
    % GN = get_eta_S_turbo_comp(GN); % TODO

    % Compression power delivered to the gas [W]
    GN.comp.P_comp = ...
        GN.comp.Delta_h_S ...
        .* GN.branch.V_dot_n_ij(GN.comp.i_branch) .* GN.gasMixProp.rho_n_avg ./ GN.comp.eta_S;
    
elseif PHYMOD.comp == 2
    %% Isothermal compression - TODO - for ideal gases: p_1/p_2 = V_2/V_1, W = -int_{V_1}^{V_2} p dV, p = R_m*T/V_m, W = R_m T 
    GN.comp.P_drive_comp = ...
        GN.branch.V_dot_n_ij(GN.comp.i_branch) .* GN.gasMixProp.rho_n_avg ./ GN.comp.eta_S ...
        .* GN.bus.Z_i(iF) .* GN.bus.T_i(iF) * CONST.R_m / GN.gasMixProp.M_avg ...
        .* log(GN.bus.p_i(iT)./GN.bus.p_i(iF));
    
elseif PHYMOD.comp == 3
    %% Polytropic compression - TODO
    error('get_P_drive_comp. Polytropic compression (PHYMOD.comp = 3) is not availabel.')
    
    % polytropic exponent ...
    %     eta_polytrop        = ...
    %     quotient            = ((kappa_i -1)./kappa_i)./eta_polytrop;
    %     kappa_polytrop_ij   = (1-quotient).^(-1);
    
    % Get compressor power needs
    %     GN.comp.P_drive_comp = ...
    %         GN.branch.V_dot_n_ij(GN.comp.i_branch) .* GN.gasMixProp.rho_n_avg ./ GN.comp.eta_S .* (kappa_polytrop_ij./(kappa_polytrop_ij-1)) ...
    %         .* GN.bus.Z_i(iF) .* GN.bus.T_i(iF) * CONST.R_m/GN.gasMixProp.M_avg ...
    %         .* ( (GN.bus.p_i(iT)./GN.bus.p_i(iF)).^((kappa_polytrop_ij-1)./kappa_polytrop_ij) - 1);

else
    error(['get_T_ij_mid_comp: PHYMOD.comp = ',num2str(PHYMOD.comp),' is not availabel.'])

end

%% Mechanical Power at the compressor shaft
GN.comp.P_mech  = GN.comp.P_comp ./ GN.comp.eta_m;

%% Power of compressor drive [W]
%   If the compressor is gas-powered, P_drive is the thermal power of the fuel gas.
%   If the compressor has an electric drive (gas_powered = false), P_drive is the electric power of the eletric drive.
GN.comp.P_drive = GN.comp.P_mech ./ GN.comp.eta_drive;

end

