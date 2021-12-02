function [GN] = get_my_JT(GN, PHYMOD)
%GET_MY_JT Joule-Thomson Coefficient for mixtures
%   [GN] = get_my_JT(GN, PHYMOD)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
<<<<<<< HEAD
%   Copyright (c) 2020-2022, High Voltage Equipment and Grids,
=======
%   Copyright (c) 2020-2021, High Voltage Equipment and Grids,
>>>>>>> Merge to public repo (#1)
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Update reduced quantities (p_r_i, p_r_ij, T_r_i, T_r_ij)
GN = get_reduced_quantities(GN, PHYMOD);

%% Heat Capacity
GN = get_c_p(GN,PHYMOD);

if PHYMOD.my_JT == 1
    %% Version 1 (Verwendung der Formel nach Weigand 2016 Thermodynamik kompakt fuer VDW-Gase)
    
    % Physical constants
    CONST = getConstants();
    
    % Quantities
    R_m     = CONST.R_m;
    M_avg   = GN.gasMixProp.M_avg;
    Z_i    = GN.bus.Z_i;
    p_i    = GN.bus.p_i;
    T_i    = GN.bus.T_i;
    V_m_i  = Z_i .* R_m .* T_i ./ p_i;
    c_p_i  = GN.bus.c_p_i;
    
    % Internal pressure a and covolume b
    if ~isfield(GN.gasMixProp,'a') || ~isfield(GN.gasMixProp,'b')
        GN = get_a_b_VanDerWaals(GN);
    end
    a = GN.gasMixProp.a;
    b = GN.gasMixProp.b;
    
    % my_JT_i
    numerator       = R_m * T_i .* V_m_i.^3 - 2 * a .* (V_m_i - b).^2 - T_i .* (V_m_i - b) .* R_m .* V_m_i.^2;
    denominator     = R_m * T_i .* V_m_i.^3 - 2 * a .* (V_m_i - b).^2;
    GN.bus.my_JT_i  = - V_m_i ./ c_p_i ./M_avg .* numerator./denominator;
    
else
    try
        GN = get_my_JT_addOn(GN, PHYMOD);
    catch
        error('Option not available, choose PHYMOD.my_JT = 1')
    end
end

end

