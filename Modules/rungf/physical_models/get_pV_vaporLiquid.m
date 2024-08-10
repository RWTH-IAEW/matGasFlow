function [p_iso, V_m_liquid, V_m_vapor] = get_pV_vaporLiquid(T_input, p_input, T_c, p_c, gasMixAndCompoProp)
%UNTITLED
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

idx         = T_input<T_c & p_input<p_c;
T_temp      = T_input(idx);
[T,~,idx_2] = unique(T_temp);

p_iso       = NaN(size(T_input));
V_m_liquid  = NaN(size(T_input));
V_m_vapor   = NaN(size(T_input));

if isempty(T)
    return
end

%% Physical constants
CONST = getConstants;

%% Quantities
R_m         = CONST.R_m;
p_c_i       = gasMixAndCompoProp.p_c;
T_c_i       = gasMixAndCompoProp.T_c;
x_mol_i     = gasMixAndCompoProp.x_mol;

%% Internal pressure a and covolume b of the gas components
a_i         = 27/64 * R_m^2 .* T_c_i.^2 ./ p_c_i;
b_i         = 1/8   * R_m   .* T_c_i    ./ p_c_i;
a           = sum(x_mol_i * x_mol_i' .* sqrt(a_i * a_i'),'all');
b           = sum(x_mol_i.*b_i);

%% Solve Cubic Equation:
%    dp/dV_m = -(R_m T)/(V_m - b)^2 + 2a/V_m^3 = 0
% => V_m^3 + B * V_m^2 + C * V_m + D = 0
B   = -2*a     ./ (R_m.*T);         % [m^3/mol]
C   =  4*a*b   ./ (R_m.*T);         % [m^6/mol^2]
D   = -2*a*b^2 ./ (R_m.*T);         % [m^9/mol^3]
V_m_ext1    = solve_cubic_equation(B,C,D);  % [m^3/mol]
p_max       = (R_m*T)./(V_m_ext1-b) - a./V_m_ext1.^2;

%%
p_0 = p_max;
p_1 = zeros(size(p_max));
p_2 = (p_0+p_1)/2;

[~, V_m_1, ~, V_m_3] = calculate_Z_VanDerWaals(p_2, T, gasMixAndCompoProp);

Int_p = (R_m * T .* log((V_m_1-b)./(V_m_3-b)) + a./V_m_1 - a./V_m_3) - p_2 .* (V_m_1-V_m_3);

while norm(Int_p) > 1e-9 || any(isnan([V_m_3;V_m_1]))
    p_0(Int_p<0)                    = p_2(Int_p<0);   % p_2 is too large
    p_1(Int_p>=0 | isnan(V_m_3))    = p_2(Int_p>=0 | isnan(V_m_3));  % p_2 is too small
    p_2 = (p_0+p_1)/2;
    [~,V_m_1, ~, V_m_3] = calculate_Z_VanDerWaals(p_2, T, gasMixAndCompoProp);
    Int_p = (R_m * T .* log((V_m_1-b)./(V_m_3-b)) + a./V_m_1 - a./V_m_3) - p_2 .* (V_m_1-V_m_3);
end

%%
p_iso(idx)      = p_2(idx_2);
V_m_liquid(idx) = V_m_3(idx_2);
V_m_vapor(idx)  = V_m_1(idx_2);

end

