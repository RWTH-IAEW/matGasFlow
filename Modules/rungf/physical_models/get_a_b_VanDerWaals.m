function [GN] = get_a_b_VanDerWaals(GN)
%GET_A_B_VANDERWAALS
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2022, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Physical constants
CONST = getConstants();

%% Quantities
R_m = CONST.R_m;
p_c = GN.gasMixAndCompoProp.p_c;
T_c = GN.gasMixAndCompoProp.T_c;
x_mol = GN.gasMixAndCompoProp.x_mol;

%% Internal pressure a and covolume b
% ... of the gas components
a_i = 27/64 * R_m^2 * T_c.^2 ./ p_c;
b_i = 1/8   * R_m   * T_c    ./ p_c;

% ... of the mixture
a = sum(x_mol * x_mol' .* sqrt(a_i * a_i'),'all');
b = sum(x_mol.*b_i);

GN.gasMixProp.a = a;
GN.gasMixProp.b = b;

end

