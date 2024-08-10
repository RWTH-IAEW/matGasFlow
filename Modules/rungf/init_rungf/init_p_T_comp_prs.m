function [GN] = init_p_T_comp_prs(GN)
%INIT_P_T_COMP_PRS(GN)
%   [ GN ] = INIT_P_T_COMP_PRS(GN)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% comp
if isfield(GN, 'comp')
    i_bus_out           = GN.branch.i_to_bus(GN.comp.i_branch);
    
    % Initialize p_ij_mid = p_in_comp (isobaric process)
    GN.comp.p_ij_mid    = GN.bus.p_i(i_bus_out);
    
    % T_ij_out
    T_controlled        = GN.comp.T_controlled;
    GN.branch.T_ij_out(GN.comp.i_branch(T_controlled))    = GN.comp.T_ij_out(T_controlled);
    GN.branch.T_ij_out(GN.comp.i_branch(~T_controlled))   = GN.bus.T_i(i_bus_out(~T_controlled));

    % T_ij_mid
    GN.comp.T_ij_mid    = GN.branch.T_ij_out(GN.comp.i_branch);
    
end

%% prs
if isfield(GN, 'prs')
    i_bus_in        = GN.branch.i_from_bus(GN.prs.i_branch);
    i_bus_out       = GN.branch.i_to_bus(GN.prs.i_branch);
    
    % Initialize p_ij_mid = p_in_prs (isobaric process)
    GN.prs.p_ij_mid = GN.bus.p_i(i_bus_in);
    
    % Initialize prs.T_ij_mid, branch.T_ij_out
    T_controlled    = GN.prs.T_controlled;
    GN.branch.T_ij_out(GN.prs.i_branch(T_controlled))    = GN.prs.T_ij_out(T_controlled);
    GN.branch.T_ij_out(GN.prs.i_branch(~T_controlled))   = GN.bus.T_i(i_bus_out(~T_controlled));

    % T_ij_mid
    GN.prs.T_ij_mid  = GN.bus.T_i(i_bus_in);
    
end

end

