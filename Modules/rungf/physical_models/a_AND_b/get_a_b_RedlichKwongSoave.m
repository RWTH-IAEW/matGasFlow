function [GN] = get_a_b_RedlichKwongSoave(GN)
%GET_A_B_REDLICHKWONGSOAVE
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
CONST = getConstants();

%% Quantities
R_m     = CONST.R_m;
M_avg   = GN.gasMixProp.M_avg;
M       = GN.gasMixAndCompoProp.M;
p_c     = GN.gasMixAndCompoProp.p_c;
T_c     = GN.gasMixAndCompoProp.T_c;
x_mol   = GN.gasMixAndCompoProp.x_mol;

%% alpha
T       = GN.bus.T_i;
T_r     = T*(1./T_c)';
omega   = GN.gasMixAndCompoProp.omega;
m       = 0.480 + 1.574.*omega - 0.176.*omega.^2;
% m       = 0.48508 + 0.55171.*omega - 0.15613.*omega.^2; % Alternative from: https://pubs.acs.org/doi/10.1021/acsomega.1c00248?ref=pdf
alpha   = ( 1 + m' .* (1-sqrt(T_r)) ).^2;
% alpha_MAT = repmat(alpha,13,1,1);
% alpha_MAT = reshape(alpha_MAT,13,13,24);
% cat(3,alpha_MAT,[3 2 1; 0 9 8; 5 3 7])

a_i = 1/9/(2^(1/3)-1) * (R_m./M).^2 .* T_c.^2 ./ p_c;
b_i = (2^(1/3)-1)/3   * R_m./M      .* T_c    ./ p_c;

% ... of the mixture
a_T = NaN(length(T),1);

for ii = 1:length(T)
    a_T(ii) = sum(x_mol * x_mol' .* sqrt((a_i * a_i') .* (alpha(ii,:)' * alpha(ii,:))),'all');
end
GN.bus.a_T = a_T;
b = sum(x_mol.*b_i);
GN.gasMixProp.b = b*M_avg;

%% Internal pressure a and covolume b of the gas components (specific value of each component)
% ... of the gas components
a_i = 1/9/(2^(1/3)-1) * (R_m./M).^2 .* T_c.^2 ./ p_c;
b_i = (2^(1/3)-1)/3   * R_m./M      .* T_c    ./ p_c;

% ... of the mixture
a = sum(x_mol * x_mol' .* sqrt(a_i * a_i'),'all');
b = sum(x_mol.*b_i);

GN.gasMixProp.a = a*M_avg^2;
GN.gasMixProp.b = b*M_avg;

%% Internal pressure a and covolume b of the gas components (molar value of each component)
% ... of the gas components
a_i = 1/9/(2^(1/3)-1) * R_m^2 * T_c.^2 ./ p_c;
b_i = (2^(1/3)-1)/3   * R_m   * T_c    ./ p_c;

% ... of the mixture
a = sum(x_mol * x_mol' .* sqrt(a_i * a_i'),'all');
b = sum(x_mol.*b_i);

GN.gasMixProp.a_m = a;
GN.gasMixProp.b_m = b;

GN.gasMixProp.a = a;
GN.gasMixProp.b = b;

end