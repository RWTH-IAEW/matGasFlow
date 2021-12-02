function [GN] = rungf(GN, NUMPARAM, PHYMOD)
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
%   Copyright (c) 2020-2021, High Voltage Equipment and Grids,
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

%% Initialization
GN = init_rungf(GN, PHYMOD);

%% any(GN.branch.connecting_branch)?
if ~any(GN.branch.connecting_branch) && NUMPARAM.OPTION_rungf == 1
    %%
    iter = 0;
    while 1
        iter = iter + 1;
        
        %% Update V_dot_n_ij
        GN = get_V_dot_n_ij_radialGN(GN);
        
        %% Calculation of p_i based on general gas flow equation
        GN = get_p_i_SLE(GN, PHYMOD);
        
        %% Calulation of nodal temperature
        if GN.isothermal ~= 1
            GN = get_T_loop(GN, NUMPARAM, PHYMOD);
        end
        
        %% Update nodal equation
        NUMPARAM.OPTION_get_V_dot_n_ij_pipe = 2;
        GN = get_f_nodal_equation(GN, NUMPARAM, PHYMOD);
        
        %% Check convergence
        GN = set_convergence(GN, ['$$rungf rad. GN (',num2str(iter),')$$']);
        if norm(GN.bus.f) < NUMPARAM.epsilon_NR_f
            break
        elseif iter >= NUMPARAM.maxIter
            error(['rungf: Non-converging while-loop. Number of interation: ',num2str(iter)])
        end
        
    end
else
    %% V_dot_n_ij Start Solution - Solving a System of Linear Equations
    if ~any(strcmp('V_dot_n_ij',GN.branch.Properties.VariableNames)) || ~any(isnan(GN.branch.V_dot_n_ij)) 
        GN = init_V_dot_n_ij(GN);
    end
    
    %% Start solution p_i
    if NUMPARAM.OPTION_rungf_meshedGN == 1
        GN = get_p_i_SLE_loop(GN, NUMPARAM, PHYMOD);
        
    elseif NUMPARAM.OPTION_rungf_meshedGN == 2
        GN = get_p_i_SLE(GN, PHYMOD);
        
    elseif NUMPARAM.OPTION_rungf_meshedGN == 3
        GN = get_p_i_Adm_loop(GN, NUMPARAM, PHYMOD);
        
    elseif NUMPARAM.OPTION_rungf_meshedGN == 4
        GN = get_p_i_Adm(GN, PHYMOD);
        
    elseif NUMPARAM.OPTION_rungf_meshedGN == 5
        try
            GN = get_p_i_DarcyWeisbach_loop(GN, NUMPARAM, PHYMOD);
        catch
            error('Option not available, choose NUMPARAM.OPTION_rungf_meshedGN = 1, 2, 3 or 4')
        end
        
    elseif NUMPARAM.OPTION_rungf_meshedGN == 6
        try
            GN = get_p_i_DarcyWeisbach(GN, PHYMOD);
        catch
            error('Option not available, choose NUMPARAM.OPTION_rungf_meshedGN = 1, 2, 3 or 4')
        end
        
    end
    
    %% Newton Raphson
    GN = Newton_Raphson_method(GN, NUMPARAM, PHYMOD);
    
end

%% Additional result
GN = get_GN_res(GN, NUMPARAM, PHYMOD);

%% Remove auxiliary variables
if flag_remove_auxiliary_variables == 1
    GN = remove_auxiliary_variables(GN);
end

end