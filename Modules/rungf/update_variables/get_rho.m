function [GN] = get_rho(GN)
%GET_RHO_IJ Summary of this function goes here
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

% Physical constants
CONST = getConstants();

%% bus
GN.bus.rho_i  = ...
    GN.gasMixProp.rho_n_avg ...
    .* GN.bus.p_i           ./CONST.p_n ...
    .* CONST.T_n            ./GN.bus.T_i ...
    .* GN.gasMixProp.Z_n_avg./GN.bus.Z_i;


%% pipe
if isfield(GN,'pipe')
    GN.pipe.rho_ij  = ...
        GN.gasMixProp.rho_n_avg ...
        .* GN.pipe.p_ij         ./CONST.p_n ...
        .* CONST.T_n            ./GN.pipe.T_ij ...
        .* GN.gasMixProp.Z_n_avg./GN.pipe.Z_ij;
end

end

