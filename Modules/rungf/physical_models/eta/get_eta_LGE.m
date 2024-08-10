function [GN] = get_eta_LGE(GN,PHYMOD)
%GET_ETA_LGE
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

%% LGE-Verfahren [Mischner 2015] S. 129
% 10 --> Original coefficients
% 11 --> optimized coefficients
% 12 --> [Burlutskiy 2012]

% rho
GN = get_rho(GN);

% Quantities
M_avg__g_per_mol    = GN.gasMixProp.M_avg.*1000; %(g/mol)
rho_ij              = GN.pipe.rho_ij;
T_ij                = GN.pipe.T_ij;

if PHYMOD.eta == 10
    iLGE = 1;
elseif PHYMOD.eta == 11
    iLGE = 2;
elseif PHYMOD.eta == 12
    iLGE = 2;
end

k_1 = [  9.4 ,   9.38 ,   16.7175    ];
k_2 = [  0.02,   0.016,    0.0419188 ];
k_3 = [  1.5 ,   1.5  ,    1.40256   ];
k_4 = [209   , 209.2  ,  212.209     ];
k_5 = [ 19   ,  19.26 ,   18.1349    ];
x_1 = [  3.5 ,   3.448,    2.12574   ];
x_2 = [986   , 986.4  , 2063.71      ];
x_3 = [  0.01,   0.01 ,    0.0011926 ];
y_1 = [  2.4 ,   2.448,    1.09809   ];
y_2 = [  0.2 ,   0.224,   -0.0392851 ];

K_const = (k_1(iLGE) + k_2(iLGE)*M_avg__g_per_mol) * (9/5*T_ij).^k_3(iLGE) ./ (k_4(iLGE) + k_5(iLGE)*M_avg__g_per_mol + 9/5*T_ij);
x_const = x_1(iLGE) + x_2(iLGE) ./ (9/5*T_ij) + x_3(iLGE)*M_avg__g_per_mol;
y_const = y_1(iLGE) - y_2(iLGE)*x_const;
GN.pipe.eta_ij = 1e-7 .* K_const .* exp(x_const .* (rho_ij.*1e-3).^y_const); % [Pa*s]

end

