function [GN] = get_V_dot_n_ij_pipe(GN, NUMPARAM)
%GET_V_DOT_N_IJ_PIPE Standard volume flow rate V_dot_n_ij in pipes [m^3/s]
%
%   [GN] = get_V_dot_n_ij_pipe(GN, NUMPARAM)
%
%   NUMPARAM.OPTION_get_V_dot_n_ij_pipe = 1
%       V_dot_n_ij = A_ij * sqrt(p_i^2 - p_j^2) * log10(B_ij/sqrt(p_i^2 - p_i^2) + C_ij)
%
%   NUMPARAM.OPTION_get_V_dot_n_ij_pipe = 2
%       V_dot_n_ij = G_ij * sqrt(p_i^2 - p_j^2)
%
%   Note: Both methods are mathematically equivalent. They may differ for numerical reasons.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Set default input arguments
if nargin < 2
    NUMPARAM = getDefaultNumericalParameters();
end

%% Check for pipes
if ~isfield(GN, 'pipe')
    return
end

%% Indices
iF = GN.branch.i_from_bus(GN.branch.pipe_branch);
iT = GN.branch.i_to_bus(GN.branch.pipe_branch);

if NUMPARAM.OPTION_get_V_dot_n_ij_pipe == 1
    %% V_dot_n_ij
    %   turbulent:  V_dot_n_ij = sign_pipe * A_ij * sqrt(p_i^2 - p_j^2) * log10(B_ij/sqrt(p_i^2 - p_i^2) + C_ij)
    %   laminar:    V_dot_n_ij = sign_pipe * pi * D_ij^4 * T_n / (256 * p_n * L_ij * eta_ij * K_ij * T_ij) * (p_in^2 - p_out^2)
    
    % Quantities
    CONST   = getConstants();
    p_n     = CONST.p_n;
    T_n     = CONST.T_n;
    D_ij    = GN.pipe.D_ij;
    L_ij    = GN.pipe.L_ij;
    eta_ij  = GN.pipe.eta_ij;
    K_ij    = GN.pipe.Z_ij / GN.gasMixProp.Z_n_avg;
    T_ij    = GN.pipe.T_ij;
    p_i     = GN.bus.p_i;
    
    % Indices
    idx         = p_i(iF) < p_i(iT);
    sign_pipe   = ones(size(GN.pipe,1),1);
    sign_pipe(idx) = -1;
    iIn         = iF;
    iIn(idx)    = iT(idx);
    iOut        = iT;
    iOut(idx)   = iF(idx);
    
    V_dot_n_ij_laminar      = sign_pipe .* pi .* D_ij.^4 * T_n ./ (256 * p_n * L_ij .* eta_ij .* K_ij .* T_ij) .* (p_i(iIn).^2 - p_i(iOut).^2);
    Re_ij_laminar           = 4*abs(V_dot_n_ij_laminar) .* GN.gasMixProp.rho_n_avg ./(pi * D_ij .* eta_ij);
    laminar_is_laminar      = Re_ij_laminar <= CONST.Re_crit;
    
    [A_ij, B_ij, C_ij]      = get_ABC_ij(GN);
    V_dot_n_ij_turbulent    = sign_pipe .* A_ij .* sqrt(p_i(iIn).^2 - p_i(iOut).^2) .* log10(B_ij ./ sqrt(p_i(iIn).^2 - p_i(iOut).^2) + C_ij);
    Re_ij_turbulent         = 4*abs(V_dot_n_ij_turbulent) .* GN.gasMixProp.rho_n_avg ./(pi * D_ij .* eta_ij);
    turbulent_is_turbulent  = Re_ij_turbulent > CONST.Re_crit;
    
    V_dot_n_ij                          = NaN(size(GN.pipe,1),1);
    V_dot_n_ij(laminar_is_laminar)      = V_dot_n_ij_laminar(laminar_is_laminar);
    V_dot_n_ij(turbulent_is_turbulent)  = V_dot_n_ij_turbulent(turbulent_is_turbulent);
    laminar_or_laminar                  = ~laminar_is_laminar & ~turbulent_is_turbulent;
    if any(laminar_or_laminar)
        V_dot_n_ij_crit                 = CONST.Re_crit / 4 / GN.gasMixProp.rho_n_avg * pi .* D_ij .* eta_ij;
        V_dot_n_ij(isnan(V_dot_n_ij))   = V_dot_n_ij_crit(isnan(V_dot_n_ij));
    end
    
    if any(isnan(V_dot_n_ij))
        NUMPARAM.OPTION_get_V_dot_n_ij_pipe = 2;
        GN_temp                         = get_V_dot_n_ij_pipe(GN, NUMPARAM);
        V_dot_n_ij_temp                 = GN_temp.branch.V_dot_n_ij(GN_temp.pipe.i_branch);
        V_dot_n_ij(isnan(V_dot_n_ij))   = V_dot_n_ij_temp(isnan(V_dot_n_ij));
    end
elseif NUMPARAM.OPTION_get_V_dot_n_ij_pipe == 2
    %% V_dot_n_ij = G_ij * sqrt(p_i^2 - p_j^2)
    GN = get_G_ij(GN,1);
    V_dot_n_ij = GN.pipe.G_ij .* sqrt(GN.bus.p_i(iF).^2 - GN.bus.p_i(iT).^2);
    V_dot_n_ij = real(V_dot_n_ij .* exp(1i.*angle(V_dot_n_ij)));
    
end
GN.branch.V_dot_n_ij(GN.pipe.i_branch) = V_dot_n_ij;

% GN = get_Re(GN); 

end

