function [GN] = get_T_ij(GN)
%GET_T_IJ
%
%   Average temperature of the gas in pipe.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2022, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if isfield(GN,'pipe')
    iF = GN.branch.i_from_bus(GN.branch.pipe_branch);
    iT = GN.branch.i_to_bus(GN.branch.pipe_branch);
    T_ij = mean([GN.bus.T_i(iF),GN.bus.T_i(iT)],2);
    GN.pipe.T_ij = T_ij(GN.pipe.i_branch);
end

end

