function [NUMPARAM] = getDefaultNumericalParameters()
%GETNUMERICALPARAMETERS Numerical parameters for steady-state gas flow
%   simulation
%
%   [NUMPARAM] = GETNUMERICALPARAMETERS() returns a struct with default
%   numerical paramteres. More information to come ...
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% G L O B A L   A C C U R A C Y
% Maximum number of while loop iterations
NUMPARAM.maxIter                    = 100;
NUMPARAM.maxIter_solver             = 100;
NUMPARAM.epsilon_norm_f             = 1e-9;     % Numerical convergence criteria for the pressure iterations
NUMPARAM.numericalTolerance         = 1e-12;
NUMPARAM.norm_OR_rms                = true;     % Convergence criterium: true -> norm, false -> rms

%% P E R F O R M A N C E   A N D   A C C U R A C Y 
% Apply solver to radial GN
NUMPARAM.assume_meshed_GN           = false;    % true: solve radial GN as a meshed GN
                                                % false: solve radial GN using the method for radial GNs

% Calculate pressure for radial GNs or as start solution for meshed GNs
NUMPARAM.radial_GN_start_solution   = true;     % true: ...
                                                % false: 

% Solver options
NUMPARAM.solver                     = 1;        % Solver, call 'help rungf_solvers' to view all options
NUMPARAM.aux_solver                 = 6;        % Auxiliary solver, call 'help rungf_solvers' to view all options
NUMPARAM.run_until_maxIter_solver   = false;    % Repeat solver until maxIter_solver is reached if last solver iteration failed
NUMPARAM.break_if_oscillation       = false;    % Break solver if values oscillate and if convergence is impossible

% Jacobian Matrix options (derivative)
NUMPARAM.OPTION_get_J               = 1;        % 1 ... 3       3 different models to calculate Jacobean Matrix. Model 1 is default. (TODO)
NUMPARAM.OPTION_get_J_dV_i_comp_dp  = true;     % true/false    true: take dV_{i,comp}/dp_i into account
NUMPARAM.OPTION_get_J_iter          = 1;        % Every xth repetition Jacobian Matrix is calculated

% Gradient descent options
NUMPARAM.epsilon_ADAGRAD            = 1e-12;
NUMPARAM.alpha_ADAGRAD              = 1e6;

% Levenberg-Marquardt options
NUMPARAM.omega_LM                   = 1e-12;
NUMPARAM.scale_omega_LM             = 10;       % choose > 1

% Damping
NUMPARAM.omega_damping_model        = 0;        % (0) no damping; (1) Binary search/DahmenReusken; (2) Golden Section Search
NUMPARAM.omega_min                  = 1e-6;     % minimal damping parameter: 0 < omega <= 1
NUMPARAM.omega_adaption_DR          = 0.5;      % Omega adaption factor for Dahmen-Reusken damping method: must be (0...1] (double) OR 'rand' (char)
NUMPARAM.epsilon_Delta_omega        = 1e-6;     % Option for Golden Section Search method. Abort if abs(omega4-omega1) > NUMPARAM.epsilon_Delta_omega

% update p_i dependent quantities
NUMPARAM.always_update_p_i_dependent_quantities = true; % set 'false' to reduce runtime. If set 'false', update_p_i_dependent_quantities runs if log10(norm(GN.bus.f)) < 1/2*log10(NUMPARAM.epsilon_norm_f)

%% A C C U R A C Y   O F   S U B F U N C T I O N S
% V_dot_n_ij_pipe
NUMPARAM.OPTION_get_V_dot_n_ij_pipe = 1;        % Options: 1, 2; Both methods are mathematically equivalent. They may differ for numerical reasons. Call 'help get_V_dot_n_ij_pipe' for more information

% abort criterion of different loops
NUMPARAM.epsilon_lambda             = 1e-9;     % Tolerance for rediuum of friction factor
NUMPARAM.epsilon_p_i                = 1e-9;     % norm((p_k-p_{k-1})./p_{k-1}) < NUMPARAM.epsilon_p_i
NUMPARAM.epsilon_T                  = 1e-9;     % norm((T_k-T_{k-1})./T_{k-1}) < NUMPARAM.epsilon_T
NUMPARAM.epsilon_Z_AGA8_92DC        = 1e-9;     % Tolerance for rediuum in calculate_Z_AGA8_92DC

%% matGasFlow Add-ons (not part of open source version)
% Newton Raphson Parampeters
NUMPARAM.dp_NR                      = 1e-6;     % pressure disturbance dp to build up the Jacobian Matrix for the NR method

% Radial and meshed gas networks
NUMPARAM.omega_get_p_i_FPI          = 1e-3;     % Damped fixed point iteration method to estimate nodal pressure

end

