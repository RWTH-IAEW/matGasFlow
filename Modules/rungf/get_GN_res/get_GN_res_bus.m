function GN = get_GN_res_bus(GN)
%UNTITLED
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

%% Get GN results
% 1) Apply results from branch to pipe, comp, prs and valve
% 2) Calculate additional results
% 3) Check results

%% Physical constants
CONST = getConstants();

%% p_i__barg
GN.bus.p_i__barg = (GN.bus.p_i - CONST.p_n)*1e-5;

%% rho
GN = get_rho(GN);

%% check p_i__barg: p_i_min__barg, p_i_max__barg, T_i_min, T_i_max
% if ismember('p_i_max__barg',GN.bus.Properties.VariableNames)
%     if any(GN.bus.p_i__barg < GN.bus.p_i_min__barg)
%         bus_ID = GN.bus.bus_ID(GN.bus.p_i__barg < GN.bus.p_i_min__barg);
%         warning(['Too low pressure at these nodes, bus_ID: ',num2str(bus_ID')])
%     end
% end
% if ismember('p_i_min__barg',GN.bus.Properties.VariableNames)
%     if any(GN.bus.p_i__barg > GN.bus.p_i_max__barg)
%         bus_ID = GN.bus.bus_ID(GN.bus.p_i__barg > GN.bus.p_i_max__barg);
%         warning(['Too high pressure at these nodes, bus_ID:
%             ',num2str(bus_ID')])
%     end
% end

%% Calculate P_th_i__MW, P_th_i, V_dot_n_i__m3_per_day, V_dot_n_i__m3_per_h or m_dot_i__kg_per_s
if ismember('P_th_i__MW',GN.bus.Properties.VariableNames)
    GN.bus.P_th_i__MW               = convert_gas_flow_quantity(GN.bus.V_dot_n_i, 'm3_per_s', 'MW',         GN.gasMixProp);
    GN.bus.V_dot_n_i = [];    
elseif ismember('P_th_i',GN.bus.Properties.VariableNames)
    GN.bus.P_th_i                   = convert_gas_flow_quantity(GN.bus.V_dot_n_i, 'm3_per_s', 'W',          GN.gasMixProp);
    GN.bus.V_dot_n_i = [];    
elseif ismember('V_dot_n_i__m3_per_day',GN.bus.Properties.VariableNames)
    GN.bus.V_dot_n_i__m3_per_day    = convert_gas_flow_quantity(GN.bus.V_dot_n_i, 'm3_per_s', 'm3_per_day', GN.gasMixProp);
    GN.bus.V_dot_n_i = [];   
elseif ismember('V_dot_n_i__m3_per_h',GN.bus.Properties.VariableNames)
    GN.bus.V_dot_n_i__m3_per_h      = convert_gas_flow_quantity(GN.bus.V_dot_n_i, 'm3_per_s', 'm3_per_h',   GN.gasMixProp);
    GN.bus.V_dot_n_i = [];    
elseif ismember('m_dot_i__kg_per_s',GN.bus.Properties.VariableNames)
    GN.bus.m_dot_i__kg_per_s        = convert_gas_flow_quantity(GN.bus.V_dot_n_i, 'm3_per_s', 'kg_per_s',   GN.gasMixProp);
    GN.bus.V_dot_n_i = [];
end

end

