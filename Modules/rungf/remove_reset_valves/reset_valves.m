function [GN] = reset_valves(GN,GN_input)
%RESET_VALVES Summary of this function goes here
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

if ~isfield(GN_input, 'valve')
    return
end

%% merge bus
new_colums      = GN.bus.Properties.VariableNames(~ismember(GN.bus.Properties.VariableNames, GN_input.bus.Properties.VariableNames));
table_temp      = array2table(NaN(size(GN_input.bus,1),length(new_colums)),"VariableNames",new_colums);
GN_input.bus    = [GN_input.bus, table_temp];
[~,i_column]    = ismember(GN.bus.Properties.VariableNames, GN_input.bus.Properties.VariableNames);
[~,i_row]       = ismember(GN.bus.bus_ID, GN_input.bus.bus_ID);
bus_temp        = GN_input.bus;
GN_input.bus(i_row,i_column) = GN.bus;
% GN_input.bus.V_dot_n_i      = bus_temp.V_dot_n_i;
GN_input.bus.slack_bus      = bus_temp.slack_bus;
GN_input.bus.active_bus     = bus_temp.active_bus;

%% merge branch
new_colums      = GN.branch.Properties.VariableNames(~ismember(GN.branch.Properties.VariableNames, GN_input.branch.Properties.VariableNames));
table_temp      = array2table(NaN(size(GN_input.branch,1),length(new_colums)),"VariableNames",new_colums);
GN_input.branch    = [GN_input.branch, table_temp];
% [~,i_column]    = ismember(GN.branch.Properties.VariableNames, GN_input.branch.Properties.VariableNames);
[~,i_row]       = ismember(GN.branch.branch_ID, GN_input.branch.branch_ID);
% branch_temp        = GN_input.branch;
GN_input.branch.V_dot_n_ij(i_row)   = GN.branch.V_dot_n_ij;
% GN_input.branch.slack_branch      = branch_temp.slack_branch;
% GN_input.branch.slack_branch      = branch_temp.slack_branch;
% GN_input.branch.active_branch     = branch_temp.active_branch;
% GN_input.branch.connecting_branch = branch_temp.connecting_branch;
% GN_input.branch.parallel_branch   = branch_temp.parallel_branch;

%%
GN = get_V_dot_n_ij_valves(GN_input);
disp('...')

[GN] = get_p_T_valve(GN);

% %% INC
% GN.INC = GN_input.INC;
% 
% %% MAT
% GN.MAT = GN_input.MAT;
% 
% %% non-pipe branches
% GN.valve = GN_input.valve;
% 
% if isfield(GN, 'pipe')
%     GN.pipe.from_bus_ID = GN_input.pipe.from_bus_ID(GN_input.pipe.in_service);
%     GN.pipe.to_bus_ID   = GN_input.pipe.to_bus_ID(GN_input.pipe.in_service);
%     GN.pipe.i_branch    = GN_input.pipe.i_branch(GN_input.pipe.in_service);
% end
% 
% if isfield(GN, 'comp')
%     GN.comp.from_bus_ID = GN_input.comp.from_bus_ID(GN_input.comp.in_service);
%     GN.comp.to_bus_ID   = GN_input.comp.to_bus_ID(GN_input.comp.in_service);
%     GN.comp.i_branch    = GN_input.comp.i_branch(GN_input.comp.in_service);
% end
% 
% if isfield(GN, 'prs')
%     GN.prs.from_bus_ID  = GN_input.prs.from_bus_ID(GN_input.prs.in_service);
%     GN.prs.to_bus_ID    = GN_input.prs.to_bus_ID(GN_input.prs.in_service);
%     GN.prs.i_branch     = GN_input.prs.i_branch(GN_input.prs.in_service);
% end
% 
% %% bus
% % [~,i_bus] = ismember(GN.bus.bus_ID, GN_input.bus.bus_ID);
% Var = intersect(GN.bus.Properties.VariableNames,GN_input.bus.Properties.VariableNames);
% GN.bus = outerjoin(GN.bus,GN_input.bus,'Keys',Var,'MergeKeys',true);
% GN.bus.slack_bus = GN_input.bus.slack_bus;
% GN.bus.active_bus = GN_input.bus.active_bus;
% 
% 
% % Valve Gruppen identifizierden
% valveStation_IDs = unique(GN_input.branch.valveStation_ID(GN_input.branch.valve_branch & GN_input.branch.in_service));
% 
% for ii = 1:length(valveStation_IDs)
%     
%     valveStation_ID = valveStation_IDs(ii);
%     ii_valveStation = GN_input.branch.valveStation_ID == valveStation_ID & GN_input.branch.in_service;
%     
%     bus_IDs_valveStation        = unique( [ GN_input.branch.from_bus_ID(ii_valveStation & GN_input.branch.in_service); GN_input.branch.to_bus_ID(ii_valveStation & GN_input.branch.in_service) ] );
% %     bus_IDs_valveStation_inOut  = bus_IDs_valveStation(ismember(bus_IDs_valveStation, [GN_input.branch.from_bus_ID(~ii_valveStation), GN_input.branch.to_bus_ID(~ii_valveStation)]));
%     bus_ID_valveStation_center  = GN_input.bus.bus_ID(ismember(GN.bus.bus_ID, bus_IDs_valveStation));
%     bus_IDs_deleted             = bus_IDs_valveStation(~ismember(bus_IDs_valveStation, GN.bus.bus_ID)); 
% %     if ~any(bus_ID_valveStation_center)
% %         bus_ID_valveStation_center = bus_IDs_valveStation_inOut(1);
% %     end
% %     bus_IDs_deleted = bus_IDs_valveStation(bus_IDs_valveStation ~= bus_ID_valveStation_center);
% %     bus_IDs_deleted = GN_input.bus.bus_ID(ismember(GN.bus.bus_ID, bus_IDs_valveStation_inOut)); 
%     
%     for jj = 1: length(bus_IDs_deleted)
%         GN.bus = [GN.bus; GN.bus(bus_ID_valveStation_center == GN.bus.bus_ID,:)];
%         GN.bus.bus_ID(end) = bus_IDs_deleted(jj);
% %         GN.bus.valve_out_bus(end) = true;
% %         GN.bus.i_valve_out(end) = ismember(GN.valve.to_bus_ID, GN.bus.bus_ID(end));
%     end
% end
% 
% % Sort GN.bus table
% [~,idx] = ismember(GN_input.bus.bus_ID, GN.bus.bus_ID);
% GN.bus = GN.bus(idx,:);
% 
% %% branch UNDER CONSTRUCTION
% GN.branch = GN_input.branch;
% if isfield(GN, 'pipe')
%     if ~ismember('V_dot_n_ij', GN.branch.Properties.VariableNames)
%         GN.branch.V_dot_n_ij(:) = NaN;
%     end
%     if ismember('V_dot_n_ij', GN.pipe.Properties.VariableNames)
%         GN.branch.V_dot_n_ij(GN.pipe.i_branch) = GN.pipe.V_dot_n_ij;
%     end
% end
% if isfield(GN, 'comp')
%     if ~ismember('V_dot_n_ij', GN.branch.Properties.VariableNames)
%         GN.branch.V_dot_n_ij(:) = NaN;
%     end
%     if ismember('V_dot_n_ij', GN.comp.Properties.VariableNames)
%         GN.branch.V_dot_n_ij(GN.comp.i_branch) = GN.comp.V_dot_n_ij;
%     end
% end
% if isfield(GN, 'prs')
%     if ~ismember('V_dot_n_ij', GN.branch.Properties.VariableNames)
%         GN.branch.V_dot_n_ij(:) = NaN;
%     end
%     if ismember('V_dot_n_ij', GN.prs.Properties.VariableNames)
%         GN.branch.V_dot_n_ij(GN.prs.i_branch) = GN.prs.V_dot_n_ij;
%     end
% end

%% valve
% GN = init_V_dot_n_ij(GN);
% GN = get_V_dot_n_ij_valves(GN);

% i_valve = GN.branch.i_valve(GN.branch.valve_branch);
% GN.valve.V_dot_n_ij(i_valve) = ...
%     GN.branch.V_dot_n_ij(GN.branch.valve_branch);

end

