function [GN] = getAdditionalExternalGridParameters(val,GN,idx_slack)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% net
try 
       
        GN.bus.net(GN.bus.bus_ID == idx_slack)= val.x_object.ext_grid.x_object.net; 
        warning ('Slack Bus:  A network name has been defined by pandapipes.')
catch 
end 

%% t_k
try 
    GN.bus.t_k_slack(GN.bus.bus_ID == idx_slack)= val.x_object.ext_grid.x_object.t_k; 
        warning ('Slack Bus:  A fixed temperature has been defined by pandapipes.')
catch 
end 

%% type
try 
        GN.bus.type_slack(GN.bus.bus_ID == idx_slack)= cell2mat(val.x_object.ext_grid.x_object.type) ; 
        warning ('Slack Bus:  Type has been defined by pandapipes.')
catch 
end 
