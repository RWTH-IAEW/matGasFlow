function [GN] = update_p_i_dependent_quantities(GN, NUMPARAM, PHYMOD)
%UPDATE_P_I_DEPENDENT_QUANTITIES
%
%   Update p_i dependent quantities
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

CONST = getConstants;
if any(GN.bus.p_i<CONST.p_n)
    error('Something went wrong.')
end

% Update p_ij
GN = get_p_ij(GN);

if NUMPARAM.always_update_p_i_dependent_quantities || ~ismember('Z_i',GN.bus.Properties.VariableNames) || log10(norm(GN.bus.f)) < 1/2*log10(NUMPARAM.epsilon_norm_f)
    %% Compressibility factor
    if GN.isothermal
        GN = get_Z(GN, PHYMOD, {'bus','pipe'}, NUMPARAM);
    else
        GN = get_Z(GN, PHYMOD, {'bus','source','pipe'}, NUMPARAM);
    end
    
    if isfield(GN,'comp') && any(GN.comp.gas_powered)
        GN = get_Z(GN, PHYMOD, {'comp','branch'}, NUMPARAM);
    end
    
    if isfield(GN,'prs') && any(GN.prs.gas_powered_heater)
        GN = get_Z(GN, PHYMOD, {'prs','branch'}, NUMPARAM);
    end

    %% Dynamic viscosity eta_ij(T,rho)
    GN = get_eta(GN,PHYMOD);
    
    %% Set convergence
    GN = set_convergence(GN, 'update_p_i_dependent_quantities');
    
end

end

