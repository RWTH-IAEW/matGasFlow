function [c_p_i, c_p_0_i] = get_c_p_VanDerWaals(p, T, Z, a, b, gasMixProp, gasCompoProp)
%GET_C_P_VANDERWAALS Specific isobaric heat capacity c_p [J/(kg*K)] using
%   the Van der Waals equation
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
R_m     = CONST.R_m;
M_avg   = gasMixProp.M_avg;
V_m     = Z .* R_m .* T ./ p;

% Ideal molar isobaric heat capacity of each gas componenten at each bus [J/(mol*K)]
% Quelle: Thermodynamik der Mischungen S. 690 und Tabelle A.2
C_p_m_0_i_x = ...
    gasCompoProp.a ...
    + gasCompoProp.b * T' ...
    + gasCompoProp.c .* (T.^2)' ...
    + gasCompoProp.d .* (T.^3)';

% Ideal specific isobaric heat capacity of each gas componenten at each bus [J/(kg*K)]
c_p_0_i_x = C_p_m_0_i_x./gasCompoProp.M;

% Ideal specific isobaric heat capacity of the gas mixture at each bus [J/(kg*K)]
c_p_0_i = sum(gasCompoProp.x_mol .* c_p_0_i_x, 1)';

% Real specific isobaric heat capacity of the gas mixture at each bus [J/(kg*K)]
numerator   = T .* R_m^2 ./ ((V_m - b).^2);
denominator = - R_m .* T ./ ((V_m - b).^2) + 2*a ./ V_m.^3;
c_p_i = c_p_0_i - (numerator./denominator)./M_avg - R_m./M_avg;

end

