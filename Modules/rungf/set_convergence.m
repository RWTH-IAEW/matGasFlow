function [GN] = set_convergence(GN, tag)
%SET_CONVERGENCE
%
%   Saves f, V_dot_n_ij, p_i and  T_i in the struct GN.CONVERGENCE
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
<<<<<<< HEAD
%   Copyright (c) 2020-2022, High Voltage Equipment and Grids,
=======
%   Copyright (c) 2020-2021, High Voltage Equipment and Grids,
>>>>>>> Merge to public repo (#1)
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~isfield(GN,'CONVERGENCE')
    GN.CONVERGENCE.f   = [];
    GN.CONVERGENCE.V_dot_n_ij = [];
    GN.CONVERGENCE.p_i = [];
    GN.CONVERGENCE.T_i = [];
    GN.CONVERGENCE.tag = {};
end

GN.CONVERGENCE.f{end+1}            = GN.bus.f;
GN.CONVERGENCE.V_dot_n_ij{end+1}   = GN.branch.V_dot_n_ij;
GN.CONVERGENCE.p_i{end+1}          = GN.bus.p_i;
GN.CONVERGENCE.T_i{end+1}          = GN.bus.T_i;
GN.CONVERGENCE.tag{end+1}          = {tag};

end

