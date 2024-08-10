function [c_p, c_p_0, dp_dT, dp_dV_m, int_d2p_dT2] = calculate_c_p_VanDerWaals(V_m, T, M_avg, gasMixAndCompoProp, PHYMOD)
%CALCULATE_C_P_VANDERWAALS Specific isobaric heat capacity c_p [J/(kg*K)] using
%   the Van der Waals equation
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
p_c_i       = gasMixAndCompoProp.p_c;
T_c_i       = gasMixAndCompoProp.T_c;
x_mol_i     = gasMixAndCompoProp.x_mol;

%% Internal pressure a and covolume b of the gas components
a_i         = 27/64 * R_m^2 .* T_c_i.^2 ./ p_c_i;
b_i         = 1/8   * R_m   .* T_c_i    ./ p_c_i;
a           = sum(x_mol_i * x_mol_i' .* sqrt(a_i * a_i'),'all');
b           = sum(x_mol_i.*b_i);

%% Partial derivations
dp_dT       =  R_m   ./(V_m-b);
dp_dV_m     = -R_m.*T./(V_m-b).^2 + 2*a ./ V_m.^3;
int_d2p_dT2 =  0;

%% Ideal specific isobaric heat capacity of the gas mixture at each bus [J/(kg*K)]
c_p_0       = calculate_c_p_0(T, M_avg, gasMixAndCompoProp, PHYMOD);

%% Real specific isobaric heat capacity of the gas mixture [J/(kg*K)]
c_p         = c_p_0 + T.*int_d2p_dT2/M_avg - T.*dp_dT.^2./dp_dV_m/M_avg - R_m/M_avg;

end


