function [GN] = get_G_ij(GN, OPTION, NUMPARAM)
%GET_G_IJ
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

%% Transport Quantities
% Reynolds number Re_ij(V_dot_n_ij, eta_ij)
GN.pipe.Re_ij = get_Re(GN);

% Pipe friction coefficient lambda(Re, k, D)
GN.pipe.lambda_ij = get_lambda(GN.pipe.Re_ij, GN.pipe.k_ij, GN.pipe.D_ij, NUMPARAM.epsilon_lambda);

%% Physical constants
if OPTION == 1
    CONST = getConstants();
    
    %% Volume flow factor  A_ij [(K*m^10)/(N^2*s^2)]
    A_ij = pi^2 * GN.pipe.D_ij.^5 * CONST.T_n ./ (16 * GN.gasMixProp.rho_n_avg * CONST.p_n * GN.pipe.L_ij);
    
    %% Volume flow factor B_ij [1/K]
    B_ij = 1./(GN.pipe.lambda_ij .* GN.pipe.Z_ij / GN.gasMixProp.Z_n_avg .* GN.pipe.T_ij);
    
    %% "Hydraulic conductance"
    GN.pipe.G_ij = sqrt(A_ij.*B_ij);
    
    %% 
    if any(GN.pipe.G_ij == 0)
        GN_temp = get_G_ij(GN, 2);
        GN.pipe.G_ij(GN.pipe.G_ij == 0) = GN_temp.pipe.G_ij(GN.pipe.G_ij == 0);
    end
    
elseif OPTION == 2
    %% rho
    GN = get_rho(GN);
    
    %% Quantities
    D_ij            = GN.pipe.D_ij;
    L_ij            = GN.pipe.L_ij;
    rho_ij          = GN.pipe.rho_ij;
    rho_n_avg       = GN.gasMixProp.rho_n_avg;
    Re_ij           = GN.pipe.Re_ij;
    lambda_ij       = GN.pipe.lambda_ij;
    eta_ij          = GN.pipe.eta_ij;
    
    %% Pneumatic conductance
    G_ij            = zeros(size(GN.pipe,1),1);
    G_ij(Re_ij==0)  = (D_ij(Re_ij==0).^4.*pi.*rho_ij(Re_ij==0)) ./ (2.*64                                .*eta_ij(Re_ij==0).*rho_n_avg.*L_ij(Re_ij==0));
    G_ij(Re_ij>0)   = (D_ij(Re_ij>0).^4 .*pi.*rho_ij(Re_ij>0))  ./ (2.*lambda_ij(Re_ij>0).*Re_ij(Re_ij>0).*eta_ij(Re_ij>0) .*rho_n_avg.*L_ij(Re_ij>0));
    GN.pipe.G_ij = G_ij;
    
else
    error('Invalid option.')
end

end

