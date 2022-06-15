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
%       success: rungf is not successful if pressure becomes negative
%
%   Calling syntax options:
%       GN = rungf(GN);
%       GN = rungf(GN, NUMPARAM);
%       GN = rungf(GN, NUMPARAM, PHYMOD);
%       [GN,success] = rungf(__)
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
GN.success = true;
if isfield(GN, 'bus') && isfield(GN, 'branch')
    GN = init_rungf(GN, NUMPARAM, PHYMOD);
elseif isfield(GN, 'bus')
    GN = get_nodalGasMixProp(GN, PHYMOD);
    return
else
    error('GN has no busses and branches.')
end

%% any(GN.branch.connecting_branch)?
if ~any(GN.branch.connecting_branch) && ~NUMPARAM.OPTION_assume_meshed_GN
    %% rungf for radial gas network
    [GN, success] = rungf_radial_GN(GN, NUMPARAM, PHYMOD);
    if ~success
        GN.success = success;
        return
    end
    
else
    %% rungf for meshed gas network
    % V_dot_n_ij start solution
    GN = init_V_dot_n_ij(GN);
    
    % p_i start solution 
    [GN, success] = get_p_i(GN, NUMPARAM, PHYMOD);
    if ~success
        GN.success = success;
        return
    end
    
    % Newton Raphson
    [GN, success] = Newton_Raphson_method(GN, NUMPARAM, PHYMOD);
    % [GN,success] = Secant_method(GN, NUMPARAM, PHYMOD);
    % [GN,success] = Levenberg_Marquardt_method(GN, NUMPARAM, PHYMOD);
    if ~success
        GN.success = success;
        return
    end
    
end

%% Prepair results
GN = get_GN_res(GN, GN_input, flag_remove_auxiliary_variables, NUMPARAM, PHYMOD);

end