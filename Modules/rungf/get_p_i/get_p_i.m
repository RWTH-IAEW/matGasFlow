function [GN, success] = get_p_i(GN, NUMPARAM, PHYMOD)
%GET_P_I Summary of this function goes here
%   Detailed explanation goes here
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2022, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Success
success = true;

%%
if NUMPARAM.OPTION_rungf_meshedGN == 1
    [GN, success] = get_p_i_SLE_loop(GN, NUMPARAM, PHYMOD);
    if ~success
        return
    end
end

if NUMPARAM.OPTION_rungf_meshedGN == 2
    [GN, success] = get_p_i_SLE(GN, PHYMOD);
    if ~success
        return
    end
end

if NUMPARAM.OPTION_rungf_meshedGN == 3
    [GN, success] = get_p_i_Adm_loop(GN, NUMPARAM, PHYMOD);
    if ~success
        return
    end
end

if NUMPARAM.OPTION_rungf_meshedGN == 4
    [GN, success] = get_p_i_Adm(GN, PHYMOD);
    if ~success
        return
    end
end

% NUMPARAM = NUMPARAM_input;
% try
%     load('p_error','p_error')
%     GN.bus.p_i(~GN.bus.slack_bus) = GN.bus.p_i(~GN.bus.slack_bus) .* p_error;
% catch
%     p_error = (0.1 + 1.8 * rand(sum(~GN.bus.slack_bus),1));
%     save('p_error','p_error')
%     GN.bus.p_i(~GN.bus.slack_bus) = GN.bus.p_i(~GN.bus.slack_bus) .* p_error;
% end

end

