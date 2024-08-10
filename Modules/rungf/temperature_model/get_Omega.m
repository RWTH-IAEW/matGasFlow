function [GN] = get_Omega(GN)
%GET_OMEGA Heat transmission coefficient
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
D_ij        = GN.pipe.D_ij;
c_p_ij      = GN.pipe.c_p_ij;
V_dot_n_ij  = GN.branch.V_dot_n_ij(GN.pipe.i_branch);
rho_n_avg   = GN.gasMixProp.rho_n_avg;
U_ij        = GN.pipe.U_ij;

%% Omega_ij
GN.pipe.Omega_ij    = U_ij .* pi .* D_ij   ./ (c_p_ij .* abs(V_dot_n_ij) .* rho_n_avg); % [Mischner 2015] p. 500 , eq. 33.17

end