function [GN] = get_T_ij(GN)
%GET_T_IJ
%
%   Average temperature of the gas in pipe.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~isfield(GN,'pipe')
    return
end

if ~ismember('Omega_ij',GN.pipe.Properties.VariableNames)
    iF              = GN.branch.i_from_bus(GN.pipe.i_branch);
    iT              = GN.branch.i_to_bus(GN.pipe.i_branch);
    GN.pipe.T_ij    = mean([GN.bus.T_i(iF),GN.bus.T_i(iT)],2);
else
    i_in            = GN.branch.i_from_bus(GN.pipe.i_branch);
    i_out           = GN.branch.i_to_bus(GN.pipe.i_branch);
    i_in( GN.branch.V_dot_n_ij(GN.pipe.i_branch) < 0)   = i_out(GN.branch.V_dot_n_ij(GN.pipe.i_branch) < 0);
    i_out(GN.branch.V_dot_n_ij(GN.pipe.i_branch) < 0)   = i_in( GN.branch.V_dot_n_ij(GN.pipe.i_branch) < 0);
    p_in            = GN.bus.p_i(i_in);
    p_out           = GN.bus.p_i(i_out);
    T_in            = GN.bus.T_i(i_in);

    L_ij            = GN.pipe.L_ij;
    Omega_ij        = GN.pipe.Omega_ij;
    my_JT_avg       = (GN.bus.my_JT_i(i_in));% + GN.bus.my_JT_i(i_out))/2;

    GN.pipe.T_ij    = ...
                        (T_in - GN.T_env)./(Omega_ij.*L_ij) .* (1-exp(-Omega_ij.*L_ij)) ...
                        + GN.T_env ...
                        - my_JT_avg .* (p_in-p_out) ./ (Omega_ij.*L_ij) ...
                        .* (1 - (1-exp(-Omega_ij.*L_ij))./(Omega_ij.*L_ij));

end

% if ~GN.isothermal
    GN.branch.T_ij_out(GN.branch.pipe_branch) = GN.pipe.T_ij(GN.branch.i_pipe(GN.branch.pipe_branch));
% end

end

