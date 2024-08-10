function [GN] = get_eta_Lucas(GN)
%GET_ETA_LUCAS
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
M_avg       = GN.gasMixProp.M_avg;
T_ij        = GN.pipe.T_ij;
p_r_ij      = GN.pipe.p_ij/GN.gasMixProp.p_pc;
T_r_ij      = GN.pipe.T_ij/GN.gasMixProp.T_pc;
p_pc        = GN.gasMixProp.p_pc; % TODO: Es muss der kritische Druck jeder einzelenen Gaskomponeten verwendet werden
T_pc        = GN.gasMixProp.T_pc; % TODO: Es muss die kritische Temperatur jeder einzelenen Gaskomponeten verwendet werden
Z_pc        = GN.gasMixProp.Z_pc;
my_dp_r_mix = GN.gasMixProp.my_dp_r_mix_2;
CONST       = getConstants;

%% eta_ideal
% xi - Inverse reduced viscosity
xi      = ( (CONST.R_m * T_pc * CONST.N_A^2)./(M_avg^3 * p_pc.^4) )^(1/6);

% eta_ideal - dynamic viscosity of gases at low pressures
% Option I
eta_r_0 = 0.807*T_r_ij.^0.618 - 0.357.*exp(-0.449*T_r_ij) + 0.340.*exp(-4.058*T_r_ij) + 0.018;

eta_ideal = eta_r_0./xi;

%% eta_real
%% Polarity
% F_p_0 - Ideal correction factor to take polarity into account (The considered gases are nonpolar)
F_p_0(0     <= my_dp_r_mix & my_dp_r_mix < 0.022)   = 1;
F_p_0(0.022 <= my_dp_r_mix & my_dp_r_mix < 0.075)   = 1 + 30.55*(0.292-Z_pc).^1.72;
F_p_0(0.075 <= my_dp_r_mix)                         = 1 + 30.55*(0.292-Z_pc).^1.72 .* abs(0.96 + 0.1*(T_r_ij(0.075 <= my_dp_r_mix) - 0.7));

% Z_2 - Considering the influence of pressure - 1<=T_r<=40, 0<=p_r<=100
A = 0.001245./T_r_ij .* exp(5.1726.*T_r_ij.^(-0.3286));
B = A .* (1.6552.*T_r_ij - 1.2723);
C = 0.04489./T_r_ij .* (3.0578.*T_r_ij.^(-37.7332));
D = 1.7368./T_r_ij .* exp(2.231.*T_r_ij.^(-7.6351));
E = 1.3088;
F = 0.9425 .* exp(-0.1853.*T_r_ij.^(0.4489));
Z_2 = 1 + ( A.* p_r_ij.^E ./ ...
    (B .* p_r_ij.^F + 1./(1 + C.*p_r_ij.^D)) );

% F_P - correction factor to take polarity into account
F_P =  1 + (F_p_0 - 1) .* Z_2.^-3 ./ F_p_0;

%% F_Q - Correction factor for quantum gas
x_mol_H2    = GN.gasMixAndCompoProp.x_mol('H2');
x_mol_CH4   = GN.gasMixAndCompoProp.x_mol('CH4');

% F_Q - Correction factor for quantum gas
if x_mol_CH4 > 0.05 && x_mol_CH4 < 0.7
    A = 1 - 0.01 * (GN.gasMixAndCompoProp.M('CH4') / GN.gasMixAndCompoProp.M('H2'))^0.87;
else
    A = 1;
end
T_r_H2 = T_ij./GN.gasMixAndCompoProp.T_c('H2');
F_Quantum_gas_H2 = ...
    x_mol_H2 .* 1.22 .* 0.76^0.15 .* ...
    ( 1 + 0.00385 .* abs(T_r_H2 - 12).^(2/(GN.gasMixAndCompoProp.M('H2').*1000)) .* abs(T_r_H2 - 12) ) ...
    .* A ;
F_Q = x_mol_H2 .* F_Quantum_gas_H2 + 1 - x_mol_H2;

GN.pipe.eta_ij = eta_ideal .* Z_2 .* F_P .* F_Q;  %[Pa/s]

%% Check result
%if T_r_ij < 1 && p_r_ij < p_s(T_r)
if ~(all(T_r_ij >= 1) && all(T_r_ij <= 40) && all(p_r_ij >= 0) && all(p_r_ij <= 100))
    warning('get_eta: Lucas'' method might be inadmissible.')
end

% There is another correction factor, which is considered only for the
% so-called quantum gases H2, D2 and He. The average error of the
% method is approx. 1...4%, which is why measurements of this quantity
% are generally dispensed with.

end

