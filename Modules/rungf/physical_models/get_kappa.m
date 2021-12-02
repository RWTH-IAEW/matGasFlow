function [GN] = get_kappa(GN, PHYMOD)
%GET_KAPPA Calculation of heat capacity ratio
%   [GN] = GET_KAPPA(GN, PHYMOD.kappa)
%       kappa = c_p/c_v
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2021, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Physical constants
CONST = getConstants();

%% Quantities
R_m     = CONST.R_m;
M_avg   = GN.gasMixProp.M_avg;
p_i     = GN.bus.p_i;
T_i     = GN.bus.T_i;
V_m_i   = GN.bus.Z_i .* R_m .* T_i ./ p_i;

%% UNDER CONSTRUCTION
if PHYMOD.c_p == 11
    PHYMOD.kappa = 10;
end

%% Isentropic exponent kappa_i - Physical Models
if PHYMOD.kappa == 1 || PHYMOD.kappa == 2
    %% Heat capacity
    GN = get_c_p(GN, PHYMOD);
    
    %% Van der Waals
    % Internal pressure a and covolume b
    if ~isfield(GN.gasMixProp,'a') || ~isfield(GN.gasMixProp,'b')
        GN = get_a_b_VanDerWaals(GN);
    end
    a = GN.gasMixProp.a;
    b = GN.gasMixProp.b;
    
    % Specific isochoric heat capacity
    try
        c_v_i = GN.bus.c_p_0_i - R_m/M_avg; % [J/(kg*mol)]
    catch
        GN_temp = GN;
        PHYMOD_temp = PHYMOD;
        PHYMOD_temp.c_p = 1;
        GN_temp = get_c_p(GN_temp, PHYMOD_temp);
        GN.bus.c_p_0_i = GN_temp.bus.c_p_0_i;
        c_v_i = GN.bus.c_p_0_i - R_m/M_avg; % [J/(kg*mol)]
    end
    
    if PHYMOD.kappa == 1
        % Isentropic exponent
        GN.bus.kappa_i          = GN.bus.c_p_i./c_v_i;
    else
        % UNDER CONSTRUCTION Größenordnung passt nicht!
        % Isothermal exponent
        isothermalExponent_i    = -V_m_i ./ p_i .* (-R_m.*T_i./(V_m_i-b).^2 + 2.*a./V_m_i.^3);
        
        % Isentropic exponent
        GN.bus.kappa_i          = GN.bus.c_p_i./c_v_i .* isothermalExponent_i;
    end
    
else
    try
        GN = get_kappa_addOn(GN, PHYMOD);
    catch
        error('Option not available, choose PHYMOD.kappa = 1 OR PHYMOD.kappa = 2')
    end
end
end