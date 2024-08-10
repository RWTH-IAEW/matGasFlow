function[GN] = get_delta_H(GN,CONST)
%GET_DELTA_H Calculation of heat exange for compressor branches
%   [GN] = get_delta_H(GN, PHYMOD)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

%% Indicies
i_branch_T_cooling  = GN.comp.i_branch(GN.comp.T_controlled);
i_comp_T_cooling    = GN.comp.i_branch==i_branch_T_cooling;
i_from_bus          = GN.branch.i_from_bus(i_branch_T_cooling);
i_to_bus            = GN.branch.i_to_bus(i_branch_T_cooling);

%% Quantities
rho_n_avg           = GN.gasMixProp.rho_n_avg; %[kg/m^3]
T_in                = GN.bus.T_i(i_from_bus); %[K]
T_out               = GN.comp.T_ij_out(i_comp_T_cooling); %[K]
T_ij_in             = GN.branch.T_ij_out_beforeCooling(i_branch_T_cooling); %[K]
T_ij_out_beforeCooling  = GN.branch.T_ij_out_beforeCooling(i_branch_T_cooling); %[K]
V_dot_n_ij          = GN.branch.V_dot_n_ij(i_branch_T_cooling); %[m^3/s]
p_in                = GN.bus.p_i(i_from_bus); %[Pa]
p_out               = GN.bus.p_i(i_to_bus); %[Pa]

GN      = get_a_b_VanDerWaals(GN);
a_VDW   = GN.gasMixProp.a_VDW; 
b_VDW   = GN.gasMixProp.b_VDW; 

% get Z [-] an v_m [m^3/mol]
[Z_in, V_m_in]                              = get_Z_VanDerWaals(p_in,   T_ij_in,            a_VDW, b_VDW);
[Z_out_beforeCooling, V_m_out]              = get_Z_VanDerWaals(p_out,  T_ij_out_beforeCooling, a_VDW, b_VDW);
[Z_out_isotherm, V_m_out_isotherm]          = get_Z_VanDerWaals(p_in,   T_out,              a_VDW, b_VDW);

delta_T = 0.001; 
[Z_out_isobar, V_m_out_isobar]              = get_Z_VanDerWaals(p_in,   T_out,              a_VDW, b_VDW);
[Z_out_isobar_temp, V_m_out_isobar_temp]    = get_Z_VanDerWaals(p_in,   T_out + delta_T,    a_VDW, b_VDW);

[Z_out, V_m_out]                            = get_Z_VanDerWaals(p_out,  T_out,              a_VDW, b_VDW);
[Z_out_temp, V_m_out_temp]                  = get_Z_VanDerWaals(p_out,  T_out + delta_T,    a_VDW, b_VDW);

[Z_in, V_m_in]                              = get_Z_VanDerWaals(p_in,   T_in,               a_VDW, b_VDW);
[Z_in_temp, V_m_in_temp]                    = get_Z_VanDerWaals(p_in,   T_in + delta_T,     a_VDW, b_VDW);

[Z_isotherm_v2, V_m_isotherm_v2]            = get_Z_VanDerWaals(p_out,  T_in,               a_VDW, b_VDW);
[Z_isotherm_temp_v2, V_m_isotherm_temp_v2]  = get_Z_VanDerWaals(p_out,  T_in + delta_T,     a_VDW, b_VDW);

% get rho [kg/m^3]
rho_in  = ...
    GN.gasMixProp.rho_n_avg ...
    .* p_in                 ./CONST.p_n ...
    .* CONST.T_n            ./T_ij_in ...
    .* GN.gasMixProp.Z_n_avg./Z_in;

rho_out_beforeCooling  = ...
    GN.gasMixProp.rho_n_avg ...
    .* p_out                ./CONST.p_n ...
    .* CONST.T_n            ./T_ij_out_beforeCooling ...
    .* GN.gasMixProp.Z_n_avg./Z_out_beforeCooling;

%% Energy Balance Compressor
% Nur die ergibt Sinn weil der Prozess adiabat ablaufen muss
GN.comp.delta_H_compressor = (p_out./rho_out_beforeCooling -p_in./rho_in).*V_dot_n_ij .*rho_n_avg;

%% Energy Balance Station 
% Willkürlicher Zustand ist hier der Zustand am Kompressoreingang 
% Die Berechnung teilt sich in einen isothermen und einen isobaren
% Teil 

%% Isobare Zustandsänderung und dann isotherme Zustandsänderung = v_1 
%isobarer Teil 
[c_p_1, c_p_0_1] = get_c_p_VanDerWaals(p_in, T_in,  Z_in,           a_VDW, b_VDW, GN.gasMixProp.M_avg, GN.gasMixAndCompoProp);
[c_p_2, c_p_0_2] = get_c_p_VanDerWaals(p_in, T_out, Z_out_isobar,   a_VDW, b_VDW, GN.gasMixProp.M_avg, GN.gasMixAndCompoProp);

h_isobar = (c_p_1 + c_p_2)/2 .*(T_out-T_in);

%isothermer Teil 
dvdT_isotherm   = (V_m_out_isobar_temp - V_m_out_isobar) / delta_T; 
dvdT_out        = (V_m_out_temp - V_m_out) / delta_T; 
h_isotherm      = ( (V_m_out + V_m_out_isotherm) / 2 / GN.gasMixProp.M_avg ...
    - T_out .* (dvdT_isotherm + dvdT_out) / 2 / GN.gasMixProp.M_avg ) .* (p_out - p_in);

%gesamte Station
GN.comp.delta_H_station_v1 = -V_dot_n_ij .*rho_n_avg.*(h_isotherm +h_isobar); 

%% Isotherme Zustandsänderung und dann isobare Zustandsänderung = v_2  
%isothermer Teil 
dvdT_in             = (V_m_in_temp -V_m_in)/delta_T; 
dvdT_isotherm_v2    = (V_m_isotherm_temp_v2 -V_m_isotherm_v2)/delta_T; 
h_isotherm_v2       = ( (V_m_in + V_m_isotherm_v2) / 2 / GN.gasMixProp.M_avg ...
    - T_in .* (dvdT_isotherm_v2 + dvdT_in) / 2 / GN.gasMixProp.M_avg ) .* (p_out - p_in);

%isobarer Teil 
[c_p_1_v2, c_p_0_1] = get_c_p_VanDerWaals(p_out, T_in,  Z_in,           a_VDW, b_VDW, GN.gasMixProp.M_avg, GN.gasMixAndCompoProp);
[c_p_2_v2, c_p_0_2] = get_c_p_VanDerWaals(p_out, T_out, Z_out_isobar,   a_VDW, b_VDW, GN.gasMixProp.M_avg, GN.gasMixAndCompoProp);

h_isobar_v2 = (c_p_1_v2 + c_p_2_v2) / 2 .* (T_out - T_in);

%Whole Station
GN.comp.delta_H_station     = -V_dot_n_ij .* rho_n_avg .* (h_isotherm + h_isobar); 
GN.comp.delta_H_station_v2  = -V_dot_n_ij .* rho_n_avg .* (h_isotherm_v2 + h_isobar_v2);

end 
