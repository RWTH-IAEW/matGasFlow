function[GN] = get_T_prs(GN, NUMPARAM, PHYMOD)
%GET_T_PRS Calculation of temperature for PRS branches
%   [GN] = get_T_prs(GN, PHYMOD)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if any(GN.branch.V_dot_n_ij(GN.branch.prs_branch) < -NUMPARAM.numericalTolerance)
    warning('V_dot_n_ij at prs became negative.')
    GN.success = false;
end

%% Indices
has_expTur      = GN.prs.exp_turbine;
T_controlled    = GN.prs.T_controlled;
Q_controlled    = ~T_controlled;
i_bus_in        = GN.branch.i_from_bus(GN.prs.i_branch);
i_bus_out       = GN.branch.i_to_bus(GN.prs.i_branch);

%% Update p_ij_mid
GN.prs.p_ij_mid = GN.bus.p_i(i_bus_in);

%% Quantities
T_in            = GN.bus.T_i(i_bus_in);

%% apply T_ij_out for all T_controlled prs
GN.branch.T_ij_out(GN.prs.i_branch(T_controlled)) = GN.prs.T_ij_out(T_controlled);

%% Calulcate T_ij_mid for all T_controlled prs and compare T_ij_in vs. T_ij_mid
if any(T_controlled)
    GN = get_Q_dot_prs(GN, NUMPARAM, PHYMOD);

    i_prs_no_heating                        = T_controlled & GN.prs.T_ij_mid<T_in;
    GN.prs.T_controlled(i_prs_no_heating)   = false;
    GN.branch.T_controlled                  = GN.prs.T_controlled(GN.branch.i_prs);
    GN.prs.Q_dot_heater(i_prs_no_heating)   = 0;
    T_controlled                            = GN.prs.T_controlled;
    Q_controlled                            = ~T_controlled;
    GN                                      = get_Z(GN, PHYMOD, 'branch');
    GN                                      = set_convergence(GN, 'get_T_prs, T_mid(T_controlled)');
end

%% Calulcate T_ij_out for all Q_controlled prs
if any(Q_controlled)
    
    %% Quantities
    p_mid           = GN.prs.p_ij_mid;
    p_out           = GN.bus.p_i(i_bus_out);
    rho_n_avg       = GN.gasMixProp.rho_n_avg;
    V_dot_n_ij      = GN.branch.V_dot_n_ij(GN.prs.i_branch);
    Q_dot_heater    = GN.prs.Q_dot_heater;

    %% Calculate T_ij_mid(Q_dot_heater)
    T_mid_temp                          = zeros(sum(Q_controlled),1);
    iter                                = 0;

    % Fix point iteration: T_mid = Q_dot_heater / V_dot_n_ij / rho_n_avg / c_p_avg(T_mid) + T_in;
    while norm(GN.prs.T_ij_mid(Q_controlled) - T_mid_temp) > NUMPARAM.epsilon_T && iter < NUMPARAM.maxIter
        T_mid_temp                      = GN.prs.T_ij_mid(Q_controlled);
        iter                            = iter + 1;
        GN                              = set_convergence(GN, ['get_T_prs, T_mid(Q_controlled), (',num2str(iter),')']);
        GN                              = get_Z(GN, PHYMOD, 'prs');
        GN                              = get_c_p(GN, PHYMOD);
        c_p_avg                         = (GN.bus.c_p_i(i_bus_in) + GN.prs.c_p_ij_mid)/2;
        GN.prs.T_ij_mid(Q_controlled)   = Q_dot_heater(Q_controlled) ./ V_dot_n_ij(Q_controlled) / rho_n_avg ./ c_p_avg(Q_controlled) + T_in(Q_controlled);
    end
    if iter == NUMPARAM.maxIter
        warning('iter = NUMPARAM.maxIter')
    end
    
    %% Calculate T_ij_out(T_ij_mid) - PRS with control valve
    i_prs                               = Q_controlled & ~has_expTur;
    if any(i_prs)
        GN                              = get_my_JT(GN, PHYMOD);
        my_JT_ij_mid                    = GN.prs.my_JT_ij_mid;
        my_JT_ij_out                    = GN.branch.my_JT_ij_out(GN.prs.i_branch);
        my_JT_avg                       = (my_JT_ij_mid+my_JT_ij_out)/2;
        GN.branch.T_ij_out(i_prs)       = GN.prs.T_ij_mid(i_prs) + my_JT_avg .* (p_out(i_prs)-p_mid(i_prs));
        
        GN.prs.Delta_T_heater(i_prs)        = Q_dot_heater(i_prs) ./ V_dot_n_ij(i_prs) ./ rho_n_avg ./ c_p_avg(i_prs);
        GN.prs.Delta_T_controlValve(i_prs)  = my_JT_avg(i_prs) .* (p_out(i_prs)-p_mid(i_prs));
        
        % T_ij_out = chi + psi * T_in = Delta_T_heater + Delta_T_controlValve + T_in
        GN.branch.chi_ij(GN.prs.i_branch(i_prs)) = GN.prs.Delta_T_heater(i_prs) + GN.prs.Delta_T_controlValve(i_prs);
        GN.branch.psi_ij(GN.prs.i_branch(i_prs)) = 1;
        
    end
    
    %% Calculate T_out(Q_dot_heater) - PRS with expasion turbine
    i_expTur                = Q_controlled & has_expTur;
    if any(i_expTur)
        % Quantities
        GN                  = get_kappa(GN, PHYMOD);
        Z_mid               = GN.prs.Z_ij_mid;
        kappa_mid           = GN.prs.kappa_ij_mid;
        eta_S               = GN.prs.eta_S;
        
        T_out_temp          = zeros(sum(i_expTur),1);
        iter                = 0;

        % Fix point iteration: T_out = T_mid*Z_mid/Z_out(T_out) * ( eta_S * ((p_out/p_mid)^((kappa_mid-1)/kappa_mid) - 1) + 1 )
        while norm(GN.branch.T_ij_out(i_expTur) - T_out_temp) > NUMPARAM.epsilon_T && iter < NUMPARAM.maxIter
            T_out_temp  = GN.branch.T_ij_out(i_expTur);
            iter        = iter + 1;
            GN          = set_convergence(GN, ['get_T_prs, T_out_exp(Q_controlled), (',num2str(iter),')']);
            GN          = get_Z(GN,PHYMOD,'branch');
            Z_out       = GN.branch.Z_ij_out(GN.prs.i_branch);
            GN.branch.T_ij_out(i_expTur)    = GN.prs.T_ij_mid(i_expTur) .* Z_mid(i_expTur)./Z_out(i_expTur) ...
                .* ( eta_S(i_expTur) .* ((p_out(i_expTur)./p_mid(i_expTur)).^((kappa_mid(i_expTur)-1)./kappa_mid(i_expTur)) - 1) + 1 );
        end
        if iter == NUMPARAM.maxIter
            warning('iter = NUMPARAM.maxIter')
        end
        
        GN.prs.Delta_T_heater(i_expTur) = Q_dot_heater(i_expTur) ./ V_dot_n_ij(i_expTur) ./ rho_n_avg ./ c_p_avg(i_expTur);
        
        % T_ij_out = T_ij_mid * psi = T_ij_in * psi + chi = T_ij_in * psi + Delta_T_heater * psi
        GN.branch.psi_ij(GN.prs.i_branch(i_expTur)) = GN.branch.T_ij_out(GN.prs.i_branch(i_expTur))./GN.prs.T_ij_mid(i_expTur);
        GN.branch.chi_ij(GN.prs.i_branch(i_expTur)) = GN.prs.Delta_T_heater(i_expTur) .* GN.branch.psi_ij(GN.prs.i_branch(i_expTur));
        
        
    end
else
    GN.branch.chi_ij(GN.prs.i_branch) = 0;
    GN.branch.psi_ij(GN.prs.i_branch) = 0;
end

%% TODO: delete
GN.branch.chi_ij_3(GN.prs.i_branch) = GN.branch.chi_ij(GN.prs.i_branch);

%% Delta_T_ij
GN.branch.Delta_T_ij(GN.prs.i_branch) = T_in - GN.branch.T_ij_out(GN.prs.i_branch);

end
