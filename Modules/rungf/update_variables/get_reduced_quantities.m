function [GN] = get_reduced_quantities(GN, PHYMOD)
%GET_REDUCED_QUANTITIES
%
%   Reduced quantities: p_r_i, T_r_i
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2021, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Physical constants
CONST = getConstants();

%% Reduced pressure and temperature
if PHYMOD.reducedQuantities == 1
    GN.bus.p_r_i    = GN.bus.p_i    / GN.gasMixProp.p_pc;
    GN.bus.T_r_i    = GN.bus.T_i    / GN.gasMixProp.T_pc;
    
    if isfield(GN, 'pipe')
        GN.pipe.p_r_ij  = GN.pipe.p_ij  / GN.gasMixProp.p_pc;
        GN.pipe.T_r_ij  = GN.pipe.T_ij  / GN.gasMixProp.T_pc;
    end
    
elseif PHYMOD.reducedQuantities == 2
    GN.bus.p_r_i    = GN.bus.p_i    / GN.gasMixProp.p_pc_adj_v1;
    GN.bus.T_r_i    = GN.bus.T_i    / GN.gasMixProp.T_pc_adj_v1;
    
    if isfield(GN, 'pipe')
        GN.pipe.p_r_ij  = GN.pipe.p_ij  / GN.gasMixProp.p_pc_adj_v1;
        GN.pipe.T_r_ij  = GN.pipe.T_ij  / GN.gasMixProp.T_pc_adj_v1;
    end
    
elseif PHYMOD.reducedQuantities == 3
    GN.bus.p_r_i    = GN.bus.p_i    / GN.gasMixProp.p_pc_adj_v2;
    GN.bus.T_r_i    = GN.bus.T_i    / GN.gasMixProp.T_pc_adj_v2;
    
    if isfield(GN, 'pipe')
        GN.pipe.p_r_ij  = GN.pipe.p_ij  / GN.gasMixProp.p_pc_adj_v2;
        GN.pipe.T_r_ij  = GN.pipe.T_ij  / GN.gasMixProp.T_pc_adj_v2;
    end
    
end

%% Reduced molar volume - unecessary
% V_m_i = GN.bus.Z_i .* CONST.R_m .* GN.bus.T_i ./ GN.bus.p_i;
% GN.bus.V_m_r_i = V_m_i / GN.gasMixProp.V_m_pc;
% V_m_ij = GN.pipe.Z_ij .* CONST.R_m .* GN.pipe.T_ij ./ GN.pipe.p_ij;
% GN.pipe.V_m_r_ij = V_m_ij / GN.gasMixProp.V_m_pc;

end

