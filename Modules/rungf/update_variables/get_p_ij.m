function [GN] = get_p_ij(GN)
%GET_P_IJ
%
%   Average pressure p_ij [Pa] in a pipe:
%
%               p_i^2 + p_i*p_j + p_j^2
%       p_ij =  -----------------------
%                  1.5*(p_i + p_j)
%
%   Reference: [MIS15] S.441, Gl.30.13
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2022, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~isfield(GN,'pipe')
    return
end

iF = GN.branch.i_from_bus(GN.pipe.i_branch);
iT = GN.branch.i_to_bus(GN.pipe.i_branch);
GN.pipe.p_ij = ...
    (GN.bus.p_i(iF).^2 + GN.bus.p_i(iF).*GN.bus.p_i(iT) + GN.bus.p_i(iT).^2) ...
    ./ (1.5 * (GN.bus.p_i(iF)+GN.bus.p_i(iT)));

end

