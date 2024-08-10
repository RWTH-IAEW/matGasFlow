function g_ij = get_g_ij(GN, OPTION)
%GET_G_IJ
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

%% Quantities
p_i = GN.bus.p_i(GN.branch.i_from_bus(GN.branch.pipe_branch));
p_j = GN.bus.p_i(GN.branch.i_to_bus(GN.branch.pipe_branch));

if OPTION == 1
    %              sqrt(p_i^2 - p_j^2)
    % V_dot_n_ij = ------------------- * sqrt(A_ij * B_ij) * (p_i - p_j)
    %                   p_i - p_j
    
    g_ij = abs(sqrt(p_i.^2 - p_j.^2)./(p_i - p_j));
    
elseif OPTION == 2
    %              sqrt(p_i^2 - p_j^2)
    % V_dot_n_ij = ------------------- * sqrt(A_ij * B_ij) * (p_i^2 - p_j^2)
    %                 p_i^2 - p_j^2
    
    g_ij = abs(sqrt(p_i.^2 - p_j.^2)./(p_i.^2 - p_j.^2));
    
else
    error('Invalid option.')
end

end

