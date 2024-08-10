function [ h ] = plot_GN_old( GN )
% PLOT_GN
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

%% Check y_coord and x_coord
if ~ismember('y_coord',GN.bus.Properties.VariableNames) || ~ismember('x_coord',GN.bus.Properties.VariableNames)
    disp('GN.bus: x_coord and/or y_coord are missing')
    return
end

%% Weights
weights = ones(size(GN.branch,1),1);
if isfield(GN, 'pipe')
    i_pipes = GN.branch.i_pipe(GN.branch.pipe_branch);
    if max(GN.pipe.D_ij(i_pipes)) ~= min(GN.pipe.D_ij(i_pipes))
        weights_min = 0.5;
        weights_max = 3;
        weights(i_pipes) = weights_min + ( GN.pipe.D_ij(i_pipes) - min(GN.pipe.D_ij(i_pipes)) )...
            * (weights_max - weights_min) /(max(GN.pipe.D_ij(i_pipes)) - min(GN.pipe.D_ij(i_pipes)));
    end
end

%% Change coordinates of busses with same coordinates
A = [GN.bus.x_coord,GN.bus.y_coord];
[~, b] = unique(A,'row');
indexToDupes = find(not(ismember(1:size(A,1),b)));

randAlpha = rand(length(indexToDupes),1)*2*pi;
offset = 0.003*(max(GN.bus.y_coord) - min(GN.bus.y_coord));

GN.bus.y_coord(indexToDupes) = GN.bus.y_coord(indexToDupes) + offset*cos(randAlpha);
GN.bus.x_coord(indexToDupes) = GN.bus.x_coord(indexToDupes) + offset*sin(randAlpha);

%% EdgeLabel
edgelabel = strings(size(GN.branch,1),1);

if ismember('V_dot_n_ij',GN.branch.Properties.VariableNames)
    V_dot_n_ij_str = string(abs(round(GN.branch.V_dot_n_ij*100)/100));
    if isfield(GN,'pipe')
        Delta_p_ij__barg_str = string(round((GN.bus.p_i__barg(GN.branch.i_from_bus) - GN.bus.p_i__barg(GN.branch.i_to_bus))*1e2)/1e2); % [bar_gauge]
        L_ij_str = repmat("",size(GN.branch,1),1);
        L_ij_str(GN.branch.pipe_branch) = string(GN.pipe.L_ij/1000); % [km]
        D_ij_str = repmat("",size(GN.branch,1),1);
        D_ij_str(GN.branch.pipe_branch) = string(GN.pipe.D_ij*1000); % [mm]
        
        is_pipe = GN.branch.pipe_branch;
        i_pipe = GN.branch.i_pipe(is_pipe);
        pipe_ID_str = string(GN.pipe.pipe_ID);
        edgelabel(is_pipe)   = join([repmat("$$(",sum(is_pipe),1),...
            pipe_ID_str(i_pipe),  repmat(')\,',sum(is_pipe),1),...
            V_dot_n_ij_str(is_pipe), repmat('\,m^3/s;\,',sum(is_pipe),1),...
            Delta_p_ij__barg_str(is_pipe), repmat('\,bar;\,',sum(is_pipe),1),...
            L_ij_str(is_pipe),       repmat('\,km;\,',sum(is_pipe),1),...
            D_ij_str(is_pipe),       repmat('\,mm$$',sum(is_pipe),1)],"");
    end
    if isfield(GN,'comp')
        is_comp = GN.branch.comp_branch;
        i_comp = GN.branch.i_comp(is_comp);
        comp_ID_str = string(GN.comp.comp_ID);
        edgelabel(is_comp) = join([  repmat('$$(',sum(is_comp),1),...
            comp_ID_str(i_comp),  repmat(')\,',sum(is_comp),1),...
            V_dot_n_ij_str(is_comp), repmat('\,m^3/s$$',sum(is_comp),1)],"");
    end
    if isfield(GN,'prs')
        is_prs = GN.branch.prs_branch;
        i_prs = GN.branch.i_prs(is_prs);
        prs_ID_str = string(GN.prs.prs_ID);
        edgelabel(is_prs) = join([   repmat('$$(',sum(is_prs),1),...
            prs_ID_str(i_prs),   repmat(')\,',sum(is_prs),1),...
            V_dot_n_ij_str(is_prs),  repmat('\,m^3/s$$',sum(is_prs),1)],"");
    end
    if isfield(GN,'valve')
        is_valve = GN.branch.valve_branch;
        i_valve = GN.branch.i_valve(is_valve);
        valve_ID_str = string(GN.valve.valve_ID);
        edgelabel(is_valve)  = join([repmat('$$(',sum(is_valve),1),...
            valve_ID_str(i_valve), repmat(')\,',sum(is_valve),1),...
            V_dot_n_ij_str(is_valve),repmat('\,m^3/s$$',sum(is_valve),1)],"");
    end
else
    if isfield(GN,'pipe')
        L_ij_str = repmat("",size(GN.branch,1),1);
        L_ij_str(GN.branch.pipe_branch) = string(GN.pipe.L_ij/1000); % [km]
        D_ij_str = repmat("",size(GN.branch,1),1);
        D_ij_str(GN.branch.pipe_branch) = string(GN.pipe.D_ij*1000); % [mm]
        is_pipe = GN.branch.pipe_branch;
        i_pipe = GN.branch.i_pipe(is_pipe);
        pipe_ID_str = string(GN.pipe.pipe_ID);
        edgelabel(is_pipe) = join([  repmat("$$(",sum(is_pipe),1),...
            pipe_ID_str(i_pipe),  repmat(')\,',sum(is_pipe),1),...
            L_ij_str(is_pipe),       repmat('\,km;\,',sum(is_pipe),1),...
            D_ij_str(is_pipe),       repmat('\,mm$$',sum(is_pipe),1)],"");
    end
    if isfield(GN,'comp')
        is_comp = GN.branch.comp_branch;
        i_comp = GN.branch.i_comp(is_comp);
        comp_ID_str = string(GN.comp.comp_ID);
        edgelabel(is_comp) = join([  repmat('$$(',sum(is_comp),1),...
            comp_ID_str(i_comp),  repmat(')$$',sum(is_comp),1)],"");
    end
    if isfield(GN,'prs')
        is_prs = GN.branch.prs_branch;
        i_prs = GN.branch.i_prs(is_prs);
        prs_ID_str = string(GN.prs.prs_ID);
        edgelabel(is_prs) = join([   repmat('$$(',sum(is_prs),1),...
            prs_ID_str(i_prs),   repmat(')$$',sum(is_prs),1)],"");
    end
    if isfield(GN,'valve')
        is_valve = GN.branch.valve_branch;
        i_valve = GN.branch.i_valve(is_valve);
        valve_ID_str = string(GN.valve.valve_ID);
        edgelabel(is_valve) = join([repmat('$$(',sum(is_valve),1),...
            valve_ID_str(i_valve),repmat(')$$',sum(is_valve),1)],"");
    end
end

%% NodeLabel
nodelabel = strings(size(GN.bus,1),1);
p_i_str   = string(round(GN.bus.p_i__barg*1e4)/1e4);

entry_exit_columns = {'P_th_i__MW', 'P_th_i', 'V_dot_n_i__m3_per_day', 'V_dot_n_i__m3_per_h', 'm_dot_i__kg_per_s', 'V_dot_n_i'};
units = {'MW','W','m^3/day','m^3/h','kg/s','m^3/s'};
idx = ismember(entry_exit_columns,GN.bus.Properties.VariableNames);
idx = find(idx);
idx = idx(1);
entry_exit_column = entry_exit_columns(idx);
unit = units(idx);
entry_exit = string(GN.bus{:,entry_exit_column});
bus_ID_str = string(GN.bus.bus_ID);

for ii = 1: size(GN.bus.p_i__barg,1)
    if     ~isnan(GN.bus.p_i__barg(ii)) && ~isnan(GN.bus{ii,entry_exit_column})
        nodelabel{ii} = ['$$($$',bus_ID_str{ii},'$$)\,$$',p_i_str{ii},'$$\,bar;\,$$',entry_exit{ii},'$$\,',unit{1},'$$'];
    elseif ~isnan(GN.bus.p_i__barg(ii)) &&  isnan(GN.bus{ii,entry_exit_column})
        nodelabel{ii} = ['$$($$',bus_ID_str{ii},'$$)\,$$',p_i_str{ii},'$$\,bar;\,$$'                                ];
    elseif  isnan(GN.bus.p_i__barg(ii)) && ~isnan(GN.bus{ii,entry_exit_column})
        nodelabel{ii} = ['$$($$',bus_ID_str{ii},'$$)\,$$',                           entry_exit{ii},'$$\,',unit{1},'$$'];
    elseif  isnan(GN.bus.p_i__barg(ii)) &&  isnan(GN.bus{ii,entry_exit_column})
        nodelabel{ii} = ['$$($$',bus_ID_str{ii},'$$)$$'                                                             ];
    end
end

%% Initialize Graphe
if ismember('V_dot_n_ij',GN.branch.Properties.VariableNames)
    i_from_bus = NaN(size(GN.branch,1),1);
    i_from_bus(GN.branch.V_dot_n_ij >= 0) = GN.branch.i_from_bus(GN.branch.V_dot_n_ij >= 0);
    i_from_bus(GN.branch.V_dot_n_ij < 0) = GN.branch.i_to_bus(GN.branch.V_dot_n_ij < 0);
    
    i_to_bus = NaN(size(GN.branch,1),1);
    i_to_bus(GN.branch.V_dot_n_ij >= 0) = GN.branch.i_to_bus(GN.branch.V_dot_n_ij >= 0);
    i_to_bus(GN.branch.V_dot_n_ij < 0)  = GN.branch.i_from_bus(GN.branch.V_dot_n_ij < 0);
else
    i_from_bus = GN.branch.i_from_bus;
    i_to_bus = GN.branch.i_to_bus;
end

EdgeTable = table(...
    [i_from_bus, i_to_bus],...
    weights,...
    edgelabel,...
    'VariableNames',{'EndNodes' 'Weight' 'edgelabel'});

NodeTable = table(nodelabel,'VariableNames',{'nodelabel'});

figure;
hold on
G = digraph(EdgeTable,NodeTable);
h = plot(G,'XData',GN.bus.x_coord, 'YData',GN.bus.y_coord,'NodeLabel',G.Nodes.nodelabel,'EdgeLabel',G.Edges.edgelabel,'LineWidth',G.Edges.Weight,'Marker', 'none');
h.Interpreter = 'latex';
set(gca,'YTickLabel',[]);
set(gca,'XTickLabel',[]);

if any(~GN.branch.in_service)
    EdgeTableOutOfService = table(...
        [i_from_bus(~GN.branch.in_service), i_to_bus(~GN.branch.in_service)],...
        weights(~GN.branch.in_service),...
        edgelabel(~GN.branch.in_service),...
        'VariableNames',{'EndNodes' 'Weight' 'edgelabel'});
    NodeTableOutOfService = table(nodelabel,'VariableNames',{'nodelabel'});
    G = digraph(EdgeTableOutOfService,NodeTableOutOfService);
    h = plot(G,'dr','XData',GN.bus.x_coord, 'YData',GN.bus.y_coord,'NodeLabel',G.Nodes.nodelabel,'EdgeLabel',G.Edges.edgelabel,'LineWidth',G.Edges.Weight,'Marker', 'none');
    h.Interpreter = 'latex';
    set(gca,'YTickLabel',[]);
    set(gca,'XTickLabel',[]);
end

sz = 50*ones(size(GN.bus,1),1);
scatter(GN.bus.x_coord,GN.bus.y_coord,sz,'.','black')

i_sink = find(GN.bus{:,entry_exit_column} > 0);
sz = 50*ones(size(i_sink));
scatter(GN.bus.x_coord(i_sink),GN.bus.y_coord(i_sink),sz,'v','filled','red')
i_source = find(GN.bus{:,entry_exit_column} < 0);
sz = 50*ones(size(i_source));
scatter(GN.bus.x_coord(i_source),GN.bus.y_coord(i_source),sz,'^','filled','green')

if isfield(GN,'comp')
    [~,iF_comp] = ismember(GN.branch.from_bus_ID(GN.branch.comp_branch),GN.bus.bus_ID);
    sz = 100*ones(size(iF_comp));
    s = scatter(GN.bus.x_coord(iF_comp),GN.bus.y_coord(iF_comp),sz,'<','filled','green');
    s.MarkerEdgeColor = 'k';
    [~,iT_comp] = ismember(GN.branch.to_bus_ID(GN.branch.comp_branch),GN.bus.bus_ID);
    sz = 100*ones(size(iT_comp));
    s = scatter(GN.bus.x_coord(iT_comp),GN.bus.y_coord(iT_comp),sz,'>','filled','red');
    s.MarkerEdgeColor = 'k';
end
if isfield(GN,'prs')
    [~,iF_prs] = ismember(GN.branch.from_bus_ID(GN.branch.prs_branch),GN.bus.bus_ID);
    sz = 100*ones(size(iF_prs));
    scatter(GN.bus.x_coord(iF_prs),GN.bus.y_coord(iF_prs),sz,'s','filled','green')
    [~,iT_prs] = ismember(GN.branch.to_bus_ID(GN.branch.prs_branch),GN.bus.bus_ID);
    sz = 100*ones(size(iT_prs));
    scatter(GN.bus.x_coord(iT_prs),GN.bus.y_coord(iT_prs),sz,'s','filled','red')
end
if isfield(GN,'valve')
    [~,iF_valve] = ismember(GN.branch.from_bus_ID(GN.branch.valve_branch),GN.bus.bus_ID);
    sz = 100*ones(size(iF_valve));
    scatter(GN.bus.x_coord(iF_valve),GN.bus.y_coord(iF_valve),sz,'x','green')
    [~,iT_valve] = ismember(GN.branch.to_bus_ID(GN.branch.valve_branch),GN.bus.bus_ID);
    sz = 100*ones(size(iT_valve));
    scatter(GN.bus.x_coord(iT_valve),GN.bus.y_coord(iT_valve),sz,'x','red')
end
