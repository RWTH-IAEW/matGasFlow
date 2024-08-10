function Z = calculate_Z_AGA8_92DC(p, T, Z_input, AGA8_92DC_tables, NUMPARAM)
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

%% N
N   = size(AGA8_92DC_tables.nParameters,1);

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

%% rho_r
rho_m       = p./R_m./T./Z_input; % [mol/m^3]
rho_r       = K^3*rho_m;
rho_r_n     = repmat(rho_r',[N,1]);

BIG_C = ...
    C_n_s .* (b_n - c_n.*k_n.*rho_r_n.^k_n) ...
    .* rho_r_n.^(b_n+1) ...
    .* exp(-c_n.*rho_r_n.^k_n);
ff  = ...
    - p*K^3/R_m./T ...
    + rho_r ...
    + rho_r.^2 .* (B./K^3 - sum(C_n_s(13:18,:))') ...
    + sum(BIG_C(13:58,:))';

iter = 0;

while norm(ff) > NUMPARAM.epsilon_Z_AGA8_92DC && iter < NUMPARAM.maxIter
    iter    = iter + 1;

    dBIG_C_drho = ...
        ( (b_n+1).*C_n_s.*b_n.*rho_r_n.^(b_n) ...
        - (k_n+b_n+1).*C_n_s.*c_n.*k_n.*rho_r_n.^(k_n+b_n) )...
        .* exp(-c_n.*rho_r_n.^k_n) ...
        + C_n_s .* (b_n - c_n.*k_n.*rho_r_n.^k_n) .* rho_r_n.^(b_n+1) .* exp(-c_n.*rho_r_n.^k_n) .* (-c_n) .* k_n .* rho_r_n.^(k_n-1);
    dff_drho = ...
        1 ...
        + 2 * rho_r .* (B./K^3 - sum(C_n_s(13:18,:))') ...
        + sum(dBIG_C_drho(13:58,:))';
    
    rho_r = rho_r - ff./dff_drho;
    rho_r_n = repmat(rho_r',[N,1]);
    
    BIG_C = ...
        C_n_s .* (b_n - c_n.*k_n.*rho_r_n.^k_n) ...
        .* rho_r_n.^(b_n+1) ...
        .* exp(-c_n.*rho_r_n.^k_n);
    ff  = ...
        - p*K^3/R_m./T ...
        + rho_r ...
        + rho_r.^2 .* (B./K^3 - sum(C_n_s(13:18,:))') ...
        + sum(BIG_C(13:58,:))';
end

%% Z_output
Z = p.*K^3./rho_r./R_m./T;

if any(isnan(Z)) || any(Z<=0)
    error('Z became negative. The gas might be in liquid phase or in vapour-liquid equelibrium phase. AGA8-92DC only applies for the gas phase.')
end

end

