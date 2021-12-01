function [ GN ] = get_V_dot_n_i_comp(GN, PHYMOD)
%GET_V_dot_N_I_COMP Summary of this function goes here
%   Detailed explanation goes here
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2021, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~any(strcmp('comp_branch',GN.branch.Properties.VariableNames))
    return
end

%% Physical constants
CONST = getConstants();

%% Indices
i_comp = GN.branch.i_comp(GN.branch.comp_branch);
i_from_bus = GN.branch.i_from_bus(GN.branch.comp_branch);
i_from_bus = i_from_bus(i_comp);
i_to_bus = GN.branch.i_to_bus(GN.branch.comp_branch);
i_to_bus = i_to_bus(i_comp);

%% Option 1: Isentroper Vergleichsprozess
% Isentrope Vergleichsprozesse werden fuer ungeuehlte ein- und mehrstufige Turbo Verdichter,
% insbesondere mit maessigem Druckverhaeltnis, und ungekuehlte wie auch einstufige
% Verdraengungs Verdichter mit Mantelkuehlung

if PHYMOD.comp == 1
    %% Isentropic compression
    % Suitable for uncooled single- and multistage turbo compressors,
    % especially with moderate pressure ratio, and uncooled as well as
    % single-stage compressors with shell cooling.
    
    if ~any(strcmp('kappa_i',GN.bus.Properties.VariableNames))
        GN = get_kappa(GN, PHYMOD);
    end
    kappa_i = GN.bus.kappa_i(i_from_bus);
    kappa_j = GN.bus.kappa_i(i_to_bus);
    kappa_ij = (kappa_i + kappa_j)/2; % UNDER CONSTRUCTION
    
    GN.comp.P_mech = ...
        GN.branch.V_dot_n_ij(GN.branch.comp_branch) .* GN.gasMixProp.rho_n_avg ./ GN.comp.eta_s .* (kappa_ij./(kappa_ij-1)) ...
        .* GN.bus.Z_i(i_from_bus) .* CONST.R_m .* GN.bus.T_i(i_from_bus) ...
        .* ( (GN.bus.p_i(i_to_bus)./GN.bus.p_i(i_from_bus)).^((kappa_ij-1)./kappa_ij) - 1);
    
elseif PHYMOD.comp == 2
    %% Isothermal compression
    try
        GN = get_V_dot_n_i_comp_isothermal(GN);
    catch
        error('Option not available, choose PHYMOD.comp = 1')
    end
    
    
elseif OPTION == 3
    %% Polytropic compression
    try
        GN = get_V_dot_n_i_comp_polytropic(GN);
    catch
        error('Option not available, choose PHYMOD.comp = 1')
    end
    
end

%% Power of compressor drive [m^3/s]
%   If the compressor is gas-powered, P_drive is the thermal power of the
%   fuel gas.
%   If the compressor has an electrical drive (gas_powered = false),
%   P_drive is the electric power of the eletric drive.
GN.comp_P_drive = GN.comp.P_mech ./ GN.comp.eta_drive;

%% V_dot_n_i_comp for gas-powered compressors [m^3/s]
GN.comp.V_dot_n_i_comp(GN.comp.gas_powered) = GN.comp.P_mech(GN.comp.gas_powered) / GN.gasMixProp.H_s_n_avg; % [W]/[Ws/m^3]=[m^3/s]
GN.comp.V_dot_n_i_comp(isnan(GN.comp.V_dot_n_i_comp)) = 0;
GN.bus.V_dot_n_i(i_from_bus) = GN.comp.V_dot_n_i_comp;

end