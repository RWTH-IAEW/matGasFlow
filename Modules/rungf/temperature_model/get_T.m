function [GN] = get_T(GN, NUMPARAM, PHYMOD, keep_T_env)
%GET_T Calculation of temperature
%   [GN] = get_T(GN, NUMPARAM, PHYMOD, keep_T_env)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% TODO: Problem if all(GN.branch.V_dot_n_ij == 0)
% if all(GN.branch.V_dot_n_ij == 0)
%     if ~ismember('T_ij_out',GN.branch.Properties.VariableNames)
%         GN.branch.T_ij_out = GN.bus.T_i(GN.branch.i_to_bus);
%     end
%     return
% end

if nargin < 4
    keep_T_env = false;
end

%% initialize T_ij_out
if ~ismember('T_ij_out',GN.branch.Properties.VariableNames)
    i_bus_out   = GN.branch.i_to_bus;
    i_bus_out(GN.branch.V_dot_n_ij < 0) = GN.branch.i_from_bus(GN.branch.V_dot_n_ij < 0);
    GN.branch.T_ij_out = GN.bus.T_i(i_bus_out);
end

%% Update p_ij_mid (comp,prs)
if isfield(GN,'comp')
    i_bus_out           = GN.branch.i_to_bus(GN.comp.i_branch);
    GN.comp.p_ij_mid    = GN.bus.p_i(i_bus_out);
end

if isfield(GN,'prs')
    i_bus_in            = GN.branch.i_from_bus(GN.prs.i_branch);
    GN.prs.p_ij_mid     = GN.bus.p_i(i_bus_in);
end

%% Calculate fundamental thermodynamics
GN = get_Z(GN, PHYMOD, 'all', NUMPARAM);
GN = get_c_p(GN, PHYMOD);

%% pipe
if isfield(GN,'pipe')
    GN = get_T_pipe(GN, PHYMOD);
end

%% comp
if isfield(GN,'comp')
    GN = get_T_comp(GN, NUMPARAM, PHYMOD);
end

%% prs
if isfield(GN,'prs')
    GN = get_T_prs(GN, NUMPARAM, PHYMOD);
end

%% Quantities
% bus
c_p_i           = GN.bus.c_p_i;

% source
V_dot_n_i_source                        = GN.bus.V_dot_n_i;
V_dot_n_i_source(GN.bus.V_dot_n_i>0)    = 0;
i_source                                = find(V_dot_n_i_source<0);
T_i_source                              = zeros(size(GN.bus.bus_ID)) ;
T_i_source(i_source)                    = GN.bus.T_i_source(i_source);
c_p_i_source                            = zeros(size(GN.bus.bus_ID)) ;
c_p_i_source(i_source)                  = GN.bus.c_p_i_source(i_source);

% branch
V_dot_n_ij      = GN.branch.V_dot_n_ij;
c_p_ij_out      = GN.branch.c_p_ij_out;
T_ij_out        = GN.branch.T_ij_out;
Delta_T_ij      = -GN.branch.Delta_T_ij; 
T_controlled    = GN.branch.T_controlled;
T_const         = Delta_T_ij;
T_const(T_controlled)  = T_ij_out(T_controlled);

%% Indices
i_bus_in                    = GN.branch.i_from_bus;
i_bus_in(V_dot_n_ij < 0)    = GN.branch.i_to_bus(V_dot_n_ij < 0);
i_bus_out                   = GN.branch.i_to_bus;
i_bus_out(V_dot_n_ij < 0)   = GN.branch.i_from_bus(V_dot_n_ij < 0);
i_var                       = find(~T_controlled);

%% c_p_avg
c_p_avg_i_source    = (c_p_i + c_p_i_source)/2;
c_p_avg_ij_out      = (c_p_ij_out + c_p_i(i_bus_out))/2;

%% T_i
m = size(GN.branch,1);
n = size(GN.bus,1);

H_source        = abs(V_dot_n_i_source) .* c_p_avg_i_source .* T_i_source;
H_const         = abs(V_dot_n_ij)       .* c_p_avg_ij_out   .* T_const;

E_source        = sparse(1:n,       1:n,        abs(V_dot_n_i_source) .* c_p_avg_i_source                        );
E_var           = sparse(i_var,     i_var,      abs(V_dot_n_ij(~T_controlled)) .* c_p_ij_out(~T_controlled), m, m);
E_all           = sparse(1:m,       1:m,        abs(V_dot_n_ij) .* c_p_avg_ij_out                                );

INC_phy_in      = sparse(i_bus_in,  1:m, ones(size(GN.branch,1),1), n, m);
INC_phy_in_T    = INC_phy_in';
INC_phy_out     = sparse(i_bus_out, 1:m, ones(size(GN.branch,1),1), n, m);
INC_phy_out_T   = INC_phy_out';

A               = -E_source + INC_phy_out*E_var*INC_phy_in_T - INC_phy_out*E_all*INC_phy_out_T;
b               = -H_source - INC_phy_out*H_const;
GN.bus.T_i_temp_1  = A\b;

%% Set GN.T_env to be minimum gas temperature (might be required for some investiagtions)
if keep_T_env
    GN.bus.T_i_temp_1(GN.bus.T_i_temp_1<GN.T_env) = GN.T_env;
end

%% T_i MODEL 2 % TODO
psi_ij      = diag(GN.branch.psi_ij);
chi_ij      = GN.branch.chi_ij;
T_ij_out    = GN.branch.T_ij_out;
T_ij_out(~GN.branch.T_controlled) = 0;
A_2               = -E_source + INC_phy_out*E_all*(psi_ij*INC_phy_in_T-INC_phy_out_T);
b_2               = -H_source - INC_phy_out*E_all*(T_ij_out+chi_ij);
GN.bus.T_i_temp_2 = A_2\b_2;

%% T_i MODEL 3 % TODO
chi_ij_3        = GN.branch.chi_ij_3;
b_3             = -H_source - INC_phy_out*E_all*(T_ij_out+chi_ij_3);
GN.bus.T_i_temp_3 = A_2\b_3;

% idx = find(GN.bus.f~=0); %TODO
% A_4 = [A_2;sparse(1:length(idx),idx,1,length(idx),size(A_2,2))];
% b_4 = [b_3;GN.T_env*ones(length(idx),1)];
% GN.bus.T_i_temp_4 = A_4\b_4;
%% 
GN.bus.T_i = GN.bus.T_i_temp_2;

%% T_i = NaN in case of no feeding flow
GN.bus.T_i(isnan(GN.bus.T_i)) = GN.T_env;

%% Check output
if any(GN.bus.T_i<0)
    error(['Something went wrong. Negative nodal temperature, min(T_i) = ',num2str(min(GN.bus.T_i)),' K'])
end

%% Apply result
GN = get_T_ij(GN);

end
