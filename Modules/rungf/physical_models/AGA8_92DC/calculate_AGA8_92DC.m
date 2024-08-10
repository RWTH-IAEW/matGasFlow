function [Z, c_p, my_JT, kappa, c_V] = calculate_AGA8_92DC(p, T, Z_input, AGA8_92DC_tables)
%CALCULATE_Z_AGA8_92DC
%   [Z, V_m, c_V, c_p, my_JT, kappa] = calculate_Z_VanDerWaals(p, T)
%   Input quantities:
%       p [Pa] - pressure
%       T [K] - temperature
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if isempty([p,T])
    Z   = [];
    return
end

%% Physical constants
CONST = getConstants();
R_m = CONST.R_m;
% R_m = 8.31451;

%% Quantities
B_n = AGA8_92DC_tables.B_n;
K   = AGA8_92DC_tables.K;

a_n = AGA8_92DC_tables.nParameters.a_n;
b_n = AGA8_92DC_tables.nParameters.b_n;
c_n = AGA8_92DC_tables.nParameters.c_n;
k_n = AGA8_92DC_tables.nParameters.k_n;
u_n = AGA8_92DC_tables.nParameters.u_n;

g_n = AGA8_92DC_tables.nParameters.g_n;
q_n = AGA8_92DC_tables.nParameters.q_n;
f_n = AGA8_92DC_tables.nParameters.f_n;

G = AGA8_92DC_tables.G;
Q = AGA8_92DC_tables.Q;
F = AGA8_92DC_tables.F;
U = AGA8_92DC_tables.U;

%% B
B           = sum(a_n(1:18) .* T'.^(-u_n(1:18)) .* B_n(1:18))'; % [m^3/kmol]
B           = B/1000; % [m^3/mol]

%% C_n_s
C_n_s       = a_n .* (G + 1 - g_n).^g_n .* (Q^2 + 1 -q_n).^q_n .* (F + 1 - f_n).^f_n .* U.^u_n .* T'.^(-u_n);

%% calculate c_p, my_JT, kappa, c_V
rho_r   = p.*K^3./Z_input./R_m./T;
% rho_m   = rho_r/K^3;

Z = Z_input;

K_kmol = 10*K; % [m^3/kmol]^(1/3)
B_kmol = B*1000; % [m^3/kmol]

B_0_i = AGA8_92DC_tables.gasProp.B_0_i;
C_0_i = AGA8_92DC_tables.gasProp.C_0_i;
D_0_i = AGA8_92DC_tables.gasProp.D_0_i;
E_0_i = AGA8_92DC_tables.gasProp.E_0_i;
F_0_i = AGA8_92DC_tables.gasProp.F_0_i;
G_0_i = AGA8_92DC_tables.gasProp.G_0_i;
H_0_i = AGA8_92DC_tables.gasProp.H_0_i;
I_0_i = AGA8_92DC_tables.gasProp.I_0_i;
J_0_i = AGA8_92DC_tables.gasProp.J_0_i;

DT = D_0_i./sinh(D_0_i./T');
DT(isnan(DT)) = 0;
FT = F_0_i./cosh(F_0_i./T');
FT(isnan(FT)) = 0;
HT = H_0_i./sinh(H_0_i./T');
HT(isnan(HT)) = 0;
JT = J_0_i./cosh(J_0_i./T');
JT(isnan(JT)) = 0;

x_mol_i     = AGA8_92DC_tables.x_mol_i;
M_avg_kmol  = AGA8_92DC_tables.M_avg_kmol;

phi_0tt     = sum(x_mol_i .* ( -(B_0_i-1)*T'.^2 - C_0_i.*DT.^2 - E_0_i.*FT.^2 - G_0_i.*HT.^2 - I_0_i.*JT.^2 ))';
t2_phi_tt   = ...
    phi_0tt .* T.^(-2) ...
    + rho_r/K_kmol^3 .*  sum( (u_n( 1:18).^2-u_n( 1:18)) .* a_n(1:18) .* B_n(1:18) .* T'.^(-u_n(1:18))   )' ...
    - rho_r     .*  sum( (u_n(13:18).^2-u_n(13:18)) .* C_n_s(13:18,:)                               )' ...
    +               sum( (u_n(13:58).^2-u_n(13:58)) .* C_n_s(13:58,:) .* rho_r'.^b_n(13:58) .* exp(-c_n(13:58).*rho_r'.^k_n(13:58)))';
c_V_kmol = -t2_phi_tt*R_m/M_avg_kmol;

BIG_C_phi_1 = C_n_s .* rho_r'.^b_n ...
    .* (b_n - (1+k_n).*c_n.*k_n.*rho_r'.^k_n + (b_n-c_n.*k_n.*rho_r'.^k_n).^2) ...
    .* exp(-c_n.*rho_r'.^k_n);
phi_1 = 1 + 2*B_kmol.*rho_r./K_kmol^3 - 2*rho_r .* sum(C_n_s(13:18,:))' + sum(BIG_C_phi_1(13:58,:))';

BIG_C_phi_2 = (1-u_n) .* C_n_s .* rho_r'.^b_n ...
    .* (b_n - c_n.*k_n.*rho_r'.^k_n) ...
    .* exp(-c_n.*rho_r'.^k_n);
phi_2 = ...
    1 ...
    + rho_r./K_kmol^3 .* sum( (1-u_n(1:18)) .* a_n(1:18) .* B_n(1:18) .* T'.^(-u_n(1:18)))' ...
    - rho_r .* sum( (1-u_n(13:18)) .* C_n_s(13:18,:) )' ...
    + sum(BIG_C_phi_2(13:58,:))';

c_p_kmol = c_V_kmol +R_m/M_avg_kmol * phi_2.^2./phi_1; % J/(K kmol)

my_JT = 1./c_p_kmol./M_avg_kmol./(rho_r./K_kmol^3).*(phi_2./phi_1 - 1)/1000;

kappa = phi_1./Z.*c_p_kmol./c_V_kmol;

c_p     = c_p_kmol*1000; % [J/kg/K]
c_V     = c_V_kmol*1000; % [J/kg/K]

if any(isnan([Z; c_p; my_JT; kappa; c_V])) || any(imag([Z; c_p; my_JT; kappa; c_V])~=0)
    error('calculate_AGA8_92DC: something went wrong.')
end

end

