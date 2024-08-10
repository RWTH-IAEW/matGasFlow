function [GN,success_prs] = get_GN_res_prs(GN, NUMPARAM, PHYMOD)
%GET_GN_RES_PRS
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

success_prs = true;

%% Apply results from branch to prs
% V_dot_n_ij
GN.prs.V_dot_n_ij = GN.branch.V_dot_n_ij(GN.prs.i_branch);

% Delta p
GN.prs.Delta_p_ij__bar  = GN.branch.Delta_p_ij__bar(GN.prs.i_branch);

%% Calculate additional results
% Q_dot_heater
if ~GN.isothermal && any(GN.prs.T_controlled & ~GN.prs.gas_powered_heater)
    GN = get_Q_dot_prs(GN, NUMPARAM, PHYMOD);
end

% P_el_heater
if ~GN.isothermal
    GN.prs.P_el_heater(:)                           = NaN;
    GN.prs.P_el_heater(~GN.prs.gas_powered_heater)  = GN.prs.Q_dot_heater(~GN.prs.gas_powered_heater) ./ GN.prs.eta_heater(~GN.prs.gas_powered_heater);
    
    % Power of expansion turbine
    GN = get_P_el_exp_turbine(GN, PHYMOD);

    % alpha_heater
    P_th_ij = convert_gas_flow_quantity(GN.prs.V_dot_n_ij, 'm3_per_s', 'W', GN.gasMixProp);
    GN.prs.alpha_heater( GN.prs.gas_powered_heater) = GN.prs.Q_dot_heater(GN.prs.gas_powered_heater)./(P_th_ij( GN.prs.gas_powered_heater) + GN.prs.Q_dot_heater(GN.prs.gas_powered_heater));
    GN.prs.alpha_heater(~GN.prs.gas_powered_heater) = GN.prs.P_el_heater(~GN.prs.gas_powered_heater)./ P_th_ij(~GN.prs.gas_powered_heater);
end

%% Check results
% Direction of V_dot_n_ij
prs_ID = GN.prs.prs_ID(GN.prs.V_dot_n_ij < -NUMPARAM.numericalTolerance & GN.prs.in_service);
if ~isempty(prs_ID)
    n_prs_wrong_direction = length(prs_ID);
    n_prs = sum(GN.prs.in_service);
    r_prs = n_prs_wrong_direction/n_prs;
    max_pressure_increase = max(GN.prs.V_dot_n_ij(GN.prs.V_dot_n_ij < -NUMPARAM.numericalTolerance & GN.prs.in_service));
    min_pressure_increase = min(GN.prs.V_dot_n_ij(GN.prs.V_dot_n_ij < -NUMPARAM.numericalTolerance & GN.prs.in_service));
    warning([num2str(n_prs_wrong_direction),...
        ' of ',num2str(n_prs),...
        ' (',num2str(100*r_prs),...
        ' %) prs beeing in service have the wrong direction. Range: ',num2str(max_pressure_increase),...
        ' m^3/s ... ',num2str(min_pressure_increase), ...
        ' m^3/s.'])
    success_prs = false;
end

% Compare input and output pressure
prs_ID = GN.prs.prs_ID(GN.prs.Delta_p_ij__bar < -NUMPARAM.numericalTolerance & GN.prs.in_service);
if ~isempty(prs_ID)
    n_prs_pressure_increase = length(prs_ID);
    n_prs = sum(GN.prs.in_service);
    r_prs = n_prs_pressure_increase/n_prs;
    max_pressure_increase = max(GN.prs.Delta_p_ij__bar(GN.prs.Delta_p_ij__bar < -NUMPARAM.numericalTolerance & GN.prs.in_service));
    min_pressure_increase = min(GN.prs.Delta_p_ij__bar(GN.prs.Delta_p_ij__bar < -NUMPARAM.numericalTolerance & GN.prs.in_service));
    warning([num2str(n_prs_pressure_increase),...
        ' of ',num2str(n_prs),...
        ' (',num2str(100*r_prs),...
        ' %) prs beeing in service have a higher output than input pressure. Range: ',num2str(min_pressure_increase),...
        ' bar ... ',num2str(max_pressure_increase), ...
        ' bar.'])
    success_prs = false;
end

%% Calculate P_th_ij__MW, P_th_ij, V_dot_n_ij__m3_per_day, V_dot_n_ij__m3_per_h or m_dot_ij__kg_per_s
if ismember('P_th_i__MW',GN.bus.Properties.VariableNames)
    GN.prs.P_th_ij__MW = ...
        convert_gas_flow_quantity(GN.prs.V_dot_n_ij, ...
            'm3_per_s',    'MW',            GN.gasMixProp);
    GN.prs.V_dot_n_ij = [];
    if ~GN.isothermal && any(GN.prs.gas_powered_heater)
        GN.prs.P_th_prs_i__MW(GN.prs.gas_powered_heater) = convert_gas_flow_quantity(GN.prs.V_dot_n_i_prs(GN.prs.gas_powered_heater),...
            'm3_per_s',    'MW',            GN.gasMixProp);
        GN.prs.V_dot_n_i_prs = [];
    end
elseif ismember('P_th_i',GN.bus.Properties.VariableNames)
    GN.prs.P_th_ij = convert_gas_flow_quantity(GN.prs.V_dot_n_ij,...
            'm3_per_s',    'W',             GN.gasMixProp);
    GN.prs.V_dot_n_ij = [];
    if ~GN.isothermal && any(GN.prs.gas_powered_heater)
        GN.prs.P_th_prs_i(GN.prs.gas_powered_heater) = convert_gas_flow_quantity(GN.prs.V_dot_n_i_prs(GN.prs.gas_powered_heater),...
            'm3_per_s',    'W',             GN.gasMixProp);
        GN.prs.V_dot_n_i_prs = [];
    end
elseif ismember('V_dot_n_i__m3_per_day',GN.bus.Properties.VariableNames)
    GN.prs.V_dot_n_ij__m3_per_day = convert_gas_flow_quantity(GN.prs.V_dot_n_ij,...
            'm3_per_s',    'm3_per_day',    GN.gasMixProp);
    GN.prs.V_dot_n_ij = [];
    if ~GN.isothermal && any(GN.prs.gas_powered_heater)
        GN.prs.V_dot_n_prs_i__m3_per_day(GN.prs.gas_powered_heater) = convert_gas_flow_quantity(GN.prs.V_dot_n_i_prs(GN.prs.gas_powered_heater),...
            'm3_per_s',    'm3_per_day',    GN.gasMixProp);
        GN.prs.V_dot_n_i_prs = [];
    end
elseif ismember('V_dot_n_i__m3_per_h',GN.bus.Properties.VariableNames)
    GN.prs.V_dot_n_ij__m3_per_h = convert_gas_flow_quantity(GN.prs.V_dot_n_ij,...
            'm3_per_s',    'm3_per_h',      GN.gasMixProp);
    GN.prs.V_dot_n_ij = [];
    if ~GN.isothermal && any(GN.prs.gas_powered_heater)
        GN.prs.V_dot_n_prs_i__m3_per_h(GN.prs.gas_powered_heater) = convert_gas_flow_quantity(GN.prs.V_dot_n_i_prs(GN.prs.gas_powered_heater),...
            'm3_per_s',    'm3_per_h',      GN.gasMixProp);
        GN.prs.V_dot_n_i_prs = [];
    end
elseif ismember('m_dot_i__kg_per_s',GN.bus.Properties.VariableNames)
    GN.prs.m_dot_ij__kg_per_s = convert_gas_flow_quantity(GN.prs.V_dot_n_ij,...
            'm3_per_s',    'kg_per_s',      GN.gasMixProp);
    GN.prs.V_dot_n_ij = [];
    if ~GN.isothermal && any(GN.prs.gas_powered_heater)
        GN.prs.m_dot_prs_i__kg_per_s(GN.prs.gas_powered_heater) = convert_gas_flow_quantity(GN.prs.V_dot_n_i_prs(GN.prs.gas_powered_heater),...
            'm3_per_s',    'kg_per_s',      GN.gasMixProp);
        GN.prs.V_dot_n_i_prs = [];
    end
end

end

