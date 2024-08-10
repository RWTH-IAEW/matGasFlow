function [GN] = get_a_b_VanDerWaals(GN)
%GET_A_B_VANDERWAALS
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
CONST   = getConstants();

%% Quantities
R_m     = CONST.R_m;
M_avg   = 1;%GN.gasMixProp.M_avg;
M       = 1;%GN.gasMixAndCompoProp.M;
p_c     = GN.gasMixAndCompoProp.p_c;
T_c     = GN.gasMixAndCompoProp.T_c;
x_mol   = GN.gasMixAndCompoProp.x_mol;

%% Internal pressure a and covolume b
% ... of the gas components
a_i = 27/64 * (R_m./M).^2 .* T_c.^2 ./ p_c;
b_i = 1/8   * R_m./M      .* T_c    ./ p_c;

% ... of the mixture
a = sum(x_mol * x_mol' .* sqrt(a_i * a_i'),'all');
b = sum(x_mol.*b_i);

GN.gasMixProp.a = a*M_avg^2;
GN.gasMixProp.b = b*M_avg;


%%
% M_avg   = GN.gasMixProp.M_avg;
% M       = GN.gasMixAndCompoProp.M;
% a_i = 27/64 * (R_m./M).^2 .* T_c.^2 ./ p_c;
% b_i = 1/8   * R_m./M      .* T_c    ./ p_c;
% 
% % ... of the mixture
% a_gr = M_avg^2 * sum(x_mol * x_mol' .* sqrt(a_i * a_i'),'all');
% b_gr = M_avg   * sum(x_mol.*b_i);

end

