function [NUMPARAM] = getDefaultNumericalParameters()
%GETNUMERICALPARAMETERS Numerical parameters for steady-state gas flow
%   simulation
%
%   [NUMPARAM] = GETNUMERICALPARAMETERS() returns a struct with default
%   numerical paramteres. More information to come ...
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2022, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% A C C U R A C Y
% Maximum number of while loop iterations
NUMPARAM.maxIter            = 50;
NUMPARAM.epsilon_NR_f       = 1e-3;         % Numerical convergence criteria for the pressure iterations
NUMPARAM.epsilon_lambda     = 1e-3;         % Calculation accuracy of lambda
NUMPARAM.numericalTolerance = 1e-12;

%% P E R F O R M A N C E
%% Parameter setting by genetic algorithm

% OPTION
NUMPARAM.OPTION_assume_meshed_GN = false;   % true/false    true: Solve radial GNs like meshed GNs
NUMPARAM.OPTION_get_J = 1;                  % 1 ... 3       3 different models to calculate Jacobean Matrix
NUMPARAM.OPTION_get_J_dV_i_comp_dp = true;  % true/false    true: take dV_{i,comp}/dp_i into account
NUMPARAM.OPTION_get_V_dot_n_ij_pipe = 1;    % 1 ... 2      	call 'help get_V_dot_n_ij_pipe' for more information
NUMPARAM.OPTION_rungf_get_p_i = 1;          % 1 ... 4       call 'help get_p_i' for more information

% Meshed GNs: Options to calculate p_i start solution
NUMPARAM.epsilon_p_i_loop = 1e-3;           %
NUMPARAM.epsilon_V_dot_n_ij_loop = 1e-3;    %

% Newton Raphson Parampeters
NUMPARAM.dp_NR = 1e-6;                      % pressure disturbance dp to build up the Jacobian Matrix for the NR method
NUMPARAM.OPTION_NR_damping = true;          % true/false
NUMPARAM.omega_NR_min = 1e-1;               % minimal damping parameter: must be 0 < omega_NR_min <= 1
NUMPARAM.omega_adaption_NR = 0.5;           % Reduction speed of omega. Default: 0.5
NUMPARAM.OPTION_get_J_iter = 1;             % Every xth repetition Jacobian Matrix is calculated. speedup_NR_iter >= 1
NUMPARAM.OPTION_update_p_i_dependent_quantities_iter = 1; % update p_i dependent quantities every i iterations

% Non-isothermal model
NUMPARAM.epsilon_get_T_loop_T_i = 1e-3;     % 

%% matGasFlow Add Ons (not open source)
% Radial and meshed gas networks
NUMPARAM.epsilon_get_p_i_FPI = 1e-3;        % 
NUMPARAM.omega_get_p_i_FPI = 1e-3;          % 

% Heuristic based on Darcy Wwisbach equation
NUMPARAM.epsilon_DW_p_i         = 1e-3;     % rungf_DW: epsilon for p_i while loop
NUMPARAM.epsilon_DW_V_dot_n_ij  = 1e-3;     % rungf_DW: epsilon for V_dot_n_ij while loop
NUMPARAM.omega_DW_V_dot_n_ij    = 0.7;      % rungf_DW: omega damping factor for V_dot_n_ij while loop

end

