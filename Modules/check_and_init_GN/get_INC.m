function [INC] = get_INC(GN)
%GET_INC Incidence Matrix of Gas Network
%   [INC] = GETINCIDENCEMATRIX(GN) returns incedence matrix considering all
%   branches that are in service.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2021, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ii = [...
    GN.branch.i_from_bus(GN.branch.in_service);...
    GN.branch.i_to_bus(GN.branch.in_service)];
if any(~GN.bus.supplied)
    ii(ii == find(~GN.bus.supplied)) = [];
end
jj = 1:sum(GN.branch.in_service);
jj = [jj';jj'];
vv = [...
    ones(size(GN.branch.i_from_bus(GN.branch.in_service)));...
    -ones(size(GN.branch.i_to_bus(GN.branch.in_service)))];
INC = sparse(ii,jj,vv);

end

