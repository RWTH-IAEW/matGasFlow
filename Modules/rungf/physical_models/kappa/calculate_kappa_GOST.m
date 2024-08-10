function [kappa] = calculate_kappa_GOST(p, T, x_mol_N2)
%CALCULATE_KAPPA_GOST
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

p__bar = p * 1e-5;

kappa = ...
    1.556 .* (1+0.074*x_mol_N2) ...
    - 3.9e-4 .* T * (1-0.68*x_mol_N2) ...
    - 0.208 * GN.gasMixProp.rho_n_avg ...
    + (p__bar./T).^1.43 .* ( ...
    2.261 * (1-x_mol_N2) .* (p__bar./T).^0.8 ...
    + 0.981 .* x_mol_N2);

end

