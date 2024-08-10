function [GN] = get_eta_Chung(GN)
%GET_ETA_CHUNG
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
CONST = getConstants;

T_r_ij              = GN.pipe.T_ij/GN.gasMixProp.T_pc;
V_m_ij              = GN.pipe.Z_ij .* CONST.R_m .* GN.pipe.T_ij ./ GN.pipe.p_ij;
T_pc                = GN.gasMixProp.T_pc;
V_m_pc              = GN.gasMixProp.V_m_pc;
sigma_mix_pow2      = GN.gasMixProp.sigma_mix_pow2;
omega_mix           = GN.gasMixProp.omega_mix;
my_dp_r_mix         = GN.gasMixProp.my_dp_r_mix;
M_mix               = GN.gasMixProp.M_mix;
M_mix__g_per_mol    = M_mix*1e3;
kappa               = 0;

F_c_mix             = 1 - 0.275*omega_mix + 0.059035*my_dp_r_mix;

T_r_temp    = 1.2593*T_r_ij;
A           = 1.16145;
B           = 0.14874;
C           = 0.52487;
D           = 0.77320;
E           = 2.16178;
F           = 2.43787;
Omega_v     = A*T_r_temp.^-B + C*exp(-D*T_r_temp) + E*exp(-F*T_r_temp);

%     eta_mix     = 26.69*F_c_mix*sqrt(M_mix__g_per_mol*T_ij)./(sigma_mix_pow2*Omega_v) * 1e-7;

E_const = [ ...
    6.324     50.412     -51.680    1189.0    ; ...
    0.00121   -0.001154   -0.006257    0.03728; ...
    5.283    254.209    -168.48     3898.0    ; ...
    6.623     38.096      -8.464      31.42   ; ...
    19.745      7.630     -14.354      31.53   ; ...
    -1.900    -12.537       4.985     -18.15   ; ...
    24.275      3.450     -11.291      69.35   ; ...
    0.7972     1.117       0.01235    -4.117  ; ...
    -0.2382     0.06770    -0.8163      4.025  ; ...
    0.06863   0.3479       0.5926     -0.727  ];
E = E_const * [1; omega_mix; my_dp_r_mix^4; kappa];

GN = get_rho(GN);

y = GN.pipe.rho_ij .* V_m_pc/6;

G_1 = (1-0.5*y)./(1-y).^3;
G_2 = ( E(1)*(1-exp(-E(4)*y))/4 + E(2)*G_1.*exp(E(5)*y) + E(3)*G_1 ) / ( E(1)*E(4) + E(2) + E(3) );
eta_temp = sqrt(T_r_temp) ./ Omega_v * F_c_mix .* (1./G_2 + E(6)*y) + E(7)*y.^2.*G_2.*exp(E(8)+E(9)./T_r_temp + E(10)./T_r_temp.^2);

V_m_c_mix__cm3_per_mol = GN.gasMixProp.sigma_mix_pow3/0.809^3;
eta_mix = eta_temp .* 36.344.*sqrt(M_mix__g_per_mol*T_pc)./(V_m_c_mix__cm3_per_mol^(2/3)) * 1e-7;


GN.pipe.eta_ij = eta_mix;

end

