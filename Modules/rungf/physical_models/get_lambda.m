function GN = get_lambda(GN, NUMPARAM)
%GET_LAMBDA   Calculation of the Darcy friction coefficient
%
%       Re < Re_crit, laminar flow: [Hagen-Poiseuille]
%       Re > Re_crit, turbulent flow: [Colebrook-White]
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Set default input arguments
if nargin < 2
    NUMPARAM = getDefaultNumericalParameters;
end

%% Constants
CONST = getConstants;

%% Quantities
Re_ij_la   = GN.pipe.Re_ij(GN.pipe.Re_ij<=CONST.Re_crit);
Re_ij_tu   = GN.pipe.Re_ij(GN.pipe.Re_ij>CONST.Re_crit);
k_ij_tu    = GN.pipe.k_ij(GN.pipe.Re_ij>CONST.Re_crit);
D_ij_tu    = GN.pipe.D_ij(GN.pipe.Re_ij>CONST.Re_crit);

%% Re <= Re_crit  -->  laminar, [Hagen-Poiseuille]
GN.pipe.lambda_ij(GN.pipe.Re_ij <= CONST.Re_crit) = 64./Re_ij_la;

%% Re > Re_crit  --> turbulent, [Colebrook-White], Newton-Raphson method
if any(GN.pipe.lambda_ij(GN.pipe.Re_ij>CONST.Re_crit) > 0)
    lambda_ij_tu = GN.pipe.lambda_ij(GN.pipe.Re_ij>CONST.Re_crit);
else
    lambda_ij_tu = (-2 .* log10(4.518 ./ Re_ij_tu .* log10(Re_ij_tu/7) + k_ij_tu./3.71./D_ij_tu)).^-2;
end

Lambda_ij_tu        = 1./sqrt(lambda_ij_tu);
f                   = 2.*log10( 2.51./Re_ij_tu.*Lambda_ij_tu + k_ij_tu./3.71./D_ij_tu) + Lambda_ij_tu;
iter                = 0;
while norm(f) > NUMPARAM.epsilon_lambda
    iter            = iter + 1;
    df_dLamdba      = 2*2.51/log(10)./ Re_ij_tu ./ (2.51./Re_ij_tu.*Lambda_ij_tu + k_ij_tu./3.71./D_ij_tu) + 1;
    Lambda_ij_tu    = Lambda_ij_tu - f./df_dLamdba;
    f               = 2.*log10( 2.51./Re_ij_tu.*Lambda_ij_tu + k_ij_tu./3.71./D_ij_tu) + Lambda_ij_tu;
end
lambda_ij_tu = 1./Lambda_ij_tu.^2;

%% Alterntive method 1
% lambda_ij_tu_1      = (-2 .* log10(4.518 ./ Re_ij_tu .* log10(Re_ij_tu/7) + k_ij_tu./3.71./D_ij_tu)).^-2; % [Hofer]
% % lambda_ij_tu_1      = 0.0032+0.221*Re_ij_tu.^-0.237; 
% lambda_ij_tu_2      = 1./(-2.*log10( 2.51./Re_ij_tu./sqrt(lambda_ij_tu_1) + k_ij_tu./3.71./D_ij_tu)).^2;
% iter_1              = 0;
% while norm((lambda_ij_tu_1-lambda_ij_tu_2) ./ lambda_ij_tu_1) > NUMPARAM.epsilon_lambda
%     iter_1          = iter_1 + 1;
%     lambda_ij_tu_1  = lambda_ij_tu_2;
%     lambda_ij_tu_2  = 1./(-2.*log10( 2.51./Re_ij_tu./sqrt(lambda_ij_tu_1) + k_ij_tu./3.71./D_ij_tu)).^2;
% end
% lambda_ij_tu = lambda_ij_tu_2;

%% Alterntive method 2
% lambda_ij_tu        = 0.0032+0.221*Re_ij_tu.^-0.237;
% f                   = 2.*log10( 2.51./Re_ij_tu./sqrt(lambda_ij_tu) + k_ij_tu./3.71./D_ij_tu) + 1./sqrt(lambda_ij_tu);
% iter_2              = 0;
% while norm(f) > NUMPARAM.epsilon_lambda
%     iter_2          = iter_2 + 1;
%     df_dlamdba      = -(2.51 ./ ( Re_ij_tu .* (2.51./Re_ij_tu./sqrt(lambda_ij_tu) + k_ij_tu./3.71./D_ij_tu) * log(10) ) + 1/2) .* lambda_ij_tu.^(-2/3);
%     lambda_ij_tu    = lambda_ij_tu - f./df_dlamdba;
%     f               = 2.*log10( 2.51./Re_ij_tu./sqrt(lambda_ij_tu) + k_ij_tu./3.71./D_ij_tu) + 1./sqrt(lambda_ij_tu);
% end

%% Result
GN.pipe.lambda_ij(GN.pipe.Re_ij > CONST.Re_crit) = lambda_ij_tu;

end