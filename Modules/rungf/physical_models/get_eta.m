function [GN] = get_eta(GN, PHYMOD)
% GET_ETA Dynamic viscosity eta [Pa*s]
%   [GN] = GET_ETA(GN, PHYMOD)
%   Dynamic viscosity eta_ij(T,rho)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2021, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~isfield(GN, 'pipe')
    return
end

if PHYMOD.eta == 1
    %% Herning-Zipperer
    
    % Physical constants
    CONST = getConstants();
    
    % Quantities
    T_ij        = GN.pipe.T_ij;
    T_n         = CONST.T_n;
    p_ij__bar   = GN.pipe.p_ij*1e-5; % [bar]
    
    % eta_mix at standard conditions
    eta_mix = ...
        sum( GN.gasMixAndCompoProp.x_mol .* GN.gasMixAndCompoProp.eta_0 .* sqrt(GN.gasMixAndCompoProp.T_c.*GN.gasMixAndCompoProp.M) ) ./ ...
        sum( GN.gasMixAndCompoProp.x_mol .* sqrt(GN.gasMixAndCompoProp.T_c.*GN.gasMixAndCompoProp.M) );
    
    % Temperature dependency
    C_s = sum( GN.gasMixAndCompoProp.x_mol .* GN.gasMixAndCompoProp.C_s );
    eta_temp = eta_mix .* ((T_ij-T_n)./ T_n + 1).^(3/2) .* (T_n+C_s) ./ (C_s+T_ij);
    
    % Pressure dependency
    z_a = 0.91690348 ...
        + 0.0004207 .* (T_ij-T_n) ...
        - 0.00002207 .* (T_ij-T_n) .* p_ij__bar...
        + 0.00434531 .* p_ij__bar;
    z_a_max = max(1,z_a);
    
    % Dynamic viscosity
    GN.pipe.eta_ij = eta_temp .* z_a_max;
    
else
    try
        GN = get_eta_addOn(GN, PHYMOD);
    catch
        error('Option not available, choose PHYMOD.eta = 1')
    end
end
end

