function [B_n, K, G, Q, F, U, x_mol_i, M_avg_kmol] = get_AGA8_92DC_parameters(AGA8_92DC_tables)
%GET_AGA8_92DC_PARAMETERS
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


%% Quantities
N   = size(AGA8_92DC_tables.nParameters,1);
a_n = AGA8_92DC_tables.nParameters.a_n;
b_n = AGA8_92DC_tables.nParameters.b_n;
c_n = AGA8_92DC_tables.nParameters.c_n;
k_n = AGA8_92DC_tables.nParameters.k_n;
u_n = AGA8_92DC_tables.nParameters.u_n;
g_n = AGA8_92DC_tables.nParameters.g_n;
q_n = AGA8_92DC_tables.nParameters.q_n;
f_n = AGA8_92DC_tables.nParameters.f_n;
s_n = AGA8_92DC_tables.nParameters.s_n;
w_n = AGA8_92DC_tables.nParameters.w_n;

I   = size(AGA8_92DC_tables.gasProp,1);
M_i = AGA8_92DC_tables.gasProp.M_i;
E_i = AGA8_92DC_tables.gasProp.E_i;
K_i = AGA8_92DC_tables.gasProp.K_i;
G_i = AGA8_92DC_tables.gasProp.G_i;
Q_i = AGA8_92DC_tables.gasProp.Q_i;
F_i = AGA8_92DC_tables.gasProp.F_i;
S_i = AGA8_92DC_tables.gasProp.S_i;
W_i = AGA8_92DC_tables.gasProp.W_i;

u_nij = zeros(1,1,N);
u_nij(1,1,:) = u_n;
u_nij = repmat(u_nij,[I,I,1]);
g_nij = zeros(1,1,N);
g_nij(1,1,:) = g_n;
g_nij = repmat(g_nij,[I,I,1]);
q_nij = zeros(1,1,N);
q_nij(1,1,:) = q_n;
q_nij = repmat(q_nij,[I,I,1]);
f_nij = zeros(1,1,N);
f_nij(1,1,:) = f_n;
f_nij = repmat(f_nij,[I,I,1]);
s_nij = zeros(1,1,N);
s_nij(1,1,:) = s_n;
s_nij = repmat(s_nij,[I,I,1]);
w_nij = zeros(1,1,N);
w_nij(1,1,:) = w_n;
w_nij = repmat(w_nij,[I,I,1]);

E_ij_s  = AGA8_92DC_tables.E_ij;
U_ij    = AGA8_92DC_tables.U_ij;
K_ij    = AGA8_92DC_tables.K_ij;
G_ij_s  = AGA8_92DC_tables.G_ij;

E_ij_s(E_ij_s==0)   = 1;
% E_ij_s              = E_ij_s-diag(ones(I,1));
U_ij(U_ij==0)       = 1;
% U_ij                = U_ij-diag(ones(I,1));
K_ij(K_ij==0)       = 1;
% K_ij                = K_ij-diag(ones(I,1));
G_ij_s(G_ij_s==0)   = 1;
% G_ij_s              = G_ij_s-diag(ones(I,1));

x_mol_i = AGA8_92DC_tables.x_mol_i;
xx_ij   = x_mol_i * x_mol_i';
xx_ij(diag(true(I,1)))   = 0;
xx_ij(triu(true(I,I),1)) = 0;

%% C_n_s
G           =   sum(x_mol_i     .* G_i)          +  1*sum(xx_ij .* (G_ij_s  - 1) .* (repmat(G_i,[1,I]) + repmat(G_i',[I,1])),'all');
Q           =   sum(x_mol_i     .* Q_i);
F           =   sum(x_mol_i.^2  .* F_i);
U           = ( sum(x_mol_i     .* E_i.^(5/2))^2 + 1*sum(xx_ij .* (U_ij.^5 - 1) .* (E_i * E_i').^(5/2),'all') )^(1/5);

%% B
E_ij        = E_ij_s .* sqrt(E_i * E_i');
G_ij        = G_ij_s .* (repmat(G_i,[1,I]) + repmat(G_i',[I,1]))./2;
B_nij_s     =   (repmat(G_ij            ,[1,1,N]) + 1 - g_nij).^g_nij .* ...
    (repmat(Q_i*Q_i'        ,[1,1,N]) + 1 - q_nij).^q_nij .* ...
    (repmat(sqrt(F_i*F_i')  ,[1,1,N]) + 1 - f_nij).^f_nij .* ...
    (repmat(S_i*S_i'        ,[1,1,N]) + 1 - s_nij).^s_nij .* ...
    (repmat(W_i*W_i'        ,[1,1,N]) + 1 - w_nij).^w_nij;

xxKK_nij    = repmat(x_mol_i * x_mol_i' .* (K_i*K_i').^(3/2), [1,1,N]);
E_nij_u_nij = repmat(E_ij,[1,1,N]).^u_nij;
B_n_temp    = sum(xxKK_nij .* B_nij_s .* E_nij_u_nij, [1,2]);
B_n         = zeros(N,1);
B_n(:)      = B_n_temp(1,1,:);

%% K
K           = ( sum(x_mol_i     .* K_i.^(5/2))^2 + 2*sum(xx_ij .* (K_ij.^5 - 1) .* (K_i * K_i').^(5/2),'all') )^(1/5); % [m^3/kmol]^(1/3)
K           = K/10; % [m^3/mol]^(1/3)

%%
x_mol_i     = AGA8_92DC_tables.x_mol_i;

%%
M_avg_kmol = sum(AGA8_92DC_tables.gasProp.M_i .* x_mol_i);

end

