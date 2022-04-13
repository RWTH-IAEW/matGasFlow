function [GN, success] = rungf(GN, NUMPARAM, PHYMOD)
%RUNGF Steady-state gas flow simulation
%
%   [GN] = RUNGF(GN, NUMPARAM, PHYMOD)
%   
%   Input arguments:
%       GN (necessarry):        gas network struct ...
%                               OR file name of the gas network model
%                               (string)
%       NUMPARAM (optional):    struct with numerical parameter
%       PHYMOD (optional):      struct with physical model settings
%
%   Output:
%       GN: gas network struct containing all results
%
%   Calling syntax options:
%       GN = rungf(GN);
%       GN = rungf(GN, NUMPARAM);
%       GN = rungf(GN, NUMPARAM, PHYMOD);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2022, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Set default input arguments
if nargin < 3
    PHYMOD = getDefaultPhysicalModels();
    
    if nargin < 2
        NUMPARAM = getDefaultNumericalParameters();
    end
end

%% Success
success = true;

%% Check GN data type
flag_remove_auxiliary_variables = 0;
if ischar(GN)
    GN = load_GN(GN);
    flag_remove_auxiliary_variables = 1;
end

%% Check for get_T add-on
path = which('get_T.m');
if isempty(path) && GN.isothermal ~=1
    error('Non-isothermal model not available, choose GN.isothermal = 1')
end

%% Save Input
GN_input = GN;

%% Initialization
if size(GN.bus,1) > 1
    GN = init_rungf(GN, NUMPARAM, PHYMOD);
elseif size(GN.bus,1) == 1
%     warning('GN has only one bus.')
    return
elseif size(GN.bus,1) == 0
    error('GN has no bus.')
end

%% any(GN.branch.connecting_branch)?
if ~any(GN.branch.connecting_branch) && NUMPARAM.OPTION_rungf == 1
    %% rungf for radial gas network
    iter = 0;
    while 1
        iter = iter + 1;
        
        % Update slack bus
        GN.bus.V_dot_n_i(GN.bus.slack_bus) = GN.bus.V_dot_n_i(GN.bus.slack_bus) - sum(GN.bus.V_dot_n_i)/sum(GN.bus.slack_bus);
        
        % Update V_dot_n_ij
        GN = get_V_dot_n_ij_radialGN(GN);
        
        % Calulation of nodal temperature
        if GN.isothermal ~= 1
            GN = get_T_loop(GN, NUMPARAM, PHYMOD);
        end
        
        % Calculation of p_i based on general gas flow equation
        [GN, success] = get_p_i_SLE(GN, PHYMOD);
        if ~success
            return
        end
        
        % Update nodal equation
        NUMPARAM.OPTION_get_V_dot_n_ij_pipe = 2;
        GN = get_f_nodal_equation(GN, NUMPARAM, PHYMOD);
        
        % Check convergence
        GN = set_convergence(GN, ['$$rungf rad. GN (',num2str(iter),')$$']);
        if norm(GN.bus.f) < NUMPARAM.epsilon_NR_f
            break
        elseif iter >= NUMPARAM.maxIter
            error(['rungf: Non-converging while-loop. Number of interation: ',num2str(iter)])
        end
        
    end
else
    %% rungf for meshed gas network
    % V_dot_n_ij start solution - Solving a System of Linear Equations
    % UNDER CONSTRUCTION: option to apply start solution and skip init_V_dot_n_ij
    GN = init_V_dot_n_ij(GN);
    
    % Start solution p_i
    [GN, success] = get_p_i(GN, NUMPARAM, PHYMOD);
    if ~success
        return
    end
    
    % Newton Raphson
    [GN, success] = Newton_Raphson_method(GN, NUMPARAM, PHYMOD);
    % [GN,success] = Secant_method(GN, NUMPARAM, PHYMOD);
    % [GN,success] = Levenberg_Marquardt_method(GN, NUMPARAM, PHYMOD);
    if ~success
        return
    end
    
end

%% Prepair results
GN = get_GN_res(GN, GN_input, flag_remove_auxiliary_variables, NUMPARAM, PHYMOD);

end