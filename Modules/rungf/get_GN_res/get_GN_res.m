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
if nargin < 5
    PHYMOD = getDefaultPhysicalModels();

    if nargin < 4
        NUMPARAM = getDefaultNumericalParameters();

        if nargin < 3
            flag_remove_auxiliary_variables = false;
            
            if nargin < 2
                GN_input = GN;
            end
        end
    end
end

%% GN plausibility check
if ~ismember('V_dot_n_ij',GN.branch.Properties.VariableNames)
    error('GN is no GN result struct. GN.branch.V_dot_n_ij is missing.')
end

%% Merge GN into GN_input
GN = merge_GN_into_GN_input(GN, GN_input);

%% Get GN results
% 1) Apply results from branch to pipe, comp, prs and valve
% 2) Calculate additional results
% 3) Check results

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

