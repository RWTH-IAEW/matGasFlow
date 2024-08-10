function [root_1, root_2, root_3] = solve_cubic_equation(B, C, D)
%SOLVE_CUBIC_EQUATION
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

allRoots = NaN(length(B),3);

for ii = 1:length(B)
    polynomial      = [1 B(ii) C(ii) D(ii)];
    allRoots(ii,:)  = roots(polynomial);
end

allRoots(imag(allRoots)~=0) = NaN;
allRoots = sort(allRoots,2,'descend','MissingPlacement','last');

root_1 = allRoots(:,1);
root_2 = allRoots(:,2);
root_3 = allRoots(:,3);

if any(isnan(root_1))
    warning('solve_cubic_equation: something went wrong.')
end

end

