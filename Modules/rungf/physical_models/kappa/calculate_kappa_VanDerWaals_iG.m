function [kappa] = calculate_kappa_VanDerWaals_iG(c_p, c_V)
%CALCULATE_KAPPA_VANDERWAALS
%   [kappa] = get_Z_VanDerWaals(c_p, c_v)
%   Input quantities:
%       c_p [J/kg K]        - specific isobaric heat capacity
%       c_v [J/kg K]        - specific isochoric heat capacity
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Isentropic exponent
kappa = c_p./c_V;

end

