function GN = get_GN_res_pipe(GN)
%GET_GN_RES_PIPE
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

%% Physical constants
CONST = getConstants();

%% Apply results from branch to pipe
% V_dot_n_ij
GN.pipe.V_dot_n_ij = GN.branch.V_dot_n_ij(GN.pipe.i_branch);

% Delta p
GN.pipe.Delta_p_ij__bar = GN.branch.Delta_p_ij__bar(GN.pipe.i_branch);

% Update G_ij, lambda_ij, Re_ij
GN = get_G_ij(GN);

%% Calculate additional results
% Calulate velocity v [m/s]
GN = get_rho(GN);
iF = GN.branch.i_from_bus(GN.branch.pipe_branch);
iT = GN.branch.i_to_bus(GN.branch.pipe_branch);
GN.pipe.v_from_bus              = GN.pipe.V_dot_n_ij ./ GN.pipe.D_ij * GN.gasMixProp.rho_n_avg ./ GN.bus.rho_i(iF);
GN.pipe.v_to_bus                = GN.pipe.V_dot_n_ij ./ GN.pipe.D_ij * GN.gasMixProp.rho_n_avg ./ GN.bus.rho_i(iT);
GN.pipe.v_max_abs               = max(abs([GN.pipe.v_from_bus ,GN.pipe.v_to_bus]),[],2);

% Get p_ij__barg
GN.pipe.p_ij__barg = (GN.pipe.p_ij - CONST.p_n)*1e-5;

% Calculate P_th_i__MW, P_th_i, V_dot_n_i__m3_per_day, V_dot_n_i__m3_per_h or m_dot_i__kg_per_s
if ismember('P_th_i__MW',GN.bus.Properties.VariableNames)
    GN.pipe.P_th_ij__MW = convert_gas_flow_quantity(GN.pipe.V_dot_n_ij,             'm3_per_s',    'MW',            GN.gasMixProp);
    GN.pipe.V_dot_n_ij = [];
elseif ismember('P_th_i',GN.bus.Properties.VariableNames)
    GN.pipe.P_th_ij = convert_gas_flow_quantity(GN.pipe.V_dot_n_ij,                 'm3_per_s',    'W',             GN.gasMixProp);
    GN.pipe.V_dot_n_ij = [];
elseif ismember('V_dot_n_i__m3_per_day',GN.bus.Properties.VariableNames)
    GN.pipe.V_dot_n_ij__m3_per_day = convert_gas_flow_quantity(GN.pipe.V_dot_n_ij,  'm3_per_s',    'm3_per_day',    GN.gasMixProp);
    GN.pipe.V_dot_n_ij = [];
elseif ismember('V_dot_n_i__m3_per_h',GN.bus.Properties.VariableNames)
    GN.pipe.V_dot_n_ij__m3_per_h = convert_gas_flow_quantity(GN.pipe.V_dot_n_ij,    'm3_per_s',    'm3_per_h',      GN.gasMixProp);
    GN.pipe.V_dot_n_ij = [];
elseif ismember('m_dot_i__kg_per_s',GN.bus.Properties.VariableNames)
    GN.pipe.m_dot_ij__kg_per_s = convert_gas_flow_quantity(GN.pipe.V_dot_n_ij,      'm3_per_s',    'kg_per_s',      GN.gasMixProp);
    GN.pipe.V_dot_n_ij = [];
end

end

