%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2022, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% SETUP

% Call setup_matGasFlow
%   - to check MATLAB version requirements, and
%   - to add necessary pathes.
setup_matGasFlow

%% EASY ACCESS

% Use rungf to run a steady-state gas flow calculation. Choose the name of
% the network model as input argument. Here are two examples:
GN_Cerbe = rungf('Cerbe');
GN_Belgium = rungf('Belgium');

%% ADAVANCED APPLICATION

% To customize the network model or supply task, to change default settings
% of numerical or physical models, to keep auxiliary variables initialized
% when loading the network model after simulation, or to reduce the runtime
% of rungf by loading the network model outside the function can be done as
% follows:

% 1) Load gas network
% -------------------

% Load a gas network model. Call 'help load_GN' for more information.
GN = load_GN('Belgium');


% 2) Customize the scenario
% -------------------------

% Change the composition of gas mixture to 'H_Gas_NorthSea'. Call
% 'help get_gasMixAndCompoProp' for more information.
gasMix = 'H_Gas_NorthSea';
GN = get_gasMixAndCompoProp(GN, gasMix);

% Change the molar fraction of H2 to 10%. Call
% 'help set_fraction_of_gas_mixture_component' for more information.
gas_mixture_component = 'H2';
x = 0.1;
GN = set_fraction_of_gas_mixture_component(GN, gas_mixture_component, x, 'x_mol');


% 3) Change default numerical parameters
% --------------------------------------

% Load default numerical paramters. Call 'help getDefaultNumericalParameters'
% for more information.
NUMPARAM = getDefaultNumericalParameters();

% Change the accuracy of the Newton-Raphson method to 1e-2. Newton-Raphson
% method will run, until norm(f) < NUMPARAM.epsilon_NR_f. f is the nodal
% equation and results at each bus from the sum of all inflowing and
% outflowing standard volume flows. 
NUMPARAM.epsilon_NR_f = 1e-6;
NUMPARAM.maxIter = 10;


% 4) Change default physical models
% ---------------------------------

% Load default settings of the physical models. Call 'help getDefaultPhysicalModels'
% for more information.
PHYMOD = getDefaultPhysicalModels();

% The current version of matGasFlow does not allow any changes of the
% physical model settings.


% 5) Run a steady-state gas flow simulation
% -----------------------------------------

% Call 'help rungf' for more information.
GN = rungf(GN, NUMPARAM, PHYMOD);


%% SAVE RESULTS

% Call 'help save_GN' for more information
save_GN(GN)

