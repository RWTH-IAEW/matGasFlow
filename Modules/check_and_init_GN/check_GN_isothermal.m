function check_GN_isothermal(GN)
%CHECK_GN_ISOTHERMAL Check logical value GN.isothermal (temperature model)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2021, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if isfield(GN,'isothermal')
    if ~all(size(GN.isothermal) == [1,1]) || GN.isothermal < 0 || GN.isothermal > 1
        error('GN.isothermal must be one logical value')
    end
    GN.isothermal(isnan(GN.isothermal)) = false; 
    GN.isothermal(GN.isothermal == 0) = false;
    GN.isothermal(GN.isothermal == 1) = true;
    GN.isothermal = logical(GN.isothermal);
    
else
    error('GN.isothermal column is missing.')
end
end