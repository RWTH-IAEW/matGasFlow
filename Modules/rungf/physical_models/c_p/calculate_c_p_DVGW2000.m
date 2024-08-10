function [c_p, c_p_0, dp_dT, dp_dV_m, int_d2p_dT2] = calculate_c_p_DVGW2000(V_m, T, Z_n_avg, M, gasMixAndCompoProp, PHYMOD)
%CALCULATE_C_P_DVGW2000
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Physical constants
CONST = getConstants();

%% Quantities
R_m     = CONST.R_m;
p_ref   = 450 * 1e5;

%% Ideal specific isobaric heat capacity of the gas mixture at each bus [J/(kg*K)]
c_p_0 = calculate_c_p_0(T, M, gasMixAndCompoProp, PHYMOD);

%% Partial derivations
dp_dT       =  R_m*Z_n_avg*p_ref^2*V_m ./ (R_m*Z_n_avg*T + p_ref*V_m).^2;
dp_dV_m     = -R_m*Z_n_avg*p_ref^2*T   ./ (R_m*Z_n_avg*T + p_ref*V_m).^2;
int_d2p_dT2 = -R_m^2*Z_n_avg^2*p_ref^2 * (R_m*Z_n_avg*T + 2*p_ref*V_m) ./ (2*p_ref^2 * (R_m*Z_n_avg*T + p_ref*V_m).^2);

%% Real specific isobaric heat capacity of the gas mixture [J/(kg*K)]
c_p = c_p_0 + T.*int_d2p_dT2/M - T.*dp_dT.^2./dp_dV_m/M - R_m/M;

end



