function [GN] = get_Z_RedlichKwongSoave(GN, object)
%GET_Z_REDLICHKWONGSOAVE
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

%% intitialize p, T
p = [];
T = [];

%% gasMixProp
if isfield(GN,'gasMixProp') && any(ismember({'gasMixProp','all'},object)) && ~strcmp(GN.gasMixProp.PHYMOD,'standard conditions')
    CONST = getConstants();
    [GN.gasMixProp.Z_n_avg, GN.gasMixProp.V_m_n_avg] = calculate_Z_RedlichKwongSoave(CONST.p_n, CONST.T_n, GN.gasMixAndCompoProp);
    GN.gasMixProp.rho_n_avg     = GN.gasMixProp.M_avg / GN.gasMixProp.V_m_n_avg;
    GN.gasMixProp.PHYMOD        = 'VanDerWaals';
end

%% bus
if any(ismember({'bus','all'},object))
    p = [p; GN.bus.p_i];
    T = [T; GN.bus.T_i];
end

%% pipe
if isfield(GN,'pipe') && any(ismember({'pipe','all'},object))
    p = [p; GN.pipe.p_ij];
    T = [T; GN.pipe.T_ij];
end

%% non-isothermal
if ~GN.isothermal
    
    %% source
    if any(ismember({'source','all'},object))
        p = [p; GN.bus.p_i(GN.bus.source_bus)];
        T = [T; GN.bus.T_i_source(GN.bus.source_bus)];
    end
    
    %% branch
    if isfield(GN,'branch') && any(ismember({'branch','all'},object))
        i_bus_out = GN.branch.i_to_bus;
        i_bus_out(GN.branch.V_dot_n_ij < 0) = GN.branch.i_from_bus(GN.branch.V_dot_n_ij < 0);
        p   = [p; GN.bus.p_i(i_bus_out)];
        T   = [T; GN.branch.T_ij_out];
    end
    
    %% comp
    if isfield(GN,'comp') && any(ismember({'comp','all'},object))
        p = [p; GN.comp.p_ij_mid];
        T = [T; GN.comp.T_ij_mid];
    end
    
    %% prs
    if isfield(GN,'prs') && any(ismember({'prs','all'},object))
        p = [p; GN.prs.p_ij_mid];
        T = [T; GN.prs.T_ij_mid];
    end
    
end

%% Calculate all Z values
if ~isempty(p)
    [Z, ~, V_m_2, V_m_3] = calculate_Z_RedlichKwongSoave(p, T, GN.gasMixAndCompoProp);
    % [p_iso, V_m_liquid, V_m_vapor] = get_pV_vaporLiquid_RedlichKwongsoave(T,
    % p, GN.gasMixProp.T_pc, GN.gasMixProp.p_pc, GN.gasMixAndCompoProp); % TODO
end

%% Apply results
%% bus
if any(ismember({'bus','all'},object))
    n_bus = size(GN.bus,1);
    GN.bus.Z_i          = Z(1:n_bus);
    GN.bus.V_m_i_2      = V_m_2(1:n_bus);
    GN.bus.V_m_i_3      = V_m_3(1:n_bus);
    % GN.bus.p_iso        = p_iso(1:n_bus);
    % GN.bus.V_m_liquid   = V_m_liquid(1:n_bus);
    % GN.bus.V_m_vapor    = V_m_vapor(1:n_bus);
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
    if any(ismember({'source','all'},object)) && any(GN.bus.source_bus)
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