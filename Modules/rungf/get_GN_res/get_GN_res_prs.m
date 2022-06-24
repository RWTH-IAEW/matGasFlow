function GN = get_GN_res_prs(GN, NUMPARAM, PHYMOD)
%GET_GN_RES_PRS Summary of this function goes here
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

%% Apply results from branch to prs
% V_dot_n_ij
GN.prs.V_dot_n_ij = GN.branch.V_dot_n_ij(GN.prs.i_branch);

% Delta p
GN.prs.delta_p_ij__bar  = GN.branch.delta_p_ij__bar(GN.prs.i_branch);

%% Calculate additional results
% Power of expansion turbine
GN = get_P_el_exp_turbine(GN, PHYMOD);

% Calculate P_th_ij__MW, P_th_ij, V_dot_n_ij__m3_per_day,
%   V_dot_n_ij__m3_per_h or m_dot_ij__kg_per_s
if ismember('P_th_i__MW',GN.bus.Properties.VariableNames)
    GN.prs.P_th_ij__MW              = GN.prs.V_dot_n_ij * 1e-6 * GN.gasMixProp.H_s_n_avg;
    % GN.prs.V_dot_n_ij               = [];
    
elseif ismember('P_th_i',GN.bus.Properties.VariableNames)
    GN.prs.P_th_ij                  = GN.prs.V_dot_n_ij * GN.gasMixProp.H_s_n_avg;
    % GN.prs.V_dot_n_ij               = [];
    
elseif ismember('V_dot_n_i__m3_per_day',GN.bus.Properties.VariableNames)
    GN.prs.V_dot_n_ij__m3_per_day   = GN.prs.V_dot_n_ij * 60 * 60 * 24;
    % GN.prs.V_dot_n_ij               = [];
    
elseif ismember('V_dot_n_i__m3_per_h',GN.bus.Properties.VariableNames)
    GN.prs.V_dot_n_ij__m3_per_h     = GN.prs.V_dot_n_ij * 60 * 60;
    % GN.prs.V_dot_n_ij               = [];
    
elseif ismember('m_dot_i__kg_per_s',GN.bus.Properties.VariableNames)
    GN.prs.m_dot_ij__kg_per_s       = GN.prs.V_dot_n_ij * GN.gasMixProp.rho_n_avg;
    % GN.prs.V_dot_n_ij               = [];
    
end

if ~GN.isothermal % UNDER CONSTRUCTION
    %Q_dot_heater_cooler
    if any(GN.prs.T_controlled)
        GN = get_Q_dot_prs(GN, PHYMOD);
    end
    
    if any(~isnan(GN.prs.Q_dot_heater_cooler))
        % Power needed by heater or cooler
        P_el_heater = zeros(length(GN.prs.prs_ID));
        P_el_cooler = zeros(length(GN.prs.prs_ID));
        GN.prs.P_el_heater_cooler(:)=0;
        
        if any(~GN.prs.gas_powered_heater_cooler)
            
            id_electrical_heater_cooler = find(~GN.prs.gas_powered_heater_cooler);
            id_heater_temp = find(GN.prs.Q_dot_heater_cooler>0);
            id_cooler_temp = find(GN.prs.Q_dot_heater_cooler<0);
            id_heater = id_heater_temp(ismember(id_heater_temp,id_electrical_heater_cooler));
            id_cooler = id_cooler_temp(ismember(id_cooler_temp,id_electrical_heater_cooler));
            
            P_el_heater(id_heater) = abs(GN.prs.Q_dot_heater_cooler(id_heater)).*GN.prs.eta_heat(id_heater);
            P_el_cooler(id_cooler) = abs(GN.prs.Q_dot_heater_cooler(id_cooler)).*GN.prs.eta_cooler(id_cooler);
            
            GN.prs.P_el_heater_cooler = P_el_heater+P_el_cooler;
        end
    end
    
    if any(GN.prs.exp_turbine)
        % Entire Power of the Station
        GN.prs.P_el_tot = GN.prs.P_el_exp_turbine + GN.prs.P_el_heater_cooler;
    end
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
    disp([num2str(n_prs_wrong_direction),...
        ' of ',num2str(n_prs),...
        ' (',num2str(r_prs),...
        ' %) prs beeing in service have the wrong direction. Range: ',num2str(max_pressure_increase),...
        ' m^3/s ... ',num2str(min_pressure_increase), ...
        ' m^3/s.'])
end

% Compare input and output pressure
prs_ID = GN.prs.prs_ID(GN.prs.delta_p_ij__bar < -NUMPARAM.numericalTolerance & GN.prs.in_service);
if ~isempty(prs_ID)
    n_prs_pressure_increase = length(prs_ID);
    n_prs = sum(GN.prs.in_service);
    r_prs = n_prs_pressure_increase/n_prs;
    max_pressure_increase = max(GN.prs.delta_p_ij__bar(GN.prs.delta_p_ij__bar < -NUMPARAM.numericalTolerance & GN.prs.in_service));
    min_pressure_increase = min(GN.prs.delta_p_ij__bar(GN.prs.delta_p_ij__bar < -NUMPARAM.numericalTolerance & GN.prs.in_service));
    disp([num2str(n_prs_pressure_increase),...
        ' of ',num2str(n_prs),...
        ' (',num2str(r_prs),...
        ' %) prs beeing in service have a higher output than input pressure. Range: ',num2str(min_pressure_increase),...
        ' bar ... ',num2str(max_pressure_increase), ...
        ' bar.'])
end

end

