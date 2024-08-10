function [c_p_0] = calculate_c_p_0(T, M_avg, gasMixAndCompoProp, PHYMOD)
%CALCULATE_C_P_ideal ideal specific isobaric heat capacity c_p_0 [J/(kg*K)] using
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

%% Quantities
CONST   = getConstants;
R_m     = CONST.R_m;
x_mol   = gasMixAndCompoProp.x_mol;

if PHYMOD.c_p_0 == 0
    %% VDI-Wärmeatlas
    a       = gasMixAndCompoProp.A_VDI;
    b       = gasMixAndCompoProp.B_VDI;
    c       = gasMixAndCompoProp.C_VDI;
    d       = gasMixAndCompoProp.D_VDI;
    e       = gasMixAndCompoProp.E_VDI;
    f       = gasMixAndCompoProp.F_VDI;
    g       = gasMixAndCompoProp.G_VDI;

    C_p_m_0_i = R_m * (b + (c-b) .* (T'./(a+T')).^2 .* ( 1 - a./(a+T') .* ( d + e.*T'./(a+T') + f.*(T'./(a+T')).^2 + g.*(T'./(a+T')).^3 ) ));

elseif PHYMOD.c_p_0 == 1
    %% Gasunie/AGA
    a       = gasMixAndCompoProp.a_AGA;
    b       = gasMixAndCompoProp.b_AGA;
    c       = gasMixAndCompoProp.c_AGA;
    d       = gasMixAndCompoProp.d_AGA;
    e       = gasMixAndCompoProp.e_AGA;

    C_p_m_0_i = ...
        a ...
        + b * T' ...
        + c * (T.^2)' ...
        + d * (T.^3)' ...
        + e * (T.^4)';

elseif PHYMOD.c_p_0 == 2
    %% Heintz
    a       = gasMixAndCompoProp.a_HEI;
    b       = gasMixAndCompoProp.b_HEI;
    c       = gasMixAndCompoProp.c_HEI;
    d       = gasMixAndCompoProp.d_HEI;

    C_p_m_0_i = ...
        a ...
        + b * T' ...
        + c * (T.^2)' ...
        + d * (T.^3)';

elseif PHYMOD.c_p_0 == 3
    %% AGA8-92DC
    B_0_i = AGA8_92DC_tables.gasProp.B_0_i;
    C_0_i = AGA8_92DC_tables.gasProp.C_0_i;
    D_0_i = AGA8_92DC_tables.gasProp.D_0_i;
    E_0_i = AGA8_92DC_tables.gasProp.E_0_i;
    F_0_i = AGA8_92DC_tables.gasProp.F_0_i;
    G_0_i = AGA8_92DC_tables.gasProp.G_0_i;
    H_0_i = AGA8_92DC_tables.gasProp.H_0_i;
    I_0_i = AGA8_92DC_tables.gasProp.I_0_i;
    J_0_i = AGA8_92DC_tables.gasProp.J_0_i;


else
    error(['PHYMOD.c_p_0 = ',num2str(PHYMOD.c_p),' is invalid.'])
end

C_p_m_0 = sum(x_mol .* C_p_m_0_i, 1)';
c_p_0   = C_p_m_0/M_avg;


end