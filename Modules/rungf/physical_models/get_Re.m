function GN = get_Re(GN)
%GET_RE Reynolds number
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ismember('Re_ij',GN.pipe.Properties.VariableNames)
    Re_ij_temp = GN.pipe.Re_ij;
end

GN.pipe.Re_ij = ...
    4*abs(GN.branch.V_dot_n_ij(GN.pipe.i_branch)) .* GN.gasMixProp.rho_n_avg ...
    ./(pi*GN.pipe.D_ij.*GN.pipe.eta_ij);

if isfield(GN,'fixRe_ij')
    CONST = getConstants;
    GN.pipe.Re_ij(GN.pipe.Re_ij>CONST.Re_crit) = CONST.Re_crit;
%     GN.pipe.Re_ij(GN.pipe.Re_ij>CONST.Re_crit & Re_ij_temp<=CONST.Re_crit) = CONST.Re_crit;
%     GN.pipe.Re_ij(GN.pipe.Re_ij<=CONST.Re_crit & Re_ij_temp>CONST.Re_crit) = CONST.Re_crit;%+1;
end
end