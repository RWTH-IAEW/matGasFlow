function [ GN ] = get_Z(GN, PHYMOD)
%GET_Z Compressibility factor
%   [ GN ] = GET_Z(GN, PHYMOD)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2021, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Compressibility K_i and Compressibility Factor Z_i
if PHYMOD.Z == 1
    %% Van-der-Waals Equation
    
    % Physical constants
    CONST = getConstants();
    
    % Internal pressure a and covolume b
    if ~isfield(GN.gasMixProp,'a') || ~isfield(GN.gasMixProp,'b')
        GN = get_a_b_VanDerWaals(GN);
    end
    a = GN.gasMixProp.a;
    b = GN.gasMixProp.b;
    
    % Update gas mixtures properties: Z_n_avg, rho_n_avg
    if ~isfield(GN.gasMixProp, 'PHYMOD')
        [GN.gasMixProp.Z_n_avg, V_m_n] = get_Z_VanDerWaals(CONST.p_n, CONST.T_n, a, b);
        GN.gasMixProp.rho_n_avg = GN.gasMixProp.M_avg / V_m_n;
        GN.gasMixProp.PHYMOD = 'VanDerWaals';
    end
    
    % bus
    GN.bus.Z_i = get_Z_VanDerWaals(GN.bus.p_i, GN.bus.T_i, a, b);
    
    % pipe
    if isfield(GN, 'pipe')
        GN.pipe.Z_ij = get_Z_VanDerWaals(GN.pipe.p_ij, GN.pipe.T_ij, a, b);
    end
    
    % non-isothermal
    if GN.isothermal == 0
        % source bus
        GN.bus.Z_i_source(GN.bus.source_bus) = ...
            get_Z_VanDerWaals( GN.bus.p_i(GN.bus.source_bus), GN.bus.T_i_source(GN.bus.source_bus), a, b);
        
        % branch out
        iF = GN.branch.i_from_bus;
        iT = GN.branch.i_to_bus;
        i_bus_out = iT;
        i_bus_out(GN.bus.p_i(iF) < GN.bus.p_i(iT)) = iF(GN.bus.p_i(iF) < GN.bus.p_i(iT));
        p_ij_out = GN.bus.p_i(i_bus_out);
        try
            T_ij_out = GN.branch.T_ij_out;
        catch
            T_ij_out = GN.bus.T_i(i_bus_out);
        end
        GN.branch.Z_ij_out = get_Z_VanDerWaals(p_ij_out, T_ij_out, a, b);
    end
else
    try
        GN = get_Z_addOn(GN, PHYMOD);
    catch
        error('Option not available, choose PHYMOD.Z = 1')
    end
end
end

