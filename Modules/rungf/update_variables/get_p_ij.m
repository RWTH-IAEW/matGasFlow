function [GN] = get_p_ij(GN)
%GET_P_IJ
%
<<<<<<< HEAD
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
=======
%   Average pressure p_ij [Pa] in a pipe
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2021, High Voltage Equipment and Grids,
>>>>>>> Merge to public repo (#1)
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

<<<<<<< HEAD
=======
%% [MIS15] Gl.30.13
% GN.pipe.p_ij(GN.branch.branchType == 1) = NaN;
% Reference: [MIS15] S.441 ff.
>>>>>>> Merge to public repo (#1)
if isfield(GN,'pipe')
    iF = GN.branch.i_from_bus(GN.branch.pipe_branch);
    iT = GN.branch.i_to_bus(GN.branch.pipe_branch);
    p_ij = ...
        (GN.bus.p_i(iF).^2 + GN.bus.p_i(iF).*GN.bus.p_i(iT) + GN.bus.p_i(iT).^2) ...
        ./ (1.5 * (GN.bus.p_i(iF)+GN.bus.p_i(iT)));
    GN.pipe.p_ij = p_ij(GN.branch.i_pipe(GN.branch.pipe_branch));
end

<<<<<<< HEAD
end

=======
>>>>>>> Merge to public repo (#1)
