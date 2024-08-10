function [GN] = get_eta_NTPMG(GN)
%GET_ETA_NTPMG
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

% Quantities
p_r_ij  = GN.pipe.p_ij/GN.gasMixProp.p_pc;
T_r_ij  = GN.pipe.T_ij/GN.gasMixProp.T_pc;

eta_t   = 1e-6 * (1.81 + 5.95*T_r_ij);
B_1     = -0.67 + 2.36 ./T_r_ij - 1.93 ./T_r_ij.^2;
B_2     =  0.8  - 2.89 ./T_r_ij + 2.65 ./T_r_ij.^2;
B_3     = -0.1  + 0.354./T_r_ij - 0.314./T_r_ij.^2;

GN.pipe.eta_ij = eta_t .* (1 + B_1.*p_r_ij + B_2.*p_r_ij.^2 + B_3.*p_r_ij.^3);

end

