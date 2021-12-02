function [GN] = get_p_i_SLE(GN, PHYMOD)
%GET_P_I_SLE Start solution for nodal pressure p_i
%   [GN] = get_p_i_SLE(GN, PHYMOD) solves system of linear equations (SLE)
%   INC' * p_i^2 = -V^2/G_ij
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2021, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Check if there is any volumen flow and check for pipes
if all(GN.branch.V_dot_n_ij == 0) || ~isfield(GN, 'pipe')
    return
end

%% Pneumatic conductance
GN = get_G_ij(GN, 1);

%% General gas flow equation
% INC' * p_i^2 = -V^2/G_ij

% Ignore parallel pipes and non-pipe branches
non_parallel_pipe_branch = GN.branch.pipe_branch & ~GN.branch.parallel_branch & ~GN.branch.connecting_branch;

INC_Pipes = GN.INC(:,non_parallel_pipe_branch);

b = sign(GN.branch.V_dot_n_ij(non_parallel_pipe_branch)) .* GN.branch.V_dot_n_ij(non_parallel_pipe_branch).^2 ...
    ./ GN.pipe.G_ij(non_parallel_pipe_branch(GN.branch.pipe_branch)).^2 ...
    - INC_Pipes(GN.bus.p_bus,:)' * GN.bus.p_i(GN.bus.p_bus).^2;
b(isnan(b)) = 0;

A = INC_Pipes(~GN.bus.p_bus,:)';

GN.bus.p_i(~GN.bus.p_bus) = sqrt(A\b);

%% Check p_i result
CONST = getConstants();
if any(imag(GN.bus.p_i) ~= 0)
    error(['get_p_i_Adm: Nodal pressure became negative: min(p_i) = ',...
        num2str(-max(imag(GN.bus.p_i))),' Pa at bus_ID ', num2str(GN.bus.bus_ID(imag(GN.bus.p_i) == max(imag(GN.bus.p_i)))), '.'])
elseif any(GN.bus.p_i <= CONST.p_n)
    error(['get_p_i_Adm: Nodal pressure became less than ',num2str(CONST.p_n),' Pa. min(p_i) = ',num2str(min(GN.bus.p_i)),' Pa at bus_ID ', num2str(GN.bus.bus_ID(GN.bus.p_i == min(GN.bus.p_i))), '.'])
end

%% Update p_i dependent quantities
% Update p_i at valve output
GN = get_p_T_valve(GN);

% Update p_ij
GN = get_p_ij(GN);

% Compressibility factor
GN = get_Z(GN, PHYMOD);

% Dynamic viscosity eta_ij(T,rho)
GN = get_eta(GN,PHYMOD);

%% Update V_dot_n_ij at parallel pipes
GN = get_V_dot_n_ij_parallelPipes(GN);

end