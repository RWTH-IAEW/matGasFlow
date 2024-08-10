function [GN] = getGasType(val,GN)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

val.x_object.fluid.x_object.is_gas(1) = erase(val.x_object.fluid.x_object.is_gas(1), ' '); 
if strcmp(val.x_object.fluid.x_object.is_gas(1), 'false')
    GN.gasMix = table;
    warning ('Pandapipe Network has not been designed for gas tranport. Gas Type will be set to hGasMix.')
    GN.gasMix = 'H_Gas_Mix'; 
end 
end 