function [GN, success] = get_p_i(GN, NUMPARAM, PHYMOD)
%GET_P_I
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

success = true;
GN_temp = GN;

if NUMPARAM.radial_GN_start_solution == 1
    GN = get_V_dot_n_ij_radialGN(GN, NUMPARAM);
    [GN, success] = get_p_i_radial_GN(GN, NUMPARAM, PHYMOD);
elseif NUMPARAM.radial_GN_start_solution == 2
    GN = get_V_dot_n_ij_radialGN(GN, NUMPARAM);
    [GN, success] = get_p_i_radial_GN_loop(GN, NUMPARAM, PHYMOD);    
end

if ~success
    GN = GN_temp;
end

end

