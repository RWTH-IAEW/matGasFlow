function [GN] = get_reduced_quantities(GN, PHYMOD)
%GET_REDUCED_QUANTITIES
%   [GN] = get_reduced_quantities(GN, PHYMOD)
%
%   Reduced quantities:
%       at busses:  p_r_i, T_r_i
%       at pipes:   p_r_ij, T_r_ij
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2022, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Reduced pressure and temperature
if PHYMOD.reducedQuantities == 1
    GN.bus.p_r_i    = GN.bus.p_i    / GN.gasMixProp.p_pc;
    GN.bus.T_r_i    = GN.bus.T_i    / GN.gasMixProp.T_pc;
    
    if isfield(GN, 'pipe')
        GN.pipe.p_r_ij  = GN.pipe.p_ij  / GN.gasMixProp.p_pc;
        GN.pipe.T_r_ij  = GN.pipe.T_ij  / GN.gasMixProp.T_pc;
    end
    
elseif PHYMOD.reducedQuantities == 2
    % Adjusted pseudo critical data - Wichtert and Aziz
    % Reference: Mischner 2015, S. 117, (9.52)...(9.54)
    if ~isfield(GN.gasMixProp,'p_pc_adj_v1') || ~isfield(GN.gasMixProp,'T_pc_adj_v1')
        epsilon = 120 * ( ...
            (gasMixAndCompoProp.x_mol('H2S') + gasMixAndCompoProp.x_mol('CO2'))^0.9 ...
            - (gasMixAndCompoProp.x_mol('H2S') + gasMixAndCompoProp.x_mol('H2'))^1.6 ) ...
            + 15  * ( gasMixAndCompoProp.x_mol('H2S')^0.5 - gasMixAndCompoProp.x_mol('H2S')^4 );
        
        GN.gasMixProp.p_pc_adj_v1 = GN.gasMixProp.p_pc * 1.8 * GN.gasMixProp.T_pc_adj_v1 ...
            / (1.8 *GN.gasMixProp.T_pc + gasMixAndCompoProp.x_mol('H2S') * (1-gasMixAndCompoProp.x_mol('H2S')) *epsilon);
        
        GN.gasMixProp.T_pc_adj_v1 = 5/9 * (1.8 * GN.gasMixProp.T_pc - epsilon);
        
    end
    
    GN.bus.p_r_i    = GN.bus.p_i    / GN.gasMixProp.p_pc_adj_v1;
    GN.bus.T_r_i    = GN.bus.T_i    / GN.gasMixProp.T_pc_adj_v1;
    
    if isfield(GN, 'pipe')
        GN.pipe.p_r_ij  = GN.pipe.p_ij  / GN.gasMixProp.p_pc_adj_v1;
        GN.pipe.T_r_ij  = GN.pipe.T_ij  / GN.gasMixProp.T_pc_adj_v1;
    end
    
elseif PHYMOD.reducedQuantities == 3
    % Adjusted pseudo critical data - Carr, Kobayashi and Burrows
    % Reference: Mischner 2015, S. 117, (9.52)...(9.54)
    if ~isfield(GN.gasMixProp,'p_pc_adj_v2') || ~isfield(GN.gasMixProp,'T_pc_adj_v2')
        GN.gasMixProp.p_pc_adj_v2 = GN.gasMixProp.p_pc ...
            + 30.3 * gasMixAndCompoProp.x_mol('CO2') ...
            + 41.1 * gasMixAndCompoProp.x_mol('H2S') ...
            - 11.7  * gasMixAndCompoProp.x_mol('N2');
        
        GN.gasMixProp.T_pc_adj_v2 = GN.gasMixProp.T_pc ...
            - 44.4 * gasMixAndCompoProp.x_mol('CO2') ...
            + 72.2 * gasMixAndCompoProp.x_mol('H2S') ...
            - 138.9 * gasMixAndCompoProp.x_mol('N2');
        
    end
    
    GN.bus.p_r_i    = GN.bus.p_i    / GN.gasMixProp.p_pc_adj_v2;
    GN.bus.T_r_i    = GN.bus.T_i    / GN.gasMixProp.T_pc_adj_v2;
    
    if isfield(GN, 'pipe')
        GN.pipe.p_r_ij  = GN.pipe.p_ij  / GN.gasMixProp.p_pc_adj_v2;
        GN.pipe.T_r_ij  = GN.pipe.T_ij  / GN.gasMixProp.T_pc_adj_v2;
    end
    
end

%% Reduced molar volume - unecessary
% CONST = getConstants(); 
% V_m_i = GN.bus.Z_i .* CONST.R_m .* GN.bus.T_i ./ GN.bus.p_i;
% GN.bus.V_m_r_i = V_m_i / GN.gasMixProp.V_m_pc;
% V_m_ij = GN.pipe.Z_ij .* CONST.R_m .* GN.pipe.T_ij ./ GN.pipe.p_ij;
% GN.pipe.V_m_r_ij = V_m_ij / GN.gasMixProp.V_m_pc;

end

