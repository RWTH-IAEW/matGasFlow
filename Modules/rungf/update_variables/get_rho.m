function [GN] = get_rho(GN)
%GET_RHO
%
%   Density rho [kg/m^3] of the gas at busses and in pipes.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Physical constants
CONST = getConstants();

%% bus
GN.bus.rho_i  = GN.bus.p_i .* GN.gasMixProp.M_avg / CONST.R_m ./ GN.bus.T_i ./ GN.bus.Z_i;

%% pipe
if isfield(GN,'pipe')
    GN.pipe.rho_ij  = GN.pipe.p_ij .* GN.gasMixProp.M_avg / CONST.R_m ./ GN.pipe.T_ij ./ GN.pipe.Z_ij;
end

end

