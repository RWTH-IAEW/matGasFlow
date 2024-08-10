function GN_res = merge_GN_into_GN_input(GN, GN_input)
%UNTITLED
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

if all(GN_input.branch.in_service) && all(GN.bus.supplied) && ~isfield(GN_input, 'valve') %TODO Not working for valves
    GN_res = GN;
    return
end

%% Merge GN.bus and GN_input.bus
new_colums                      = GN.bus.Properties.VariableNames(~ismember(GN.bus.Properties.VariableNames, GN_input.bus.Properties.VariableNames));
table_missing_columns           = array2table(NaN(size(GN_input.bus,1),length(new_colums)),"VariableNames",new_colums);
GN_input.bus                    = [GN_input.bus, table_missing_columns];
[~,i_row]                       = ismember(GN.bus.bus_ID, GN_input.bus.bus_ID);
[~,i_column]                    = ismember(GN.bus.Properties.VariableNames, GN_input.bus.Properties.VariableNames);
bus_temp                        = GN_input.bus;
GN_input.bus(i_row,i_column)    = GN.bus;

% Keep some properties from GN_input.bus % TODO
if any(GN_input.bus.slack_bus   ~= bus_temp.slack_bus)
    GN_input.bus.slack_bus      = bus_temp.slack_bus;
end

%% Merge GN.branch into GN_input.branch
if isfield(GN, 'branch')
    % Keep everything from GN_input.branch except new columns (e.g. V_dot_n_ij)
    new_colums      = GN.branch.Properties.VariableNames(~ismember(GN.branch.Properties.VariableNames, GN_input.branch.Properties.VariableNames));
    table_temp      = array2table(NaN(size(GN_input.branch,1),length(new_colums)),"VariableNames",new_colums);
    GN_input.branch = [GN_input.branch, table_temp];
    [~,i_row]       = ismember(GN.branch.branch_ID, GN_input.branch.branch_ID);
    GN_input.branch(i_row,new_colums)   = GN.branch(:,new_colums);
end

%% Merge GN.pipe into GN_input.pipe
if isfield(GN, 'pipe')
    if size(GN.pipe,1) == size(GN_input.pipe,1)
        GN_input.pipe = GN.pipe;
    else
        new_colums                      = GN.pipe.Properties.VariableNames(~ismember(GN.pipe.Properties.VariableNames, GN_input.pipe.Properties.VariableNames));
        table_missing_columns           = array2table(NaN(size(GN_input.pipe,1),length(new_colums)),"VariableNames",new_colums);
        GN_input.pipe                   = [GN_input.pipe, table_missing_columns];
        [~,i_row]                       = ismember(GN.pipe.pipe_ID, GN_input.pipe.pipe_ID);
        [~,i_column]                    = ismember(GN.pipe.Properties.VariableNames, GN_input.pipe.Properties.VariableNames);
        pipe_temp                       = GN_input.pipe;
        GN_input.pipe(i_row,i_column)   = GN.pipe;
        
        % Keep some properties and indices from GN_input.pipe
        if any(...
                GN_input.pipe.i_branch      ~= pipe_temp.i_branch | ...
                GN_input.pipe.branch_ID     ~= pipe_temp.branch_ID) %
            GN_input.pipe.i_branch      = pipe_temp.i_branch;
            GN_input.pipe.branch_ID     = pipe_temp.branch_ID;
        end
    end
end

%% Merge GN.comp into GN_input.comp
if isfield(GN, 'comp')
    if size(GN.comp,1) == size(GN_input.comp,1)
        GN_input.comp = GN.comp;
    else
        new_colums                      = GN.comp.Properties.VariableNames(~ismember(GN.comp.Properties.VariableNames, GN_input.comp.Properties.VariableNames));
        table_missing_columns           = array2table(NaN(size(GN_input.comp,1),length(new_colums)),"VariableNames",new_colums);
        GN_input.comp                   = [GN_input.comp, table_missing_columns];
        [~,i_row]                       = ismember(GN.comp.comp_ID, GN_input.comp.comp_ID);
        [~,i_column]                    = ismember(GN.comp.Properties.VariableNames, GN_input.comp.Properties.VariableNames);
        comp_temp                       = GN_input.comp;
        GN_input.comp(i_row,i_column)   = GN.comp;
        
        % Keep some properties and indices from GN_input.comp
        if any(...
                GN_input.comp.i_branch      ~= comp_temp.i_branch | ...
                GN_input.comp.branch_ID     ~= comp_temp.branch_ID) %
            GN_input.comp.i_branch      = comp_temp.i_branch;
            GN_input.comp.branch_ID     = comp_temp.branch_ID;
        end
    end
end

%% Merge GN.prs into GN_input.prs
if isfield(GN, 'prs')
    if size(GN.prs,1) == size(GN_input.prs,1)
        GN_input.prs = GN.prs;
    else
        new_colums                      = GN.prs.Properties.VariableNames(~ismember(GN.prs.Properties.VariableNames, GN_input.prs.Properties.VariableNames));
        table_missing_columns           = array2table(NaN(size(GN_input.prs,1),length(new_colums)),"VariableNames",new_colums);
        GN_input.prs                   = [GN_input.prs, table_missing_columns];
        [~,i_row]                       = ismember(GN.prs.prs_ID, GN_input.prs.prs_ID);
        [~,i_column]                    = ismember(GN.prs.Properties.VariableNames, GN_input.prs.Properties.VariableNames);
        prs_temp                       = GN_input.prs;
        GN_input.prs(i_row,i_column)   = GN.prs;
        
        % Keep some properties and indices from GN_input.prs
        if any(...
                GN_input.prs.i_branch      ~= prs_temp.i_branch | ...
                GN_input.prs.branch_ID     ~= prs_temp.branch_ID) %
            GN_input.prs.i_branch      = prs_temp.i_branch;
            GN_input.prs.branch_ID     = prs_temp.branch_ID;
        end
    end
end

%% Temporary Data
if isfield(GN,'CONVERGENCE')
    GN_input.CONVERGENCE = GN.CONVERGENCE;
end

%% Calculate V_dot_n_i [m^3/s]
if ismember('V_dot_n_i',GN_input.bus.Properties.VariableNames)
    GN_temp = get_V_dot_n_i(GN_input);
    GN_input.bus.V_dot_n_i(isnan(GN_input.bus.V_dot_n_i)) = GN_temp.bus.V_dot_n_i(isnan(GN_input.bus.V_dot_n_i));
end

%% success
GN_input.success = GN.success;

%% Return GN_input as result
GN_res = GN_input;

end

