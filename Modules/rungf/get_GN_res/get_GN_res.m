function [GN] = get_GN_res(GN, NUMPARAM, PHYMOD)
%GET_GN_RESULT Result preparation
%   GN = get_GN_res(GN, NUMPARAM, PHYMOD)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2021, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~any(strcmp('V_dot_n_ij',GN.branch.Properties.VariableNames))
    error('GN is no GN result struct. GN.branch.V_dot_n_ij is missing.')
end

%% Physical constants
CONST = getConstants();

%% comp
if isfield(GN,'comp')
    % GN = get_P_el_comp(GN, PHYMOD); % UNDER CONSTRCUTION
    
    % Get V_dot_n_ij from branch
    i_comp = GN.branch.i_comp(GN.branch.comp_branch);
    GN.comp.V_dot_n_ij(i_comp) = ...
        GN.branch.V_dot_n_ij(GN.branch.comp_branch);
    
    % Check V_dot_n_ij
    if any(GN.comp.V_dot_n_ij < -NUMPARAM.numericalTolerance)
        comp_ID = GN.comp.comp_ID(GN.comp.V_dot_n_ij < -NUMPARAM.numericalTolerance);
        warning(['The volume flows at these compressors have the wrong direction, comp_ID: ',num2str(comp_ID')])
    end
    
    % Compare input and output pressure
    i_from_bus = GN.branch.i_from_bus(GN.branch.comp_branch);
    i_to_bus = GN.branch.i_to_bus(GN.branch.comp_branch);
    p_i = GN.bus.p_i(i_from_bus);
    p_j = GN.bus.p_i(i_to_bus);
    delta_p = p_j - p_i;
    comp_ID = GN.branch.comp_ID(GN.branch.comp_branch);
    if any(delta_p < -NUMPARAM.numericalTolerance)
        comp_ID = comp_ID(delta_p < -NUMPARAM.numericalTolerance);
        warning(['Output pressure is smaler than input pressure at these compressors, comp_ID: ',num2str(comp_ID)])
    end
    
    % Calculate P_th_ij__MW, P_th_ij, V_dot_n_ij__m3_per_day,
    %   V_dot_n_ij__m3_per_h or m_dot_ij__kg_per_s
    if any(strcmp('P_th_i__MW',GN.bus.Properties.VariableNames))
        GN.comp.P_th_ij__MW                 = GN.comp.V_dot_n_ij * 1e-6 * GN.gasMixProp.H_s_n_avg;
%         GN.comp.V_dot_n_ij                  = [];
        GN.comp.P_th_i_comp__MW             = GN.comp.V_dot_n_i_comp * 1e-6 * GN.gasMixProp.H_s_n_avg;
%         GN.comp.V_dot_n_i_comp              = [];
        
    elseif any(strcmp('P_th_i',GN.bus.Properties.VariableNames))
        GN.comp.P_th_ij                     = GN.comp.V_dot_n_ij * GN.gasMixProp.H_s_n_avg;
%         GN.comp.V_dot_n_ij                  = [];
        GN.comp.P_th_i_comp                 = GN.comp.V_dot_n_i_comp * GN.gasMixProp.H_s_n_avg;
%         GN.comp.V_dot_n_i_comp              = [];
        
    elseif any(strcmp('V_dot_n_i__m3_per_day',GN.bus.Properties.VariableNames))
        GN.comp.V_dot_n_ij__m3_per_day      = GN.comp.V_dot_n_ij * 60 * 60 * 24;
%         GN.comp.V_dot_n_ij                  = [];
        GN.comp.V_dot_n_i_comp__m3_per_day  = GN.comp.V_dot_n_i_comp * 60 * 60 * 24;
%         GN.comp.V_dot_n_i_comp              = [];
        
    elseif any(strcmp('V_dot_n_i__m3_per_h',GN.bus.Properties.VariableNames))
        GN.comp.V_dot_n_ij__m3_per_h        = GN.comp.V_dot_n_ij * 60 * 60;
%         GN.comp.V_dot_n_ij                  = [];
        GN.comp.V_dot_n_i_comp__m3_per_h    = GN.comp.V_dot_n_i_comp * 60 * 60;
%         GN.comp.V_dot_n_i_comp              = [];
        
    elseif any(strcmp('m_dot_i__kg_per_s',GN.bus.Properties.VariableNames))
        GN.comp.m_dot_ij__kg_per_s          = GN.comp.V_dot_n_ij * GN.gasMixProp.rho_n_avg;
%         GN.comp.V_dot_n_ij                  = [];
        GN.comp.m_dot_i_comp__kg_per_s      = GN.comp.V_dot_n_i_comp * GN.gasMixProp.rho_n_avg;
%         GN.comp.V_dot_n_i_comp              = [];
    end
    
    % UNDER CONSTRUCTION: Q_dot_cooler
end

%% prs
if isfield(GN,'prs')
    % P_el_exp_turbine
    GN = get_P_el_exp_turbine(GN, PHYMOD);
    
    % Get V_dot_n_ij from branch
    i_prs = GN.branch.i_prs(GN.branch.prs_branch);
    GN.prs.V_dot_n_ij(i_prs) = ...
        GN.branch.V_dot_n_ij(GN.branch.prs_branch);
    
    % Check V_dot_n_ij
    if any(GN.prs.V_dot_n_ij < -NUMPARAM.numericalTolerance)
        prs_ID = GN.prs.prs_ID(GN.prs.V_dot_n_ij < -NUMPARAM.numericalTolerance);
        warning(['The volume flows at these pressure gegulator stations have the wrong direction, prs_ID: ',num2str(prs_ID')])
    end
    
    % Calculate P_th_ij__MW, P_th_ij, V_dot_n_ij__m3_per_day,
    %   V_dot_n_ij__m3_per_h or m_dot_ij__kg_per_s
    if any(strcmp('P_th_i__MW',GN.bus.Properties.VariableNames))
        GN.prs.P_th_ij__MW              = GN.prs.V_dot_n_ij * 1e-6 * GN.gasMixProp.H_s_n_avg;
%         GN.prs.V_dot_n_ij               = [];
        
    elseif any(strcmp('P_th_i',GN.bus.Properties.VariableNames))
        GN.prs.P_th_ij                  = GN.prs.V_dot_n_ij * GN.gasMixProp.H_s_n_avg;
%         GN.prs.V_dot_n_ij               = [];
        
    elseif any(strcmp('V_dot_n_i__m3_per_day',GN.bus.Properties.VariableNames))
        GN.prs.V_dot_n_ij__m3_per_day   = GN.prs.V_dot_n_ij * 60 * 60 * 24;
%         GN.prs.V_dot_n_ij               = [];
        
    elseif any(strcmp('V_dot_n_i__m3_per_h',GN.bus.Properties.VariableNames))
        GN.prs.V_dot_n_ij__m3_per_h     = GN.prs.V_dot_n_ij * 60 * 60;
%         GN.prs.V_dot_n_ij               = [];
        
    elseif any(strcmp('m_dot_i__kg_per_s',GN.bus.Properties.VariableNames))
        GN.prs.m_dot_ij__kg_per_s       = GN.prs.V_dot_n_ij * GN.gasMixProp.rho_n_avg;
%         GN.prs.V_dot_n_ij               = [];
        
    end
    
    % UNDER CONSTRUCTION: Q_dot_heater
end

%% valve
if isfield(GN,'valve')
    % V_dot_n_ij
    i_valve = GN.branch.i_valve(GN.branch.valve_branch);
    GN.valve.V_dot_n_ij(i_valve) = ...
        GN.branch.V_dot_n_ij(GN.branch.valve_branch);
    
    % Get V_dot_n_ij from branch
    if any(GN.valve.V_dot_n_ij < -NUMPARAM.numericalTolerance)
        valve_ID = GN.valve.valve_ID(GN.valve.V_dot_n_ij < -NUMPARAM.numericalTolerance);
        warning(['The volume flows at these valves have the wrong direction, valve_ID: ',num2str(valve_ID')])
    end
    
    % Calculate P_th_ij__MW, P_th_ij, V_dot_n_ij__m3_per_day,
    %   V_dot_n_ij__m3_per_h or m_dot_ij__kg_per_s
    if any(strcmp('P_th_i__MW',GN.bus.Properties.VariableNames))
        GN.valve.P_th_ij__MW                = GN.valve.V_dot_n_ij * 1e-6 * GN.gasMixProp.H_s_n_avg;
%         GN.valve.V_dot_n_ij                 = [];
        
    elseif any(strcmp('P_th_i',GN.bus.Properties.VariableNames))
        GN.valve.P_th_ij                    = GN.valve.V_dot_n_ij * GN.gasMixProp.H_s_n_avg;
%         GN.valve.V_dot_n_ij                 = [];
        
    elseif any(strcmp('V_dot_n_i__m3_per_day',GN.bus.Properties.VariableNames))
        GN.valve.V_dot_n_ij__m3_per_day     = GN.valve.V_dot_n_ij * 60 * 60 * 24;
%         GN.valve.V_dot_n_ij                 = [];
        
    elseif any(strcmp('V_dot_n_i__m3_per_h',GN.bus.Properties.VariableNames))
        GN.valve.V_dot_n_ij__m3_per_h       = GN.valve.V_dot_n_ij * 60 * 60;
%         GN.valve.V_dot_n_ij                 = [];
        
    elseif any(strcmp('m_dot_i__kg_per_s',GN.bus.Properties.VariableNames))
        GN.valve.m_dot_ij__kg_per_s         = GN.valve.V_dot_n_ij * GN.gasMixProp.rho_n_avg;
%         GN.valve.V_dot_n_ij                 = [];
        
    end
end

%% pipe
if isfield(GN,'pipe')
    % Get V_dot_n_ij from branch
    i_pipe = GN.branch.i_pipe(GN.branch.pipe_branch);
    GN.pipe.V_dot_n_ij(i_pipe) = ...
        GN.branch.V_dot_n_ij(GN.branch.pipe_branch);
    
    % Get rho_ij - UNDER CONSTRCUTION: Necessary?
    if ~any(strcmp('rho_ij',GN.pipe.Properties.VariableNames))
        GN = get_rho(GN);
    end
    
    % Calulate velocity v [m/s]
    iF = GN.branch.i_from_bus(GN.branch.pipe_branch);
    iT = GN.branch.i_to_bus(GN.branch.pipe_branch);
    GN.pipe.v_from_bus              = GN.pipe.V_dot_n_ij ./ GN.pipe.D_ij * GN.gasMixProp.rho_n_avg ./ GN.bus.rho_i(iF);
    GN.pipe.v_to_bus                = GN.pipe.V_dot_n_ij ./ GN.pipe.D_ij * GN.gasMixProp.rho_n_avg ./ GN.bus.rho_i(iT);
    
    % Check v
    if any(strcmp('v_max',GN.pipe.Properties.VariableNames))
        if any(GN.pipe.v_from_bus > GN.pipe.v_max) || any(GN.pipe.v_to_bus > GN.pipe.v_max)
            pipe_ID = GN.pipe.pipe_ID(GN.pipe.v_from_bus > GN.pipe.v_max | GN.pipe.v_to_bus > GN.pipe.v_max);
            warning(['Too high temperature at these nodes, bus_ID: ',num2str(pipe_ID')])
        end
    end
    
    % Get p_ij__barg
    GN.pipe.p_ij__barg = (GN.pipe.p_ij - CONST.p_n)*1e-5;
    GN.pipe.p_ij = [];
    
    % Get lambda_ij
    if any(strcmp('lambda_ij',GN.pipe.Properties.VariableNames))
        GN.pipe.lambda_ij(isinf(GN.pipe.lambda_ij)) = NaN;
    end
    
    % Calculate P_th_i__MW, P_th_i, V_dot_n_i__m3_per_day,
    %   V_dot_n_i__m3_per_h or m_dot_i__kg_per_s
    if any(strcmp('P_th_i__MW',GN.bus.Properties.VariableNames))
        GN.pipe.P_th_ij__MW = GN.pipe.V_dot_n_ij * 1e-6 * GN.gasMixProp.H_s_n_avg;
%         GN.pipe.V_dot_n_ij = [];
    elseif any(strcmp('P_th_i',GN.bus.Properties.VariableNames))
        GN.pipe.P_th_ij = GN.pipe.V_dot_n_ij * GN.gasMixProp.H_s_n_avg;
%         GN.pipe.V_dot_n_ij = [];
    elseif any(strcmp('V_dot_n_i__m3_per_day',GN.bus.Properties.VariableNames))
        GN.pipe.V_dot_n_ij__m3_per_day  = GN.pipe.V_dot_n_ij * 60 * 60 * 24;
%         GN.pipe.V_dot_n_ij = [];
    elseif any(strcmp('V_dot_n_i__m3_per_h',GN.bus.Properties.VariableNames))
        GN.pipe.V_dot_n_ij__m3_per_h    = GN.pipe.V_dot_n_ij * 60 * 60;
%         GN.pipe.V_dot_n_ij = [];
    elseif any(strcmp('m_dot_i__kg_per_s',GN.bus.Properties.VariableNames))
        GN.pipe.m_dot_ij__kg_per_s      = GN.pipe.V_dot_n_ij * GN.gasMixProp.rho_n_avg;
%         GN.pipe.V_dot_n_ij = [];
    end
end

%% bus
if any(strcmp('p_i',GN.bus.Properties.VariableNames))
    % Get p_i__barg
    GN.bus.p_i__barg = (GN.bus.p_i - CONST.p_n)*1e-5;
    GN.bus.p_i = [];
    
    % check p_i__barg: p_i_min__barg, p_i_max__barg, T_i_min, T_i_max
    if any(strcmp('p_i_max__barg',GN.bus.Properties.VariableNames))
        if any(GN.bus.p_i__barg < GN.bus.p_i_min__barg)
            bus_ID = GN.bus.bus_ID(GN.bus.p_i__barg < GN.bus.p_i_min__barg);
            warning(['Too low pressure at these nodes, bus_ID: ',num2str(bus_ID')])
        end
    end
    if any(strcmp('p_i_min__barg',GN.bus.Properties.VariableNames))
        if any(GN.bus.p_i__barg > GN.bus.p_i_max__barg)
            bus_ID = GN.bus.bus_ID(GN.bus.p_i__barg > GN.bus.p_i_max__barg);
%             warning(['Too high pressure at these nodes, bus_ID:
%             ',num2str(bus_ID')]) % UNDER CONSTRUCTION
        end
    end
    if any(strcmp('T_i_min',GN.bus.Properties.VariableNames))
        if any(GN.bus.T_i < GN.bus.T_i_min)
            bus_ID = GN.bus.bus_ID(GN.bus.T_i < GN.bus.T_i_min);
            warning(['Too low temperature at these nodes, bus_ID: ',num2str(bus_ID')])
        end
    end
    if any(strcmp('T_i_max',GN.bus.Properties.VariableNames))
        if any(GN.bus.T_i > GN.bus.T_i_max)
            bus_ID = GN.bus.bus_ID(GN.bus.T_i > GN.bus.T_i_max);
            warning(['Too high temperature at these nodes, bus_ID: ',num2str(bus_ID')])
        end
    end
    
    % Calculate P_th_i__MW, P_th_i, V_dot_n_i__m3_per_day,
    %   V_dot_n_i__m3_per_h or m_dot_i__kg_per_s
    if any(strcmp('P_th_i__MW',GN.bus.Properties.VariableNames))
        GN.bus.P_th_i__MW = GN.bus.V_dot_n_i * 1e-6 * GN.gasMixProp.H_s_n_avg;
%         GN.bus.V_dot_n_i = [];
    elseif any(strcmp('P_th_i',GN.bus.Properties.VariableNames))
        GN.bus.P_th_i = GN.bus.V_dot_n_i * GN.gasMixProp.H_s_n_avg;
%         GN.bus.V_dot_n_i = [];
    elseif any(strcmp('V_dot_n_i__m3_per_day',GN.bus.Properties.VariableNames))
        GN.bus.V_dot_n_i__m3_per_day  = GN.bus.V_dot_n_i * 60 * 60 * 24;
%         GN.bus.V_dot_n_i = [];
    elseif any(strcmp('V_dot_n_i__m3_per_h',GN.bus.Properties.VariableNames))
        GN.bus.V_dot_n_i__m3_per_h    = GN.bus.V_dot_n_i * 60 * 60;
%         GN.bus.V_dot_n_i = [];
    elseif any(strcmp('m_dot_i__kg_per_s',GN.bus.Properties.VariableNames))
        GN.bus.m_dot_i__kg_per_s      = GN.bus.V_dot_n_i * GN.gasMixProp.rho_n_avg;
%         GN.bus.V_dot_n_i = [];
    end
end
end

