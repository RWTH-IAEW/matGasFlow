function [ GN ] = set_fraction_of_gas_mixture_component( GN, gas_mixture_component, x, xVar )
%SET_FRACTION_OF_GAS_MIXTURE_COMPONENT changes the fraction of a gas type
%
%   set_fraction_of_gas_mixture_component(GN, gas_mixture_component, x, xVar)
%   changes the fraction (x) of one gas mixture component of the gas mixture
%   (GN.gasMixAndCompoProp). The fraction (x) can be interpreted as volume 
%   fraction(xVar = 'x_vol'), mass fraction (xVar = 'x_mass') and mole
%   fraction(xVar = 'x_mol').
%
%   gas_mixture_component options:
%       'CH4', 'N2', 'CO2', 'C2H6', 'C3H8', 'n_C4H10', 'iso_C4H10',
%       'n_C5H12', 'iso_C5H12', 'neo_C5H12', 'C6', 'H2', 'H2S'
%   
%   x optins:
%       0 <= x <= 1
%
%   xVar options:
%       'x_vol', 'x_mass', 'x_mol'
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


if x >= 0 && x < 1
    if strcmp(xVar,'x_mol')
        GN.gasMixAndCompoProp{gas_mixture_component,'x_mol'} = 0;
        GN.gasMixAndCompoProp{:,'x_mol'} = GN.gasMixAndCompoProp{:,xVar}/sum(GN.gasMixAndCompoProp{:,xVar})*(1-x);
        GN.gasMixAndCompoProp{gas_mixture_component,'x_mol'} = x;
        GN.gasMixAndCompoProp{:,'x_vol'}  = GN.gasMixAndCompoProp{:,'x_mol'} .* GN.gasMixAndCompoProp{:,'V_m_n'} / sum(GN.gasMixAndCompoProp{:,'x_mol'} .* GN.gasMixAndCompoProp{:,'V_m_n'});
        GN.gasMixAndCompoProp{:,'x_mass'} = GN.gasMixAndCompoProp{:,'x_mol'} .* GN.gasMixAndCompoProp{:,'M'}     / sum(GN.gasMixAndCompoProp{:,'x_mol'} .* GN.gasMixAndCompoProp{:,'M'}    );
    elseif strcmp(xVar,'x_vol')
        GN.gasMixAndCompoProp{gas_mixture_component,'x_vol'} = 0;
        GN.gasMixAndCompoProp{:,'x_vol'} = GN.gasMixAndCompoProp{:,xVar}/sum(GN.gasMixAndCompoProp{:,xVar})*(1-x);
        GN.gasMixAndCompoProp{gas_mixture_component,'x_vol'} = x;
        GN.gasMixAndCompoProp{:,'x_mol'}  = GN.gasMixAndCompoProp{:,'x_vol'}./GN.gasMixAndCompoProp{:,'V_m_n'}/sum(GN.gasMixAndCompoProp{:,'x_vol'}./GN.gasMixAndCompoProp{:,'V_m_n'});
        GN.gasMixAndCompoProp{:,'x_mass'} = GN.gasMixAndCompoProp{:,'x_vol'}.*GN.gasMixAndCompoProp{:,'rho_n'}/sum(GN.gasMixAndCompoProp{:,'x_vol'}.*GN.gasMixAndCompoProp{:,'rho_n'});
    elseif strcmp(xVar,'x_mass')
        GN.gasMixAndCompoProp{gas_mixture_component,'x_mass'} = 0;
        GN.gasMixAndCompoProp{:,'x_mass'} = GN.gasMixAndCompoProp{:,xVar}/sum(GN.gasMixAndCompoProp{:,xVar})*(1-x);
        GN.gasMixAndCompoProp{gas_mixture_component,'x_mass'} = x;
        GN.gasMixAndCompoProp{:,'x_mol'}  = GN.gasMixAndCompoProp{:,'x_mass'}./GN.gasMixAndCompoProp{:,'M'}/sum(GN.gasMixAndCompoProp{:,'x_mass'}./GN.gasMixAndCompoProp{:,'M'});
        GN.gasMixAndCompoProp{:,'x_vol'} = GN.gasMixAndCompoProp{:,'x_mass'}./GN.gasMixAndCompoProp{:,'rho_n'}/sum(GN.gasMixAndCompoProp{:,'x_mass'}./GN.gasMixAndCompoProp{:,'rho_n'});
    else
        error('This fraction specification does not exist.')
    end
elseif x == 1
    GN.gasMixAndCompoProp{:,'x_mol'} = 0;
    GN.gasMixAndCompoProp{gas_mixture_component,'x_mol'} = x;
    GN.gasMixAndCompoProp{:,'x_vol'} = 0;
    GN.gasMixAndCompoProp{gas_mixture_component,'x_vol'} = x;
    GN.gasMixAndCompoProp{:,'x_mass'} = 0;
    GN.gasMixAndCompoProp{gas_mixture_component,'x_mass'} = x;
else
    error('x must have a value between 0 and 1')
end

if any(isnan(GN.gasMixAndCompoProp.x_mol))
    error('x_mol became NaN.')
elseif any(isinf(GN.gasMixAndCompoProp.x_mol))
    error('x_mol became Inf.')
end

%% Update gas mixture properties
GN.gasMixProp = get_gasMixProp(GN.gasMixAndCompoProp);

%% Check the need of a calorific value
if GN.gasMixProp.H_s_n_avg <= 0 && ...
        (ismember('P_th_i__MW',GN.bus.Properties.VariableNames) || ismember('P_th_i__MW',GN.bus.Properties.VariableNames))
    error('The gas mixture needs a caloric value.')
end

%% Remove standard gas type
if isfield(GN,'gasMix')
    GN =  rmfield(GN , 'gasMix');
end

%% Update AGA8-92DC table
GN = get_AGA8_92DC_tables(GN);

end

