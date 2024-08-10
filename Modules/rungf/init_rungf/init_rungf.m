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
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 3
    PHYMOD = getDefaultPhysicalModels;
    if nargin < 2
        NUMPARAM = getDefaultNumericalParameters;
    end
end

%% Update gas mixtures properties: Z_n_avg, rho_n_avg
GN = get_Z(GN,PHYMOD,'gasMixProp');

%% Calculate V_dot_n_i [m^3/s]
GN = get_V_dot_n_i(GN);

%% Remove ...
% ... branches that are out of service
GN = remove_branches_out_of_service(GN);

% ... unsupplied busses
GN = remove_unsupplied_busses(GN);

% ... valves
GN = remove_valves(GN);

%% V_dot_n_ij start solution
GN = init_V_dot_n_ij(GN);

%% Reset CONVERGENCE
if isfield(GN,'CONVERGENCE')
    GN = rmfield(GN,'CONVERGENCE');
end

%% V_dot_n_i start solution
i_V_bus_isnan = isnan(GN.bus.V_dot_n_i) & GN.bus.V_bus;
if any(i_V_bus_isnan)
    error(['Demand/feed-in value of some busses are missing. bus_IDs: ',num2str(GN.bus.bus_ID(i_V_bus_isnan))])
end
GN.bus.V_dot_n_i(isnan(GN.bus.V_dot_n_i)) = 0;

%% Update GN.bus.source_bus
if ~GN.isothermal
    GN.bus.source_bus(GN.bus.V_dot_n_i <=  0)   = true;
    GN.bus.source_bus(GN.bus.V_dot_n_i > 0)     = false;
end

%% Initialize pressure and temperature
GN = init_p_i(GN);
GN = init_T_i(GN);
GN = get_T_ij(GN);
GN = init_p_T_comp_prs(GN);

%% Update p_i dependent quantities 
GN = update_p_i_dependent_quantities(GN, NUMPARAM, PHYMOD);

%% Calculate nodal residuum
GN = get_f_nodal_equation(GN, NUMPARAM, PHYMOD);

end

