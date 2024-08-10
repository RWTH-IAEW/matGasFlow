function [GN] = update_T_dependent_quantities(GN, NUMPARAM, PHYMOD)
%UPDATE_T_DEPENDENT_QUANTITIES
%
%   Update T_i dependent quantities
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Compressibility factor
GN = get_Z(GN, PHYMOD, 'all',    NUMPARAM);

%% Dynamic viscosity eta_ij(T,rho)
GN = get_eta(GN,PHYMOD);
    
%% Set convergence
GN = set_convergence(GN, 'update_T_dependent_quantities');
    
end

