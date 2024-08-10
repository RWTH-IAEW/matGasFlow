function [GN] = get_Z_AGA(GN)
%GET_Z_AGA
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
p_pc = GN.gasMixProp.p_pc;
T_pc = GN.gasMixProp.T_pc;

%% bus
p_r             = GN.bus.p_i/p_pc;
T_r             = GN.bus.T_i/T_pc;
GN.bus.Z_i      = 1 + 0.257*p_r - 0.533*p_r./T_r;

%% pipe
if isfield(GN,'pipe')
    p_r         = GN.pipe.p_ij/p_pc;
    T_r         = GN.pipe.T_ij/T_pc;
    GN.pipe.Z_ij    = 1 + 0.257*p_r - 0.533*p_r./T_r;
end

%% non-isothermal
if ~GN.isothermal
    
    %% source
    if any(GN.bus.source_bus)
        p_r         = GN.bus.p_i(GN.bus.source_bus)/p_pc;
        T_r         = GN.bus.T_i_source(GN.bus.source_bus)/T_pc;
        GN.bus.Z_i_source(GN.bus.source_bus) = 1 + 0.257*p_r - 0.533*p_r./T_r;
    end
    
    %% branch
    if isfield(GN,'branch')
        i_bus_out   = GN.branch.i_to_bus;
        i_bus_out(GN.branch.V_dot_n_ij < 0) = GN.branch.i_from_bus(GN.branch.V_dot_n_ij < 0);
        p_r         = GN.bus.p_i(i_bus_out)/p_pc;
        T_r         = GN.branch.T_ij_out/T_pc;
        GN.branch.Z_ij_out = 1 + 0.257*p_r - 0.533*p_r./T_r;
    end
    
    %% comp
    if isfield(GN,'comp')
        p_r         = GN.comp.p_ij_mid/p_pc;
        T_r         = GN.comp.T_ij_mid/T_pc;
        GN.comp.Z_ij_mid    = 1 + 0.257*p_r - 0.533*p_r./T_r;
    end
    
    %% prs
    if isfield(GN,'prs')
        p_r         = GN.prs.p_ij_mid/p_pc;
        T_r         = GN.prs.T_ij_mid/T_pc;
        GN.prs.Z_ij_mid     = 1 + 0.257*p_r - 0.533*p_r./T_r;
    end
    
end

end

