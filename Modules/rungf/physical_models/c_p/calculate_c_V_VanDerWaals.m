function [c_V] = calculate_c_V_VanDerWaals(T, M_avg, gasMixAndCompoProp, PHYMOD)
%CALCULATE_C_V_VANDERWAALS Specific isochoric heat capacity c_V [J/(kg*K)]
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
CONST       = getConstants();

%% Quantities
R_m         = CONST.R_m;

%% Partial derivations
int_d2p_dT2 = 0;

%% Ideal specific isobaric heat capacity of the gas mixture at each bus [J/(kg*K)]
c_p_0       = calculate_c_p_0(T, M_avg, gasMixAndCompoProp, PHYMOD);

%% Real specific isobaric heat capacity of the gas mixture [J/(kg*K)]
c_V         = c_p_0 + T.*int_d2p_dT2/M_avg - R_m/M_avg;

end

