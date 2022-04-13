function [GN] = get_V_dot_n_i(GN)
%GET_V_DOT_N_I Summary of this function goes here
%   Calculate V_dot_n_i [m^3/s]
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2022, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if any(strcmp('P_th_i__MW',GN.bus.Properties.VariableNames))
    GN.bus.V_dot_n_i = GN.bus.P_th_i__MW ...
        * 1e6 / GN.gasMixProp.H_s_n_avg;    % [MW]*1e6/[Ws/m^3] = [m^3/s]
    
elseif any(strcmp('P_th_i',GN.bus.Properties.VariableNames))
    GN.bus.V_dot_n_i = GN.bus.P_th_i ...
        / GN.gasMixProp.H_s_n_avg;          % [W]/[Ws/m^3] = [m^3/s]
    
elseif any(strcmp('V_dot_n_i__m3_per_day',GN.bus.Properties.VariableNames))
    GN.bus.V_dot_n_i = GN.bus.V_dot_n_i__m3_per_day ...
        / (60 * 60 * 24);                   % [m^3/d]*1d/(24h*60min*60s) = [m^3/s]
    
elseif any(strcmp('V_dot_n_i__m3_per_h',GN.bus.Properties.VariableNames))
    GN.bus.V_dot_n_i = GN.bus.V_dot_n_i__m3_per_h ...
        * 60 * 60;                          % [m^3/h]*1h/(60min*60s) = [m^3/s]
    
elseif any(strcmp('m_dot_i__kg_per_s',GN.bus.Properties.VariableNames))
    GN.bus.V_dot_n_i = GN.bus.m_dot_i__kg_per_s ...
        / GN.gasMixProp.rho_n_avg;          % [kg/s]/[kg/m^3] = [m^3/s]
    
end

end

