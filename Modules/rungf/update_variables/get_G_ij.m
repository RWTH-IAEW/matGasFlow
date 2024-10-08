function [GN] = get_G_ij(GN, OPTION, NUMPARAM)
%GET_G_IJ
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Return if GN has no pipe
if ~isfield(GN, 'pipe')
    return
end

%% Set default input arguments
if nargin < 3
    NUMPARAM = getDefaultNumericalParameters;
    
    if nargin < 2
        OPTION = 1;
    end
end

%% Physical constants
if OPTION == 1
    CONST = getConstants();
    
    %% Calculate transport quantities
    % Reynolds number Re_ij(V_dot_n_ij, eta_ij)
    GN = get_Re(GN);
    
    % Pipe friction coefficient lambda(Re, k, D)
    GN = get_lambda(GN, NUMPARAM);
    
    %% Quantities
    p_n             = CONST.p_n;
    T_n             = CONST.T_n;
    rho_n_avg       = GN.gasMixProp.rho_n_avg;
    Z_n_avg         = GN.gasMixProp.Z_n_avg;
    
    T_ij            = GN.pipe.T_ij;
    Z_ij            = GN.pipe.Z_ij;
    
    D_ij            = GN.pipe.D_ij;
    L_ij            = GN.pipe.L_ij;
        
    lambda_ij       = GN.pipe.lambda_ij;
        
    %% Pipe conductivity
    % Volume flow factor  A_ij [(K*m^10)/(N^2*s^2)]
    A_ij = pi^2 * D_ij.^5 * T_n ./ (16 * rho_n_avg * p_n * L_ij);
    
    % Volume flow factor B_ij [1/K]
    B_ij = 1./(lambda_ij .* Z_ij / Z_n_avg .* T_ij);
    
    GN.pipe.G_ij = sqrt(A_ij.*B_ij);
    
    %% 
    if any(GN.pipe.G_ij == 0)
        GN_temp = get_G_ij(GN, 2);
        GN.pipe.G_ij(GN.pipe.G_ij == 0) = GN_temp.pipe.G_ij(GN.pipe.G_ij == 0);
    end
    
elseif OPTION == 2
    %% Linearized pipe conductivity
    
    %% calculate rho and transport tuantities
    % rho
    GN = get_rho(GN);

    % Reynolds number Re_ij(V_dot_n_ij, eta_ij)
    GN = get_Re(GN);
    
    % Pipe friction coefficient lambda(Re, k, D)
    GN = get_lambda(GN, NUMPARAM);
    
    %% Quantities
    D_ij            = GN.pipe.D_ij;
    L_ij            = GN.pipe.L_ij;
    rho_ij          = GN.pipe.rho_ij;
    rho_n_avg       = GN.gasMixProp.rho_n_avg;
    Re_ij           = GN.pipe.Re_ij;
    lambda_ij       = GN.pipe.lambda_ij;
    eta_ij          = GN.pipe.eta_ij;
    
    %% Linearized pipe conductivity
    GN.pipe.G_ij            = zeros(size(GN.pipe,1),1);
    GN.pipe.G_ij(Re_ij==0)  = (D_ij(Re_ij==0).^4.*pi.*rho_ij(Re_ij==0)) ./ (2.*64                                .*eta_ij(Re_ij==0).*rho_n_avg.*L_ij(Re_ij==0));
    GN.pipe.G_ij(Re_ij>0)   = (D_ij(Re_ij>0).^4 .*pi.*rho_ij(Re_ij>0))  ./ (2.*lambda_ij(Re_ij>0).*Re_ij(Re_ij>0).*eta_ij(Re_ij>0) .*rho_n_avg.*L_ij(Re_ij>0));
    
elseif OPTION == 3
    %              sqrt(p_i^2 - p_j^2)
    % V_dot_n_ij = ------------------- * sqrt(A_ij * B_ij) * (p_i - p_j)
    %                   p_i - p_j
    OPTION = 1;
    GN = get_G_ij(GN, OPTION, NUMPARAM);
    p_i = GN.bus.p_i(GN.branch.i_from_bus(GN.branch.pipe_branch));
    p_i = p_i(GN.branch.i_pipe(GN.branch.pipe_branch));
    p_j = GN.bus.p_i(GN.branch.i_to_bus(GN.branch.pipe_branch));
    p_j = p_j(GN.branch.i_pipe(GN.branch.pipe_branch));
    
    GN.pipe.G_ij = abs(sqrt(p_i.^2 - p_j.^2)./(p_i - p_j)) .* GN.pipe.G_ij;
    
elseif OPTION == 4
    %              sqrt(p_i^2 - p_j^2)
    % V_dot_n_ij = ------------------- * sqrt(A_ij * B_ij) * (p_i^2 - p_j^2)
    %                 p_i^2 - p_j^2
    OPTION = 1;
    GN = get_G_ij(GN, OPTION, NUMPARAM);
    p_i = GN.bus.p_i(GN.branch.i_from_bus(GN.branch.pipe_branch));
    p_i = p_i(GN.branch.i_pipe(GN.branch.pipe_branch));
    p_j = GN.bus.p_i(GN.branch.i_to_bus(GN.branch.pipe_branch));
    p_j = p_j(GN.branch.i_pipe(GN.branch.pipe_branch));
    
    GN.pipe.G_ij = abs(sqrt(p_i.^2 - p_j.^2)./(p_i.^2 - p_j.^2)) .* GN.pipe.G_ij;
    
else
    error('Invalid option.')
end

end

