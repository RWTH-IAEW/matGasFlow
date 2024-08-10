function [PLOTOPTIONS] = getDefaultPlotGNOptions()
%GETDEFAULTPLOTGNOPTIONS
%
%
%   HINT: when show text: Use a cell array if different quantities shall be printed.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

PLOTOPTIONS.bus_show                = true;         % Options: true, false
PLOTOPTIONS.bus_Color               = 'default';    % Options: 'default', any quantity (e.g. 'p_i__barg', 'T_i', 'area_ID', ...)
PLOTOPTIONS.bus_colorbar_text       = [];
PLOTOPTIONS.bus_Size                = 'default';    % Options: 'default', any quantity (e.g. 'p_i__barg', 'T_i', 'area_ID', ...)
PLOTOPTIONS.bus_text                = [];           % Options: any text or quantity (e.g. 'p_i__barg', 'T_i', 'area_ID', 'bus_ID', ...)
PLOTOPTIONS.bus_show_colorbar       = false;

PLOTOPTIONS.pipe_show               = true;         % Options: true, false
PLOTOPTIONS.pipe_Color              = 'default';    % Options: 'default', any quantity (e.g. 'D_ij', 'P_th_ij__MW', 'area_ID', ...)
PLOTOPTIONS.pipe_Color_min_value    = [];
PLOTOPTIONS.pipe_Color_max_value    = [];
PLOTOPTIONS.pipe_colorbar_text      = [];
PLOTOPTIONS.pipe_LineWidth          = 'D_ij';       % Options: 'default', any quantity (e.g. 'D_ij', 'P_th_ij__MW', 'area_ID', ...)
PLOTOPTIONS.pipe_show_parallel      = false;        % Options: true, false
PLOTOPTIONS.pipe_text               = [];           % Options: any text or quantity (e.g. 'D_ij', 'P_th_ij__MW', 'area_ID', 'pipe_ID', ...) 
PLOTOPTIONS.pipe_text_Color         = 'r';          % 
PLOTOPTIONS.pipe_show_colorbar      = false;

PLOTOPTIONS.comp_show               = true;         % Options: true, false
PLOTOPTIONS.comp_Color              = 'default';    % Options: 'default', any quantity (e.g. 'P_drive', ...)
PLOTOPTIONS.comp_Color_min_value    = [];
PLOTOPTIONS.comp_Color_max_value    = [];
PLOTOPTIONS.comp_colorbar_text      = [];
PLOTOPTIONS.comp_LineWidth          = 'default';    % Options: 'default', any quantity (e.g. 'P_drive', ...)
PLOTOPTIONS.comp_text               = [];           % Options: any text or quantity (e.g. 'P_drive', 'comp_ID', ...)
PLOTOPTIONS.comp_text_Color         = 'r';          % 
PLOTOPTIONS.comp_show_colorbar      = false;

PLOTOPTIONS.prs_show                = true;         % Options: true, false
PLOTOPTIONS.prs_Color               = 'default';    % Options: 'default', any quantity (e.g. 'Q_dot_heater', ...)
PLOTOPTIONS.prs_Color_min_value     = [];
PLOTOPTIONS.prs_Color_max_value     = [];
PLOTOPTIONS.prs_colorbar_text       = [];
PLOTOPTIONS.prs_LineWidth           = 'default';    % Options: 'default', any quantity (e.g. 'Q_dot_heater', ...)
PLOTOPTIONS.prs_text                = [];           % Options: any text or quantity (e.g. 'Q_dot_heater', 'prs_ID'...)
PLOTOPTIONS.prs_text_Color          = 'c';          % 
PLOTOPTIONS.prs_show_colorbar       = false;

PLOTOPTIONS.valve_show              = true;         % Options: true, false
PLOTOPTIONS.valve_Color             = 'default';    % Options: 'default', any quantity (e.g. 'P_th_ij__MW', ...)
PLOTOPTIONS.valve_Color_min_value   = [];
PLOTOPTIONS.valve_Color_max_value   = [];
PLOTOPTIONS.valve_colorbar_text     = [];
PLOTOPTIONS.valve_LineWidth         = 'default';    % Options: 'default', any quantity (e.g. 'P_drive', ...)
PLOTOPTIONS.valve_size              = 'none';       % Options: 'default', any quantity (e.g. 'P_th_ij__MW', ...)
PLOTOPTIONS.valve_text              = [];           % Options: any text or quantity (e.g. 'P_th_ij__MW', 'valve_ID', ...)
PLOTOPTIONS.valve_text_Color        = 'g';          %
PLOTOPTIONS.valve_show_colorbar     = false;

PLOTOPTIONS.grid_on                 = true;         % Options: true, false
PLOTOPTIONS.axis_on                 = false;        % Options: true, false
PLOTOPTIONS.area_IDs                = [];           % area_IDs to be highlighted
PLOTOPTIONS.PlotFontSize            = 8;
PLOTOPTIONS.FigurePosition          = [];

end

