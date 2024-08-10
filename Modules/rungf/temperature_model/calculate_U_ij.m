function [U] = calculate_U_ij(depth,lambda_soil)
%CALCULATE_U_IJ Basic heat transfer coefficient
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% [Mischner 2015] eq. 33.53
Lambda_soil = D_ij/2/lambda_soil .* log(2*depth./D_ij + sqrt((2*depth./D_ij).^2-1));
U           = 1./Lambda_soil;

end

