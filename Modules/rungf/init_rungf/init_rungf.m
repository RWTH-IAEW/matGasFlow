function [GN] = init_rungf(GN, PHYMOD)
%INITRUNGFSTARTSOLUTION Summary of this function goes here
%   Detailed explanation goes here
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2021, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Check if GN is initialized
if ~isfield(GN,'INC')
    GN = check_and_init_GN(GN);
end

%% Remove ...
% Remove branches that are out of service and unsupplied busses
GN = remove_unsupplied_areas(GN);

% Remove valves
try
%     GN = remove_valves(GN);
catch
end

%% Reset CONVERGENCE
if isfield(GN,'CONVERGENCE')
    GN = rmfield(GN,'CONVERGENCE');
end

%% p_i
% Physical constants
CONST = getConstants();

% p_i [Pa]
GN.bus.p_i = GN.bus.p_i__barg*1e5 + CONST.p_n;
GN.bus = movevars(GN.bus, 'p_i', 'After', 'p_i__barg');

%% V_dot_n_i
if any(strcmp('P_th_i__MW',GN.bus.Properties.VariableNames))
    GN.bus.V_dot_n_i(~isnan(GN.bus.P_th_i__MW)) = GN.bus.P_th_i__MW(~isnan(GN.bus.P_th_i__MW)) * 1e6 / GN.gasMixProp.H_s_n_avg; % [MW]*1e6/[Ws/m^3] = [m^3/s]
elseif any(strcmp('P_th_i',GN.bus.Properties.VariableNames))
    GN.bus.V_dot_n_i(~isnan(GN.bus.P_th_i)) = GN.bus.P_th_i(~isnan(GN.bus.P_th_i)) / GN.gasMixProp.H_s_n_avg; % [W]/[Ws/m^3] = [m^3/s]
elseif any(strcmp('V_dot_n_i__m3_per_day',GN.bus.Properties.VariableNames))
    GN.bus.V_dot_n_i(~isnan(GN.bus.V_dot_n_i__m3_per_day)) = GN.bus.V_dot_n_i__m3_per_day(~isnan(GN.bus.V_dot_n_i__m3_per_day)) / (60 * 60 * 24);
elseif any(strcmp('V_dot_n_i__m3_per_h',GN.bus.Properties.VariableNames))
    GN.bus.V_dot_n_i(~isnan(GN.bus.V_dot_n_i__m3_per_h)) = GN.bus.V_dot_n_i__m3_per_h(~isnan(GN.bus.V_dot_n_i__m3_per_h)) * 60 * 60;
elseif any(strcmp('m_dot_i__kg_per_s',GN.bus.Properties.VariableNames))
    GN.bus.V_dot_n_i(~isnan(GN.bus.m_dot_i__kg_per_s)) = GN.bus.m_dot_i__kg_per_s(~isnan(GN.bus.m_dot_i__kg_per_s)) / GN.gasMixProp.rho_n_avg; % [kg/s]/[kg/m^3] = [m^3/s]
end

%% Update of the slack node: flow rate balance to(+)/from(-) the slack node
GN.bus.V_dot_n_i(GN.bus.slack_bus) = -sum(GN.bus.V_dot_n_i(~GN.bus.slack_bus));
if GN.isothermal == 0
    if GN.bus.V_dot_n_i(GN.bus.slack_bus) < 0
        GN.bus.source_bus(GN.bus.slack_bus) = true;
    else
        GN.bus.source_bus(GN.bus.slack_bus) = false;
    end
end

%% p_i, T_i, p_ij, T_ij
GN = init_p_i(GN);
GN = init_T_i(GN);
GN = get_p_ij(GN);
GN = get_T_ij(GN);

%% Update p_i dependent quantities 
% Compressibility factor
GN = get_Z(GN, PHYMOD);

% Dynamic viscosity eta_ij(T,rho)
if isfield(GN, 'pipe')
    GN = get_eta(GN,PHYMOD);
end

end

