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
i_prs = GN.branch.i_prs(GN.branch.prs_branch);
GN.prs.V_dot_n_ij(i_prs) = ...
    GN.branch.V_dot_n_ij(GN.branch.prs_branch);

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
prs_ID = GN.prs.prs_ID(GN.prs.V_dot_n_ij < -NUMPARAM.numericalTolerance);
if ~isempty(prs_ID)
    warning(['The volume flows at these pressure gegulator stations have the wrong direction, prs_ID: ',num2str(prs_ID')])
end

% Compare input and output pressure
i_from_bus  = GN.branch.i_from_bus(GN.branch.prs_branch);
i_to_bus    = GN.branch.i_to_bus(GN.branch.prs_branch);
p_i         = GN.bus.p_i(i_from_bus);
p_j         = GN.bus.p_i(i_to_bus);
delta_p     = p_i - p_j;
prs_ID      = GN.prs.prs_ID(delta_p < -NUMPARAM.numericalTolerance & GN.prs.in_service);
if ~isempty(prs_ID)
    if length(prs_ID)/sum(GN.branch.prs_branch & GN.branch.in_service) < 0.02
        warning(['Output pressure is smaler than input pressure at these prs_IDs: ',num2str(prs_ID')])
    else
        warning(['At ',num2str(length(prs_ID)),' of ',num2str(sum(GN.branch.prs_branch & GN.branch.in_service)),' prs, output pressure is smaler than input pressure.'])
    end
end

end

