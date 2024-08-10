function [GN] = get_p_ij(GN)
%GET_P_IJ
%
%   Average pressure p_ij [Pa] in a pipe:
%
%               p_i^2 + p_i*p_j + p_j^2
%       p_ij =  -----------------------
%                  1.5*(p_i + p_j)
%
%   Reference: [Mischner 2015] S.441, Gl.30.13
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~isfield(GN,'pipe')
    return
end

iF  = GN.branch.i_from_bus(GN.pipe.i_branch);
iT  = GN.branch.i_to_bus(GN.pipe.i_branch);
p_F = GN.bus.p_i(iF);
p_T = GN.bus.p_i(iT);
GN.pipe.p_ij = (p_F.^2 + p_F.*p_T + p_T.^2) ./ (1.5 * (p_F+p_T));

end

