function [GN,success] = get_GN_res(GN, GN_input, remove_auxiliary_variables, NUMPARAM, PHYMOD)
%GET_GN_RESULT Result preparation
%   GN = get_GN_res(GN, NUMPARAM, PHYMOD)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

success = true;

%% Set default input arguments
if nargin < 5 || isempty(PHYMOD)
    PHYMOD = getDefaultPhysicalModels();
end
if nargin < 4 || isempty(NUMPARAM)
    NUMPARAM = getDefaultNumericalParameters();
end
if nargin < 3 || isempty(remove_auxiliary_variables)
    remove_auxiliary_variables = false;
end
if nargin < 2
    GN_input = [];
end

%% GN plausibility check
if ~ismember('V_dot_n_ij',GN.branch.Properties.VariableNames)
    error('GN is no GN result struct. GN.branch.V_dot_n_ij is missing.')
end

%% p_i
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
GN.branch.Delta_p_ij__bar = GN.bus.p_i__barg(GN.branch.i_from_bus) - GN.bus.p_i__barg(GN.branch.i_to_bus);

if GN.success
    %% pipe
    if isfield(GN,'pipe')
        GN = get_GN_res_pipe(GN);
    end
    
    %% comp
    if isfield(GN,'comp')
        [GN,success] = get_GN_res_comp(GN, NUMPARAM, PHYMOD);
    end
    
    %% prs
    if isfield(GN,'prs')
        [GN,success] = get_GN_res_prs(GN, NUMPARAM, PHYMOD);
    end
    
    %% valve
    if isfield(GN,'valve')
        GN = get_GN_res_valve(GN, NUMPARAM);
    end
end

%% Merge GN into GN_input
if ~isempty(GN_input)
    GN = merge_GN_into_GN_input(GN, GN_input);
end

%% Remove Pa-pressure values bus
GN.bus.p_i = [];
if isfield(GN,'pipe')
    GN.pipe.p_ij = [];
end

%% Remove auxiliary variables
if remove_auxiliary_variables
    GN = remove_auxiliary_variables(GN);
end

end

