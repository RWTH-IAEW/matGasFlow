function [GN] = get_Z_DIN_EN_ISO_6976(GN)
%GET_Z_DIN_EN_ISO_6976
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

% TODO
error('TODO...')

% %%
% load('sum_factor_DIN6976.mat', 'sum_factor_DIN')
% load('temperature_values_DIN6976.mat', 'temperature_values')
% 
% %% Physical constants
% CONST = getConstants();
% 
% %% bus
% s_bus = NaN(size(GN.bus,1), size(sum_factor_DIN,1));
% for ii = 1:size(sum_factor_DIN,1)
%     s_bus(:,ii) = interp1(temperature_values,sum_factor_DIN(ii,:),(GN.bus.T_i - 273.15));
%     if any(GN.bus.T_i > 293.15)
%         s_bus(GN.bus.T_i > 293.15, ii) = interp1(temperature_values,sum_factor_DIN(ii,:),(20));
%     end
% end
% 
% GN.bus.Z_i = 1 - GN.bus.p_i./CONST.p_n .* (sum(s_bus * GN.gasMixAndCompoProp.x_mol )).^2;
% GN.bus.K_i = GN.bus.Z_i / GN.gasMixProp.Z_n_avg;


end

