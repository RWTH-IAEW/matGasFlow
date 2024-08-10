function [GN] = get_kappa_GOST(GN)
%GET_KAPPA_GOST
%
%   see also [Mischner 2015] Gl. 9.100, [GOST 30319.1-96]
%   applicable for p <= 100bar and 240K <= T <= 360K
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
x_mol_N2 = GN.gasMixAndCompoProp.x_mol('N2');

%% bus
% Quantities
p     = GN.bus.p_i;
T     = GN.bus.T_i;
GN.bus.kappa_i = calculate_kappa_GOST(p, T, x_mol_N2);

%% prs
if isfield(GN, 'prs')
    % Quantities
    p     = GN.prs.p_ij_mid;
    T     = GN.prs.T_ij_mid;
    GN.prs.kappa_ij_mid = calculate_kappa_GOST(p, T, x_mol_N2);
end

end

