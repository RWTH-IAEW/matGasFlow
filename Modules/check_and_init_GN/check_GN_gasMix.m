function GN = check_GN_gasMix(GN)
%CHECK_GN_GASMIX Check gasMix string
%   GN = check_GN_gasMix(GN)
%   Check and initialization of GN.gasMix (Name of gas mixture)
%       GN.gasMix must be a char
%       default value: GN.gasMix = 'H_Gas_Mix'
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2022, High Voltage Equipment and Grids,
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
elseif isfield(GN,'gasMixProp') && isfield(GN,'gasMixAndCompoProp')
    return
else
    GN.gasMix = 'H_Gas_Mix';
    warning('GN.gasMix: As the gas network contains no information about the gas mixture, it has been initialized as ''H_Gas_Mix''')
end

end