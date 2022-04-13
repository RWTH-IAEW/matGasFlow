function [Z,V_m] = get_Z_VanDerWaals(p, T, a, b)
%GET_Z_VANDERWAALS
%   [Z,V_m] = get_Z_VanDerWaals(p, T, a, b)
%   Input quantities:
%       p [Pa] - pressure
%       T [K] - temperature
%       a [N m^4/mol^2] - internal pressure
%       b [m^3/mol] - covolume
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

%% Solve Cubic Equation V_m^3 + B * V_m^2 + C * V_m + D = 0
B = -(b + R_m .* T ./ p);           % [m^3/mol]
C = a ./ p;                         % [m^6/mol^2]
D = -a .* b ./ p;                   % [m^9/mol^3]

V_m = solve_cubic_equation(B,C,D);    % [m^3/mol]

Z = p .* V_m ./ (R_m .* T);         % [-]

end