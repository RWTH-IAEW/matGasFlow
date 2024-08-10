function [GN] = get_Z_Mis15__9_68(GN)
%GET_Z_MIS15__9_68
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

%%
if strcmp(GN.gasMix,'hGasRuss')
    E = 2.38e-8;
    F = 4.2155;
elseif strcmp(GN.gasMix,'hGasNorthSea')
    E = 2.04e-8;
    F = 4.198;
elseif strcmp(GN.gasMix,'H_Gas_Mix')
    E = 2.68e-8;
    F = 4.1532;
else
    error('get_Z_Mis15__9_67: GN.gasMix must be ''hGasRuss'', ''H_Gas_NorthSea'' or ''H_Gas_Mix''')
end

%% Quantities
CONST   = getConstants;
p_n     = CONST.p_n;
Z_n_avg = GN.gasMixProp.Z_n_avg;

%% bus
p__bar          = (GN.bus.p_i + p_n) * 1e-5;
T               = GN.bus.T_i;
K               = 1 - p__bar./(E * T.^F);
GN.bus.Z_i      = K/Z_n_avg;

%% pipe
if isfield(GN,'pipe')
    p__bar      = (GN.pipe.p_ij + p_n) * 1e-5;
    T           = GN.pipe.T_ij;
    K           = 1 - p__bar./(E * T.^F);
    GN.pipe.Z_ij= K/Z_n_avg;
end

%% non-isothermal
if ~GN.isothermal
    
    %% source
    if any(GN.bus.source_bus)
        p__bar      = (GN.bus.p_i(GN.bus.source_bus) + p_n) * 1e-5;
        T           = GN.bus.T_i_source(GN.bus.source_bus);
        K           = 1 - p__bar./(E * T.^F);
        GN.bus.Z_i_source(GN.bus.source_bus) = K/Z_n_avg;
    end
    
    %% branch
    if isfield(GN,'branch')
        i_bus_out   = GN.branch.i_to_bus;
        i_bus_out(GN.branch.V_dot_n_ij < 0) = GN.branch.i_from_bus(GN.branch.V_dot_n_ij < 0);
        p__bar      = (GN.bus.p_i(i_bus_out) + p_n) * 1e-5;
        T           = GN.branch.T_ij_out;
        K           = 1 - p__bar./(E * T.^F);
        GN.branch.Z_ij_out = K/Z_n_avg;
    end
    
    %% comp
    if isfield(GN,'comp')
        p__bar      = (GN.comp.p_ij_mid + p_n) * 1e-5;
        T           = GN.comp.T_ij_mid;
        K           = 1 - p__bar./(E * T.^F);
        GN.comp.Z_ij_mid    = K/Z_n_avg;
    end
    
    %% prs
    if isfield(GN,'prs')
        p__bar  	= (GN.prs.p_ij_mid + p_n) * 1e-5;
        T           = GN.prs.T_ij_mid;
        K           = 1 - p__bar./(E * T.^F);
        GN.prs.Z_ij_mid     = K/Z_n_avg;
    end
    
end

end

