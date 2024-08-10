function [GN, success] = rungf(GN, NUMPARAM, PHYMOD, remove_auxiliary_variables)
%RUNGF Steady-state gas flow simulation
%
%   [GN, success] = RUNGF(GN, NUMPARAM, PHYMOD)
%
%   Input arguments:
%       GN (necessarry):        gas network struct ...
%                               OR file name of the gas network model
%                               (string)
%       NUMPARAM (optional):    struct with numerical parameter
%       PHYMOD (optional):      struct with physical model settings
%
%   Output:
%       GN:                     gas network struct containing all results
%       success:                rungf is not successful if pressure becomes
%                               negative
%
%   Calling syntax options:
%       GN = rungf(GN);
%       GN = rungf(GN, NUMPARAM);
%       GN = rungf(GN, NUMPARAM, PHYMOD);
%       [GN,success] = rungf(__)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Set default input arguments
if nargin < 4 || isempty(PHYMOD)
    remove_auxiliary_variables = false;
end
if nargin < 3 || isempty(PHYMOD)
    PHYMOD = getDefaultPhysicalModels();
end
if nargin < 2 || isempty(NUMPARAM)
    NUMPARAM = getDefaultNumericalParameters();
end

%% Unitialize success
success = true;

%% Check GN data type
if ischar(GN)
    GN = load_GN(GN);
    remove_auxiliary_variables = false;
end

%% Check for availability of non-isothermal model
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

%% run solver
if any(GN.branch.connecting_branch) || NUMPARAM.assume_meshed_GN
    %% rungf for meshed gas network
    [GN, success] = rungf_meshed_GN(GN, NUMPARAM, PHYMOD);
else
    %% rungf for radial gas network
    [GN, success] = rungf_radial_GN(GN, NUMPARAM, PHYMOD);
end

%% Prepair results
if success
    [GN,success] = get_GN_res(GN, GN_input, remove_auxiliary_variables, NUMPARAM, PHYMOD); 
end

%% Success
GN.success = success;

end
