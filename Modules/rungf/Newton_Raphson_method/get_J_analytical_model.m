function [GN] = get_J_analytical_model(GN, NUMPARAM, PHYMOD)
%GET_J_ANALYTICAL_MODEL Jacobian Matrix J = df/dp
%
%   |-----------------------------------|
%   | df_1/dp_1   .   .   .   df_1/dp_N |
%   |     .       .               .     |
%   |     .           .           .     |
%   |     .               .       .     |
%   | df_N/dp_1   .   .   .   df_N/dp_N |
%   |-----------------------------------|
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2022, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Quantities
p_i = GN.bus.p_i;

%% d(V_dot_n_ij)/dp
if isfield(GN, 'pipe')
    % Indices
    iF_pipe = GN.branch.i_from_bus(GN.branch.pipe_branch);
    iT_pipe = GN.branch.i_to_bus(GN.branch.pipe_branch);
    is_p_i_greater_than_p_j = p_i(iF_pipe) > p_i(iT_pipe);
    
    iIn = iF_pipe;
    iIn(~is_p_i_greater_than_p_j) = iT_pipe(~is_p_i_greater_than_p_j);
    iOut = iT_pipe;
    iOut(~is_p_i_greater_than_p_j) = iF_pipe(~is_p_i_greater_than_p_j);
    
    % Quantites
    p_i = GN.bus.p_i(iIn);
    p_j = GN.bus.p_i(iOut);
    
    % laminar or turbolent
    laminar     = GN.pipe.Re_ij <= 2320;
    turbolent   = GN.pipe.Re_ij > 2320;
    V_dot_n_ij_pipe = GN.branch.V_dot_n_ij(GN.branch.pipe_branch);
    sign_V_dot_n_ij_pipe = sign(V_dot_n_ij_pipe);
    sign_V_dot_n_ij_pipe(is_p_i_greater_than_p_j(GN.branch.pipe_branch))  = 1;
    sign_V_dot_n_ij_pipe(~is_p_i_greater_than_p_j(GN.branch.pipe_branch)) = -1;
    
    d_V_ij_d_p_iIn  = NaN(size(GN.pipe,1),1);
    dV_ij_dp_iOut   = NaN(size(GN.pipe,1),1);
    
    %% laminar
    if any(laminar)
        % Quantities
        CONST   = getConstants();
        p_n     = CONST.p_n;
        T_n     = CONST.T_n;
        D_ij    = GN.pipe.D_ij;
        L_ij    = GN.pipe.L_ij;
        eta_ij  = GN.pipe.eta_ij;
        K_ij    = GN.pipe.Z_ij / GN.gasMixProp.Z_n_avg;
        T_ij    = GN.pipe.T_ij;
        
        % p_i > p_j, i: flow input, j: flow output
        d_V_ij_d_p_iIn_laminar = sign_V_dot_n_ij_pipe .* pi .* D_ij.^4 * T_n ./ (128 * p_n * L_ij .* eta_ij .* K_ij .* T_ij) .* p_i;
        d_V_ij_d_p_iIn_laminar(isnan(d_V_ij_d_p_iIn_laminar)) = 0;
        d_V_ij_d_p_iIn_laminar(GN.bus.slack_bus(iIn)) = 0;
        d_V_ij_d_p_iIn(laminar) = d_V_ij_d_p_iIn_laminar(laminar);
        
        % p_j > p_i, j: flow input, i: flow output
        dV_ij_dp_iOut_laminar = - sign_V_dot_n_ij_pipe .* pi .* D_ij.^4 * T_n ./ (128 * p_n * L_ij .* eta_ij .* K_ij .* T_ij) .* p_j;
        dV_ij_dp_iOut_laminar(isnan(dV_ij_dp_iOut_laminar)) = 0;
        dV_ij_dp_iOut_laminar(GN.bus.slack_bus(iOut)) = 0;
        dV_ij_dp_iOut(laminar) = dV_ij_dp_iOut_laminar(laminar);
    end
    
    %% turbolent
    if any(turbolent)
        [A_ij, B_ij, C_ij] = get_ABC_ij(GN);
        
        % p_i > p_j, i: flow input, j: flow output
        d_V_ij_d_p_iIn_turbolent = ...
            sign_V_dot_n_ij_pipe .* (...
              A_ij .* p_i ./ sqrt(p_i.^2 - p_j.^2) .* log10( B_ij ./ sqrt(p_i.^2 - p_j.^2) + C_ij) ...
            - A_ij .* B_ij .* p_i ./ log(10) ./ (p_i.^2 - p_j.^2) ./ (B_ij ./ sqrt(p_i.^2 - p_j.^2) + C_ij) ...
            );
        d_V_ij_d_p_iIn_turbolent(isnan(d_V_ij_d_p_iIn_turbolent)) = 0;
        d_V_ij_d_p_iIn_turbolent(GN.bus.slack_bus(iIn)) = 0;
        d_V_ij_d_p_iIn(turbolent) = d_V_ij_d_p_iIn_turbolent(turbolent);
        
        % p_j > p_i, j: flow input, i: flow output
        dV_ij_dp_iOut_turbolent = ...
            sign_V_dot_n_ij_pipe .* (...
            - A_ij .* p_j ./ sqrt(p_i.^2 - p_j.^2) .* log10( B_ij ./ sqrt(p_i.^2 - p_j.^2) + C_ij) ...
            + A_ij .* B_ij .* p_j ./ log(10) ./ (p_i.^2 - p_j.^2) ./ (B_ij ./ sqrt(p_i.^2 - p_j.^2) + C_ij) ...
            );
        dV_ij_dp_iOut_turbolent(isnan(dV_ij_dp_iOut_turbolent)) = 0;
        dV_ij_dp_iOut_turbolent(GN.bus.slack_bus(iOut)) = 0;
        dV_ij_dp_iOut(turbolent) = dV_ij_dp_iOut_turbolent(turbolent);
    end
    
        
    %% dV_ij_dp_i, dV_ij_dp_j
    dV_ij_dp_i = d_V_ij_d_p_iIn;
    dV_ij_dp_i(~is_p_i_greater_than_p_j(GN.branch.pipe_branch)) = dV_ij_dp_iOut(~is_p_i_greater_than_p_j(GN.branch.pipe_branch));
    dV_ij_dp_j = dV_ij_dp_iOut;
    dV_ij_dp_j(~is_p_i_greater_than_p_j(GN.branch.pipe_branch)) = d_V_ij_d_p_iIn(~is_p_i_greater_than_p_j(GN.branch.pipe_branch));
    
else
    iF_pipe = [];
    iT_pipe = [];
    dV_ij_dp_i = [];
    dV_ij_dp_j = [];
end

%% V_dot_n_i demand at compressor inputs
if NUMPARAM.OPTION_get_f_nodal_equation == 1 || NUMPARAM.OPTION_get_f_nodal_equation == 3
    if isfield(GN,'comp')
        % Indices
        iF_comp = GN.branch.i_from_bus(GN.branch.comp_branch);
        iT_comp = GN.branch.i_to_bus(GN.branch.comp_branch);
        
        % Quantities
        p_i = GN.bus.p_i(iF_comp);
        p_j = GN.bus.p_i(iT_comp);
        if ~ismember('kappa_i',GN.bus.Properties.VariableNames)
            GN = get_kappa(GN, PHYMOD);
        end
        kappa_i = GN.bus.kappa_i(iF_comp);
        
        % Physical constants
        CONST = getConstants();
        
        D_ij = GN.branch.V_dot_n_ij(GN.branch.comp_branch) .* GN.gasMixProp.rho_n_avg ./ GN.comp.eta_drive ./ GN.comp.eta_s ./ GN.gasMixProp.H_s_n_avg ...
            .* GN.bus.Z_i(iF_comp) .* CONST.R_m .* GN.bus.T_i(iF_comp);
        
        dV_i_comp_dp_i = D_ij .* (p_j ./ p_i).^(-1./kappa_i) .* (- p_j ./ p_i.^2);
        dV_i_comp_dp_j = D_ij .* (p_j ./ p_i).^(-1./kappa_i) ./ p_i;
    else
        iF_comp = [];
        iT_comp = [];
        dV_i_comp_dp_i = [];
        dV_i_comp_dp_j = [];
    end
end

%% 
if NUMPARAM.OPTION_get_f_nodal_equation == 1 || NUMPARAM.OPTION_get_f_nodal_equation == 2
    dV_ij_dp_j_branch = zeros(size(GN.branch,1),1);
    
    % pipe
    if any(GN.branch.pipe_branch)
        dV_ij_dp_j_branch(GN.branch.pipe_branch) = dV_ij_dp_j;
    end
    
    if any(strcmp('station_ID',GN.branch.Properties.VariableNames))
        station_IDs = unique(GN.branch.station_ID(~isnan(GN.branch.station_ID)));
        iF_Station  = [];
        k_bus       = [];
        dV_jk_dp_k  = [];
        
        for iii = 1:length(station_IDs)
            station_ID      = station_IDs(iii);
            reduce_Station  = sum(GN.INC(:,GN.branch.station_ID == station_ID),2);
            iF_Station_temp = find(reduce_Station == 1);
            iT_Station_temp = find(reduce_Station == -1);
            iBranch_jk      = GN.branch.i_from_bus == iT_Station_temp & GN.branch.pipe_branch;
            iBranch_kj      = GN.branch.i_to_bus == iT_Station_temp & GN.branch.pipe_branch;
            
            nBusses = sum([iBranch_jk;iBranch_kj]);
            iF_Station( length(iF_Station) + 1 : length(iF_Station) + nBusses, 1) = ...
                iF_Station_temp*ones(nBusses,1);
            k_bus( length(k_bus) + 1 : length(k_bus) + nBusses, 1) = ...
                [GN.branch.i_to_bus(iBranch_jk); GN.branch.i_from_bus(iBranch_kj)];
            dV_jk_dp_k( length(dV_jk_dp_k) + 1 : length(dV_jk_dp_k) + nBusses, 1) = ...
                [dV_ij_dp_j_branch(iBranch_jk); -dV_ij_dp_j_branch(iBranch_kj)];
        end
    else
        iF_Station = [];
        k_bus = [];
        dV_jk_dp_k = [];
    end
end

%% Jacobian Matrix (sparse)
if      NUMPARAM.OPTION_get_f_nodal_equation == 1
    ii = [iF_pipe;          iT_pipe;            iT_pipe;            iF_pipe;        iF_comp;        iF_comp;        iF_Station ];
    jj = [iF_pipe;          iF_pipe;            iT_pipe;            iT_pipe;        iF_comp;        iT_comp;        k_bus      ];
    vv = [dV_ij_dp_i;       -dV_ij_dp_i;        -dV_ij_dp_j;        dV_ij_dp_j;     dV_i_comp_dp_i; dV_i_comp_dp_j; dV_jk_dp_k ];
    
elseif  NUMPARAM.OPTION_get_f_nodal_equation == 2
    ii = [iF_pipe;          iT_pipe;            iT_pipe;            iF_pipe;                                        iF_Station  ];
    jj = [iF_pipe;          iF_pipe;            iT_pipe;            iT_pipe;                                        k_bus       ];
    vv = [dV_ij_dp_i;       -dV_ij_dp_i;        -dV_ij_dp_j;        dV_ij_dp_j;                                     dV_jk_dp_k  ];
    
elseif  NUMPARAM.OPTION_get_f_nodal_equation == 3
    ii = [iF_pipe;          iT_pipe;            iT_pipe;            iF_pipe;        iF_comp;        iF_comp                     ];
    jj = [iF_pipe;          iF_pipe;            iT_pipe;            iT_pipe;        iF_comp;        iT_comp                     ];
    vv = [dV_ij_dp_i;       -dV_ij_dp_i;        -dV_ij_dp_j;        dV_ij_dp_j;     dV_i_comp_dp_i; dV_i_comp_dp_j              ];
    
elseif  NUMPARAM.OPTION_get_f_nodal_equation == 4
    ii = [iF_pipe;          iT_pipe;            iT_pipe;            iF_pipe;                                                    ];
    jj = [iF_pipe;          iF_pipe;            iT_pipe;            iT_pipe;                                                    ];
    vv = [dV_ij_dp_i;       -dV_ij_dp_i;        -dV_ij_dp_j;        dV_ij_dp_j;                                                 ];
    
end
mm = size(GN.bus,1);
nn = mm;
J = sparse(ii,jj,vv,mm,nn);
GN.J = J(~GN.bus.slack_bus,~GN.bus.slack_bus);

end

