function GN = get_T_pipe(GN,PHYMDO)
%GET_T_PIPE
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
V_dot_n_ij                  = GN.branch.V_dot_n_ij;
i_bus_in                    = GN.branch.i_from_bus;
i_bus_in(V_dot_n_ij < 0)    = GN.branch.i_to_bus(V_dot_n_ij < 0);
i_bus_out                   = GN.branch.i_to_bus;
i_bus_out(V_dot_n_ij < 0)   = GN.branch.i_from_bus(V_dot_n_ij < 0);
i_bus_in_pipe               = i_bus_in(GN.pipe.i_branch);
i_bus_out_pipe              = i_bus_out(GN.pipe.i_branch);

%% Update Omega
% get_Z(GN, PHYMOD, {'bus','pipe'}),get_c_p(GN, PHYMOD) --> already up to date
GN = get_Omega(GN);

%% my_JT
GN                          = get_my_JT(GN, PHYMDO);

%% Quantities
p_in        = GN.bus.p_i(i_bus_in_pipe);
p_out       = GN.bus.p_i(i_bus_out_pipe);
T_i         = GN.bus.T_i;
T_env_ij    = GN.pipe.T_env_ij;
Omega_ij    = GN.pipe.Omega_ij;
my_JT_in    = GN.bus.my_JT_i(i_bus_in_pipe);
my_JT_out   = GN.branch.my_JT_ij_out(GN.pipe.i_branch);
my_JT_avg   = (my_JT_in + my_JT_out)/2;
L_ij        = GN.pipe.L_ij;

%% T_ij_out = chi + psi * T_ij_in
GN.branch.chi_ij(GN.pipe.i_branch) = ...
    T_env_ij .* (1 - exp(-Omega_ij .* L_ij)) ...
    - (my_JT_avg .* (p_in - p_out)) ...
        ./ (Omega_ij .* L_ij) .* (1 - exp(-Omega_ij .* L_ij));

GN.branch.psi_ij(GN.pipe.i_branch) = exp(-Omega_ij .* L_ij);

%% T_ij_out
GN.branch.T_ij_out(GN.pipe.i_branch) = T_i(i_bus_in_pipe) .* GN.branch.psi_ij(GN.pipe.i_branch) + GN.branch.chi_ij(GN.pipe.i_branch);

%% Delta_T_ij
GN.branch.Delta_T_ij(GN.pipe.i_branch) = T_i(i_bus_in_pipe) - GN.branch.T_ij_out(GN.pipe.i_branch);

%% T_ij_out = chi + psi * T_ij_in
chi_ij_3a = T_env_ij .* (1 - exp(-Omega_ij .* L_ij));
chi_ij_3b = - my_JT_avg/2 .* sqrt(pi*(p_in.^2-p_out.^2)./L_ij./Omega_ij) .* exp(Omega_ij.*p_in.^2./(p_in.^2-p_out.^2).*L_ij - Omega_ij.*L_ij) ...
    .* (erf(sqrt(Omega_ij.*p_in.^2./(p_in.^2-p_out.^2).*L_ij)) - erf(sqrt(Omega_ij.*p_in.^2./(p_in.^2-p_out.^2).*L_ij - Omega_ij.*L_ij)));
chi_ij_3b(isnan(chi_ij_3b)) = 0;
GN.branch.chi_ij_3(GN.pipe.i_branch) = chi_ij_3a + chi_ij_3b;

end

