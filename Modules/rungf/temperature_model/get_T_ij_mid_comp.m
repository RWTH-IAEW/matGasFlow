function [GN] = get_T_ij_mid_comp(GN, NUMPARAM, PHYMOD)
%GET_T_IJ_MID_COMP
%
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

%% Indices
i_comp_branch   = GN.comp.i_branch;
i_bus_in        = GN.branch.i_from_bus(i_comp_branch);

%% Quantities
p_in            = GN.bus.p_i(i_bus_in);
p_mid           = GN.comp.p_ij_mid;
T_in            = GN.bus.T_i(i_bus_in);
Z_in            = GN.bus.Z_i(i_bus_in);

%% Exponent
if PHYMOD.comp ==1
    %% Isentropic compression
    % get_Z(GN,PHYMOD,'bus'), get_c_p(GN,PHYMOD) --> already up to date
    GN                  = get_kappa(GN, PHYMOD);
    kappa_in            = GN.bus.kappa_i(i_bus_in);
    eta_S               = GN.comp.eta_S;
    
    % Calculate T_ij_mid
    Z_mid               = Z_in; % start point
    GN.comp.T_ij_mid    = T_in .* Z_in./Z_mid .* ( ( (p_mid ./ p_in).^((kappa_in - 1)./kappa_in) - 1 )./eta_S + 1);
    
    T_mid_temp          = zeros(size(GN.comp,1),1);
    iter                = 0;

    % Fix point iteration: T_mid = T_in * Z_in/Z_mid(T_mid) * ( ( (p_mid/p_in)^((kappa_in-1)/kappa_in) - 1)/eta_S + 1 );
    while norm(GN.comp.T_ij_mid - T_mid_temp) > NUMPARAM.epsilon_T && iter < NUMPARAM.maxIter
        T_mid_temp          = GN.comp.T_ij_mid;
        iter                = iter + 1;
        GN                  = set_convergence(GN, ['get_T_ij_mid_comp, (',num2str(iter),')']);
        GN                  = get_Z(GN,PHYMOD,'comp');
        Z_mid               = GN.comp.Z_ij_mid;
        GN.comp.T_ij_mid    = T_in .* Z_in./Z_mid .* ( ( (p_mid./p_in).^((kappa_in-1)./kappa_in) - 1)./eta_S + 1 );
    end
    if iter == NUMPARAM.maxIter
        warning('get_T_ij_mid_comp: iter = NUMPARAM.maxIter')
    end
    
elseif PHYMOD.comp == 2
    %% Isothermal compression
    GN.comp.T_ij_mid    = T_in;
    
elseif PHYMOD.comp == 3
    %% Polytropic compression - TODO
    error('get_T_ij_mid_comp: Polytropic compression (PHYMOD.comp = 3) is not availabel.')

else
    error(['get_T_ij_mid_comp: PHYMOD.comp = ',num2str(PHYMOD.comp),' is not availabel.'])
    
end

end

