function [GN] = get_V_dot_n_i(GN)
%GET_V_DOT_N_I
%   Calculate V_dot_n_i [m^3/s]
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ismember('P_th_i__MW',GN.bus.Properties.VariableNames)
    GN.bus.V_dot_n_i = convert_gas_flow_quantity(GN.bus.P_th_i__MW,             'MW',           'm3_per_s', GN.gasMixProp);
    
elseif ismember('P_th_i',GN.bus.Properties.VariableNames)
    GN.bus.V_dot_n_i = convert_gas_flow_quantity(GN.bus.P_th_i,                 'W',            'm3_per_s', GN.gasMixProp);
    
elseif ismember('V_dot_n_i__m3_per_day',GN.bus.Properties.VariableNames)
    GN.bus.V_dot_n_i = convert_gas_flow_quantity(GN.bus.V_dot_n_i__m3_per_day,  'm3_per_day',   'm3_per_s', GN.gasMixProp);
    
elseif ismember('V_dot_n_i__m3_per_h',GN.bus.Properties.VariableNames)
    GN.bus.V_dot_n_i = convert_gas_flow_quantity(GN.bus.V_dot_n_i__m3_per_h,    'm3_per_h',     'm3_per_s', GN.gasMixProp);
    
elseif ismember('m_dot_i__kg_per_s',GN.bus.Properties.VariableNames)
    GN.bus.V_dot_n_i = convert_gas_flow_quantity(GN.bus.m_dot_i__kg_per_s,      'kg_per_s',     'm3_per_s', GN.gasMixProp);
    
end

end

