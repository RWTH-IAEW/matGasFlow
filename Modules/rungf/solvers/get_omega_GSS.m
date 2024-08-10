function [GN,success] = get_omega_GSS(GN, GN_0, NUMPARAM, PHYMOD)
%GET_OMEGA_GSS
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

success = true;

%%
p_i_0       = GN_0.bus.p_i;
Delta_p_0   = GN.bus.p_i - p_i_0;
norm_f_0    = norm(GN_0.bus.f);

%% Constants
CONST = getConstants();

%% Golden secation
gr              = (sqrt(5) + 1) / 2;

%% norm_f(omega1)
omega1      = 0;
norm_f_1    = norm_f_0;

%% norm_f(omega4)
omega4      = 1;
norm_f_4    = norm(GN.bus.f);

%% Check convergence
if norm_f_4 < norm_f_1
    return
end

iter = 0;
while abs(omega4-omega1) > NUMPARAM.epsilon_Delta_omega
    iter    = iter + 1;
    GN      = set_convergence(GN, ['get_omega_GSS, (',num2str(iter),')']);

    %% calculate omega2, omega3
    omega2 = omega4 - (omega4 - omega1) / gr;
    omega3 = omega1 + (omega4 - omega1) / gr;

    %% Check norm_f(omega2)
    %     if iter == 1 || norm_f_2_temp < norm_f_3_temp

    GN.bus.p_i = p_i_0 + omega2 * Delta_p_0;
    if any(GN.bus.p_i < CONST.p_n)
        GN.bus.p_i(GN.bus.p_i < CONST.p_n) = CONST.p_n;
    end

    % Update p_i dependent quantities and nodal equation
    GN          = update_p_i_dependent_quantities(GN, NUMPARAM, PHYMOD);
    GN          = get_f_nodal_equation(GN, NUMPARAM, PHYMOD, 'bus');

    % Set convergence
    GN          = set_convergence(GN, ['get_omega_GSS, (',num2str(iter),')']);

    % Check convergence
    norm_f_2    = norm(GN.bus.f);
    if norm_f_2 < norm_f_1
        return
    end
    %     else
    %         norm_f_2    = norm_f_3_temp;
    %     end

    %% Check norm_f(omega3)
    %     if iter == 1 || norm_f_2_temp > norm_f_3_temp

    GN.bus.p_i = p_i_0 + omega3 * Delta_p_0;
    if any(GN.bus.p_i < CONST.p_n)
        GN.bus.p_i(GN.bus.p_i < CONST.p_n) = CONST.p_n;
    end

    % Update p_i dependent quantities and nodal equation
    GN          = update_p_i_dependent_quantities(GN, NUMPARAM, PHYMOD);
    GN          = get_f_nodal_equation(GN, NUMPARAM, PHYMOD, 'bus');
    
    % Check convergence
    norm_f_3    = norm(GN.bus.f);
    if norm_f_3 < norm_f_1
        return
    end
    %     else
    %         norm_f_3 = norm_f_2_temp;
    %     end

    %% Update limits x1 and x4
    if min([norm_f_1,norm_f_2]) < min([norm_f_3,norm_f_4])
        omega4      = omega3;
        norm_f_4    = norm_f_3;
    else
        omega1      = omega2;
        norm_f_1    = norm_f_2;
    end
    %     norm_f_2_temp = norm_f_2;
    %     norm_f_3_temp = norm_f_3;
end

success = false;

end



