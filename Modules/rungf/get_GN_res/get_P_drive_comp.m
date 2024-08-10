function [GN] = get_P_drive_comp(GN, PHYMOD)
%GET_P_DRIVE_COMP
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

%% Physical constants
CONST = getConstants();

%% Indices
iF  = GN.branch.i_from_bus(GN.comp.i_branch);
iT  = GN.branch.i_to_bus(GN.comp.i_branch);

%% Option 1: Isentroper Vergleichsprozess
% Isentrope Vergleichsprozesse werden fuer ungeuehlte ein- und mehrstufige Turbo Verdichter,
% insbesondere mit maessigem Druckverhaeltnis, und ungekuehlte wie auch einstufige
% Verdraengungs Verdichter mit Mantelkuehlung

if PHYMOD.comp == 1
    %% Isentropic compression
    % Suitable for uncooled single- and multistage turbo compressors,
    % especially with moderate pressure ratio, and uncooled as well as
    % single-stage compressors with shell cooling.
    
    if ~ismember('kappa_i',GN.bus.Properties.VariableNames)
        GN = get_kappa(GN, PHYMOD);
    end
    kappa_i = GN.bus.kappa_i(iF);
    
    %% Mechanical power on the compressor's shaft [W]
    GN.comp.P_mech = ...
        GN.branch.V_dot_n_ij(GN.branch.comp_branch) .* GN.gasMixProp.rho_n_avg ./ GN.comp.eta_s .* (kappa_i./(kappa_i-1)) ...
        .* GN.bus.Z_i(iF) .* CONST.R_m .* GN.bus.T_i(iF) ...
        .* ( (GN.bus.p_i(iT)./GN.bus.p_i(iF)).^((kappa_i-1)./kappa_i) - 1);
    
    %% Power of compressor drive [W]
    %   If the compressor is gas-powered, P_drive is the thermal power of
    %       the fuel gas.
    %   If the compressor has an electric drive (gas_powered = false),
    %       P_drive is the electric power of the eletric drive.
    GN.comp.P_drive = GN.comp.P_mech ./ GN.comp.eta_drive;
    
elseif PHYMOD.comp == 2
    %% Isothermal compression
    path = which('get_P_drive_comp_isothermal.m');
    if isempty(path)
        error('Option not available, choose PHYMOD.comp = 1')
    end
    GN = get_P_drive_comp_isothermal(GN);
    
elseif OPTION == 3
    %% Polytropic compression
    path = which('get_P_drive_comp_polytropic.m');
    if isempty(path)
        error('Option not available, choose PHYMOD.comp = 1')
    end
    GN = get_P_drive_comp_polytropic(GN);
    
end

end

