function [GN] = get_GN_MAT(GN)
%GET_GN_MAT Summary of this function goes here
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2022, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ii = [...
    GN.bus.area_ID(GN.branch.i_from_bus(GN.branch.active_branch & GN.branch.in_service)); ...
    GN.bus.area_ID(GN.branch.i_to_bus(  GN.branch.active_branch & GN.branch.in_service))];
jj = [...
    find(GN.branch.active_branch & GN.branch.in_service); ...
    find(GN.branch.active_branch & GN.branch.in_service)];
vv = [...
     1 * ones(sum(GN.branch.active_branch & GN.branch.in_service),1); ...
    -1 * ones(sum(GN.branch.active_branch & GN.branch.in_service),1)];
nn = length(unique(GN.bus.area_ID));
mm = size(GN.branch,1);
GN.MAT.area_active_branch = sparse(ii, jj, vv, nn, mm);

ii = GN.bus.area_ID;
jj = 1:size(GN.bus,1);
vv = 1;
nn = length(unique(GN.bus.area_ID));
mm = size(GN.bus,1);
GN.MAT.area_bus = sparse(ii, jj, vv, nn, mm);

end

