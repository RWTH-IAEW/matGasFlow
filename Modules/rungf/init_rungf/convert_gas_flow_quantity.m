function [output_quantity] = convert_gas_flow_quantity(input_quantity, input_unit, output_unit, gasMixProp)
%CONVERT_GAS_FLOW_QUANTITY
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

if strcmp(input_unit,'MW')              % P_th
    V_dot_n__m3_per_s = input_quantity * 1e6 / gasMixProp.H_s_n_avg;    % [MW]*1e6/[Ws/m^3] = [m^3/s]
elseif strcmp(input_unit,'W')           % P_th
    V_dot_n__m3_per_s = input_quantity / gasMixProp.H_s_n_avg;          % [W]/[Ws/m^3] = [m^3/s]
elseif strcmp(input_unit,'m3_per_day') % V_dot_n
    V_dot_n__m3_per_s = input_quantity / (60 * 60 * 24);                % [m^3/d]*1d/(24h*60min*60s) = [m^3/s]
elseif strcmp(input_unit,'m3_per_h')    % V_dot_n
    V_dot_n__m3_per_s = input_quantity / (60 * 60);                     % [m^3/h]*1h/(60min*60s) = [m^3/s]
elseif strcmp(input_unit,'kg_per_s')    % m_dot
    V_dot_n__m3_per_s = input_quantity / gasMixProp.rho_n_avg;          % [kg/s]/[kg/m^3] = [m^3/s]
elseif strcmp(input_unit,'m3_per_s')    % V_dot_n
    V_dot_n__m3_per_s = input_quantity;                                 % [m^3/s]
else
    error(['Invalid input unit: ',input_unit])
end

if strcmp(output_unit,'MW')              % P_th
    output_quantity = V_dot_n__m3_per_s * 1e-6 * gasMixProp.H_s_n_avg;  % [MW]*1e6/[Ws/m^3] = [m^3/s]
elseif strcmp(output_unit,'W')           % P_th
    output_quantity = V_dot_n__m3_per_s * gasMixProp.H_s_n_avg;         % [W]/[Ws/m^3] = [m^3/s]
elseif strcmp(output_unit,'m3_per_day') % V_dot_n
    output_quantity = V_dot_n__m3_per_s * (60 * 60 * 24);               % [m^3/d]*1d/(24h*60min*60s) = [m^3/s]
elseif strcmp(output_unit,'m3_per_h')    % V_dot_n
    output_quantity = V_dot_n__m3_per_s * (60 * 60);                    % [m^3/h]*1h/(60min*60s) = [m^3/s]
elseif strcmp(output_unit,'kg_per_s')    % m_dot
    output_quantity = V_dot_n__m3_per_s * gasMixProp.rho_n_avg;         % [kg/s]/[kg/m^3] = [m^3/s]
elseif strcmp(output_unit,'m3_per_s')    % V_dot_n
    output_quantity = V_dot_n__m3_per_s;
else
    error(['Invalid output unit: ',output_unit])
end


end

