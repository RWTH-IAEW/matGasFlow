function [NUMPARAM] = getDefaultNumericalParameters()
%GETNUMERICALPARAMETERS Numerical parameters for steady-state gas flow calculation
%   [NUMPARAM] = GETNUMERICALPARAMETERS() returns a struct
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2021, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% A C C U R A C Y
% Maximum number of while loop iterations
NUMPARAM.maxIter = 50;
NUMPARAM.epsilon_NR_f = 1e-2;               % Numerical convergence criteria for the pressure iterations
NUMPARAM.epsilon_lambda = 1e-3;             % Calculation accuracy of lambda
NUMPARAM.numericalTolerance = 1e-12;

%% P E R F O R M A N C E
%% Parameter setting by genetic algorithm

% OPTION
NUMPARAM.OPTION_rungf = 1;                  % 1, 2
NUMPARAM.OPTION_get_J = 1;                  % 1 ... 3
NUMPARAM.OPTION_get_f_nodal_equation = 1;   % 1 ... 4
NUMPARAM.OPTION_get_V_dot_n_ij_pipe = 1;    % 1, 2
NUMPARAM.OPTION_rungf_meshedGN = 3;         % 1, 2

% Radial and meshed gas networks
NUMPARAM.epsilon_get_f_nodal_equation = 1e-3;      % General Gas Flow Equation: epsilon for V_dot_n_ij while loop
NUMPARAM.epsilon_get_p_i_SLE = 1e-3;        % General Gas Flow Equation: epsilon for p_i while loop
NUMPARAM.epsilon_get_p_i_FPI = 1e-3;        % 
NUMPARAM.omega_get_p_i_FPI = 0.001;         % 

% Meshed gas networks
NUMPARAM.epsilon_p_i_loop = 1e-2;           %
NUMPARAM.epsilon_V_dot_n_ij_loop = 1e-1;    %

NUMPARAM.epsilon_DW_p_i = 1e-2;             % rungf_DW: epsilon for p_i while loop
NUMPARAM.epsilon_DW_V_dot_n_ij = 1e-1;      % rungf_DW: epsilon for V_dot_n_ij while loop
NUMPARAM.omega_DW_V_dot_n_ij = 0.7;         % rungf_DW: omega damping factor for V_dot_n_ij while loop

% Non-isothermal model
NUMPARAM.epsilon_get_T_loop_T_i = 1e-3;     % 

% Newton Raphson Parampeters
NUMPARAM.dp_NR = 1e-6;                      % pressure disturbance dp to build up the Jacobian Matrix for the NR method
NUMPARAM.OPTION_NR_damping = 1;             % 1 = on ; 2 = no damping;
NUMPARAM.omega_NR_min = 1e-6;               % minimal damping parameter: must be 0 < omega_NR_min <= 1
NUMPARAM.omega_adaption_NR = 0.5;           % Reduction speed of omega. Default: 0.5
NUMPARAM.OPTION_get_J_iter = 1; % Every xth repetition Jacobian Matrix is calculated. speedup_NR_iter >= 1

