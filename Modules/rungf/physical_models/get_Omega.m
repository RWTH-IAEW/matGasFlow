function [Omega_ij] = get_Omega(GN)
%GET_OMEGA Summary of this function goes here
%   Calculation of the Heat transmission coefficient, see MA Longye Zheng p. 48 eqn. 3.42
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2021, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Quantities
D_ij        = GN.pipe.D_ij;
c_p_ij      = GN.pipe.c_p_ij;
V_dot_n_ij  = GN.branch.V_dot_n_ij(GN.pipe.i_branch);
rho_n_avg   = GN.gasMixProp.rho_n_avg;

% Constants (hard coded, UNDER CONSTRUCTION)
lambda_soil = 2;    % [W/m*K] vgl. [MIS15] S.515 Tabelle 33.4
depth       = 1;    % [m]

% Heat transfer coefficient
U = 1./(2*D_ij./lambda_soil .* log(2*depth./D_ij + sqrt(2*depth./D_ij-1))); % vgl. [MIS15] Gl. 33.53

Omega_ij    = U .* pi .* D_ij ./ (c_p_ij .* abs(V_dot_n_ij) .* rho_n_avg); % [MIS15] S. 500 

end