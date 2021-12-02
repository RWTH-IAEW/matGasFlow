function [GN] = get_c_p(GN, PHYMOD)
%GET_C_P Specific isobaric heat capacity of the pipes and the busses
%   c_p [J/(kg*K)]
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
<<<<<<< HEAD
%   Copyright (c) 2020-2022, High Voltage Equipment and Grids,
=======
%   Copyright (c) 2020-2021, High Voltage Equipment and Grids,
>>>>>>> Merge to public repo (#1)
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if PHYMOD.c_p == 1
    %% Van der Waals model
    %% Internal pressure a and covolume b
    if ~isfield(GN.gasMixProp,'a') || ~isfield(GN.gasMixProp,'b')
        GN = get_a_b_VanDerWaals(GN);
    end
    a = GN.gasMixProp.a;
    b = GN.gasMixProp.b;
    
    %% bus
    p_i     = GN.bus.p_i;
    T_i     = GN.bus.T_i;
    Z_i     = GN.bus.Z_i;
    [GN.bus.c_p_i, GN.bus.c_p_0_i] = get_c_p_VanDerWaals(p_i, T_i, Z_i, a, b, GN.gasMixProp, GN.gasMixAndCompoProp);
    
    %% Non-isothermal model
    if GN.isothermal == 0
        %% pipe
        if isfield(GN, 'pipe')
            p_ij    = GN.pipe.p_ij;
            T_ij    = GN.pipe.T_ij;
            Z_ij    = GN.pipe.Z_ij;
            [GN.pipe.c_p_ij, GN.pipe.c_p_0_ij] = get_c_p_VanDerWaals(p_ij, T_ij, Z_ij, a, b, GN.gasMixProp, GN.gasMixAndCompoProp);
        end
        
        %% Source bus
        p_i_source = p_i(GN.bus.source_bus);
        T_i_source = GN.bus.T_i(GN.bus.source_bus);
        Z_i_source = GN.bus.Z_i(GN.bus.source_bus);
        [GN.bus.c_p_i_source(GN.bus.source_bus), GN.bus.c_p_0_i_source(GN.bus.source_bus)] = ...
            get_c_p_VanDerWaals(p_i_source, T_i_source, Z_i_source, a, b, GN.gasMixProp, GN.gasMixAndCompoProp);
        
        %% Branch output
        i_bus_out = GN.branch.i_to_bus;
        i_bus_out(GN.branch.V_dot_n_ij < 0) = GN.branch.i_from_bus(GN.branch.V_dot_n_ij < 0);
        p_ij_out = GN.bus.p_i(i_bus_out);
        try
            T_ij_out = GN.branch.T_ij_out;
            Z_ij_out = GN.branch.Z_ij_out;
        catch
            T_ij_out = GN.bus.T_i(i_bus_out);
            Z_ij_out = GN.bus.Z_i(i_bus_out);
        end
        [GN.branch.c_p_ij_out, GN.branch.c_p_0_ij_out] = get_c_p_VanDerWaals(p_ij_out, T_ij_out, Z_ij_out, a, b, GN.gasMixProp, GN.gasMixAndCompoProp);
    end
    
else
<<<<<<< HEAD
    %try
        GN = get_c_p_addOn(GN, PHYMOD);
    %catch
%        error('Option not available, choose PHYMOD.c_p = 1')
    %end
=======
    try
        GN = get_c_p_addOn(GN, PHYMOD);
    catch
        error('Option not available, choose PHYMOD.c_p = 1')
    end
>>>>>>> Merge to public repo (#1)
end

end

