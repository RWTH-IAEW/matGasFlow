function [GN] = update_p_i_dependent_quantities(GN, PHYMOD)
%UPDATE_P_I_DEPENDENT_QUANTITIES
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2022, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin < 2
    PHYMOD = getDefaultPhysicalModels;
end

%% Update p_i dependent quantities
% Update p_ij
GN = get_p_ij(GN);

% Compressibility factor
GN = get_Z(GN, PHYMOD);

% Dynamic viscosity eta_ij(T,rho)
GN = get_eta(GN,PHYMOD);

end

