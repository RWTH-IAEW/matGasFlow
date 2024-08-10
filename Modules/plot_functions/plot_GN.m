function [h,ax_bus,ax_branch,cb_bus,cb_branch,text_bus] = plot_GN(GN, PLOTOPTIONS, h)
%PLOT_GN_AREA
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

if nargin < 2
    PLOTOPTIONS = getDefaultPlotGNOptions;
end

if nargin < 3
    if ~isempty(PLOTOPTIONS.FigurePosition)
        h = figure('units','inch','position',PLOTOPTIONS.FigurePosition);
    else
        h = figure;
    end
    hold on
else
    h = figure(h);
    hold on
end

%% Initialize
cb_bus      = [];
cb_branch   = [];
text_bus    = [];

%% %%%%%%%%%%%%%%% TODO
% PLOTOPTIONS.axis_on = true;
% PLOTOPTIONS.pipe_show_colorbar =true;

%%
if ~PLOTOPTIONS.axis_on
    axis off
end

if ischar(GN)
    GN = load_GN(GN);
end

n_branch_colorbars = sum([...
    PLOTOPTIONS.pipe_show_colorbar, ...
    PLOTOPTIONS.comp_show_colorbar, ...
    PLOTOPTIONS.prs_show_colorbar, ...
    PLOTOPTIONS.valve_show_colorbar]);
if n_branch_colorbars>1
    error('For pipe, comp, prs and valve only one colorbar can be shown.')
end

%% x_coord, y_coord
if any(~ismember({'x_coord','y_coord'}, GN.bus.Properties.VariableNames))
    error('Missing bus properties: x_coord and/or y_coord.')
end

%% area_IDs
if isempty(PLOTOPTIONS.area_IDs)
    area_IDs = unique(GN.bus.area_ID);
else
    area_IDs = PLOTOPTIONS.area_IDs;
end

%% area_Color
if strcmp(PLOTOPTIONS.bus_Color, 'area_ID') || strcmp(PLOTOPTIONS.pipe_Color, 'area_ID')
    col         = rwthcolor;
    fns         = fieldnames(col);
    area_Color  = zeros(length(fns),3);
    for ii = 1:length(fns)
        area_Color(ii,:) = col.(fns{ii});
    end
    
    if length(area_IDs) > size(area_Color,1)
        area_Color  = [area_Color; rand(3*ceil((length(area_IDs)-length(area_Color))/3),3)];
        temp        = 1:size(area_Color,1);
        temp        = reshape(temp, 3, length(temp)/3);
        temp        = reshape(temp', size(temp,1)*size(temp,2), 1);
        area_Color  = area_Color(temp,:);
    else
        area_Color  = area_Color(floor(1:length(fns)/length(area_IDs):length(fns)),:);
    end
end

%% Pipe
if isfield(GN,'pipe') && PLOTOPTIONS.pipe_show && any(GN.pipe.in_service)
    
    x = [GN.bus.x_coord(GN.branch.i_from_bus(GN.pipe.i_branch))'; GN.bus.x_coord(GN.branch.i_to_bus(GN.pipe.i_branch))'];
    y = [GN.bus.y_coord(GN.branch.i_from_bus(GN.pipe.i_branch))'; GN.bus.y_coord(GN.branch.i_to_bus(GN.pipe.i_branch))'];
    
    % Color
    if strcmp(PLOTOPTIONS.pipe_Color,'default')
        pipe_Color = zeros(size(GN.pipe,1),3);
    elseif ismember(PLOTOPTIONS.pipe_Color, GN.pipe.Properties.VariableNames)
        pipe_Color_values   = GN.pipe.(PLOTOPTIONS.pipe_Color);
        pipe_Color          = colormap();
        cmin                = min([pipe_Color_values(:);PLOTOPTIONS.pipe_Color_min_value]);
        cmax                = max([pipe_Color_values(:);PLOTOPTIONS.pipe_Color_max_value]);
        m                   = length(pipe_Color);
        idx                 = fix((pipe_Color_values-cmin)/(cmax-cmin)*(m-1))+1;
        idx(isnan(idx))     = 1;
        pipe_Color          = pipe_Color(idx,:);
    end
    
    % LineWidth
    if strcmp(PLOTOPTIONS.pipe_LineWidth,'default')
        pipe_LineWidth  = 0.5*ones(size(GN.comp,1),1); % MATLAB default value
    elseif ismember(PLOTOPTIONS.pipe_LineWidth, GN.pipe.Properties.VariableNames)
        pipe_LineWidth_values = GN.pipe.(PLOTOPTIONS.pipe_LineWidth);
        max_LineWidth   = 3;
        pipe_LineWidth  = ((pipe_LineWidth_values-min(pipe_LineWidth_values))/max(pipe_LineWidth_values-min(pipe_LineWidth_values))*(max_LineWidth-1)+1);
    end
    
    % show_parallel
    %     pipe_show_parallel  = repmat('-',size(GN.pipe,1),1);
    %     if strcmp(PLOTOPTIONS.pipe_show_parallel,'on')
    %         max_bus_ID = max(GN.pipe.from_bus_ID,GN.pipe.to_bus_ID);
    %         min_bus_ID = min(GN.pipe.from_bus_ID,GN.pipe.to_bus_ID);
    %         pipe_show_parallel(GN.pipe.parallel)
    %     end
    
    % line plot
    for ii = 1:sum(GN.pipe.in_service)
        line(x(:,ii),y(:,ii),'Color',pipe_Color(ii,:),'LineWidth', pipe_LineWidth(ii))
    end
    
    % pipe text
    % ...
end

%% Comp
if isfield(GN,'comp') && PLOTOPTIONS.comp_show && any(GN.comp.in_service)
    x = [GN.bus.x_coord(GN.branch.i_from_bus(GN.branch.comp_branch & GN.branch.in_service))'; GN.bus.x_coord(GN.branch.i_to_bus(GN.branch.comp_branch & GN.branch.in_service))'];
    y = [GN.bus.y_coord(GN.branch.i_from_bus(GN.branch.comp_branch & GN.branch.in_service))'; GN.bus.y_coord(GN.branch.i_to_bus(GN.branch.comp_branch & GN.branch.in_service))'];
    %     ax_comp = axes;
    %     ax_comp.Visible = 'off';
    % Color
    if strcmp(PLOTOPTIONS.comp_Color,'default')
        comp_Color = zeros(size(GN.comp,1),3);
    elseif ismember(PLOTOPTIONS.comp_Color, GN.comp.Properties.VariableNames)
        comp_Color_values   = GN.comp.(PLOTOPTIONS.comp_Color);
        comp_Color          = colormap();
        cmin                = min([comp_Color_values(:); PLOTOPTIONS.comp_Color_min_value]);
        cmax                = max([comp_Color_values(:); PLOTOPTIONS.comp_Color_min_value]);
        m                   = length(comp_Color);
        idx                 = fix((comp_Color_values-cmin)/(cmax-cmin)*(m-1))+1; %A
        comp_Color          = comp_Color(idx,:);
    end
    
    % LineWidth
    if strcmp(PLOTOPTIONS.comp_LineWidth,'default')
        comp_LineWidth  = 0.5*ones(size(GN.comp,1),1); % MATLAB default value
    elseif ismember(PLOTOPTIONS.comp_Color, GN.comp.Properties.VariableNames)
        comp_LineWidth_values = GN.comp.(PLOTOPTIONS.comp_LineWidth);
        max_LineWidth   = 4;
        comp_LineWidth  = ((comp_LineWidth_values-min(comp_LineWidth_values))/max(comp_LineWidth_values-min(comp_LineWidth_values))*(max_LineWidth-1)+1);
    end
    
    % line plot
    for ii = 1:sum(GN.comp.in_service)
        line(x(:,ii),y(:,ii),'Color',comp_Color(ii,:),'LineWidth', comp_LineWidth(ii))
    end
    
    %     linkaxes([ax_pipe,ax_comp])
    
    % Text - TODO
    if ~isempty(PLOTOPTIONS.comp_text)
        text(mean(x), mean(y), PLOTOPTIONS.comp_text, 'Color', PLOTOPTIONS.comp_text_Color)
    end
end

%% Prs
if isfield(GN,'prs') && PLOTOPTIONS.prs_show && any(GN.prs.in_service)
    x = [GN.bus.x_coord(GN.branch.i_from_bus(GN.branch.prs_branch & GN.branch.in_service))'; GN.bus.x_coord(GN.branch.i_to_bus(GN.branch.prs_branch & GN.branch.in_service))'];
    y = [GN.bus.y_coord(GN.branch.i_from_bus(GN.branch.prs_branch & GN.branch.in_service))'; GN.bus.y_coord(GN.branch.i_to_bus(GN.branch.prs_branch & GN.branch.in_service))'];
    
    % Color
    if strcmp(PLOTOPTIONS.prs_Color,'default')
        prs_Color = zeros(size(GN.prs,1),3);
    elseif ismember(PLOTOPTIONS.prs_Color, GN.prs.Properties.VariableNames)
        prs_Color_values    = GN.prs.(PLOTOPTIONS.prs_Color);
        prs_Color           = colormap();
        cmin                = min([prs_Color_values(:); PLOTOPTIONS.prs_Color_min_value]);
        cmax                = max([prs_Color_values(:); PLOTOPTIONS.prs_Color_min_value]);
        m                   = length(prs_Color);
        idx                 = fix((prs_Color_values-cmin)/(cmax-cmin)*(m-1))+1; %A
        prs_Color           = prs_Color(idx,:);
    end
    
    % LineWidth
    if strcmp(PLOTOPTIONS.prs_LineWidth,'default')
        prs_LineWidth   = 0.5*ones(size(GN.prs,1),1); % MATLAB default value
    elseif ismember(PLOTOPTIONS.prs_Color, GN.prs.Properties.VariableNames)
        prs_LineWidth_values = GN.prs.(PLOTOPTIONS.prs_LineWidth);
        max_LineWidth   = 4;
        prs_LineWidth   = ((prs_LineWidth_values-min(prs_LineWidth_values))/max(prs_LineWidth_values-min(prs_LineWidth_values))*(max_LineWidth-1)+1);
    end
    
    % line plot
    for ii = 1:sum(GN.prs.in_service)
        line(x(:,ii),y(:,ii),'Color',prs_Color(ii,:),'LineWidth', prs_LineWidth(ii))
    end
    
    % Text
    %     line(x, y, 'Color', 'c')
    %     text(mean(x), mean(y), 'p', 'Color', 'c')
    %
    %     x = [GN.bus.x_coord(GN.branch.i_from_bus(GN.branch.prs_branch & ~GN.branch.in_service))'; GN.bus.x_coord(GN.branch.i_to_bus(GN.branch.prs_branch & ~GN.branch.in_service))'];
    %     y = [GN.bus.y_coord(GN.branch.i_from_bus(GN.branch.prs_branch & ~GN.branch.in_service))'; GN.bus.y_coord(GN.branch.i_to_bus(GN.branch.prs_branch & ~GN.branch.in_service))'];
    %     line(x, y, 'Color', 'c')
    %     text(mean(x), mean(y), 'p', 'Color', 'c', 'LineStyle', '--')
end

%% Valve
if isfield(GN,'valve') && PLOTOPTIONS.valve_show && any(GN.valve.in_service)
    x = [GN.bus.x_coord(GN.branch.i_from_bus(GN.branch.valve_branch & GN.branch.in_service))'; GN.bus.x_coord(GN.branch.i_to_bus(GN.branch.valve_branch & GN.branch.in_service))'];
    y = [GN.bus.y_coord(GN.branch.i_from_bus(GN.branch.valve_branch & GN.branch.in_service))'; GN.bus.y_coord(GN.branch.i_to_bus(GN.branch.valve_branch & GN.branch.in_service))'];
    
    % Color
    if strcmp(PLOTOPTIONS.valve_Color,'default')
        valve_Color = zeros(size(GN.valve,1),3);
    elseif ismember(PLOTOPTIONS.valve_Color, GN.valve.Properties.VariableNames)
        valve_Color_values   = GN.valve.(PLOTOPTIONS.valve_Color);
        valve_Color          = colormap();
        cmin    = min([valve_Color_values(:); PLOTOPTIONS.valve_Color_min_value]);
        cmax    = max([valve_Color_values(:); PLOTOPTIONS.valve_Color_min_value]);
        m       = length(valve_Color);
        idx     = fix((valve_Color_values-cmin)/(cmax-cmin)*(m-1))+1; %A
        valve_Color    = valve_Color(idx,:);
    end
    
    % LineWidth
    if strcmp(PLOTOPTIONS.valve_LineWidth,'default')
        valve_LineWidth = 0.5*ones(size(GN.valve,1),1); % MATLAB default value
    elseif ismember(PLOTOPTIONS.valve_Color, GN.valve.Properties.VariableNames)
        valve_LineWidth_values = GN.valve.(PLOTOPTIONS.valve_LineWidth);
        max_LineWidth   = 4;
        valve_LineWidth = ((valve_LineWidth_values-min(valve_LineWidth_values))/max(valve_LineWidth_values-min(valve_LineWidth_values))*(max_LineWidth-1)+1);
    end
    
    % line plot
    for ii = 1:size(GN.valve,1)
        line(x(:,ii),y(:,ii),'Color',valve_Color(ii,:),'LineWidth', valve_LineWidth(ii))
    end
    
    % Text
    %     line(x, y, 'Color', 'm')
    %     text(mean(x), mean(y), 'v', 'Color', 'm')
    %     x = [GN.bus.x_coord(GN.branch.i_from_bus(GN.branch.valve_branch & ~GN.branch.in_service))'; GN.bus.x_coord(GN.branch.i_to_bus(GN.branch.valve_branch & ~GN.branch.in_service))'];
    %     y = [GN.bus.y_coord(GN.branch.i_from_bus(GN.branch.valve_branch & ~GN.branch.in_service))'; GN.bus.y_coord(GN.branch.i_to_bus(GN.branch.valve_branch & ~GN.branch.in_service))'];
    %     line(x, y, 'Color', 'c')
    %     text(mean(x), mean(y), 'p', 'Color', 'c', 'LineStyle', '--')
end


%% colorbar
if PLOTOPTIONS.pipe_show_colorbar
    ax_branch                       = axes;
    xaxisprop                       = get(ax_branch, 'XAxis');
    xaxisprop.TickLabelInterpreter  = 'latex';
    xaxisprop.FontSize              = PLOTOPTIONS.PlotFontSize;
    yaxisprop                       = get(ax_branch, 'YAxis');
    yaxisprop.TickLabelInterpreter  = 'latex';
    yaxisprop.FontSize              = PLOTOPTIONS.PlotFontSize;
    if ~PLOTOPTIONS.axis_on
        ax_branch.Visible              = 'off';
    end
    ax_branch.CLim      = [...
        min([pipe_Color_values(:);PLOTOPTIONS.pipe_Color_min_value]), ...
        max([pipe_Color_values(:);PLOTOPTIONS.pipe_Color_max_value])];
    
    if PLOTOPTIONS.bus_show_colorbar && ~strcmp(PLOTOPTIONS.bus_Color,'default')
        cb_branch = colorbar(ax_branch,'Position',[0.1 0.1095 0.0381 0.8167]);
    else
        cb_branch = colorbar(ax_branch,'Position',[0.8298+0.05 0.1095 0.0381 0.8167]);
    end
    cb_branch.TickLabelInterpreter  = 'latex';
    cb_branch.Title.Interpreter     = 'latex';
    cb_branch.FontSize              = PLOTOPTIONS.PlotFontSize;
    cb_branch.Title.FontSize        = PLOTOPTIONS.PlotFontSize;
    if ~isempty(PLOTOPTIONS.pipe_colorbar_text)
        cb_branch.Title.String = PLOTOPTIONS.pipe_colorbar_text;
    elseif strcmp(PLOTOPTIONS.pipe_Color,'p_ij__barg')
        cb_branch.Title.String = '$p_{mean} [bar_g]$';
    elseif strcmp(PLOTOPTIONS.pipe_Color,'T_ij')
        cb_branch.Title.String = '$T_{mean} [K]$';
    elseif strcmp(PLOTOPTIONS.pipe_Color,'v_max_abs')
        cb_branch.Title.String = '$|v_{max}| [m/s]$';
    elseif strcmp(PLOTOPTIONS.pipe_Color,'V_dot_n_ij')
        cb_branch.Title.String = '$\dot{V}_n [m^3/s]$';
    else
        cb_branch.Title.String = ['$',PLOTOPTIONS.pipe_Color,'$'];
    end
    
elseif PLOTOPTIONS.comp_show_colorbar
    
elseif PLOTOPTIONS.prs_show_colorbar
    
elseif PLOTOPTIONS.valve_show_colorbar
    
else
    ax_branch = [];
end

%% Bus
if PLOTOPTIONS.bus_show
    idx_bus = ismember(GN.bus.area_ID,area_IDs);
    x       = GN.bus.x_coord(idx_bus);
    y       = GN.bus.y_coord(idx_bus);
    
    % Size
    if strcmp(PLOTOPTIONS.bus_Size,'default')
        bus_Size    = 20; % MATLAB default value
    elseif isnumeric(PLOTOPTIONS.bus_Size)
        bus_Size    = PLOTOPTIONS.bus_Size;
    elseif ismember(PLOTOPTIONS.bus_Size, GN.bus.Properties.VariableNames)
        bus_Size_values = GN.bus.(PLOTOPTIONS.bus_Color);
        max_Size    = 400;
        bus_Size    = ((bus_Size_values-min(bus_Size_values))/max(bus_Size_values-min(bus_Size_values))*(max_Size-1)+1);
    end
    
    % Color
    ax_bus = axes;
    if strcmp(PLOTOPTIONS.bus_Color,'default')
        scatter(ax_bus, x, y, bus_Size,   'k', 'filled', 'MarkerEdgeColor', 'k');
    else
        value = GN.bus.(PLOTOPTIONS.bus_Color);
        scatter(ax_bus, x, y, bus_Size, value, 'filled', 'MarkerEdgeColor', 'k');
        if PLOTOPTIONS.bus_show_colorbar
            cb_bus = colorbar(ax_bus,'Position',[0.8298+0.05 0.1095 0.0381 0.8167]);
            if ~isempty(PLOTOPTIONS.bus_Color_min_value) && ~isempty(PLOTOPTIONS.bus_Color_max_value)
                if PLOTOPTIONS.bus_Color_min_value < PLOTOPTIONS.bus_Color_max_value
                    caxis([PLOTOPTIONS.bus_Color_min_value,PLOTOPTIONS.bus_Color_max_value])
                end
            end
            cb_bus.TickLabelInterpreter     = 'latex';
            cb_bus.Title.Interpreter        = 'latex';
            cb_bus.FontSize                 = PLOTOPTIONS.PlotFontSize;
            cb_bus.Title.FontSize           = PLOTOPTIONS.PlotFontSize;
            if ~isempty(PLOTOPTIONS.bus_colorbar_text)
                cb_bus.Title.String = PLOTOPTIONS.bus_colorbar_text;
            elseif strcmp(PLOTOPTIONS.bus_Color,'$p_i__barg$')
                cb_bus.Title.String = '$p_i \,[bar_g]$';
            elseif strcmp(PLOTOPTIONS.bus_Color,'$T_i$')
                cb_bus.Title.String = '$T_i \,[K]$';
            else
                cb_bus.Title.String = ['$',PLOTOPTIONS.bus_Color,'$'];
            end
        end
    end
    xaxisprop                       = get(ax_bus, 'XAxis');
    xaxisprop.TickLabelInterpreter  = 'latex';
    xaxisprop.FontSize              = PLOTOPTIONS.PlotFontSize;
    yaxisprop                       = get(ax_bus, 'YAxis');
    yaxisprop.TickLabelInterpreter  = 'latex';
    yaxisprop.FontSize              = PLOTOPTIONS.PlotFontSize;
    if PLOTOPTIONS.grid_on
        grid on
    end
    if ~PLOTOPTIONS.axis_on
        ax_bus.Visible              = 'off';
    end
    
    % Text
    if ~isempty(PLOTOPTIONS.bus_text)
        if ismember(PLOTOPTIONS.bus_text, GN.bus.Properties.VariableNames)
            if isnumeric(GN.bus.(PLOTOPTIONS.bus_text))
                x_offset = 0.1*(max(x)-min(x))/7;
                y_offset = 0.3*(max(x)-min(x))/10;
                text_bus = text(x+x_offset,y+y_offset,num2str(GN.bus.(PLOTOPTIONS.bus_text)));
            else
                text_bus = text(x+0.1,y+0.1,GN.bus.(PLOTOPTIONS.bus_text));
            end
        else
            text_bus = text(x,y,PLOTOPTIONS.bus_text);
        end
    end    
else
    ax_bus = [];
end

%% further options
if PLOTOPTIONS.grid_on
    grid on
end

end

