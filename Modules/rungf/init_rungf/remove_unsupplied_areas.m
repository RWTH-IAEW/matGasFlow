function [GN] = remove_unsupplied_areas(GN)
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

%% Remove branches that are out of service (~in_service)
if any(~GN.branch.in_service)
    if isfield(GN,'pipe')
        GN.pipe(GN.branch.i_pipe(~GN.branch.in_service & GN.branch.pipe_branch),:) = [];
    end
    
    if isfield(GN,'comp')
        GN.comp(GN.branch.i_comp(~GN.branch.in_service & GN.branch.comp_branch),:) = [];
    end
    
    if isfield(GN,'prs')
        GN.prs(GN.branch.i_prs(~GN.branch.in_service & GN.branch.prs_branch),:) = [];
    end
    
    if isfield(GN,'valve')
        GN.valve(GN.branch.i_valve(~GN.branch.in_service & GN.branch.valve_branch),:) = [];
    end
    
    % Inititalize GN.branch
    GN = init_GN_branch(GN);

    % Inititialize indecies
    GN = init_GN_indices(GN);
    
    % Check area restrictions
    keep_slack_properties = true;
    GN = check_GN_area_restrictions(GN,keep_slack_properties);

end

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

