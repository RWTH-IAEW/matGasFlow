function [GN] = set_interconnecting_active_branches_out_of_service(GN)
%SET_INTERCONNECTING_ACTIVE_BRANCHES_OUT_OF_SERVICE
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

% TODO: Bypass might be a better idea?!

%%
if isfield(GN,'comp')
    i_comp_branch = ...
        GN.bus.area_ID(GN.branch.i_from_bus) == GN.bus.area_ID(GN.branch.i_to_bus) ...
        & GN.branch.comp_branch ...
        & GN.branch.in_service;
    
    if any(i_comp_branch)
        disp(GN.branch(i_comp_branch,:))
        warning('Compressors with the same area_ID at from_bus and to_bus have been set out of service.')
        GN.comp.in_service(GN.branch.i_comp(i_comp_branch))     = false;
        GN.branch.in_service(i_comp_branch)                     = false;
    end
end
    
if isfield(GN,'prs')
    i_prs_branch = ...
        GN.bus.area_ID(GN.branch.i_from_bus) == GN.bus.area_ID(GN.branch.i_to_bus) ...
        & GN.branch.prs_branch ...
        & GN.branch.in_service;
    
    if any(i_prs_branch) % TODO
        disp(GN.branch(i_prs_branch,:))
        warning('PRS with the same area_ID at from_bus and to_bus have been set out of service.')
        GN.prs.in_service(GN.branch.i_prs(i_prs_branch))        = false;
        GN.branch.in_service(i_prs_branch)                      = false;
        
        i_valve_in_service                                                  = GN.branch.i_bypass_valve(i_prs_branch);
        GN.valve.in_service(i_valve_in_service(~isnan(i_valve_in_service))) = true;
        i_valve_branch_in_of_service                                        = GN.valve.i_branch(GN.valve.in_service);
        GN.branch.in_service(i_valve_branch_in_of_service)                  = true;
        
    end
end

%% Repeate procedure
if (isfield(GN,'comp') && any(i_comp_branch)) || (isfield(GN,'prs') && any(i_prs_branch))
    % Check and initialize area_ID
    GN = check_and_init_area_ID(GN);

    % Check for islands
    GN = check_GN_islands(GN);

    % System Matrices
    GN = get_GN_MAT(GN);
end

end

