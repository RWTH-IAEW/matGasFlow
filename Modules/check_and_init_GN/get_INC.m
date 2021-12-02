function [INC] = get_INC(GN)
%GET_INC Incidence Matrix of Gas Network
%   [INC] = GETINCIDENCEMATRIX(GN) returns incedence matrix considering all
%   branches that are in service.
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

ii = [...
    GN.branch.i_from_bus(GN.branch.in_service);...
    GN.branch.i_to_bus(GN.branch.in_service)];
if any(~GN.bus.supplied)
    ii(ii == find(~GN.bus.supplied)) = [];
end
jj = 1:sum(GN.branch.in_service);
<<<<<<< HEAD
% jj = find(GN.branch.in_service);
=======
>>>>>>> Merge to public repo (#1)
jj = [jj';jj'];
vv = [...
    ones(size(GN.branch.i_from_bus(GN.branch.in_service)));...
    -ones(size(GN.branch.i_to_bus(GN.branch.in_service)))];
INC = sparse(ii,jj,vv);

end

