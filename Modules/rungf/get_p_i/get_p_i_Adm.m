function [GN] = get_p_i_Adm(GN, PHYMOD)
%GET_P_I_ADM Summary of this function goes here
%   Detailed explanation goes here
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

%% Admittance Matrix - Pneumatic conductance G_ij
GN = get_G_ij(GN, 2);

G_ij = GN.pipe.G_ij;
INC_Pipes = GN.INC(:,GN.branch.pipe_branch);
G_ij_diag = abs(INC_Pipes)*abs(G_ij);

i_from_bus = GN.branch.i_from_bus(GN.branch.pipe_branch);
i_to_bus = GN.branch.i_to_bus(GN.branch.pipe_branch);
G = sparse(...
    [i_from_bus', i_to_bus',1:length(G_ij_diag)],...
    [i_to_bus', i_from_bus',1:length(G_ij_diag)],...
    [-G_ij',-G_ij',G_ij_diag']);

ADM_G_ij = G(:,~GN.bus.p_bus);

%% General gas flow equation
% V_dot_n_i = G_ij * sqrt(p_i^2 - p_j^2)
% ~> G * p_i = V_dot_n_i

V_dot_n_i_nonPipes = GN.INC(:,~GN.branch.pipe_branch) * GN.branch.V_dot_n_ij(~GN.branch.pipe_branch);
if isempty(V_dot_n_i_nonPipes)
    V_dot_n_i_nonPipes = zeros(size(GN.bus.V_dot_n_i));
end
b = -(GN.bus.V_dot_n_i + V_dot_n_i_nonPipes) - G(:, GN.bus.p_bus) * GN.bus.p_i(GN.bus.p_bus);

p_i = ADM_G_ij\b;

%% p_i
GN.bus.p_i(~GN.bus.p_bus) = p_i;

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

end

