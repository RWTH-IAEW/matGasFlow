function [GN] = get_J_analytical_model(GN, NUMPARAM)
%GET_J_ANALYTICAL_MODEL Summary of this function goes here
%   Detailed explanation goes here
%
%|-----------------------------------|
%| df_1/dp_1   .   .   .   df_1/dp_N |
%|     .       .               .     |
%|     .           .           .     |
%|     .               .       .     |
%| df_N/dp_1   .   .   .   df_N/dp_N |
%|-----------------------------------|
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2021, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

p_i = GN.bus.p_i;

%%
if isfield(GN, 'pipe')
    iF_pipe = GN.branch.i_from_bus(GN.branch.pipe_branch);
    iT_pipe = GN.branch.i_to_bus(GN.branch.pipe_branch);
    
    idx = p_i(iF_pipe) < p_i(iT_pipe);
    iIn = iF_pipe;
    iIn(idx) = iT_pipe(idx);
    iOut = iT_pipe;
    iOut(idx) = iF_pipe(idx);
    
    p_i = GN.bus.p_i(iIn);
    p_j = GN.bus.p_i(iOut);
    
    %% turbolent
    [A_ij, B_ij, C_ij] = get_ABC_ij(GN);
    V_dot_n_ij_pipe = GN.branch.V_dot_n_ij(GN.branch.pipe_branch);
    
    d_V_ij_d_p_iIn = ...
        sign(V_dot_n_ij_pipe) .* (...
        A_ij .* p_i ./ sqrt(p_i.^2 - p_j.^2) .* log10( B_ij ./ sqrt(p_i.^2 - p_j.^2) + C_ij) ...
        - A_ij .* B_ij .* p_i ./ log(10) ./ (p_i.^2 - p_j.^2) ./ (B_ij ./ sqrt(p_i.^2 - p_j.^2) + C_ij) ...
        );
    d_V_ij_d_p_iIn(isnan(d_V_ij_d_p_iIn)) = 0;
    d_V_ij_d_p_iIn(GN.bus.p_bus(iIn)) = 0;
    
    dV_ij_dp_jOut = ...
        sign(V_dot_n_ij_pipe) .* (...
        - A_ij .* p_j ./ sqrt(p_i.^2 - p_j.^2) .* log10( B_ij ./ sqrt(p_i.^2 - p_j.^2) + C_ij) ...
        + A_ij .* B_ij .* p_j ./ log(10) ./ (p_i.^2 - p_j.^2) ./ (B_ij ./ sqrt(p_i.^2 - p_j.^2) + C_ij) ...
        );
    dV_ij_dp_jOut(isnan(dV_ij_dp_jOut)) = 0;
    dV_ij_dp_jOut(GN.bus.p_bus(iOut)) = 0;
    
    %% laminar
    
    
    %%
    dV_ij_dp_i = d_V_ij_d_p_iIn;
    dV_ij_dp_i(sign(V_dot_n_ij_pipe) == -1) = dV_ij_dp_jOut(sign(V_dot_n_ij_pipe) == -1);
    dV_ij_dp_j = dV_ij_dp_jOut;
    dV_ij_dp_j(sign(V_dot_n_ij_pipe) == -1) = d_V_ij_d_p_iIn(sign(V_dot_n_ij_pipe) == -1);
    
end

%% V_dot_n_i demand at compressor inputs
if NUMPARAM.OPTION_get_f_nodal_equation == 1 || NUMPARAM.OPTION_get_f_nodal_equation == 3
    if isfield(GN,'comp')
        iF_comp = GN.branch.i_from_bus(GN.branch.comp_branch);
        iT_comp = GN.branch.i_to_bus(GN.branch.comp_branch);
        
        p_i = GN.bus.p_i(iF_comp);
        p_j = GN.bus.p_i(iT_comp);
        
        % Physical constants
        CONST = getConstants();
        
        kappa_i = GN.bus.kappa_i(iF_comp);
        kappa_j = GN.bus.kappa_i(iT_comp);
        kappa_ij = (kappa_i + kappa_j)/2;
        
        D_ij = GN.branch.V_dot_n_ij(GN.branch.comp_branch) .* GN.gasMixProp.rho_n_avg ./ GN.comp.eta_drive ./ GN.comp.eta_s ./ GN.gasMixProp.H_s_n_avg ...
            .* GN.bus.Z_i(iF_comp) .* CONST.R_m .* GN.bus.T_i(iF_comp);
        
        dV_i_comp_dp_i = D_ij .* (p_j ./ p_i).^(-1./kappa_ij) .* (- p_j ./ p_i.^2);
        dV_i_comp_dp_j = D_ij .* (p_j ./ p_i).^(-1./kappa_ij) ./ p_i;
    else
        iF_comp = [];
        iT_comp = [];
        dV_i_comp_dp_i = [];
        dV_i_comp_dp_j = [];
    end
end

%%
if NUMPARAM.OPTION_get_f_nodal_equation == 1 || NUMPARAM.OPTION_get_f_nodal_equation == 2
    if any(strcmp('station_ID',GN.branch.Properties.VariableNames))
        station_IDs = unique(GN.branch.station_ID(~isnan(GN.branch.station_ID)));
        iF_Station  = [];
        k_bus       = [];
        dV_jk_dp_k  = [];
        dV_ij_dp_j_branch = zeros(size(GN.branch,1),1);
        dV_ij_dp_j_branch(GN.branch.pipe_branch) = dV_ij_dp_j;
        
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

%%
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
J(GN.bus.f_0_bus,:) = [];
J(:,GN.bus.p_bus) = [];

%%
GN.J = J;

end

