function [A_ij, B_ij, C_ij] = get_ABC_ij(GN)
%GET_ABC_IJ
%
%   Parameters A_ij, B_ij and B_ij to calculate V_dot_n_ij_pipe and
%   Jacobian Matrix
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Quantities
CONST = getConstants();
p_n = CONST.p_n;
T_n = CONST.T_n;
rho_n_avg = GN.gasMixProp.rho_n_avg;
D_ij = GN.pipe.D_ij;
L_ij = GN.pipe.L_ij;
k_ij = GN.pipe.k_ij;
eta_ij = GN.pipe.eta_ij;
K_ij = GN.pipe.Z_ij / GN.gasMixProp.Z_n_avg;
T_ij = GN.pipe.T_ij;

%% A, B, C
A_ij = -1/2 * sqrt((pi^2 * D_ij.^5 * T_n) ./ (p_n * rho_n_avg * K_ij .* T_ij .* L_ij));
B_ij = 2.51 * pi * D_ij .* eta_ij ./ (4 * rho_n_avg) ...
    .* sqrt((16 * p_n * rho_n_avg * K_ij .* T_ij .* L_ij) ./ (pi^2 * D_ij.^5 * T_n));
C_ij = k_ij ./ (3.71 * D_ij);

end

