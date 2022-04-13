function [GN] = check_and_update_p_area(GN, all_areas)
%CHECK_AND_UPDATE_P_AREA Summary of this function goes here
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

%%
if nargin < 2
    all_areas = false;
end

%%    
% mode = {'p_i_min','p_i_max'};
mode = 'p_i_min';
% mode = 'p_i_mean';


%%
if ismember('p_i', GN.bus.Properties.VariableNames)
    % Physical constants
    CONST = getConstants();
    
    % p_i__brag [barg]
    GN.bus.p_i__barg = GN.bus.p_i*1e-5 - CONST.p_n;
end

%%


%% p_i_min mode
if any(strcmp(mode, 'p_i_min'))
    
    if ~ismember('p_i_min__barg', GN.bus.Properties.VariableNames)
        return
    end
    
    if all_areas
        area_IDs = unique(GN.bus.area_ID);
    else
        area_IDs = unique(GN.bus.area_ID(GN.bus.p_i__barg < GN.bus.p_i_min__barg));
    end
        
    for ii = 1:length(area_IDs)
        min_p_i__barg               = min(GN.bus.p_i__barg(GN.bus.area_ID == area_IDs(ii)));
        i_bus_min_p_i__barg         = GN.bus.p_i__barg == min_p_i__barg & GN.bus.area_ID == area_IDs(ii);
        
        GN.bus.p_bus(GN.bus.area_ID == area_IDs(ii))    = false;
        GN.bus.p_bus(i_bus_min_p_i__barg)               = true;
        GN.bus.p_i__barg(i_bus_min_p_i__barg)           = GN.bus.p_i_min__barg(i_bus_min_p_i__barg);
    end
end

if any(strcmp(mode, 'p_i_max'))
    
    if ~ismember('p_i_max__barg', GN.bus.Properties.VariableNames)
        return
    end
    
    if all_areas
        area_IDs = unique(GN.bus.area_ID);
    else
        area_IDs = unique(GN.bus.area_ID(GN.bus.p_i__barg > GN.bus.p_i_max__barg));
    end
    
    for ii = 1:length(area_IDs)
        max_p_i__barg               = max(GN.bus.p_i__barg(GN.bus.area_ID == area_IDs(ii)));
        i_bus_max_p_i__barg         = GN.bus.p_i__barg == max_p_i__barg & GN.bus.area_ID == area_IDs(ii);
        
        GN.bus.p_bus(GN.bus.area_ID == area_IDs(ii))    = false;
        GN.bus.p_bus(i_bus_max_p_i__barg)               = true;
        GN.bus.p_i__barg(i_bus_max_p_i__barg)           = GN.bus.p_i_max__barg(i_bus_max_p_i__barg);
    end
end

%%
GN = init_p_i(GN);


% p_p_bus_input = GN_input.bus.p_i__barg(GN.bus.p_bus);
% [p_p_bus_input,idx] = sort(p_p_bus_input);
% area_ID_input = GN_input.bus.area_ID(GN.bus.p_bus);
% area_ID_input = area_ID_input(idx);
% 
% area_ID_min = unique(GN_input.bus.area_ID);
% p_min = NaN(size(area_ID_min));
% for ii = 1:length(area_ID_min)
%     p_min(ii) = min(GN_input.bus.p_i__barg(GN_input.bus.area_ID == area_ID_min(ii)));
% end
% [~,idx] = ismember(area_ID_min,area_ID_input);
% p_min(idx) = p_min;
% area_ID_min(idx) = area_ID_min;
% 
% p_p_bus_new = GN.bus.p_i__barg(GN.bus.p_bus);
% area_ID_new = GN.bus.area_ID(GN.bus.p_bus);
% [~,idx] = ismember(area_ID_new,area_ID_input);
% p_p_bus_new(idx) = p_p_bus_new;
% area_ID_new(idx) = area_ID_new;
% 
% figure
% hold on
% stairs(p_p_bus_new)
% stairs(p_min)
% stairs(p_p_bus_input)
% xticks(1:length(area_ID_new))
% xticklabels({area_ID_new})
% xlabel('area ID')
% ylabel('p_i(p-bus) [barg]')

end

