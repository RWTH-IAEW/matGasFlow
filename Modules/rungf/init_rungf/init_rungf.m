function [GN] = init_rungf(GN, NUMPARAM, PHYMOD)
%INIT_RUNGF
%   [GN] = init_rungf(GN, PHYMOD)
%       - Check if GN is initialized
%       - Remove branches that are out of service and unsupplied busses
%       - Remove valves
%       - Reset CONVERGENCE
%       - Initialize p_i
%       - Calculate V_dot_n_i
%       - Update of the slack bus: flow rate balance to(+)/from(-) the
%           slack bus
%       - Initialize p_i, T_i and calculate p_ij, T_ij
%       - Update p_i dependent quantities (Z, eta)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2022, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 3
    PHYMOD = getDefaultPhysicalModels;
    if nargin < 2
        NUMPARAM = getDefaultNumericalParameters;
    end
end

%% Calculate V_dot_n_i [m^3/s]
GN = get_V_dot_n_i(GN);

%% Calculate V_dot_n_ij_preset [m^3/s]
GN = get_V_dot_n_ij_preset(GN);

%% Remove ...
% ... branches that are out of service
GN = remove_branches_out_of_service(GN);

% ... unsupplied busses
GN = remove_unsupplied_busses(GN);

% ... valves
GN = remove_valves(GN);

%% Reset CONVERGENCE
if isfield(GN,'CONVERGENCE')
    GN = rmfield(GN,'CONVERGENCE');
end

%% Update of the slack bus: flow rate balance to(+)/from(-) the slack bus
GN = get_V_dot_n_slack(GN, 'GN', NUMPARAM);

%% Update GN.bus.source_bus
if ~GN.isothermal
    GN.bus.source_bus(GN.bus.V_dot_n_i <  0) = true;
    GN.bus.source_bus(GN.bus.V_dot_n_i >= 0) = false;
end

%% Initialize pressure and temperature
GN = init_p_i(GN);
GN = init_T_i(GN);
GN = get_T_ij(GN);

% Update p_i dependent quantities 
GN = update_p_i_dependent_quantities(GN, PHYMOD);

end

