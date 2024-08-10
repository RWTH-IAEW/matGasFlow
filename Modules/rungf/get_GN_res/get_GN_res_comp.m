function [GN,success_comp] = get_GN_res_comp(GN, NUMPARAM, PHYMOD)
%GET_GN_RES_COMP
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

success_comp = true;

%% Apply results from branch to comp
% V_dot_n_ij
GN.comp.V_dot_n_ij = GN.branch.V_dot_n_ij(GN.comp.i_branch);

% Delta p
GN.comp.Delta_p_ij__bar = GN.branch.Delta_p_ij__bar(GN.comp.i_branch);

%% Calculate additional results
% Power of compressor drive [W]
GN = get_P_drive_comp(GN, PHYMOD);

% T_ij_mid [K], Q_dot_cooler [W]
if ~GN.isothermal && any(GN.comp.T_controlled)
    GN = get_Q_dot_comp(GN, NUMPARAM, PHYMOD);

    % P_el_cooler [W]
    GN.comp.P_el_cooler = GN.comp.eta_cooler .* -GN.comp.Q_dot_cooler;
end

% alpha_comp
P_th_ij = convert_gas_flow_quantity(GN.comp.V_dot_n_ij, 'm3_per_s', 'W', GN.gasMixProp);
GN.comp.alpha_comp( GN.comp.gas_powered) = GN.comp.P_drive( GN.comp.gas_powered)./(P_th_ij( GN.comp.gas_powered) + GN.comp.P_drive(GN.comp.gas_powered));
GN.comp.alpha_comp(~GN.comp.gas_powered) = GN.comp.P_drive(~GN.comp.gas_powered)./ P_th_ij(~GN.comp.gas_powered);

% alpha_cooler
GN.comp.alpha_cooler = GN.comp.Q_dot_cooler./P_th_ij;

%% Check results
% Direction of V_dot_n_ij
comp_ID = GN.comp.comp_ID(GN.comp.V_dot_n_ij < -NUMPARAM.numericalTolerance & GN.comp.in_service);
if ~isempty(comp_ID)
    n_comp_wrong_direction = length(comp_ID);
    n_comp = sum(GN.comp.in_service);
    r_comp = n_comp_wrong_direction/n_comp;
    max_pressure_increase = max(GN.comp.V_dot_n_ij(GN.comp.V_dot_n_ij < -NUMPARAM.numericalTolerance & GN.comp.in_service));
    min_pressure_increase = min(GN.comp.V_dot_n_ij(GN.comp.V_dot_n_ij < -NUMPARAM.numericalTolerance & GN.comp.in_service));
    warning([num2str(n_comp_wrong_direction),...
        ' of ',num2str(n_comp),...
        ' (',num2str(100*r_comp),...
        ' %) compressors beeing in service have the wrong direction. Range: ',num2str(max_pressure_increase),...
        ' m^3/s ... ',num2str(min_pressure_increase), ...
        ' m^3/s.'])
    success_comp = false;
end

% Compare input and output pressure
comp_ID = GN.comp.comp_ID(GN.comp.Delta_p_ij__bar > NUMPARAM.numericalTolerance & GN.comp.in_service);
if ~isempty(comp_ID)
    n_comp_pressure_increase = length(comp_ID);
    n_comp = sum(GN.comp.in_service);
    r_comp = n_comp_pressure_increase/n_comp;
    max_pressure_increase = max(GN.comp.Delta_p_ij__bar(GN.comp.Delta_p_ij__bar > NUMPARAM.numericalTolerance & GN.comp.in_service));
    min_pressure_increase = min(GN.comp.Delta_p_ij__bar(GN.comp.Delta_p_ij__bar > NUMPARAM.numericalTolerance & GN.comp.in_service));
    warning([num2str(n_comp_pressure_increase),...
        ' of ',num2str(n_comp),...
        ' (',num2str(100*r_comp),...
        ' %) compressors beeing in service have a lower output than input pressure. Range: ',num2str(min_pressure_increase),...
        ' bar ... ',num2str(max_pressure_increase), ...
        ' bar.'])
    success_comp = false;
end

%% Calculate P_th_ij__MW, P_th_ij, V_dot_n_ij__m3_per_day, V_dot_n_ij__m3_per_h or m_dot_ij__kg_per_s
if ismember('P_th_i__MW',GN.bus.Properties.VariableNames)
    GN.comp.P_th_ij__MW = ...
        convert_gas_flow_quantity(GN.comp.V_dot_n_ij, ...
            'm3_per_s',    'MW',            GN.gasMixProp);
    GN.comp.V_dot_n_ij = [];
    if any(GN.comp.gas_powered)
        GN.comp.P_th_comp_i__MW(GN.comp.gas_powered) = convert_gas_flow_quantity(GN.comp.V_dot_n_i_comp(GN.comp.gas_powered),...
            'm3_per_s',    'MW',            GN.gasMixProp);
        GN.comp.V_dot_n_i_comp = [];
    end
elseif ismember('P_th_i',GN.bus.Properties.VariableNames)
    GN.comp.P_th_ij = convert_gas_flow_quantity(GN.comp.V_dot_n_ij,...
            'm3_per_s',    'W',             GN.gasMixProp);
    GN.comp.V_dot_n_ij = [];
    if any(GN.comp.gas_powered)
        GN.comp.P_th_comp_i(GN.comp.gas_powered) = convert_gas_flow_quantity(GN.comp.V_dot_n_i_comp(GN.comp.gas_powered),...
            'm3_per_s',    'W',             GN.gasMixProp);
        GN.comp.V_dot_n_i_comp = [];
    end
elseif ismember('V_dot_n_i__m3_per_day',GN.bus.Properties.VariableNames)
    GN.comp.V_dot_n_ij__m3_per_day = convert_gas_flow_quantity(GN.comp.V_dot_n_ij,...
            'm3_per_s',    'm3_per_day',    GN.gasMixProp);
    GN.comp.V_dot_n_ij = [];
    if any(GN.comp.gas_powered)
        GN.comp.V_dot_n_comp_i__m3_per_day(GN.comp.gas_powered) = convert_gas_flow_quantity(GN.comp.V_dot_n_i_comp(GN.comp.gas_powered),...
            'm3_per_s',    'm3_per_day',    GN.gasMixProp);
        GN.comp.V_dot_n_i_comp = [];
    end
elseif ismember('V_dot_n_i__m3_per_h',GN.bus.Properties.VariableNames)
    GN.comp.V_dot_n_ij__m3_per_h = convert_gas_flow_quantity(GN.comp.V_dot_n_ij,...
            'm3_per_s',    'm3_per_h',      GN.gasMixProp);
    GN.comp.V_dot_n_ij = [];
    if any(GN.comp.gas_powered)
        GN.comp.V_dot_n_comp_i__m3_per_h(GN.comp.gas_powered) = convert_gas_flow_quantity(GN.comp.V_dot_n_i_comp(GN.comp.gas_powered),...
            'm3_per_s',    'm3_per_h',      GN.gasMixProp);
        GN.comp.V_dot_n_i_comp = [];
    end
elseif ismember('m_dot_i__kg_per_s',GN.bus.Properties.VariableNames)
    GN.comp.m_dot_ij__kg_per_s = convert_gas_flow_quantity(GN.comp.V_dot_n_ij,...
            'm3_per_s',    'kg_per_s',      GN.gasMixProp);
    GN.comp.V_dot_n_ij = [];
    if any(GN.comp.gas_powered)
        GN.comp.m_dot_comp_i__kg_per_s(GN.comp.gas_powered) = convert_gas_flow_quantity(GN.comp.V_dot_n_i_comp(GN.comp.gas_powered),...
            'm3_per_s',    'kg_per_s',      GN.gasMixProp);
        GN.comp.V_dot_n_i_comp = [];
    end
end

end

