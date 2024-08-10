function GN = check_GN_T_env(GN)
%CHECK_GN_T_ENV
%   GN = check_GN_T_env(GN)
%   Check and initialization of GN.T_env (environmental temperature)
%       GN.T_env must be between 0 and 373
%       default value: GN.T_env = 283.15
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2022, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if isfield(GN,'T_env')
    if ~all(size(GN.T_env) == [1,1]) || ~isa(GN.T_env,'double')
        error('GN.T_env must be one double value')
    elseif GN.T_env < 0
        error(['GN.T_env must be one double value greater than 0 Kelvin. GN.T_env = ', num2str(GN.T_env)])
    elseif GN.T_env > 373
        warning(['GN.T_env is very large: GN.T_env = ',num2str(GN.T_env)])
    end
elseif all(~isfield(GN,{'pipe', 'comp', 'prs', 'valve'}))
    return
else
    GN.T_env = 283.15;
    warning('GN.T_env is missing. The environmental temperature is set to the default value 283.15 K.')
end

end

