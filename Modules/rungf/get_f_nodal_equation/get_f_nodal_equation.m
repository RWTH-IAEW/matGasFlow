function [GN] = get_f_nodal_equation(GN, NUMPARAM, PHYMOD, OPTION)
%GET_F_NODAL_EQUAION
%   [GN] = get_f_nodal_equation(GN, NUMPARAM, PHYMOD, OPTION)
%       f = sum(V_dot_n_ij) + V_dot_n_i for every bus i
%   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2021, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Set default input arguments
if nargin == 3
    OPTION = 1;
end


%%
if OPTION == 1
    % Gas flow rate V_dot_n_ij in Pipes
    GN = get_V_dot_n_ij_pipe(GN, NUMPARAM);
    
    % Gas flow rate V_dot_n_ij in non-Pipes
    GN = get_V_dot_n_ij_nonPipe(GN);
    
    % V_dot_n_i demand of compressors
    GN = get_V_dot_n_i_comp(GN, PHYMOD);
    
elseif OPTION == 2
    % Standard gas flow rate V_dot_n_ij
    GN = get_V_dot_n_ij_pipe(GN, NUMPARAM);
    
    % Gas flow rate V_dot_n_ij in non-Pipes
    GN = get_V_dot_n_ij_nonPipe(GN);
    
elseif OPTION == 3
    % Standard gas flow rate V_dot_n_ij
    GN = get_V_dot_n_ij_pipe(GN, NUMPARAM);
    
    % V_dot_n_i demand of compressors
    GN = get_V_dot_n_i_comp(GN, PHYMOD);
    
elseif OPTION == 4
    % Standard gas flow rate V_dot_n_ij
    GN = get_V_dot_n_ij_pipe(GN, NUMPARAM);
    
end

% Update of the slack node: flow rate balance to(+)/from(-) the slack node
GN.bus.V_dot_n_i(GN.bus.slack_bus) = -sum(GN.bus.V_dot_n_i(~GN.bus.slack_bus));
if GN.isothermal == 0
    if GN.bus.V_dot_n_i(GN.bus.slack_bus) < 0
        GN.bus.source_bus(GN.bus.slack_bus) = true;
    else
        GN.bus.source_bus(GN.bus.slack_bus) = false;
    end
end

% f(p_i,T_i) = SUM(V_dot_n_ij) + V_dot_n_i
GN.bus.f = GN.INC * GN.branch.V_dot_n_ij + GN.bus.V_dot_n_i;


end

