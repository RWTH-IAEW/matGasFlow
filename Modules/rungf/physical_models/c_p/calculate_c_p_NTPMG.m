function [c_p] = calculate_c_p_NTPMG(p_r, T_r, M_avg)
%CALCULATE_C_P_NTPMG
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

CONST = getConstants;

D_0 =  4.437 -  1.015.*T_r +  0.591.*T_r.^2;
D_1 =  3.290 - 11.370./T_r + 10.900./T_r.^2;
D_2 =  3.230 - 16.270./T_r + 25.480./T_r.^2 - 11.81./T_r.^3;
D_3 = -0.214 +  0.908./T_r -  0.967./T_r.^2;

c_p = (D_0 + D_1.*p_r + D_2.*p_r.^2 + D_3.*p_r.^3) * CONST.R_m/M_avg;

end

