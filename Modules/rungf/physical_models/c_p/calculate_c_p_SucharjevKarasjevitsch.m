function [c_p, c_p_0] = calculate_c_p_SucharjevKarasjevitsch(T, T_r, p_r, M_avg)
%CALCULATE_C_P_SUCHARJEVKARASJEVITSCH
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

% Constants
C_0 = 41.205;
C_1 = -9.4802;
C_2 = 3.2342;
C_3 = -0.22399;

C_p_m_0     = C_0 + C_1 * T * 1e-2 + C_2 * T.^2 * 1e-4 + C_3 * T.^3 * 1e-6; % [J/(mol*K)]
c_p_0       = C_p_m_0/M_avg;                                                % [J/(kg*K)]
delta_C_p_m = p_r.^1.25 .* 10.^(1.5*T_r.^2 - 6*T_r + 6.36);                 % [J/(mol*K)]
delta_c_p   = delta_C_p_m/M_avg;                                            % [J/(kg*K)]
c_p         = c_p_0 + delta_c_p;                                            % [J/(kg*K)]

end

