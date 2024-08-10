function [GN] = get_f_nodal_equation(GN, NUMPARAM, PHYMOD, f_mode)
%GET_F_NODAL_EQUAION
%   [GN] = get_f_nodal_equation(GN, NUMPARAM, PHYMOD, OPTION)
%       f = sum(V_dot_n_ij) + V_dot_n_i for every bus i
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% if nargin < 4
%     f_mode = 'GN';
% end

%% Gas flow rate V_dot_n_ij in Pipes
GN = get_V_dot_n_ij_pipe(GN, NUMPARAM);

%% V_dot_n_i demand of compressors
GN = get_V_dot_n_i_comp(GN, PHYMOD);

%% V_dot_n_i demand of prs heater
GN = get_V_dot_n_i_prs(GN, NUMPARAM, PHYMOD);

%% Update slack bus and slack branch
% GN = get_V_dot_n_slack(GN, f_mode, NUMPARAM);

%% Calculate f
GN.bus.f = GN.MAT.INC * GN.branch.V_dot_n_ij + GN.bus.V_dot_n_i;

%% Set convergence
GN = set_convergence(GN, 'update f');

end


%% TODO: old code, try to avoid oscilation between laminar and turbulent state
% Gas flow rate V_dot_n_ij in Pipes
% V_dot_n_ij_pipe = GN.branch.V_dot_n_ij(GN.pipe.i_branch);
% GN              = get_V_dot_n_ij_pipe(GN, NUMPARAM);
% CONST           = getConstants;
% if any(V_dot_n_ij_pipe == 0 & GN.branch.V_dot_n_ij(GN.pipe.i_branch) ~= 0 & GN.pipe.Re_ij > CONST.Re_crit)
%     GN = get_V_dot_n_ij_pipe(GN, NUMPARAM);
% end
%
% flag = false;
% 
% if ismember('Re_ij',GN.pipe.Properties.VariableNames)
%     laminar_0   = GN.pipe.Re_ij <= CONST.Re_crit;
%     flag = true;
% end
%
% laminar_1   = GN.pipe.Re_ij <= CONST.Re_crit;
% if flag
%     while any(laminar_0 ~= laminar_1)
%         laminar_0   = laminar_1;
%         GN          = get_V_dot_n_ij_pipe(GN, NUMPARAM);
%         laminar_1   = GN.pipe.Re_ij <= CONST.Re_crit;
%         GN.branch.V_dot_n_ij(GN.pipe.i_branch(laminar_0))
%     end
% end
%
% while norm(V_dot_n_ij - GN.branch.V_dot_n_ij) > NUMPARAM.numericalTolerance
%     V_dot_n_ij = GN.branch.V_dot_n_ij;
%     GN = get_V_dot_n_ij_pipe(GN, NUMPARAM);
% end