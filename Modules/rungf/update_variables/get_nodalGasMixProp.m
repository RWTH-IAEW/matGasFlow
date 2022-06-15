function GN = get_nodalGasMixProp(GN, PHYMOD)
%GET_NODALGASMIXPROP Summary of this function goes here
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

%% Set default input arguments
if nargin < 2
    PHYMOD = getDefaultPhysicalModels();
end

%% Initialize pressure and temperature
GN = init_p_i(GN);
GN = init_T_i(GN);

%% Compressibility factor
GN = get_Z(GN, PHYMOD);

%% Joule-Thomson Coefficient
GN = get_my_JT(GN, PHYMOD);

%% kappa
GN = get_kappa(GN, PHYMOD);

end

