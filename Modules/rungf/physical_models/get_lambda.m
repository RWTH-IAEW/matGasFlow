function GN = get_lambda(GN, NUMPARAM)
%GET_LAMBDA   Calculation of the Darcy friction coefficient
%   GET_LAMBDA( Re_ij, k_ij, D_ij, epsilon_lambda )
%   Re_ij, k_ij and D_ij must have same dimensions
%       INPUT                    UNIT
%       Reynolds Number (Re_ij)  [-]
%       Pipe roughness (k_ij)    [m], meter
%       Pipe diameter (D_ij)     [m], meter
%       epsilon_lambda           [-]
%
%       Re < 2320, laminar flow: [Hagen-Poiseuille]
%       Re > 2320, turbulent flow: [Colebrook-White]
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2022, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Set default input arguments
if nargin < 2
    NUMPARAM = getDefaultNumericalParameters;
end

%% Quantities
Re_ij   = GN.pipe.Re_ij;
k_ij    = GN.pipe.k_ij;
D_ij    = GN.pipe.D_ij;

%% Init
lambda_ij = NaN(size(Re_ij));

%% Re <= 2320  -->  laminar, [Hagen-Poiseuille]
lambda_ij(Re_ij<=2320) = 64./Re_ij(Re_ij<2320);

%% Re > 2320  --> turbulent, [Colebrook-White]
lambda_temp_1 = 0.0032+0.221*Re_ij(Re_ij>2320).^-0.237;
lambda_temp_2 = 1./(-2.*log10( 2.51./Re_ij(Re_ij>2320)./sqrt(lambda_temp_1) + k_ij(Re_ij>2320)./3.71./D_ij(Re_ij>2320))).^2;
while norm((lambda_temp_1-lambda_temp_2) ./ lambda_temp_1) > NUMPARAM.epsilon_lambda
    lambda_temp_1 = lambda_temp_2;
    lambda_temp_2 = 1./(-2.*log10( 2.51./Re_ij(Re_ij>2320)./sqrt(lambda_temp_1) + k_ij(Re_ij>2320)./3.71./D_ij(Re_ij>2320))).^2;
end
lambda_ij(Re_ij>2320) = lambda_temp_2;

%% Result
GN.pipe.lambda_ij = lambda_ij;

end