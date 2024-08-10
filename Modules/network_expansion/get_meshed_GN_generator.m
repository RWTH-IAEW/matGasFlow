function [GN] = get_meshed_GN_generator(n_horizontal, n_vertical)
%GET_MESHED_GN_GENERATOR
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
GN = load_GN('one_pipe');
n_buses = (n_horizontal+1)*(n_vertical+1);
n_pipes = n_horizontal*(n_vertical+1) + (n_horizontal+1)*n_vertical;

GN.bus              = repmat(GN.bus(1,:),n_buses);
GN.bus.bus_ID       = (1:n_buses)';
GN.pipe             = repmat(GN.pipe,n_pipes);
GN.pipe.pipe_ID     = (1:n_pipes)';

from_bus_IDs_hori        = (1:n_buses)';
from_bus_IDs_hori(n_horizontal+1:n_horizontal+1:n_buses) = [];
from_bus_IDs_vert       = (1:n_buses)';
from_bus_IDs_vert(n_vertical+1:n_vertical+1:n_buses) = [];
GN.pipe.from_bus_ID = [from_bus_IDs_hori;from_bus_IDs_vert];

to_bus_IDs_hori         = (1:n_buses)';
to_bus_IDs_hori(1:n_horizontal+1:(n_horizontal+1)*(n_vertical+1)) = [];
to_bus_IDs_vert         = (1:n_buses)';
to_bus_IDs_vert(1:n_horizontal+1) = [];
GN.pipe.to_bus_ID        = [to_bus_IDs_hori;to_bus_IDs_vert];

GN = rmfield(GN,'branch');
GN = check_and_init_GN(GN);

GN.bus.P_th_i__MW(GN.bus.slack_bus) = -sum(GN.bus.P_th_i__MW);

%%
end

