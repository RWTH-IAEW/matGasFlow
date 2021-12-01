function [GN] = get_J(GN, NUMPARAM, PHYMOD)
%GET_J
%
%   Jacobian Matrix J = df/dp
%
%   |-----------------------------------|
%   | df_1/dp_1   .   .   .   df_1/dp_N |
%   |     .       .               .     |
%   |     .           .           .     |
%   |     .               .       .     |
%   | df_N/dp_1   .   .   .   df_N/dp_N |
%   |-----------------------------------|
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2021, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if NUMPARAM.OPTION_get_J == 1
    GN = get_J_analytical_model(GN, NUMPARAM);
    
elseif NUMPARAM.OPTION_get_J == 2
    try
        GN = get_J_dpModel(GN, NUMPARAM, PHYMOD);
    catch
        error('Option not available, choose NUMPARAM.OPTION_get_J = 1')
    end
    
elseif NUMPARAM.OPTION_get_J == 3
    try
        GN = get_J_dpForLoopModel(GN, NUMPARAM, PHYMOD);
    catch
        error('Option not available, choose NUMPARAM.OPTION_get_J = 1')
    end
    
end
end

