function [result] = solve_cubic_equation(B, C, D)
%SOLVE_CUBIC_EQUATION
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
<<<<<<< HEAD
%   Copyright (c) 2020-2022, High Voltage Equipment and Grids,
=======
%   Copyright (c) 2020-2021, High Voltage Equipment and Grids,
>>>>>>> Merge to public repo (#1)
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

result = zeros(size(B));
for ii = 1:length(result)
    polynomial = [1 B(ii) C(ii) D(ii)];
    solution = roots(polynomial);
    result(ii) = real(solution(1));
end
end

