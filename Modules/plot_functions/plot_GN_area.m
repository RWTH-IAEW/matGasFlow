function h = plot_GN_area(GN, h, area_IDs, print_bus_ID, show_prs, show_comp, show_valves, color_p_i)
%PLOT_GN_AREA Summary of this function goes here
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
if nargin < 8
    color_p_i = true;
    
    if nargin < 7
        show_valves = true;
        
        if nargin < 6
            show_prs = true;
            
            if nargin < 5
                show_comp = true;
                
                if nargin < 4
                    print_bus_ID = false;
                    
                    if nargin < 3
                        area_IDs = unique(GN.bus.area_ID);
                        
                        if nargin < 2
                            h = [];
                        end
                    end
                end
            end
        end
    end
end

if isempty(area_IDs)
    area_IDs = unique(GN.bus.area_ID);
end

col = rwthcolor;
fns = fieldnames(col);
COL = zeros(length(fns),3);
for ii = 1:length(fns)
    COL(ii,:) = col.(fns{ii});
end

if length(area_IDs) > size(COL,1)
    COL = [COL; rand(3*ceil((length(area_IDs)-length(COL))/3),3)];
    temp = 1:size(COL,1);
    temp = reshape(temp, 3, length(temp)/3);
    temp = reshape(temp', size(temp,1)*size(temp,2), 1);
    COL = COL(temp,:);
else
    COL = COL(floor(1:length(fns)/length(area_IDs):length(fns)),:);
end

if ~isfield(GN, 'branch')
    GN = check_and_init_GN(GN);
end

h = figure(h);
hold on
x = [GN.bus.x_coord(GN.branch.i_from_bus)'; GN.bus.x_coord(GN.branch.i_to_bus)'];
y = [GN.bus.y_coord(GN.branch.i_from_bus)'; GN.bus.y_coord(GN.branch.i_to_bus)'];
line(x, y, 'Color','black','LineStyle','--')

if print_bus_ID && isempty(area_IDs)
    text(GN.bus.x_coord, GN.bus.y_coord, num2str(GN.bus.bus_ID))
end

for ii = 1:length(area_IDs)
    idx_bus = GN.bus.area_ID == area_IDs(ii);
    
    scatter(GN.bus.x_coord(idx_bus), GN.bus.y_coord(idx_bus), [], COL(ii,:) )
    
    if print_bus_ID
        text(GN.bus.x_coord(idx_bus), GN.bus.y_coord(idx_bus), num2str(GN.bus.bus_ID(idx_bus)))
    end
    
    if isfield(GN, 'pipe')
        idx_pipe = GN.pipe.area_ID == area_IDs(ii);
        idx_branch = ismember(GN.branch.branch_ID, GN.pipe.branch_ID(idx_pipe));
        x = [GN.bus.x_coord(GN.branch.i_from_bus(idx_branch))'; GN.bus.x_coord(GN.branch.i_to_bus(idx_branch))'];
        y = [GN.bus.y_coord(GN.branch.i_from_bus(idx_branch))'; GN.bus.y_coord(GN.branch.i_to_bus(idx_branch))'];
        line(x, y, 'Color', COL(ii,:) )
        text(mean(x), mean(y), num2str(area_IDs(ii)))
    end
end
if color_p_i
    idx_bus = ismember(GN.bus.area_ID,area_IDs);
    x = GN.bus.x_coord(idx_bus);
    y = GN.bus.y_coord(idx_bus);
    if ismember('p_i__barg',GN.bus.Properties.VariableNames)
        p = GN.bus.p_i__barg(idx_bus);
        scatter(x,y,[],p,'filled')
        c = colorbar;
        c.Label.String = 'p_{i} [bar_g]';
    else
        p = GN.bus.p_i(idx_bus);
        scatter(x,y,[],p,'filled')
        c = colorbar;
        c.Label.String = 'p_{i} [Pa]';
    end
    
end

if show_prs && isfield(GN, 'prs')
    x = [GN.bus.x_coord(GN.branch.i_from_bus(GN.branch.prs_branch & GN.branch.in_service))'; GN.bus.x_coord(GN.branch.i_to_bus(GN.branch.prs_branch & GN.branch.in_service))'];
    y = [GN.bus.y_coord(GN.branch.i_from_bus(GN.branch.prs_branch & GN.branch.in_service))'; GN.bus.y_coord(GN.branch.i_to_bus(GN.branch.prs_branch & GN.branch.in_service))'];
    line(x, y, 'Color', 'c')
    text(mean(x), mean(y), 'p', 'Color', 'c')
    
    x = [GN.bus.x_coord(GN.branch.i_from_bus(GN.branch.prs_branch & ~GN.branch.in_service))'; GN.bus.x_coord(GN.branch.i_to_bus(GN.branch.prs_branch & ~GN.branch.in_service))'];
    y = [GN.bus.y_coord(GN.branch.i_from_bus(GN.branch.prs_branch & ~GN.branch.in_service))'; GN.bus.y_coord(GN.branch.i_to_bus(GN.branch.prs_branch & ~GN.branch.in_service))'];
    line(x, y, 'Color', 'c')
    text(mean(x), mean(y), 'p', 'Color', 'c', 'LineStyle', '--')
end
if show_comp && isfield(GN, 'comp')
    x = [GN.bus.x_coord(GN.branch.i_from_bus(GN.branch.comp_branch & GN.branch.in_service))'; GN.bus.x_coord(GN.branch.i_to_bus(GN.branch.comp_branch & GN.branch.in_service))'];
    y = [GN.bus.y_coord(GN.branch.i_from_bus(GN.branch.comp_branch & GN.branch.in_service))'; GN.bus.y_coord(GN.branch.i_to_bus(GN.branch.comp_branch & GN.branch.in_service))'];
    line(x, y, 'Color', 'r')
    text(mean(x), mean(y), 'c', 'Color', 'r')
    x = [GN.bus.x_coord(GN.branch.i_from_bus(GN.branch.comp_branch & ~GN.branch.in_service))'; GN.bus.x_coord(GN.branch.i_to_bus(GN.branch.comp_branch & ~GN.branch.in_service))'];
    y = [GN.bus.y_coord(GN.branch.i_from_bus(GN.branch.comp_branch & ~GN.branch.in_service))'; GN.bus.y_coord(GN.branch.i_to_bus(GN.branch.comp_branch & ~GN.branch.in_service))'];
    line(x, y, 'Color', 'c')
    text(mean(x), mean(y), 'p', 'Color', 'c', 'LineStyle', '--')
end
if show_valves && isfield(GN, 'valve')
    x = [GN.bus.x_coord(GN.branch.i_from_bus(GN.branch.valve_branch & GN.branch.in_service))'; GN.bus.x_coord(GN.branch.i_to_bus(GN.branch.valve_branch & GN.branch.in_service))'];
    y = [GN.bus.y_coord(GN.branch.i_from_bus(GN.branch.valve_branch & GN.branch.in_service))'; GN.bus.y_coord(GN.branch.i_to_bus(GN.branch.valve_branch & GN.branch.in_service))'];
    line(x, y, 'Color', 'm')
    text(mean(x), mean(y), 'v', 'Color', 'm')
    x = [GN.bus.x_coord(GN.branch.i_from_bus(GN.branch.valve_branch & ~GN.branch.in_service))'; GN.bus.x_coord(GN.branch.i_to_bus(GN.branch.valve_branch & ~GN.branch.in_service))'];
    y = [GN.bus.y_coord(GN.branch.i_from_bus(GN.branch.valve_branch & ~GN.branch.in_service))'; GN.bus.y_coord(GN.branch.i_to_bus(GN.branch.valve_branch & ~GN.branch.in_service))'];
    line(x, y, 'Color', 'c')
    text(mean(x), mean(y), 'p', 'Color', 'c', 'LineStyle', '--')
end


end

