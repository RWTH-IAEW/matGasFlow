function [GN] = remove_unsupplied_busses(GN)
%REMOVE_UNSUPPLIED_AREAS
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2022, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%% Remove unsupplied busses
if any(~GN.bus.supplied)
    GN.bus(~GN.bus.supplied,:) = [];
    
    % Inititialize indecies
    GN = init_GN_indices(GN);
    
    % Check area restrictions
    keep_slack_properties = true;
    GN = check_GN_area_restrictions(GN,keep_slack_properties);
end

%%
if isfield(GN,'GN_NR')
    GN.GN_NR = remove_unsupplied_areas(GN.GN_NR);
end

end

