function setup_matGasFlow
%setup_matGasFlow
%   setup_matGasFlow has no output. The function
%       - checks MATLAB version requirements, and
%       - adds necessary pathes.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2021, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Check MATLAB version requirements - UNDER CONSTRUCTION
% matlab_version = ver('matlab');

%% Add necessary pathes
addpath(genpath('CI'));
addpath(genpath('Data'));
addpath(genpath('log'));
addpath(genpath('Modules'));

end

