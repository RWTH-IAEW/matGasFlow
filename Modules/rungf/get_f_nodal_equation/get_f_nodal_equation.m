function [GN] = get_f_nodal_equation(GN, NUMPARAM, PHYMOD)
%GET_F_NODAL_EQUAION
%   [GN] = get_f_nodal_equation(GN, NUMPARAM, PHYMOD, OPTION)
%       f = sum(V_dot_n_ij) + V_dot_n_i for every bus i
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2022, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Gas flow rate V_dot_n_ij in Pipes
GN = get_V_dot_n_ij_pipe(GN, NUMPARAM);

%% V_dot_n_i demand of compressors
GN = get_V_dot_n_i_comp(GN, PHYMOD);

%% V_dot_n_i demand of prs heater
GN = get_V_dot_n_i_prs(GN);

%% Update slack bus and slack branch - UNDER CONSTRUCTION
GN = get_V_dot_n_slack(GN, 'bus', NUMPARAM);

%% Calculate f
GN.bus.f = GN.INC * GN.branch.V_dot_n_ij + GN.bus.V_dot_n_i;

end

