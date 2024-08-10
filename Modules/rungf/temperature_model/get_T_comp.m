function GN = get_T_comp(GN, NUMPARAM, PHYMOD)
%GET_T_COMP Calculation of temperature for compressor branches
%   [GN] = get_T_comp(GN, PHYMOD)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if any(GN.branch.V_dot_n_ij(GN.branch.comp_branch) < -NUMPARAM.numericalTolerance)
    warning('V_dot_n_ij at compressor became negative.')
    GN.success = false;
end

%% Indices
T_controlled        = GN.comp.T_controlled;
Q_controlled        = ~T_controlled;
i_bus_in            = GN.branch.i_from_bus(GN.comp.i_branch);
i_bus_out           = GN.branch.i_to_bus(GN.comp.i_branch);

%% T_in
T_in                = GN.bus.T_i(i_bus_in);

%% Update p_ij_mid
GN.comp.p_ij_mid    = GN.bus.p_i(i_bus_out);

%% Calculate T_ij_mid
GN                  = get_T_ij_mid_comp(GN, NUMPARAM, PHYMOD);

%% Calulcate T_ij_out for all Q_controlled comp
if any(Q_controlled)
    
    %% Quantities
    rho_n_avg       = GN.gasMixProp.rho_n_avg;
    V_dot_n_ij      = GN.branch.V_dot_n_ij(GN.comp.i_branch(Q_controlled));
    Q_dot_cooler    = GN.comp.Q_dot_cooler(Q_controlled);
    
    %% Calculate T_ij_out(Q_dot_cooler)
    T_out_temp                  = zeros(size(GN.comp,1),1);
    iter                        = 0;

    % Fix point iteration: T_out = Q_dot_cooler / V_dot_n_ij  / rho_n_avg / c_p_avg(T_out) + T_mid
    while norm(T_out_temp - GN.branch.T_ij_out(GN.comp.i_branch)) > NUMPARAM.epsilon_T && iter < NUMPARAM.maxIter
        T_out_temp              = GN.branch.T_ij_out(GN.comp.i_branch);
        iter                    = iter+1;
        GN                      = set_convergence(GN, ['get_T_comp, (',num2str(iter),')']);
        GN                      = get_Z(GN,PHYMOD,'bus');   % Z_out
        GN                      = get_c_p(GN,PHYMOD);       % c_p_out
        c_p_out                 = GN.bus.c_p_i(i_bus_out(Q_controlled));
        c_p_avg                 = (c_p_out + GN.comp.c_p_ij_mid(Q_controlled))/2;
        T_mid                   = GN.comp.T_ij_mid;
        GN.branch.T_ij_out(GN.comp.i_branch(Q_controlled))  = Q_dot_cooler ./ V_dot_n_ij  ./ rho_n_avg ./ c_p_avg + T_mid;
        GN.comp.Delta_T_cooler(Q_controlled)                = Q_dot_cooler ./ V_dot_n_ij  ./ rho_n_avg ./ c_p_avg;
    end
    
    % T_ij_out = chi + psi * T_in = T_in * T_mid/T_in + Delta_T_cooler
    GN.branch.chi_ij(GN.comp.i_branch(Q_controlled))    = GN.comp.Delta_T_cooler(Q_controlled);
    GN.branch.psi_ij(GN.comp.i_branch(Q_controlled))    = GN.comp.T_ij_mid(Q_controlled)./T_in(Q_controlled);
end

%% Calulcate T_ij_out for all T_controlled comp
if any(T_controlled)
    %% apply T_ij_out for all T_controlled comp
    GN.branch.T_ij_out(GN.comp.i_branch(T_controlled))  = min([GN.comp.T_ij_out(T_controlled), GN.comp.T_ij_mid],[],2);
    GN.branch.chi_ij(GN.comp.i_branch(T_controlled))    = 0;%GN.branch.T_ij_out(GN.comp.i_branch(T_controlled)); % TODO
    GN.branch.psi_ij(GN.comp.i_branch(T_controlled))    = 0;
end

%% TODO: delete
GN.branch.chi_ij_3(GN.comp.i_branch) = GN.branch.chi_ij(GN.comp.i_branch);

%% Delta_T_ij
T_in = GN.bus.T_i(i_bus_in);
GN.branch.Delta_T_ij(GN.comp.i_branch) = T_in - GN.branch.T_ij_out(GN.comp.i_branch);

end

