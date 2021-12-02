function [GN] = remove_unsupplied_areas(GN)
%REMOVE_UNSUPPLIED_AREAS
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
<<<<<<< HEAD
%   Copyright (c) 2020-2022, High Voltage Equipment and Grids,
=======
%   Copyright (c) 2020-2021, High Voltage Equipment and Grids,
>>>>>>> Merge to public repo (#1)
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

<<<<<<< HEAD
%% Remove branches that are out of service (~in_service)
=======
>>>>>>> Merge to public repo (#1)
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
    
<<<<<<< HEAD
    % Inititalize GN.branch
    GN = init_GN_branch(GN);

    % Inititialize indecies
    GN = init_GN_indices(GN);
    
    % Check area restrictions
    keep_bus_properties = true;
    GN = check_GN_area_restrictions(GN,keep_bus_properties);

end

%% Remove unsupplied busses
=======
    GN.branch(~GN.branch.in_service,:) = [];
    
    % Inititialize indecies
    GN = init_GN_indices(GN);
end

>>>>>>> Merge to public repo (#1)
if any(~GN.bus.supplied)
    GN.bus(~GN.bus.supplied,:) = [];
    
    % Inititialize indecies
    GN = init_GN_indices(GN);
<<<<<<< HEAD
    
    % Check area restrictions
    keep_bus_properties = true;
    GN = check_GN_area_restrictions(GN,keep_bus_properties);
end

%%
if isfield(GN,'GN_NR')
    GN.GN_NR = remove_unsupplied_areas(GN.GN_NR);
end

=======
end

if isfield(GN,'GN_NR')
    GN.GN_NR = remove_unsupplied_areas(GN.GN_NR);
end
>>>>>>> Merge to public repo (#1)
end

