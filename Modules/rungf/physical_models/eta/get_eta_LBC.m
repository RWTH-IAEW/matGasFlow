function [GN] = get_eta_LBC(GN)
%GET_ETA_LBC
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

CONST       = getConstants;
R_m         = CONST.R_m;

% Quantities
M_avg       = GN.gasMixProp.M_avg;
T_r_ij      = GN.pipe.T_ij/GN.gasMixProp.T_pc;
V_m_ij      = GN.pipe.Z_ij./GN.pipe.p_ij.*R_m.*GN.pipe.T_ij;
p_pc        = GN.gasMixProp.p_pc;
T_pc        = GN.gasMixProp.T_pc;
V_m_pc      = GN.gasMixProp.Z_pc/p_pc*R_m*T_pc;

%% eta_i
u_eta   = 1e-7;     % Pa*s
u_M     = 1e-3;     % kg/mol
u_T     = 1;        % K
u_p     = 101325;   % Pa
M_i     = GN.gasMixAndCompoProp.M;
T_c_i   = GN.gasMixAndCompoProp.T_c;
p_c_i   = GN.gasMixAndCompoProp.p_c;
alpha_i               = 3.4 * T_r_ij.^0.94;
alpha_i2              = 1.778 * (4.58 * T_r_ij - 1.67).^0.625;
alpha_i(T_r_ij > 1.5) = alpha_i2(T_r_ij > 1.5);
eta_i = u_eta .* (M_i/u_M).^(1/2) .* (T_c_i/u_T).^(-1/6) .* (p_c_i/u_p).^(2/3) .* alpha_i';

%% eta_mix
x_mol_i = GN.gasMixAndCompoProp.x_mol;
eta_mix = sum(x_mol_i .* eta_i .* sqrt(M_i))' ./ sum(x_mol_i .* sqrt(M_i))';

%% xi
xi = u_eta * (M_avg/u_M).^(1/2) * (T_pc/u_T)^(-1/6) .* (p_pc/u_p).^(2/3);

%% delta
V_m_r_ij = V_m_ij/V_m_pc;
rho_r_ij = 1./V_m_r_ij;
delta = 1.023 + 0.23364 * rho_r_ij + 0.58533 * rho_r_ij.^2 - 0.40758 * rho_r_ij.^3 + 0.093324 * rho_r_ij.^4;

%% eta
GN.pipe.eta_ij = eta_mix + xi .* (delta.^4-1);

end

