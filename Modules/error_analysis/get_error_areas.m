function [SUCCESS] = get_error_areas(GN, NUMPARAM, PHYMOD)
%GET_ERROR_AREAS Summary of this function goes here
%   Detailed explanation goes here
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2022, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 3
    PHYMOD = getDefaultPhysicalModels();
    
    if nargin < 2
        NUMPARAM = getDefaultNumericalParameters();
    end
end

% Initialize ...
area_IDs    = unique(GN.bus.area_ID);
SUCCESS     = true(length(area_IDs),1);

for ii = 1:length(area_IDs)
    try
        GN_area = get_GN_area(GN, ii);
        rungf(GN_area, NUMPARAM, PHYMOD);
    catch
        SUCCESS(ii) = false;
    end
end

end

