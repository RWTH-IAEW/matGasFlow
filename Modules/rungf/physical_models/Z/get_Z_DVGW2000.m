function [GN] = get_Z_DVGW2000(GN)
%GET_Z_DVGW_G_2000
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
Z_n_avg = GN.gasMixProp.Z_n_avg;
p_ref   = 450 * 1e5;

%% bus
GN.bus.Z_i          = Z_n_avg * (1 - GN.bus.p_i/p_ref);

%% pipe
if isfield(GN,'pipe')
    GN.pipe.Z_ij    = Z_n_avg * (1 - GN.bus.p_i/p_ref);
end

%% non-isothermal
if ~GN.isothermal
    
    %% source
    if any(GN.bus.source_bus)
        GN.bus.Z_i_source(GN.bus.source_bus) = Z_n_avg * (1 - GN.bus.p_i(GN.bus.source_bus)/p_ref);
    end
    
    %% branch
    if isfield(GN,'branch')
        i_bus_out           = GN.branch.i_to_bus;
        i_bus_out(GN.branch.V_dot_n_ij < 0) = GN.branch.i_from_bus(GN.branch.V_dot_n_ij < 0);
        GN.branch.Z_ij_out  = Z_n_avg * (1 - GN.bus.p_i(i_bus_out)/p_ref);
    end
    
    %% comp
    if isfield(GN,'comp')
        GN.comp.Z_ij_mid    = Z_n_avg * (1 - GN.comp.p_ij_mid/p_ref);
    end
    
    %% prs
    if isfield(GN,'prs')
        GN.prs.Z_ij_mid     = Z_n_avg * (1 - GN.prs.p_ij_mid/p_ref);
    end
    
end

end

