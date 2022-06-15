function [GN, success] = get_p_i(GN, NUMPARAM, PHYMOD)
%GET_P_I Summary of this function goes here
%   Detailed explanation goes here
%   UNDER CONSTRUCTION: Description is missing
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2022, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Success
success = true;

%%
if NUMPARAM.OPTION_rungf_get_p_i == 1
    [GN, success] = get_p_i_SLE(GN, PHYMOD);
elseif NUMPARAM.OPTION_rungf_get_p_i == 2
    [GN, success] = get_p_i_SLE_loop(GN, NUMPARAM, PHYMOD);
elseif NUMPARAM.OPTION_rungf_get_p_i == 3
    [GN, success] = get_p_i_Adm(GN, PHYMOD);
elseif NUMPARAM.OPTION_rungf_get_p_i == 4
    [GN, success] = get_p_i_Adm_loop(GN, NUMPARAM, PHYMOD);
end

end

