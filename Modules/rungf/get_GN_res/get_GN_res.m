function [GN] = get_GN_res(GN, GN_input, flag_remove_auxiliary_variables, NUMPARAM, PHYMOD)
%GET_GN_RESULT Result preparation
%   GN = get_GN_res(GN, NUMPARAM, PHYMOD)
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
if nargin < 5 || isempty(PHYMOD)
    PHYMOD = getDefaultPhysicalModels();
end
if nargin < 4 || isempty(NUMPARAM)
    NUMPARAM = getDefaultNumericalParameters();
end
if nargin < 3 || isempty(flag_remove_auxiliary_variables)
    flag_remove_auxiliary_variables = false;
end
if nargin < 2
    GN_input = [];
end

%% GN plausibility check
if ~ismember('V_dot_n_ij',GN.branch.Properties.VariableNames)
    error('GN is no GN result struct. GN.branch.V_dot_n_ij is missing.')
end

%% Merge GN into GN_input
if ~isempty(GN_input)
    GN = merge_GN_into_GN_input(GN, GN_input);
end

%%
if ~ismember('p_i', GN.bus.Properties.VariableNames)
    CONST = getConstants;
    GN.bus.p_i = GN.bus.p_i__barg * 1e5 + CONST.p_n;
end
if isfield(GN, 'pipe') && ~ismember('p_ij', GN.pipe.Properties.VariableNames)
    GN = get_p_ij(GN);
end

%% bus
GN = get_GN_res_bus(GN);

%% branch
GN.branch.delta_p_ij__bar = GN.bus.p_i__barg(GN.branch.i_from_bus) - GN.bus.p_i__barg(GN.branch.i_to_bus);

%% pipe
if isfield(GN,'pipe')
    GN = get_GN_res_pipe(GN);
end

%% comp
if isfield(GN,'comp')
    GN = get_GN_res_comp(GN, NUMPARAM, PHYMOD);
end

%% prs
if isfield(GN,'prs')
    GN = get_GN_res_prs(GN, NUMPARAM, PHYMOD);
end

%% valve
if isfield(GN,'valve')
    GN = get_GN_res_valve(GN);
end

%% bus
GN.bus.p_i = [];

%% Remove auxiliary variables
if flag_remove_auxiliary_variables
    GN = remove_auxiliary_variables(GN);
end

end

