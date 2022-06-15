function GN = get_GN_res_pipe(GN)
%GET_GN_RES_PIPE Summary of this function goes here
%   Detailed explanation goes here
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2022, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Physical constants
CONST = getConstants();

%% Apply results from branch to pipe
% V_dot_n_ij
i_pipe = GN.branch.i_pipe(GN.branch.pipe_branch);
GN.pipe.V_dot_n_ij(i_pipe) = ...
    GN.branch.V_dot_n_ij(GN.branch.pipe_branch);

% Delta p
GN.pipe.delta_p_ij__bar = GN.branch.delta_p_ij__bar(GN.pipe.i_branch);

%% Calculate additional results
% Calulate velocity v [m/s]
GN = get_rho(GN);
iF = GN.branch.i_from_bus(GN.branch.pipe_branch);
iT = GN.branch.i_to_bus(GN.branch.pipe_branch);
GN.pipe.v_from_bus              = GN.pipe.V_dot_n_ij ./ GN.pipe.D_ij * GN.gasMixProp.rho_n_avg ./ GN.bus.rho_i(iF);
GN.pipe.v_to_bus                = GN.pipe.V_dot_n_ij ./ GN.pipe.D_ij * GN.gasMixProp.rho_n_avg ./ GN.bus.rho_i(iT);

% Get p_ij__barg
GN.pipe.p_ij__barg = (GN.pipe.p_ij - CONST.p_n)*1e-5;
GN.pipe.p_ij = [];

% Calculate P_th_i__MW, P_th_i, V_dot_n_i__m3_per_day, V_dot_n_i__m3_per_h or m_dot_i__kg_per_s
if ismember('P_th_i__MW',GN.bus.Properties.VariableNames)
    GN.pipe.P_th_ij__MW = GN.pipe.V_dot_n_ij * 1e-6 * GN.gasMixProp.H_s_n_avg;
    %         GN.pipe.V_dot_n_ij = [];
elseif ismember('P_th_i',GN.bus.Properties.VariableNames)
    GN.pipe.P_th_ij = GN.pipe.V_dot_n_ij * GN.gasMixProp.H_s_n_avg;
    %         GN.pipe.V_dot_n_ij = [];
elseif ismember('V_dot_n_i__m3_per_day',GN.bus.Properties.VariableNames)
    GN.pipe.V_dot_n_ij__m3_per_day  = GN.pipe.V_dot_n_ij * 60 * 60 * 24;
    %         GN.pipe.V_dot_n_ij = [];
elseif ismember('V_dot_n_i__m3_per_h',GN.bus.Properties.VariableNames)
    GN.pipe.V_dot_n_ij__m3_per_h    = GN.pipe.V_dot_n_ij * 60 * 60;
    %         GN.pipe.V_dot_n_ij = [];
elseif ismember('m_dot_i__kg_per_s',GN.bus.Properties.VariableNames)
    GN.pipe.m_dot_ij__kg_per_s      = GN.pipe.V_dot_n_ij * GN.gasMixProp.rho_n_avg;
    %         GN.pipe.V_dot_n_ij = [];
end
end

