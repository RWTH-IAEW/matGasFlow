function GN = check_GN_gasMix(GN)
%CHECK_GN_GASMIX Summary of this function goes here
%   Detailed explanation goes here
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2021, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if isfield(GN,'gasMix')
    if ~ischar(GN.gasMix)
        error('GN.gasMix: Must be a char')
    elseif size(GN.gasMix,1) ~= 1
        error('GN.gasMix: To many entries.')
    end
else
    GN.gasMix = 'H_Gas_Mix';
    warning('GN.gasMix: As the gas network contains no information about the gas mixture (gasMix), it has been initialized as "H_Gas_Mix"')
end

end