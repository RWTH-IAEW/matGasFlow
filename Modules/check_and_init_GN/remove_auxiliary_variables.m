function [GN] = remove_auxiliary_variables(GN)
%REMOVE_AUXILIARY_VARIABLES
%   GN = remove_auxiliary_variables(GN)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2022, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fields = {'INC', 'gasMixProp', 'branch', 'J', 'CONVERGENCE'};
idx = isfield(GN, fields);
GN = rmfield(GN, fields(idx));

%% bus
varNames = {'area_ID', 'supplied'};
idx = ismember(GN.bus.Properties.VariableNames,varNames);
GN.bus(:,idx) = [];

%% pipe
if isfield(GN,'pipe')
    varNames = {'branch_ID', 'i_branch', 'area_ID'};
    idx = ismember(GN.pipe.Properties.VariableNames,varNames);
    GN.pipe(:,idx) = [];
end

%% comp
if isfield(GN,'comp')
    varNames = {'branch_ID', 'i_branch'};
    idx = ismember(GN.comp.Properties.VariableNames,varNames);
    GN.comp(:,idx) = [];
end

%% prs
if isfield(GN, 'prs')
    varNames = {'branch_ID', 'i_branch'};
    idx = ismember(GN.prs.Properties.VariableNames,varNames);
    GN.prs(:,idx) = [];
end

%% valve
if isfield(GN, 'valve')
    varNames = {'branch_ID', 'i_branch'};
    idx = ismember(GN.valve.Properties.VariableNames,varNames);
    GN.valve(:,idx) = [];
end

end

