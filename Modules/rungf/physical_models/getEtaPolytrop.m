function [eta_polytrop] = getEtaPolytrop(GN)

load('model_data', 'model_data')

% Index
i_comp = GN.branch.i_comp(GN.branch.comp_branch);
i_from_bus = GN.branch.i_from_bus(GN.branch.comp_branch);
i_from_bus = i_from_bus(i_comp);
i_to_bus = GN.branch.i_to_bus(GN.branch.comp_branch);
i_to_bus = i_to_bus(i_comp);

%% Get v_molar

% Physical constants
CONST = getConstants();

% Quantities

R_m = CONST.R_m;
rho = GN.gasMixProp.rho_n_avg; 
M_avg = GN.gasMixProp.M_avg; 
V_dot_n_ij        = GN.branch.V_dot_n_ij(i_comp);
a                 = GN.gasMixProp.a;
b                 = GN.gasMixProp.b;
T                 = GN.bus.T_i(i_from_bus); 
p                 = GN.bus.p_i(i_from_bus); 

% Solve Cubic Equation V_m^3 + B * V_m^2 + C * V_m + D = 0

B = -(b + R_m .* T ./ p);           % [m^3/mol]
C = a ./ p;                         % [m^6/mol^2]
D = -a .* b ./ p;                   % [m^9/mol^3]

v_molar = solveCubicEquation(B,C,D);    % [m^3/mol]
    
%% Get V_dot

n_dot_molar = V_dot_n_ij(i_comp)./rho./M_avg; 
V_dot = n_dot_molar.*v_molar; 

%% Get eta_polytrop

data_eta = (model_data.eta_polytrop.eta_polytrop);
data_V_dot = (model_data.eta_polytrop.V_dot);
if V_dot< 4.7195
    eta_polytrop = 0.67; 
else
eta_polytrop = interp1(data_V_dot,data_eta,V_dot); 
end 
end