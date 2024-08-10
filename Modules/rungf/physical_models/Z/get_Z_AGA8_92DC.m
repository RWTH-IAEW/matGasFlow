function [GN] = get_Z_AGA8_92DC(GN, object, NUMPARAM)
%GET_Z_AGA8_92DC
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Variabels
p       = [];
T       = [];
Z_input = [];

%% Read AGA8_92DC_tables.xlsx
if ~isfield(GN,'AGA8_92DC_tables')
    GN = get_AGA8_92DC_tables(GN);
end

%% gasMixProp
if isfield(GN,'gasMixProp') && any(ismember({'gasMixProp','all'},object)) && ~strcmp(GN.gasMixProp.PHYMOD,'standard conditions')
    CONST = getConstants();
    [GN.gasMixProp.Z_n_avg]     = calculate_Z_AGA8_92DC(CONST.p_n, CONST.T_n, 1, GN.AGA8_92DC_tables, NUMPARAM);
    GN.gasMixProp.V_m_n_avg     = GN.gasMixProp.Z_n_avg/CONST.p_n*CONST.R_m*CONST.T_n;
    GN.gasMixProp.rho_n_avg     = GN.gasMixProp.M_avg / GN.gasMixProp.V_m_n_avg;
    GN.gasMixProp.PHYMOD        = 'AGA8_92DC';
end

%% bus
if any(ismember({'bus','all'},object))
    p = [p; GN.bus.p_i];
    T = [T; GN.bus.T_i];
    try
        Z_input = [Z_input; GN.bus.Z_i];
    catch
        Z_input = [Z_input; ones(height(GN.bus),1)];
    end
end

%% pipe
if isfield(GN,'pipe') && any(ismember({'pipe','all'},object))
    p = [p; GN.pipe.p_ij];
    T = [T; GN.pipe.T_ij];
    try
        Z_input = [Z_input; GN.pipe.Z_ij];
    catch
        Z_input = [Z_input; ones(height(GN.pipe),1)];
    end
end

%% source
if any(ismember({'source','all'},object))
    p = [p; GN.bus.p_i(GN.bus.source_bus)];
    T = [T; GN.bus.T_i_source(GN.bus.source_bus)];
    if ismember('Z_i_source',GN.bus.Properties.VariableNames)
        Z_input = [Z_input; GN.bus.Z_i_source(GN.bus.source_bus)];
    else
        Z_input = [Z_input; ones(sum(GN.bus.source_bus),1)];
    end
end

%% branch
if isfield(GN,'branch') && any(ismember({'branch','all'},object))
    i_bus_out = GN.branch.i_to_bus;
    i_bus_out(GN.branch.V_dot_n_ij < 0) = GN.branch.i_from_bus(GN.branch.V_dot_n_ij < 0);
    p   = [p; GN.bus.p_i(i_bus_out)];
    T   = [T; GN.branch.T_ij_out];
    if ismember('Z_ij_out',GN.branch.Properties.VariableNames)
        Z_input = [Z_input; GN.branch.Z_ij_out];
    else
        Z_input = [Z_input; ones(height(GN.branch),1)];
    end
end

%% comp
if isfield(GN,'comp') && any(ismember({'comp','all'},object))
    p = [p; GN.comp.p_ij_mid];
    T = [T; GN.comp.T_ij_mid];
    if ismember('Z_ij_mid',GN.comp.Properties.VariableNames)
        Z_input = [Z_input; GN.comp.Z_ij_mid];
    else
        Z_input = [Z_input; ones(height(GN.comp),1)];
    end
end

%% prs
if isfield(GN,'prs') && any(ismember({'prs','all'},object))
    p = [p; GN.prs.p_ij_mid];
    T = [T; GN.prs.T_ij_mid];
    if ismember('Z_ij_mid',GN.prs.Properties.VariableNames)
        Z_input = [Z_input; GN.prs.Z_ij_mid];
    else
        Z_input = [Z_input; ones(height(GN.prs),1)];
    end
end

%% Calculate all Z values
Z = calculate_Z_AGA8_92DC(p, T, Z_input, GN.AGA8_92DC_tables, NUMPARAM);

%% Apply results
%% bus
if any(ismember({'bus','all'},object))
    n_bus = size(GN.bus,1);
    GN.bus.Z_i = Z(1:n_bus);
    Z(1:n_bus) = [];
end

%% pipe
if isfield(GN,'pipe') && any(ismember({'pipe','all'},object))
    n_pipe = size(GN.pipe,1);
    GN.pipe.Z_ij = Z(1:n_pipe);
    Z(1:n_pipe) = [];
end

%% non-isothermal
if ~GN.isothermal
    
    %% source
    if any(ismember({'source','all'},object))
        n_source = sum(GN.bus.source_bus);
        GN.bus.Z_i_source(GN.bus.source_bus) = Z(1:n_source);
        Z(1:n_source) = [];
    end
    
    %% branch
    if isfield(GN,'branch') && any(ismember({'branch','all'},object))
        n_branch = size(GN.branch,1);
        GN.branch.Z_ij_out = Z(1:n_branch);
        Z(1:n_branch) = [];
    end
    
    %% comp
    if isfield(GN,'comp') && any(ismember({'comp','all'},object))
        n_comp = size(GN.comp,1);
        GN.comp.Z_ij_mid = Z(1:n_comp);
        Z(1:n_comp) = [];
    end
    
    %% prs
    if isfield(GN,'prs') && any(ismember({'prs','all'},object))
        n_prs = size(GN.prs,1);
        GN.prs.Z_ij_mid = Z(1:n_prs);
    end
    
end

end