function GN = get_GN_res_comp(GN, NUMPARAM, PHYMOD)
%GET_GN_RES_COMP Summary of this function goes here
%   Detailed explanation goes here
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2022, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Physical constants
CONST = getConstants();

%% Apply results from branch to comp
% V_dot_n_ij
GN.comp.V_dot_n_ij = GN.branch.V_dot_n_ij(GN.comp.i_branch);

% Delta p
GN.comp.delta_p_ij__bar = GN.branch.delta_p_ij__bar(GN.comp.i_branch);

%% Calculate additional results
% Calculate P_th_ij__MW, P_th_ij, V_dot_n_ij__m3_per_day, V_dot_n_ij__m3_per_h or m_dot_ij__kg_per_s
if ismember('P_th_i__MW',GN.comp.Properties.VariableNames)
    GN.comp.P_th_ij__MW                 = GN.comp.V_dot_n_ij * 1e-6 * GN.gasMixProp.H_s_n_avg;
    GN.comp.V_dot_n_ij                  = [];
    if any(GN.comp.gas_powered)
        GN.comp.P_th_i_comp__MW(GN.comp.gas_powered) = GN.comp.V_dot_n_i_comp(GN.comp.gas_powered) * 1e-6 * GN.gasMixProp.H_s_n_avg;
    end
    GN.comp.V_dot_n_i_comp              = [];
    
elseif ismember('P_th_i',GN.comp.Properties.VariableNames)
    GN.comp.P_th_ij                     = GN.comp.V_dot_n_ij * GN.gasMixProp.H_s_n_avg;
    GN.comp.V_dot_n_ij                  = [];
    GN.comp.P_th_i_comp                 = GN.comp.V_dot_n_i_comp * GN.gasMixProp.H_s_n_avg;
    GN.comp.V_dot_n_i_comp              = [];
    
elseif ismember('V_dot_n_i__m3_per_day',GN.comp.Properties.VariableNames)
    GN.comp.V_dot_n_ij__m3_per_day      = GN.comp.V_dot_n_ij * 60 * 60 * 24;
    % GN.comp.V_dot_n_ij                  = [];
    GN.comp.V_dot_n_i_comp__m3_per_day  = GN.comp.V_dot_n_i_comp * 60 * 60 * 24;
    % GN.comp.V_dot_n_i_comp              = [];
    
elseif ismember('V_dot_n_i__m3_per_h',GN.comp.Properties.VariableNames)
    GN.comp.V_dot_n_ij__m3_per_h        = GN.comp.V_dot_n_ij * 60 * 60;
    % GN.comp.V_dot_n_ij                  = [];
    GN.comp.V_dot_n_i_comp__m3_per_h    = GN.comp.V_dot_n_i_comp * 60 * 60;
    % GN.comp.V_dot_n_i_comp              = [];
    
elseif ismember('m_dot_i__kg_per_s',GN.comp.Properties.VariableNames)
    GN.comp.m_dot_ij__kg_per_s          = GN.comp.V_dot_n_ij * GN.gasMixProp.rho_n_avg;
    % GN.comp.V_dot_n_ij                  = [];
    GN.comp.m_dot_i_comp__kg_per_s      = GN.comp.V_dot_n_i_comp * GN.gasMixProp.rho_n_avg;
    % GN.comp.V_dot_n_i_comp              = [];
    
end

%% Calculate additional results
if ~(any(GN.comp.gas_powered))
    GN.comp.V_dot_n_i_comp(:) = 0;
end

if ~GN.isothermal % UNDER CONSTRUCTION
    %delta_H
    if any(~isnan(GN.comp.T_ij_out))
        GN = get_delta_H(GN,CONST);
    end
    
    %Q_dot_cooler
    if any(~isnan(GN.comp.T_ij_out))
        GN = get_Q_dot_comp(GN,PHYMOD);
        GN = get_Q_dot_comp_v2(GN,PHYMOD);
%         GN = get_Q_dot_comp_v3(GN,PHYMOD,NUMPARAM);
    end
    
    % Power needed by compressor station
    P_el_comp = zeros(length(GN.comp.comp_ID));
    P_el_cool = zeros(length(GN.comp.comp_ID));
    if any(~GN.comp.gas_powered)
        P_el_comp = abs(GN.comp.V_dot_n_i_comp(~GN.comp.gas_powered)).*GN.gasMixProp.H_s_n_avg./GN.comp.eta_drive(~GN.comp.gas_powered);
    end
    if (any(~isnan(GN.comp.Q_dot_cooler)))
        P_el_cool = abs(GN.comp.Q_dot_cooler) ./ GN.comp.eta_cooler;
    end
    GN.comp.Power_el_tot = P_el_comp + P_el_cool;
    
end

%% Check results
% Direction of V_dot_n_ij
comp_ID = GN.comp.comp_ID(GN.comp.V_dot_n_ij < -NUMPARAM.numericalTolerance & GN.comp.in_service);
if ~isempty(comp_ID)
    n_comp_wrong_direction = length(comp_ID);
    n_comp = sum(GN.comp.in_service);
    r_comp = n_comp_wrong_direction/n_comp;
    max_pressure_increase = max(GN.comp.V_dot_n_ij(GN.comp.V_dot_n_ij < -NUMPARAM.numericalTolerance & GN.comp.in_service));
    min_pressure_increase = min(GN.comp.V_dot_n_ij(GN.comp.V_dot_n_ij < -NUMPARAM.numericalTolerance & GN.comp.in_service));
    disp([num2str(n_comp_wrong_direction),...
        ' of ',num2str(n_comp),...
        ' (',num2str(r_comp),...
        ' %) compressors beeing in service have the wrong direction. Range: ',num2str(max_pressure_increase),...
        ' m^3/s ... ',num2str(min_pressure_increase), ...
        ' m^3/s.'])
end

% Compare input and output pressure
comp_ID = GN.comp.comp_ID(GN.comp.delta_p_ij__bar > NUMPARAM.numericalTolerance & GN.comp.in_service);
if ~isempty(comp_ID)
    n_comp_pressure_increase = length(comp_ID);
    n_comp = sum(GN.comp.in_service);
    r_comp = n_comp_pressure_increase/n_comp;
    max_pressure_increase = max(GN.comp.delta_p_ij__bar(GN.comp.delta_p_ij__bar > NUMPARAM.numericalTolerance & GN.comp.in_service));
    min_pressure_increase = min(GN.comp.delta_p_ij__bar(GN.comp.delta_p_ij__bar > NUMPARAM.numericalTolerance & GN.comp.in_service));
    disp([num2str(n_comp_pressure_increase),...
        ' of ',num2str(n_comp),...
        ' (',num2str(r_comp),...
        ' %) compressors beeing in service have a lower output than input pressure. Range: ',num2str(min_pressure_increase),...
        ' bar ... ',num2str(max_pressure_increase), ...
        ' bar.'])
end

end

