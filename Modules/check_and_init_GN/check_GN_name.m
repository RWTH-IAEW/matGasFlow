function GN = check_GN_name(GN)
%CHECK_GN_NAME
%   GN = check_GN_name(GN)
%   Check and initialization of GN.name (gas network name)
%       GN.name must be char
%       default value: GN.name = 'GN'
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if isfield(GN,'name') % check
    if iscell(GN.name)
        GN.name = GN.name{1};
    elseif isstring(GN.name)
        GN.name = char(GN.name);
    elseif isnumeric(GN.name)
        GN.name = num2str(GN.name);
    end
else % initialization of default name
    GN.name = 'GN';
    warning('GN.name is missing, default value: GN.name = ''GN''')
end

end

