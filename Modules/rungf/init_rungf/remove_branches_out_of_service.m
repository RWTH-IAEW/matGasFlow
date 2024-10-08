function GN = remove_branches_out_of_service(GN)
%UNTITLED
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

if any(~GN.branch.in_service)
    if isfield(GN,'pipe')
        GN.pipe(GN.branch.i_pipe(~GN.branch.in_service & GN.branch.pipe_branch),:) = [];
        if isempty(GN.pipe)
            GN = rmfield(GN,'pipe');
        end
    end
    
    if isfield(GN,'comp')
        GN.comp(GN.branch.i_comp(~GN.branch.in_service & GN.branch.comp_branch),:) = [];
        if isempty(GN.comp)
            GN = rmfield(GN,'comp');
        end
    end
    
    if isfield(GN,'prs')
        GN.prs(GN.branch.i_prs(~GN.branch.in_service & GN.branch.prs_branch),:) = [];
        if isempty(GN.prs)
            GN = rmfield(GN,'prs');
        end
    end
    
    if isfield(GN,'valve')
        GN.valve(GN.branch.i_valve(~GN.branch.in_service & GN.branch.valve_branch),:) = [];
        if isempty(GN.valve)
            GN = rmfield(GN,'valve');
        end
    end
    
    % Inititalize GN.branch
    GN = init_GN_branch(GN);

    % Inititialize indecies
    GN = init_GN_indices(GN);
    
    % Check area restrictions
    keep_slack_properties = true;
    GN = check_GN_area_restrictions(GN,keep_slack_properties);

end

end

