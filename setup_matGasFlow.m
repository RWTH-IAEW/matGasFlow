function setup_matGasFlow
%setup_matGasFlow
%   setup_matGasFlow has no output. The function
%       - checks MATLAB version requirements, and
%       - adds necessary pathes.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Check MATLAB version requirements
matlab_version = ver('matlab');
version_year = str2double(matlab_version.Release(3:6));
if version_year<2019
    warning(['matGasFlow is tested for MATLAB > (R2019b). You are using ',matlab_version.Release,'.'])
end

%% Add necessary pathes
addpath(genpath('CI'));
addpath(genpath('Data'));
addpath(genpath('log'));
addpath(genpath('Modules'));
addpath(genpath('Examples'));

end

