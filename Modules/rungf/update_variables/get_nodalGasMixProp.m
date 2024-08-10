function GN = get_nodalGasMixProp(GN, PHYMOD)
%GET_NODALGASMIXPROP
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

%% Set default input arguments
if nargin < 2
    PHYMOD = getDefaultPhysicalModels();
end

%% Initialize pressure and temperature
GN = init_p_i(GN);
GN = init_T_i(GN);

%% Compressibility factor - Z
GN = get_Z(GN, PHYMOD, {'gasMixProp','bus'});

%% Specific isobaric heat capacity
GN = get_c_p(GN, PHYMOD);

%% Joule-Thomson coefficient - my_JT
GN = get_my_JT(GN, PHYMOD);

%% Heat capacity ratio - kappa
GN = get_kappa(GN, PHYMOD);

%% Molar isobaric and isochoric heat capacity
GN.bus.C_p_m_i = GN.bus.c_p_i*GN.gasMixProp.M_avg; % J/(kg K)*kg/mol = J(mol K)
GN.bus.C_V_m_i = GN.bus.c_V_i*GN.gasMixProp.M_avg; % J/(kg K)*kg/mol = J(mol K)

%% Dynamic viscosity - eta
if ~isfield(GN, 'pipe')
    bus_ID  = GN.bus.bus_ID;
    T_ij    = GN.bus.T_i;
    p_ij    = GN.bus.p_i;
    Z_ij    = GN.bus.Z_i;
    GN.pipe = table(bus_ID, T_ij, p_ij, Z_ij);
end
GN = get_eta(GN, PHYMOD);
GN.bus.eta_i = GN.pipe.eta_ij;
GN = rmfield(GN, 'pipe');

%% rho, V_m
GN              = get_rho(GN);
GN.bus.V_m_i    = GN.gasMixProp.M_avg./GN.bus.rho_i;

GN.bus.p_per_T  = GN.bus.p_i./GN.bus.T_i;
GN.bus.temp(:)  = 0.5 * GN.gasMixProp.p_pc/GN.gasMixProp.T_pc;
end

