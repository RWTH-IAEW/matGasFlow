function [GN] = get_eta_HerningZipperer(GN, PHYMOD)
%GET_ETA_HERNINGZIPPERER
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if PHYMOD.eta == 1
    % [Herning, Zipperer 1936], [Hering 1966], [Sutherland 1893], [van der Grinten 2020]
    
    % Physical constants
    CONST = getConstants();
    
    % Quantities
    T_ij        = GN.pipe.T_ij;
    T_n         = CONST.T_n;
    p_ij__bar   = GN.pipe.p_ij*1e-5; % [bar]
    x_mol       = GN.gasMixAndCompoProp.x_mol;
    eta_n       = GN.gasMixAndCompoProp.eta_n;
    T_c         = GN.gasMixAndCompoProp.T_c;
    M           = GN.gasMixAndCompoProp.M;
    
    % eta_mix at standard conditions in Pa*s [Herning, Zipperer 1936]
    eta_mix_n = sum( x_mol .* eta_n .* sqrt(T_c.*M) ) ./ sum( x_mol .* sqrt(T_c.*M) );
    
    % Temperature dependency (Sutherland Constants [Sutherland 1893])
    C_S_mix     = sum( x_mol .* GN.gasMixAndCompoProp.C_s);
    K_T         = (T_ij/T_n).^(3/2) .* (T_n+C_S_mix)./(T_ij+C_S_mix);
    
    % Pressure dependency [van der Grinten 2020]
    K_p = 0.91690348 ...
        + 0.00042070 .* (T_ij-T_n) ...
        - 0.00002207 .* (T_ij-T_n) .* p_ij__bar...
        + 0.00434531 .* p_ij__bar;
    
    % Dynamic viscosity
    GN.pipe.eta_ij = eta_mix_n .* K_T .* max(1,K_p);
    
elseif PHYMOD.eta == 1.5
    %% Herning-Zipperer
    % [Herning, Zipperer 1936]
    % [Hering 1966]
    
    % Physical constants
    CONST = getConstants();
    
    % Quantities
    T_ij        = GN.pipe.T_ij;
    T_n         = CONST.T_n;
    p_ij__bar   = GN.pipe.p_ij*1e-5; % [bar]
    
    % Pressure dependency
    K_p = 0.91690348 ...
        + 0.00042070 .* (T_ij-T_n) ...
        - 0.00002207 .* (T_ij-T_n) .* p_ij__bar...
        + 0.00434531 .* p_ij__bar;
    
    % Temperature dependency
    C_S_i   = GN.gasMixAndCompoProp.C_s;
    K_T     = (T_ij'/T_n).^(3/2) .* ((T_n+C_S_i)*1./(T_ij'+C_S_i));
    
    % eta_i
    eta_n_i = GN.gasMixAndCompoProp.eta_n;
    eta_i   = eta_n_i .* K_T .* max(1,K_p)';
    
    % eta_mix at standard conditions in Pa*s [Herning, Zipperer 1936]
    GN.pipe.eta_ij = ...
        (sum( GN.gasMixAndCompoProp.x_mol .* sqrt(GN.gasMixAndCompoProp.T_c.*GN.gasMixAndCompoProp.M) .* eta_i) / ...
        sum( GN.gasMixAndCompoProp.x_mol .* sqrt(GN.gasMixAndCompoProp.T_c.*GN.gasMixAndCompoProp.M) ))';
    
end

end

