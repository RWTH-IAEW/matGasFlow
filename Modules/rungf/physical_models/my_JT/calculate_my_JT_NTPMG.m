function [my_JT] = calculate_my_JT_NTPMG(p_r,T_r)
%CALCULATE_MY_JT_NTPMG
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% my_JT
E_0 =  2.496  - 2.03  .* T_r + 0.457 .* T_r.^2;
E_1 =  0.566  - 1.992 ./ T_r + 1.689 ./ T_r.^2;
E_2 = -0.411  + 1.468 ./ T_r - 1.339 ./ T_r.^2;
E_3 =  0.0568 - 0.2   ./ T_r + 0.179 ./ T_r.^2;
my_JT = (E_0 + E_1 .* p_r + E_2 .* p_r.^2 + E_3 .* p_r.^3)*1e-5; % [K/Pa]

end

