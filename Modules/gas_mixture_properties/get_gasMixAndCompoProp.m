function [GN] = get_gasMixAndCompoProp(GN, gasMix)
%GET_GASMIXANDCOMPOPROP
%   get_gasMixAndCompoProp(GN, gasMix) initializes the gas mixture in the
%   gas network. The gas mixture can be one of 'gasMix_library.csv' or a
%   pure gas.
%   gasMix options from gasMix_library.csv:
%       H_Gas_NorthSea, H_Gas_Mix, H_Gas_Russia, H_Gas_Holland,
%       H_Gas_GERG2008, L_Gas_Verbund, L_Gas_WeserEms, TENP_North, or
%       TENP_South
%
%   Or choose a pure gas for gasMix:
%       CH4, C2H6, C3H8, n_C4H10, iso_C4H10, n_C5H12, iso_C5H12, neo_C5H12,
%       C6H14, CO, H2, H2S, N2 or CO2
%
%   matGasFlow allows steady-state gas flow simulation also for non
%   combustible gases (e.g. N2, CO2).
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2022, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 2
    gasMix = GN.gasMix;
elseif nargin == 2
    GN.gasMix = gasMix;
end

%% Gas properties
GN.gasMixAndCompoProp = readtable('pure_gas_properties.csv');

% Molar volume [m^3/mol]
GN.gasMixAndCompoProp.V_m_n = GN.gasMixAndCompoProp.M ./ GN.gasMixAndCompoProp.rho_n;
GN.gasMixAndCompoProp = movevars(GN.gasMixAndCompoProp,'V_m_n','After','rho_n');

%% Composition
gasMix_library = readtable('gasMix_library.csv');

deleteVariables = ismember(gasMix_library.gas, gasMix_library.Properties.VariableNames);
gasMix_library(:,deleteVariables) = [];

pureGases_library = array2table(eye(length(gasMix_library.gas)), 'VariableNames', gasMix_library.gas');
gasMix_library = [gasMix_library, pureGases_library];

% Check gasMix_library
NUMPARAM = getDefaultNumericalParameters;
if any(abs(sum(table2array(gasMix_library(:,2:end)))-1) > NUMPARAM.numericalTolerance)
    error('gasMix_library.csv: The sum of the molar fractions of each gas type must be equal to one.')
end

% Percentage of amount of substance
[ismem,idx] = ismember(GN.gasMixAndCompoProp.gas, gasMix_library.gas);
idx(idx==0) = [];
try
    % try to load composition of gas mixture
    GN.gasMixAndCompoProp.x_mol(ismem) = gasMix_library{idx,gasMix};
catch
    % return error message if gasMix is not availabe in gasMix_library.csv
    gasMix_strings          = gasMix_library.Properties.VariableNames(2:end);
    gasMix_strings(1:end-2) = append(gasMix_strings(1:end-2), ', ');
    gasMix_strings(end-1)   = append(gasMix_strings(end-1), ' or ');
    error([gasMix, ' is not available. Chose one of these gas types: ',gasMix_strings{1:end}])
end
GN.gasMixAndCompoProp = movevars(GN.gasMixAndCompoProp,'x_mol','After','gas');

% Percentage of volume
GN.gasMixAndCompoProp.x_vol = GN.gasMixAndCompoProp.x_mol .* GN.gasMixAndCompoProp.V_m_n / sum(GN.gasMixAndCompoProp.x_mol .* GN.gasMixAndCompoProp.V_m_n);
GN.gasMixAndCompoProp = movevars(GN.gasMixAndCompoProp,'x_vol','After','x_mol');

% Percentage of mass
GN.gasMixAndCompoProp.x_mass = GN.gasMixAndCompoProp.x_mol .* GN.gasMixAndCompoProp.M / sum(GN.gasMixAndCompoProp.x_mol .* GN.gasMixAndCompoProp.M);
GN.gasMixAndCompoProp = movevars(GN.gasMixAndCompoProp,'x_mass','After','x_vol');

GN.gasMixAndCompoProp.Properties.RowNames = GN.gasMixAndCompoProp{:,'gas'};

%% Update gas mixture properties
GN.gasMixProp = get_gasMixProp(GN.gasMixAndCompoProp);

%% Check the need of a calorific value
if GN.gasMixProp.H_s_n_avg <= 0 && ...
        (ismember('P_th_i__MW',GN.bus.Properties.VariableNames) || ismember('P_th_i__MW',GN.bus.Properties.VariableNames))
    error('The gas mixture needs a caloric value.')
end

end

