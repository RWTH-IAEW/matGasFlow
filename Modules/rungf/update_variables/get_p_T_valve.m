function [GN] = get_p_T_valve(GN)
%GET_P_T_VALVE
%
%   Update p_i and T_i at valve output with p_i and T_i at valve input.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2021, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
if ~isfield(GN,'valve')
    return
end

i_from_bus = GN.branch.i_from_bus(GN.branch.valve_branch);
i_to_bus = GN.branch.i_to_bus(GN.branch.valve_branch);

iter = sum(GN.INC(:,~GN.branch.pipe_branch) * GN.INC(:,~GN.branch.pipe_branch)'==2,'all') - sum(GN.bus.slack_bus) + 2;
for ii = 1:iter
    GN.bus.p_i(i_to_bus) = GN.bus.p_i(i_from_bus);
    GN.bus.T_i(i_to_bus) = GN.bus.T_i(i_from_bus);
end

end

