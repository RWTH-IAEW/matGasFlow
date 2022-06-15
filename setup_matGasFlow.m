function setup_matGasFlow
%setup_matGasFlow
%   setup_matGasFlow has no output. The function
%       - checks MATLAB version requirements, and
%       - adds necessary pathes.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2022, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Check MATLAB version requirements
matlab_version = ver('matlab');
if ~ismember(matlab_version.Release, {'(R2019b)','(R2020a)','(R2020b)','(R2021a)','(R2021b)','(R2022a)'})
    warning(['matGasFlow is tested for MATLAB > (R2019b). You are using ',matlab_version.Release,'.'])
end

%% Add necessary pathes
addpath(genpath('CI'));
addpath(genpath('Data'));
addpath(genpath('log'));
addpath(genpath('Modules'));

end

