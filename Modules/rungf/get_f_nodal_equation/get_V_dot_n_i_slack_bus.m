function [GN] = get_V_dot_n_i_slack_bus(GN)
%GET_V_DOT_N_I_SLACK_BUS Summary of this function goes here
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


f_area = GN.MAT.area_bus * GN.bus.f;

slack_bus_area_MAT = GN.MAT.area_bus(:,GN.bus.slack_bus)';

GN.bus.V_dot_n_i(GN.bus.slack_bus) = - slack_bus_area_MAT * f_area;




% % area_bus_MAT
% [~,ii] = ismember(GN.bus.area_ID, unique(GN.bus.area_ID));
% jj = 1:size(GN.bus,1);
% vv = 1;
% mm = length(unique(GN.bus.area_ID));
% nn = size(GN.bus,1);
% area_bus_MAT = sparse(ii,jj,vv,mm,nn);
% 
% % ii_temp = find(GN.bus.slack_bus);
% % jj = area_bus_MAT(any(area_bus_MAT(:,GN.bus.slack_bus),2),:);
% % sum_jj = sum(jj,2);
% % ii = [];
% % for iii = 1:sum(GN.bus.slack_bus)
% %     ii = [ii;ii_temp(iii)*ones(sum_jj(iii),1)];
% % end
% % jj = find(sum(jj))';
% % vv = 1;
% % mm = size(GN.bus,1);
% % nn = size(GN.bus,1);
% % slack_bus_bus_MAT = sparse(ii,jj,vv,mm,nn);
% 
% 
% JJ = area_bus_MAT(any(area_bus_MAT(:,GN.bus.slack_bus),2),:);
% [ii,jj] = find(JJ);
% vv = 1;
% mm = sum(GN.bus.slack_bus);
% nn = size(GN.bus,1);
% slack_bus_bus_MAT = sparse(ii,jj,vv,mm,nn);
% 
% 
% GN.bus.V_dot_n_i(GN.bus.slack_bus) = ...
%     slack_bus_bus_MAT * GN.bus.V_dot_n_i - GN.bus.V_dot_n_i(GN.bus.slack_bus);
% 
% 
% % GN.bus.V_dot_n_i(GN.bus.slack_bus) = -sum(GN.bus.V_dot_n_i(~GN.bus.slack_bus))/sum(GN.bus.slack_bus); % UNDER CONSTRUCTION
% % GN.bus.V_dot_n_i(GN.bus.slack_bus) = -sum(GN.bus.V_dot_n_i(~GN.bus.slack_bus))/sum(GN.bus.slack_bus);
% % idx = ismember(GN.bus.area_ID, GN.bus.area_ID(GN.bus.slack_bus)) & ~GN.bus.slack_bus;
% % [~,idx] = ismember(GN.bus.area_ID, GN.bus.area_ID(GN.bus.slack_bus));
% % idx(GN.bus.slack_bus) = 0;
% % 
% % ii = idx;
% % jj = 1:size(GN.bus,1);
% % jj(ii==0) = [];
% % ii(ii==0) = [];
% % vv = 1;
% % mm = sum(GN.bus.slack_bus);
% % nn = size(GN.bus,1);
% % slack_bus_MAT = sparse(ii,jj,vv,mm,nn);
% % 
% % [~,idx] = ismember(GN.bus.area_ID(GN.bus.slack_bus),GN.area.area_ID);
% % GN.bus.V_dot_n_i(GN.bus.slack_bus) = - slack_bus_MAT * GN.bus.V_dot_n_i - GN.area.V_dot_n_nonPipe(idx);

end

