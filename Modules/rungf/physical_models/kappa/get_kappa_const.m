function [GN] = get_kappa_const(GN, PHYMOD)
%GET_KAPPA_CONST
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

%% bus
GN.bus.kappa_i(:) = PHYMOD.kappa_const;

%% prs
if isfield(GN, 'prs')
    GN.prs.kappa_ij_mid(:) = PHYMOD.kappa_const;
end

end

