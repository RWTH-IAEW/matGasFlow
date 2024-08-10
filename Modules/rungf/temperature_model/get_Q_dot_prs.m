function[GN] = get_Q_dot_prs(GN, NUMPARAM, PHYMOD)
%GET_Q_DOT_PRS Calculation of heat exange for prsressor branches
%   [GN] = get_Q_dot_prs(GN, PHYMOD)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if GN.isothermal || ~isfield(GN,'prs') || all(~GN.prs.T_controlled)
    return
end

if any(GN.branch.V_dot_n_ij(GN.branch.prs_branch) < -NUMPARAM.numericalTolerance)
    warning('V_dot_n_ij at prs became negative.')
    GN.success = false;
end

%% Indices
has_expTur      = GN.prs.exp_turbine;
T_controlled    = GN.prs.T_controlled;
i_bus_in        = GN.branch.i_from_bus(GN.prs.i_branch);
i_bus_out       = GN.branch.i_to_bus(GN.prs.i_branch);

%% Quantities
p_in            = GN.bus.p_i(i_bus_in);
GN.prs.p_ij_mid = p_in;
p_mid           = GN.prs.p_ij_mid;
p_out           = GN.bus.p_i(i_bus_out);

T_in            = GN.bus.T_i(i_bus_in);
T_mid           = GN.prs.T_ij_mid;
T_out           = GN.branch.T_ij_out(GN.prs.i_branch);

Z_out           = GN.bus.Z_i(i_bus_out);

rho_n_avg       = GN.gasMixProp.rho_n_avg;
V_dot_n_ij      = GN.branch.V_dot_n_ij(GN.prs.i_branch);
eta_S           = GN.prs.eta_S;
eta_heater      = GN.prs.eta_heater;

%% Calculate T_ij_mid(T_ij_out) - PRS with control valve
i_prs           = T_controlled & ~has_expTur;
if any(i_prs)
    T_mid_temp  = zeros(sum(i_prs),1);
    iter        = 0;

    % Fix point iteration: T_mid = T_out - my_JT_avg(T_mid) * (p_out - p_in);
    while norm(GN.prs.T_ij_mid(i_prs) - T_mid_temp) > NUMPARAM.epsilon_T && iter < NUMPARAM.maxIter
        T_mid_temp              = GN.prs.T_ij_mid(i_prs);
        iter                    = iter + 1;
        GN                      = set_convergence(GN, ['get_Q_dot_prs, (',num2str(iter),')']);
        GN                      = get_Z(GN,PHYMOD,'prs');
        GN                      = get_c_p(GN,PHYMOD);
        GN                      = get_my_JT(GN, PHYMOD);
        my_JT_avg               = (GN.prs.my_JT_ij_mid+GN.branch.my_JT_ij_out(GN.prs.i_branch))/2;
        GN.prs.T_ij_mid(i_prs)  = T_out(i_prs) - my_JT_avg(i_prs) .* (p_out(i_prs) - p_in(i_prs));
    end
    if iter == NUMPARAM.maxIter
        warning('iter = NUMPARAM.maxIter')
    end
end

%% Calculate T_ij_mid(T_ij_out) - PRS with expasion turbine
i_expTur            = T_controlled & has_expTur;
if any(i_expTur)
    T_mid_temp      = zeros(sum(i_expTur),1);
    iter            = 0;
    % Fix point iteration: T_mid = T_out * Z_out/Z_mid(T_mid) / ( eta_S * ((p_out/p_mid)^((kappa_mid(T_mid)-1)/kappa_mid) - 1) + 1 )
    while norm(GN.prs.T_ij_mid(i_expTur) - T_mid_temp) > NUMPARAM.epsilon_T && iter < NUMPARAM.maxIter
        T_mid_temp          = GN.prs.T_ij_mid(i_expTur);
        iter                = iter + 1;
        GN                  = set_convergence(GN, ['get_Q_dot_prs, exp, (',num2str(iter),')']);
        GN                  = get_Z(GN, PHYMOD,'prs');
        GN                  = get_c_p(GN,PHYMOD);
        GN                  = get_kappa(GN, PHYMOD);
        Z_mid               = GN.prs.Z_ij_mid;
        if imag(Z_mid)~=0
            warning('...')
        end
        kappa_mid           = GN.prs.kappa_ij_mid;
        GN.prs.T_ij_mid(i_expTur)     = T_out(i_expTur) .* Z_out(i_expTur)./Z_mid(i_expTur) ./ ( eta_S(i_expTur) .* ((p_out(i_expTur)./p_mid(i_expTur)).^((kappa_mid(i_expTur)-1)./kappa_mid(i_expTur))-1) + 1 );
        if any(GN.prs.T_ij_mid < 0)
            error('get_Q_dot_prs: fix point iteration did noch converge: GN.prs.T_ij_mid < 0')
        end
    end
    if iter == NUMPARAM.maxIter
        warning('iter = NUMPARAM.maxIter')
    end
end

%% Q_dot_heater
GN                                  = get_c_p(GN,PHYMOD);
c_p_in                              = GN.bus.c_p_i(i_bus_in);
c_p_avg                             = (c_p_in + GN.prs.c_p_ij_mid)/2;
Q_dot_heater                        = V_dot_n_ij * rho_n_avg .* c_p_avg .* (T_mid - T_in)./eta_heater;
GN.prs.Q_dot_heater(T_controlled)   = Q_dot_heater(T_controlled);

end

