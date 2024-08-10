function [GN] = get_eta_Wilke(GN)
%GET_ETA_WILKE
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

x_mol               = GN.gasMixAndCompoProp.x_mol;
eta_n               = GN.gasMixAndCompoProp.eta_n;
M                   = GN.gasMixAndCompoProp.M;
phi                 = ( 1 + sqrt(eta_n*(1./eta_n)') .* ((1./M)*M').^(1/4)).^2 ./ sqrt(8 * (1+ M*(1./M)' ) );
eta_mix_n           = sum( x_mol.*eta_n  ./ sum( phi .* x_mol',2) );
GN.pipe.eta_ij(:)   = eta_mix_n;

end

