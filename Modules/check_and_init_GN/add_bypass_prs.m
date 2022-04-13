function [GN] = add_bypass_prs(GN, branch_object_to_be_bypassed, object_ID_to_be_bypassed, bypass_type, apply_check_and_init_GN)
%ADD_BYPASS_PRS Summary of this function goes here
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

if ~isfield(GN, 'prs')
    warning('GN has no prs.')    
    return
end

if ~strcmp('prs',branch_object_to_be_bypassed)
    error('So far only prs can be bypassed.')
end

if ~all(ismember(object_ID_to_be_bypassed,GN.prs.prs_ID))
    error('Some branch_object_ID_to_be_bypassed do not exist.')
end
    
% add prs
i_object_to_be_bypassed = ismember(GN.prs.prs_ID, object_ID_to_be_bypassed);
prs_ID          = GN.prs.prs_ID(i_object_to_be_bypassed) + max(GN.prs.prs_ID);
from_bus_ID     = GN.prs.to_bus_ID(i_object_to_be_bypassed);    % switch direction
to_bus_ID       = GN.prs.from_bus_ID(i_object_to_be_bypassed);  % switch direction
in_service      = false(size(prs_ID));
bypass_prs_ID   = GN.prs.prs_ID(i_object_to_be_bypassed);

prs_temp  = table(prs_ID, from_bus_ID, to_bus_ID, in_service);

missing_column  = GN.prs.Properties.VariableNames(~ismember(GN.prs.Properties.VariableNames, prs_temp.Properties.VariableNames));
table_temp      = array2table(NaN(size(prs_temp,1),length(missing_column)),"VariableNames",missing_column);
prs_temp      = [prs_temp, table_temp];
[~,i_column]    = ismember(GN.prs.Properties.VariableNames, prs_temp.Properties.VariableNames);
GN.prs        = [GN.prs;prs_temp(:,i_column)];
if ~ismember('bypass_prs_ID', GN.prs.Properties.VariableNames)
    GN.prs.bypass_prs_ID(:) = NaN;
end
GN.prs.bypass_prs_ID(end-size(prs_temp,1)+1:end) = bypass_prs_ID;
[has_bypass_prs,i_prs] = ismember(GN.prs.prs_ID,GN.prs.bypass_prs_ID);
GN.prs.bypass_prs_ID(i_object_to_be_bypassed) = GN.prs.prs_ID(i_prs(has_bypass_prs));

if apply_check_and_init_GN
    % Check prs
    GN = check_GN_prs(GN);

    % Inititalize GN.branch
    GN = init_GN_branch(GN);
    
    % Inititialize indecies
    GN = init_GN_indices(GN);
    
    % Check area restrictions
    keep_bus_properties = true;
    GN = check_GN_area_restrictions(GN,keep_bus_properties);
end

end


