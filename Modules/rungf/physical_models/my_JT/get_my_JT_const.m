function [GN] = get_my_JT_const(GN,PHYMOD)
%GET_MY_JT Joule-Thomson Coefficient for mixtures
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% bus
GN.bus.my_JT_i(:) = PHYMOD.my_JT_const;

%% pipe and prs outflow
if isfield(GN, 'pipe') || isfield(GN, 'prs')
    GN.branch.my_JT_ij_out(:) = PHYMOD.my_JT_const;
end

%% prs
if isfield(GN, 'prs')
    GN.prs.my_JT_ij_mid(:) = PHYMOD.my_JT_const;
end

end

