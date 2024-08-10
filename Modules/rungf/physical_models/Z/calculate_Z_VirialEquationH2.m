function [Z, V_m] = calculate_Z_VirialEquationH2(p, T)
%CALCULATE_Z_VIRALEQUATIONH2
%   [Z, V_m] = calculate_Z_VirialEquationH2(p, T)
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

%% Physical constants
CONST = getConstants();

%% Quantities
R_m = CONST.R_m;

%% Ref.: A. Michels, W. de Graaff, T. Wassenaar, J.M.H. Levelt, and P. Louwerse (1959) bublished in is published in [Dymond & Smith] on page 205.
T_0 = [ 98.15 103.15 113.15 123.15 138.15 153.15 173.15 198.15 223.13 248.15 273.15 298.15 323.15 348.15 373.15 398.15 423.15];
B_0 = [ -2.99  -1.6    0.8    2.68   5.03   6.98   8.93  10.79  12.05  13.03  13.74  14.37  14.92  15.38  15.67  15.86  16.08]*1e-6; % mol/m^3
C_0 = [503    511    506    519    516    480    459    414    406    388    389    356    323    295    290    296    280   ]*1e-12; % mol^2/m^6

if any(min(T) < min(T_0) | max(T) > max(T_0))
    error(['To apply the virial equation for H2, T must be: ',num2str(min(T_0)),' K <= T <= ',num2str(max(T_0)),' K'])
end

B_T = interp1(T_0,B_0,T);
C_T = interp1(T_0,C_0,T);

%% Solve Cubic Equation V_m^3 + b * V_m^2 + c * V_m + d = 0
b = -R_m*T./p;      % [m^3/mol]
c = -R_m*T./p.*B_T; % [m^6/mol^2]
d = -R_m*T./p.*C_T; % [m^9/mol^3]

V_m = solve_cubic_equation(b,c,d);  % [m^3/mol]

Z = p .* V_m ./ (R_m .* T);         % [-]

end