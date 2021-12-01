function [Re_ij] = get_Re(GN)
%GET_RE Summary of this function goes here
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

% Pipeline or Heater_Cooler
V_dot_n_ij = GN.branch.V_dot_n_ij(GN.pipe.i_branch);
Re_ij = ...
    4*abs(V_dot_n_ij) .* GN.gasMixProp.rho_n_avg ...
    ./(pi*GN.pipe.D_ij.*GN.pipe.eta_ij);

end