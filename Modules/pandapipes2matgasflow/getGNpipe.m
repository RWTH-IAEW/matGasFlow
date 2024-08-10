function [GN] = getGNpipe(val,GN,AdditionalParameters)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

GN.pipe                 = val.x_object.pipe.x_object;

GN.pipe.from_bus_ID     = GN.pipe.from_junction;
GN.pipe.from_junction   = [];
GN.pipe.to_bus_ID       = GN.pipe.to_junction;
GN.pipe.to_junction     = [];
GN.pipe.L_ij            = GN.pipe.length_km*1000;
GN.pipe.length_km       = [];
GN.pipe.D_ij            = GN.pipe.diameter_m;
GN.pipe.diameter_m      = [];
GN.pipe.k_ij            = GN.pipe.k_mm/1000;
GN.pipe.k_mm            = [];
in_service              = false(height(GN.pipe),1);
in_service(strcmp(GN.pipe.in_service,'true')) = true;
GN.pipe.in_service      = [];
GN.pipe.in_service      = in_service;

if isfield(GN.pipe, 'index')
    GN.pipe.pipe_ID = GN.pipe.index;
    GN.pipe.index   = [];
else
    GN.pipe.pipe_ID = (1:height(GN.pipe))';
end

GN.pipe.L_ij(GN.pipe.L_ij==0) = 0.1;

GN.valve = GN.pipe(GN.pipe.L_ij==0,:);
GN.valve.valve_ID = GN.valve.pipe_ID;
GN.valve.pipe_ID = [];
GN.pipe(GN.pipe.L_ij==0,:) = [];  

end 
