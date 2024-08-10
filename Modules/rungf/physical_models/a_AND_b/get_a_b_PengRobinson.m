function [GN] = get_a_b_PengRobinson(GN)
%GET_A_B_PENGROBINSON
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
x_mass  = GN.gasMixAndCompoProp.x_mass;

%% Internal pressure a and covolume b of the gas components (specific value of each component)
% ... of the gas components
a_i = 0.457235 * (R_m./M).^2 .* T_c.^2 ./ p_c;
b_i = 0.077796 * R_m./M      .* T_c    ./ p_c;

% ... of the mixture
a = sum(x_mass * x_mass' .* sqrt(a_i * a_i'),'all');
b = sum(x_mass.*b_i);

GN.gasMixProp.a = a*M_avg^2;
GN.gasMixProp.b = b*M_avg;

%% Internal pressure a and covolume b of the gas components (molar value of each component)
% ... of the gas components
a_i = 0.457235 * R_m^2 * T_c.^2 ./ p_c;
b_i = 0.077796 * R_m   * T_c    ./ p_c;

% ... of the mixture
a = sum(x_mol * x_mol' .* sqrt(a_i * a_i'),'all');
b = sum(x_mol.*b_i);

GN.gasMixProp.a_m = a;
GN.gasMixProp.b_m = b;

% GN.gasMixProp.a = a;
% GN.gasMixProp.b = b;

end