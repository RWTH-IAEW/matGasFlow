function setup_matGasFlow
%setup_matGasFlow
%   setup_matGasFlow has no output. The function
%       - checks MATLAB version requirements, and
%       - adds necessary pathes.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
<<<<<<< HEAD
%   Copyright (c) 2020-2022, High Voltage Equipment and Grids,
=======
%   Copyright (c) 2020-2021, High Voltage Equipment and Grids,
>>>>>>> Merge to public repo (#1)
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

