function [GN] = get_V_dot_n_ij_nonPipe(GN)
%GET_V_DOT_N_IJ_NONPIPE
%   [GN] = get_V_dot_n_ij_nonPipe(GN)
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

if all(GN.branch.pipe_branch)
    return
end    

%%
i_to_bus_non_pipe = GN.branch.i_to_bus(~GN.branch.pipe_branch);
ii = i_to_bus_non_pipe;
jj = find(~GN.branch.pipe_branch);
vv = 1;
mm = size(GN.INC,1);
nn = size(GN.INC,2);
INC_temp = GN.INC + sparse(ii,jj,vv,mm,nn);

iter = sum(GN.INC(:,~GN.branch.pipe_branch) * GN.INC(:,~GN.branch.pipe_branch)'==2,'all') + 1;
<<<<<<< HEAD
[GN] = init_V_dot_n_ij_nonPipe(GN);

% UNDER COSNTRUCTION
% for ii = 1:iter
%     GN.branch.V_dot_n_ij(~GN.branch.pipe_branch) = ...
%         INC_temp(i_to_bus_non_pipe,:) * GN.branch.V_dot_n_ij + GN.bus.V_dot_n_i(i_to_bus_non_pipe);
%     
% end
=======
for ii = 1:iter
    GN.branch.V_dot_n_ij(~GN.branch.pipe_branch) = ...
        INC_temp(i_to_bus_non_pipe,:) * GN.branch.V_dot_n_ij + GN.bus.V_dot_n_i(i_to_bus_non_pipe);
    
end
>>>>>>> Merge to public repo (#1)

end

