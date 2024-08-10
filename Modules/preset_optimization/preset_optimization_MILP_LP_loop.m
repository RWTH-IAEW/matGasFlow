function [GN_output, SUCCESS, convergence] = preset_optimization_MILP_LP_loop(GN)
%PRESET_OPTIMIZATION_MILP_LP_LOOP
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

GN_input_0  = GN;

%%
NUMPARAM = getDefaultNumericalParameters;
NUMPARAM.epsilon_norm_f = 1e-6;
NUMPARAM.omega_adaption_DR = 0.5;
[GN_input_1,SUCCESS]  = rungf_time_step(GN_input_0, NUMPARAM);
if SUCCESS < 0
    GN_output = GN_input_1;
    return
end

%%
[GN_input2,SUCCESS] = preset_optimization_MILP_LP(GN_input_1);
if SUCCESS < 0
    GN_output = GN_input_1;
    return
end

%%
GN                              = GN_input2;
opt_model                       = 'MILP';
include_out_of_service_branches = true;
keep_in_service_states          = true;
reduce_V_dot_n_ij_bounds        = false;

convergence.SUCCESS_opt         = [];
convergence.result_opt          = [];
convergence.bin_sitches         = [];
convergence.max_Delta_p_i       = [];
convergence.norm_Delta_p_prs    = [];
convergence.SUCCESS_rungf       = [];
convergence.GN_res              = [];
GN_temp                         = [];

rungf_success                   = false;
iter                            = 0;
error_flag                      = 0;

while 1
    iter = iter + 1;
    
    if strcmp(opt_model,'LP')
        GN.prs.in_service(~isnan(GN.prs.associate_prs_ID)) = true;
        GN.branch.in_service(~isnan(GN.branch.associate_prs_ID)) = true;
    end
    
    % optimization
    [GN, SUCCESS, ~, result]        = preset_optimization_MILP_LP(GN, opt_model, include_out_of_service_branches, keep_in_service_states, reduce_V_dot_n_ij_bounds);
    convergence.SUCCESS_opt         = [convergence.SUCCESS_opt, SUCCESS];
    convergence.result_opt{iter}    = {result};
    
    if SUCCESS
        % rungf
        try
            GN_temp                 = check_and_init_GN(GN);
        catch
            break
        end
        [GN_res,rungf_success]      = rungf(GN_temp);
        convergence.SUCCESS_rungf   = [convergence.SUCCESS_rungf, rungf_success];
        if rungf_success
            if keep_in_service_states && strcmp(opt_model,'MILP')
                convergence.bin_sitches     = [convergence.bin_sitches, result.bin_sitches];
            end
            idx = find(result.Delta_p_i == max(result.Delta_p_i));
            convergence.max_Delta_p_i       = [convergence.max_Delta_p_i, result.Delta_p_i(idx(1))];
            
            % GN_temp = GN;
            % GN      = GN_res;
            
            disp(['SUCCESS: ',num2str(iter)])
            if isfield(GN_res,'time_series')
                GN_res = rmfield(GN_res,'time_series');
            end
            convergence.GN_res{iter}        = {GN_res};
            idx                             = GN_res.prs.Delta_p_ij__bar < 0 & GN_res.prs.in_service;
            convergence.norm_Delta_p_prs    = [convergence.norm_Delta_p_prs, norm(GN_res.prs.Delta_p_ij__bar(idx))];
            reduce_V_dot_n_ij_bounds        = true;
            if convergence.norm_Delta_p_prs(end) < 1 || sum(~isnan(convergence.norm_Delta_p_prs)) >= 10
                break
            end
            
        else
            convergence.norm_Delta_p_prs = [convergence.norm_Delta_p_prs, NaN];
        end
        
    else
        disp('------------------- NO SUCCESS! -------------------')
        % reduce_V_dot_n_ij_bounds = false;
        break
        %         if ~isempty(GN_temp)
        %             error_flag = error_flag + 1;
        %             if error_flag == 2
        %                 break
        %             end
        %             GN = GN_temp;
        %         else
        %             break
        %         end
    end
    
    if iter >= 30
        break
    end
    
end
if ~isempty(convergence.norm_Delta_p_prs) && any(~isnan(convergence.norm_Delta_p_prs))
    idx = find(convergence.norm_Delta_p_prs == min(convergence.norm_Delta_p_prs));
    GN_output = convergence.GN_res{idx(1)};
    GN_output = GN_output{1,1};
else
    GN_output = GN_input2;
    SUCCESS = -3;
end

end

