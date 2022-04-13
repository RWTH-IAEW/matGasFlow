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

%% Check if GN is initialized
if ~isfield(GN,'INC')
    GN = check_and_init_GN(GN);
end

%% Calculate V_dot_n_i [m^3/s]
GN = get_V_dot_n_i(GN);

%% Calculate V_dot_n_ij_preset [m^3/s] UNDER CONSTRUCTION "~isnan" unneccessary
GN = get_V_dot_n_ij_preset(GN);

%% Remove ...
% Remove branches that are out of service and unsupplied busses
GN = remove_unsupplied_areas(GN);

% Remove valves
GN = remove_valves(GN);

%% Reset CONVERGENCE
if isfield(GN,'CONVERGENCE')
    GN = rmfield(GN,'CONVERGENCE');
end

%% Initialize V_dot_n_ij
if ~any(ismember(GN.branch.Properties.VariableNames,'V_dot_n_ij'))
    GN.branch.V_dot_n_ij(~GN.branch.active_branch) = zeros(sum(~GN.branch.active_branch),1);
end

%% Update of the slack bus: flow rate balance to(+)/from(-) the slack bus
if abs(sum(GN.bus.V_dot_n_i)/sum(GN.bus.slack_bus & GN.bus.V_dot_n_i ~= 0)) > NUMPARAM.numericalTolerance
    %     GN.bus.V_dot_n_i(GN.bus.slack_bus) = GN.bus.V_dot_n_i(GN.bus.slack_bus) - sum(GN.bus.V_dot_n_i)/sum(GN.bus.slack_bus);
    if any(GN.bus.V_dot_n_i(GN.bus.slack_bus) ~= 0)
        GN.bus.V_dot_n_i(GN.bus.slack_bus & GN.bus.V_dot_n_i ~= 0) = ...
            GN.bus.V_dot_n_i(GN.bus.slack_bus & GN.bus.V_dot_n_i ~= 0) ...
            - sum(GN.bus.V_dot_n_i)/sum(GN.bus.slack_bus & GN.bus.V_dot_n_i ~= 0);
    else
        GN.bus.V_dot_n_i(GN.bus.slack_bus) = ...
            GN.bus.V_dot_n_i(GN.bus.slack_bus) ...
            - sum(GN.bus.V_dot_n_i)/sum(GN.bus.slack_bus);
    end
    %     warning('Entries and exits are not balanced. V_dot_n_ij of the slack busses have been updated.')
end

% Upadte GN.bus.source_bus
if GN.isothermal == 0
    if GN.bus.V_dot_n_i(GN.bus.slack_bus) < 0
        GN.bus.source_bus(GN.bus.slack_bus) = true;
    else
        GN.bus.source_bus(GN.bus.slack_bus) = false;
    end
end

%% Initialize pressure and temperature
GN = init_p_i(GN);
GN = init_T_i(GN);
GN = get_p_ij(GN);
GN = get_T_ij(GN);

%% Update p_i dependent quantities 
% Compressibility factor
GN = get_Z(GN, PHYMOD);

% Dynamic viscosity eta_ij(T,rho)
if isfield(GN, 'pipe')
    GN = get_eta(GN,PHYMOD);
end

end

