function [GN] = cut_GN_res(GN, time_series_res_white_list)
%CUT_GN_RES
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


if isfield(GN,'bus')
    i_bus = strcmp(time_series_res_white_list(:,1),'bus');
    if ~all(strcmp(time_series_res_white_list(i_bus,2),'all'))
        [i_bus_column] = ~ismember(GN.bus.Properties.VariableNames,['bus_ID';time_series_res_white_list(i_bus,2)]);
        GN.bus(:,i_bus_column) = [];
    elseif all(~i_bus)
        GN = rmfield(GN,'bus');
    end
end

if isfield(GN,'pipe')
    i_pipe = strcmp(time_series_res_white_list(:,1),'pipe');
    if ~all(strcmp(time_series_res_white_list(i_pipe,2),'all'))
        [i_pipe_column] = ~ismember(GN.pipe.Properties.VariableNames,['pipe_ID';time_series_res_white_list(i_pipe,2)]);
        GN.pipe(:,i_pipe_column) = [];
    elseif all(~i_pipe)
        GN = rmfield(GN,'pipe');
    end
end

if isfield(GN,'comp')
    i_comp = strcmp(time_series_res_white_list(:,1),'comp');
    if ~all(strcmp(time_series_res_white_list(i_comp,2),'all'))
        [i_comp_column] = ~ismember(GN.comp.Properties.VariableNames,['comp_ID';time_series_res_white_list(i_comp,2)]);
        GN.comp(:,i_comp_column) = [];
    elseif all(~i_comp)
        GN = rmfield(GN,'comp');
    end
end

if isfield(GN,'prs')
    i_prs = strcmp(time_series_res_white_list(:,1),'prs');
    if ~all(strcmp(time_series_res_white_list(i_prs,2),'all'))
        [i_prs_column] = ~ismember(GN.prs.Properties.VariableNames,['prs_ID';time_series_res_white_list(i_prs,2)]);
        GN.prs(:,i_prs_column) = [];
    elseif all(~i_prs)
        GN = rmfield(GN,'prs');
    end
end

if isfield(GN,'valve')
    i_valve = strcmp(time_series_res_white_list(:,1),'valve');
    if ~all(strcmp(time_series_res_white_list(i_valve,2),'all'))
        [i_valve_column] = ~ismember(GN.valve.Properties.VariableNames,['valve_ID';time_series_res_white_list(i_valve,2)]);
        GN.valve(:,i_valve_column) = [];
    elseif all(~i_valve)
        GN = rmfield(GN,'valve');
    end
end

if isfield(GN,'branch')
    i_branch = strcmp(time_series_res_white_list(:,1),'branch');
    if ~all(strcmp(time_series_res_white_list(i_branch,2),'all'))
        [i_branch_column] = ~ismember(GN.branch.Properties.VariableNames,['branch_ID';time_series_res_white_list(i_branch,2)]);
        GN.branch(:,i_branch_column) = [];
    elseif all(~i_branch)
        GN = rmfield(GN,'branch');
    end
end

if isfield(GN,'gasMix')
    is_gasMix = strcmp(time_series_res_white_list(:,1),'gasMix');
    if ~any(is_gasMix)
        GN = rmfield(GN,'gasMix');
    end
end

if isfield(GN,'gasMixProp')
    is_gasMixProp = strcmp(time_series_res_white_list(:,1),'gasMixProp');
    if ~any(is_gasMixProp)
        GN = rmfield(GN,'gasMixProp');
    end
end

if isfield(GN,'gasMixAndCompoProp')
    i_gasMixAndCompoProp = strcmp(time_series_res_white_list(:,1),'gasMixAndCompoProp');
    if ~all(strcmp(time_series_res_white_list(i_gasMixAndCompoProp,2),'all'))
        [i_gasMixAndCompoProp_column] = ~ismember(GN.gasMixAndCompoProp.Properties.VariableNames,time_series_res_white_list(i_gasMixAndCompoProp,2));
        GN.gasMixAndCompoProp(:,i_gasMixAndCompoProp_column) = [];
    elseif all(~i_gasMixAndCompoProp)
        GN = rmfield(GN,'gasMixAndCompoProp');
    end
end

if isfield(GN,'T_env')
    is_T_env = strcmp(time_series_res_white_list(:,1),'T_env');
    if ~any(is_T_env)
        GN = rmfield(GN,'T_env');
    end
end

if isfield(GN,'isothermal')
    is_isothermal = strcmp(time_series_res_white_list(:,1),'isothermal');
    if ~any(is_isothermal)
        GN = rmfield(GN,'isothermal');
    end
end

if isfield(GN,'MAT')
    is_MAT = strcmp(time_series_res_white_list(:,1),'MAT');
    if ~any(is_MAT)
        GN = rmfield(GN,'MAT');
    end
end

if isfield(GN,'time_series')
    is_time_series = strcmp(time_series_res_white_list(:,1),'time_series');
    if ~any(is_time_series)
        GN = rmfield(GN,'time_series');
    end
end

if isfield(GN,'name')
    is_name = strcmp(time_series_res_white_list(:,1),'name');
    if ~any(is_name)
        GN = rmfield(GN,'name');
    end
end

if isfield(GN,'time_series_struct')
    is_time_series_struct = strcmp(time_series_res_white_list(:,1),'time_series_struct');
    if ~any(is_time_series_struct)
        GN = rmfield(GN,'time_series_struct');
    end
end

end

