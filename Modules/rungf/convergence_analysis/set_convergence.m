function [GN] = set_convergence(GN, tag)
%SET_CONVERGENCE
%
%   Saves f, V_dot_n_ij, p_i and  T_i in the struct GN.CONVERGENCE
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~isfield(GN,'CONVERGENCE')
    GN.CONVERGENCE.f   = [];
    GN.CONVERGENCE.V_dot_n_ij = [];
    GN.CONVERGENCE.p_i = [];
    GN.CONVERGENCE.T_i = [];
    GN.CONVERGENCE.tag = {};
end

if ismember('f',GN.bus.Properties.VariableNames)
    GN.CONVERGENCE.f{end+1}             = GN.bus.f;
else
    GN.CONVERGENCE.f{end+1}             = NaN;
end
if ismember('V_dot_n_ij',GN.branch.Properties.VariableNames)
    GN.CONVERGENCE.V_dot_n_ij{end+1}    = GN.branch.V_dot_n_ij;
else
    GN.CONVERGENCE.V_dot_n_ij{end+1}    = NaN;
end
GN.CONVERGENCE.p_i{end+1}               = GN.bus.p_i;
GN.CONVERGENCE.T_i{end+1}               = GN.bus.T_i;
GN.CONVERGENCE.tag{end+1}               = {tag};

if size(GN.CONVERGENCE.tag,1) == 1
    GN.CONVERGENCE.tag = GN.CONVERGENCE.tag';
end

end

