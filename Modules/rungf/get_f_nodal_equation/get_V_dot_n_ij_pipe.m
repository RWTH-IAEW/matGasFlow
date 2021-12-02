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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2021, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
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
    %% V_dot_n_ij = A_ij * sqrt(p_i^2 - p_j^2) * log10(B_ij/sqrt(p_i^2 - p_i^2) + C_ij)
    
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
    
    [A_ij, B_ij, C_ij] = get_ABC_ij(GN);
    
    % Indices
    idx         = p_i(iF) < p_i(iT);
    sign_pipe   = ones(size(GN.pipe,1),1);
    sign_pipe(idx) = -1;
    iIn         = iF;
    iIn(idx)    = iT(idx);
    iOut        = iT;
    iOut(idx)   = iF(idx);
    
    % Reynolds number Re_ij(V_dot_n_ij, eta_ij)
    GN.pipe.Re_ij = get_Re(GN);
    laminar     = GN.pipe.Re_ij <= 2320;
    turbolent   = GN.pipe.Re_ij > 2320;
    
    V_dot_n_ij = NaN(size(GN.pipe,1),1);
    if any(laminar)
        V_dot_n_ij_laminar = ...
            sign_pipe .* pi .* D_ij.^4 * T_n ./ (256 * p_n * L_ij .* eta_ij .* K_ij .* T_ij) .* (p_i(iIn).^2 - p_i(iOut).^2);
        V_dot_n_ij(laminar) = V_dot_n_ij_laminar(laminar);
    end
    
    if any(turbolent)
        V_dot_n_ij_turbolent = ...
            sign_pipe .* A_ij .* sqrt(p_i(iIn).^2 - p_i(iOut).^2) .* log10(B_ij ./ sqrt(p_i(iIn).^2 - p_i(iOut).^2) + C_ij);
        V_dot_n_ij(turbolent)  = V_dot_n_ij_turbolent(turbolent);
    end
    
elseif NUMPARAM.OPTION_get_V_dot_n_ij_pipe == 2
    %% V_dot_n_ij = G_ij * sqrt(p_i^2 - p_j^2)
    
    CONST = getConstants();
    
    %% Volume flow factor  A_ij [(K*m^10)/(N^2*s^2)]
    A_ij = pi^2 * GN.pipe.D_ij.^5 * CONST.T_n ./ (16 * GN.gasMixProp.rho_n_avg * CONST.p_n * GN.pipe.L_ij);
    
    %% Volume flow factor B_ij [1/K]
    B_ij = 1./(GN.pipe.lambda_ij .* GN.pipe.Z_ij / GN.gasMixProp.Z_n_avg .* GN.pipe.T_ij);
    
    %% Pneumatic conductance
    GN.pipe.G_ij = sqrt(A_ij.*B_ij);
    
    %% 
    if any(GN.pipe.G_ij == 0)
        GN_temp = get_G_ij(GN, 2);
        GN.pipe.G_ij(GN.pipe.G_ij == 0) = GN_temp.pipe.G_ij(GN.pipe.G_ij == 0);
    end
    
    V_dot_n_ij = GN.pipe.G_ij .* sqrt(GN.bus.p_i(iF).^2 - GN.bus.p_i(iT).^2);
    V_dot_n_ij = real(V_dot_n_ij .* exp(1i.*angle(V_dot_n_ij)));
    
end
pipe_branch = GN.branch.pipe_branch;
i_pipe      = GN.branch.i_pipe(pipe_branch);
GN.branch.V_dot_n_ij(pipe_branch) = V_dot_n_ij(i_pipe);

end

