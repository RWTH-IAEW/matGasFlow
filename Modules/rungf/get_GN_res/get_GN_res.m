<<<<<<< HEAD
function [GN] = get_GN_res(GN, GN_input, flag_remove_auxiliary_variables, NUMPARAM, PHYMOD)
=======
function [GN] = get_GN_res(GN, NUMPARAM, PHYMOD)
>>>>>>> Merge to public repo (#1)
%GET_GN_RESULT Result preparation
%   GN = get_GN_res(GN, NUMPARAM, PHYMOD)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
<<<<<<< HEAD
%   Copyright (c) 2020-2022, High Voltage Equipment and Grids,
=======
%   Copyright (c) 2020-2021, High Voltage Equipment and Grids,
>>>>>>> Merge to public repo (#1)
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (m.kurth@iaew.rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

<<<<<<< HEAD
%% Set default input arguments
if nargin < 3
    PHYMOD = getDefaultPhysicalModels();
    
    if nargin < 2
        NUMPARAM = getDefaultNumericalParameters();
    end
end

=======
>>>>>>> Merge to public repo (#1)
if ~any(strcmp('V_dot_n_ij',GN.branch.Properties.VariableNames))
    error('GN is no GN result struct. GN.branch.V_dot_n_ij is missing.')
end

<<<<<<< HEAD
%% BUS - megre GN and GN_input
% GN and GN_input must be merged because unsuuplied busses,
% out-of-service-branches and valves are not included in GN
%% merge GN.bus and GN_input.bus
new_colums                      = GN.bus.Properties.VariableNames(~ismember(GN.bus.Properties.VariableNames, GN_input.bus.Properties.VariableNames));
table_missing_columns           = array2table(NaN(size(GN_input.bus,1),length(new_colums)),"VariableNames",new_colums);
GN_input.bus                    = [GN_input.bus, table_missing_columns];
[~,i_row]                       = ismember(GN.bus.bus_ID, GN_input.bus.bus_ID);
[~,i_column]                    = ismember(GN.bus.Properties.VariableNames, GN_input.bus.Properties.VariableNames);
bus_temp                        = GN_input.bus;
GN_input.bus(i_row,i_column)    = GN.bus;

% Keep some properties from GN_input.bus
if any(...
        GN_input.bus.slack_bus      ~= bus_temp.slack_bus | ...
        GN_input.bus.p_bus      	~= bus_temp.p_bus | ...
        GN_input.bus.active_bus     ~= bus_temp.active_bus)
    GN_input.bus.slack_bus      = bus_temp.slack_bus;
    GN_input.bus.p_bus      	= bus_temp.p_bus;
    GN_input.bus.active_bus     = bus_temp.active_bus;
end

%% BRANCH - merge GN.branch and GN_input.branch
if isfield(GN, 'branch')
    % Keep everything from GN_input.branch except new columns (e.g. V_dot_n_ij)
    new_colums      = GN.branch.Properties.VariableNames(~ismember(GN.branch.Properties.VariableNames, GN_input.branch.Properties.VariableNames));
    table_temp      = array2table(NaN(size(GN_input.branch,1),length(new_colums)),"VariableNames",new_colums);
    GN_input.branch = [GN_input.branch, table_temp];
    [~,i_row]       = ismember(GN.branch.branch_ID, GN_input.branch.branch_ID);
    GN_input.branch(i_row,new_colums)   = GN.branch(:,new_colums);
end

%% Reset out-of-service-branches
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

GN = GN_input;

%% Get GN results
% 1) Apply results from branch to pipe, comp, prs and valve
% 2) Calculate additional results
% 3) Check results

=======
>>>>>>> Merge to public repo (#1)
%% Physical constants
CONST = getConstants();

%% comp
if isfield(GN,'comp')
<<<<<<< HEAD
    
    % 1) Apply results from branch
=======
    % GN = get_P_el_comp(GN, PHYMOD); % UNDER CONSTRCUTION
    
    % Get V_dot_n_ij from branch
>>>>>>> Merge to public repo (#1)
    i_comp = GN.branch.i_comp(GN.branch.comp_branch);
    GN.comp.V_dot_n_ij(i_comp) = ...
        GN.branch.V_dot_n_ij(GN.branch.comp_branch);
    
<<<<<<< HEAD
    % 2) Calculate additional results
    % 2.1) Compressor power
    % GN = get_P_el_comp(GN, PHYMOD); % UNDER CONSTRUCTION
    
    % 3) Check results
    % 3.1) Direction of V_dot_n_ij
=======
    % Check V_dot_n_ij
>>>>>>> Merge to public repo (#1)
    if any(GN.comp.V_dot_n_ij < -NUMPARAM.numericalTolerance)
        comp_ID = GN.comp.comp_ID(GN.comp.V_dot_n_ij < -NUMPARAM.numericalTolerance);
        warning(['The volume flows at these compressors have the wrong direction, comp_ID: ',num2str(comp_ID')])
    end
<<<<<<< HEAD
    if ~(any(GN.comp.gas_powered))
        GN.comp.V_dot_n_i_comp(:) = 0;
    end
    
    % 3.2) Compare input and output pressure
=======
    
    % Compare input and output pressure
>>>>>>> Merge to public repo (#1)
    i_from_bus = GN.branch.i_from_bus(GN.branch.comp_branch);
    i_to_bus = GN.branch.i_to_bus(GN.branch.comp_branch);
    p_i = GN.bus.p_i(i_from_bus);
    p_j = GN.bus.p_i(i_to_bus);
    delta_p = p_j - p_i;
    comp_ID = GN.branch.comp_ID(GN.branch.comp_branch);
    if any(delta_p < -NUMPARAM.numericalTolerance)
        comp_ID = comp_ID(delta_p < -NUMPARAM.numericalTolerance);
<<<<<<< HEAD
        warning(['Output pressure is smaler than input pressure at these compressors, comp_ID: ',num2str(comp_ID')])
    end
    
    % 2.2) Calculate P_th_ij__MW, P_th_ij, V_dot_n_ij__m3_per_day, V_dot_n_ij__m3_per_h or m_dot_ij__kg_per_s
    %     if any(strcmp('P_th_i__MW',GN_input.comp.Properties.VariableNames))
    %         GN.comp.P_th_ij__MW                 = GN.comp.V_dot_n_ij * 1e-6 * GN.gasMixProp.H_s_n_avg;
    %         GN.comp.V_dot_n_ij                  = [];
    %         if any(GN.comp.gas_powered)
    %             GN.comp.P_th_i_comp__MW(GN.comp.gas_powered) = GN.comp.V_dot_n_i_comp(GN.comp.gas_powered) * 1e-6 * GN.gasMixProp.H_s_n_avg;
    %         end
    %         GN.comp.V_dot_n_i_comp              = [];
    %
    %     elseif any(strcmp('P_th_i',GN_input.comp.Properties.VariableNames))
    %         GN.comp.P_th_ij                     = GN.comp.V_dot_n_ij * GN.gasMixProp.H_s_n_avg;
    %                 GN.comp.V_dot_n_ij                  = [];
    %         GN.comp.P_th_i_comp                 = GN.comp.V_dot_n_i_comp * GN.gasMixProp.H_s_n_avg;
    %                 GN.comp.V_dot_n_i_comp              = [];
    %
    %     elseif any(strcmp('V_dot_n_i__m3_per_day',GN_input.comp.Properties.VariableNames))
    %         GN.comp.V_dot_n_ij__m3_per_day      = GN.comp.V_dot_n_ij * 60 * 60 * 24;
    %         %         GN.comp.V_dot_n_ij                  = [];
    %         GN.comp.V_dot_n_i_comp__m3_per_day  = GN.comp.V_dot_n_i_comp * 60 * 60 * 24;
    %         %         GN.comp.V_dot_n_i_comp              = [];
    %
    %     elseif any(strcmp('V_dot_n_i__m3_per_h',GN_input.comp.Properties.VariableNames))
    %         GN.comp.V_dot_n_ij__m3_per_h        = GN.comp.V_dot_n_ij * 60 * 60;
    %         %         GN.comp.V_dot_n_ij                  = [];
    %         GN.comp.V_dot_n_i_comp__m3_per_h    = GN.comp.V_dot_n_i_comp * 60 * 60;
    %         %         GN.comp.V_dot_n_i_comp              = [];
    %
    %     elseif any(strcmp('m_dot_i__kg_per_s',GN_input.comp.Properties.VariableNames))
    %         GN.comp.m_dot_ij__kg_per_s          = GN.comp.V_dot_n_ij * GN.gasMixProp.rho_n_avg;
    %         %         GN.comp.V_dot_n_ij                  = [];
    %         GN.comp.m_dot_i_comp__kg_per_s      = GN.comp.V_dot_n_i_comp * GN.gasMixProp.rho_n_avg;
    %         %         GN.comp.V_dot_n_i_comp              = [];
    %     end
    
    if ~GN.isothermal || GN.isothermal == 0
        %delta_H
        if any(~isnan(GN.comp.T_ij_out))
            GN = get_delta_H(GN,CONST);
        end
        
        %Q_dot_cooler
        if any(~isnan(GN.comp.T_ij_out))
            GN = get_Q_dot_comp(GN,PHYMOD);
            GN = get_Q_dot_comp_v2(GN,PHYMOD);
            GN = get_Q_dot_comp_v3(GN,PHYMOD,NUMPARAM);
        end
        
        % Power needed by compressor station
        P_el_comp = zeros(length(GN.comp.comp_ID));
        P_el_cool = zeros(length(GN.comp.comp_ID));
        if any(~GN.comp.gas_powered)
            P_el_comp = abs(GN.comp.V_dot_n_i_comp(~GN.comp.gas_powered)).*GN.gasMixProp.H_s_n_avg./GN.comp.eta_drive(~GN.comp.gas_powered);
        end
        if (any(~isnan(GN.comp.Q_dot_cooler)))
            P_el_cool = abs(GN.comp.Q_dot_cooler) ./ GN.comp.eta_cool;
        end
        GN.comp.Power_el_tot = P_el_comp + P_el_cool;
        
    end
=======
        warning(['Output pressure is smaler than input pressure at these compressors, comp_ID: ',num2str(comp_ID)])
    end
    
    % Calculate P_th_ij__MW, P_th_ij, V_dot_n_ij__m3_per_day,
    %   V_dot_n_ij__m3_per_h or m_dot_ij__kg_per_s
    if any(strcmp('P_th_i__MW',GN.bus.Properties.VariableNames))
        GN.comp.P_th_ij__MW                 = GN.comp.V_dot_n_ij * 1e-6 * GN.gasMixProp.H_s_n_avg;
%         GN.comp.V_dot_n_ij                  = [];
        GN.comp.P_th_i_comp__MW             = GN.comp.V_dot_n_i_comp * 1e-6 * GN.gasMixProp.H_s_n_avg;
%         GN.comp.V_dot_n_i_comp              = [];
        
    elseif any(strcmp('P_th_i',GN.bus.Properties.VariableNames))
        GN.comp.P_th_ij                     = GN.comp.V_dot_n_ij * GN.gasMixProp.H_s_n_avg;
%         GN.comp.V_dot_n_ij                  = [];
        GN.comp.P_th_i_comp                 = GN.comp.V_dot_n_i_comp * GN.gasMixProp.H_s_n_avg;
%         GN.comp.V_dot_n_i_comp              = [];
        
    elseif any(strcmp('V_dot_n_i__m3_per_day',GN.bus.Properties.VariableNames))
        GN.comp.V_dot_n_ij__m3_per_day      = GN.comp.V_dot_n_ij * 60 * 60 * 24;
%         GN.comp.V_dot_n_ij                  = [];
        GN.comp.V_dot_n_i_comp__m3_per_day  = GN.comp.V_dot_n_i_comp * 60 * 60 * 24;
%         GN.comp.V_dot_n_i_comp              = [];
        
    elseif any(strcmp('V_dot_n_i__m3_per_h',GN.bus.Properties.VariableNames))
        GN.comp.V_dot_n_ij__m3_per_h        = GN.comp.V_dot_n_ij * 60 * 60;
%         GN.comp.V_dot_n_ij                  = [];
        GN.comp.V_dot_n_i_comp__m3_per_h    = GN.comp.V_dot_n_i_comp * 60 * 60;
%         GN.comp.V_dot_n_i_comp              = [];
        
    elseif any(strcmp('m_dot_i__kg_per_s',GN.bus.Properties.VariableNames))
        GN.comp.m_dot_ij__kg_per_s          = GN.comp.V_dot_n_ij * GN.gasMixProp.rho_n_avg;
%         GN.comp.V_dot_n_ij                  = [];
        GN.comp.m_dot_i_comp__kg_per_s      = GN.comp.V_dot_n_i_comp * GN.gasMixProp.rho_n_avg;
%         GN.comp.V_dot_n_i_comp              = [];
    end
    
    % UNDER CONSTRUCTION: Q_dot_cooler
>>>>>>> Merge to public repo (#1)
end

%% prs
if isfield(GN,'prs')
<<<<<<< HEAD
    
    % 1) Apply results from branch
=======
    % P_el_exp_turbine
    GN = get_P_el_exp_turbine(GN, PHYMOD);
    
    % Get V_dot_n_ij from branch
>>>>>>> Merge to public repo (#1)
    i_prs = GN.branch.i_prs(GN.branch.prs_branch);
    GN.prs.V_dot_n_ij(i_prs) = ...
        GN.branch.V_dot_n_ij(GN.branch.prs_branch);
    
<<<<<<< HEAD
    % 2) Calculate additional results
    % 2.1) Power of expansion turbine
    GN = get_P_el_exp_turbine(GN, PHYMOD);
    
    % 3) Check results
    % 3.1) Direction of V_dot_n_ij
=======
    % Check V_dot_n_ij
>>>>>>> Merge to public repo (#1)
    if any(GN.prs.V_dot_n_ij < -NUMPARAM.numericalTolerance)
        prs_ID = GN.prs.prs_ID(GN.prs.V_dot_n_ij < -NUMPARAM.numericalTolerance);
        warning(['The volume flows at these pressure gegulator stations have the wrong direction, prs_ID: ',num2str(prs_ID')])
    end
    
    % Calculate P_th_ij__MW, P_th_ij, V_dot_n_ij__m3_per_day,
    %   V_dot_n_ij__m3_per_h or m_dot_ij__kg_per_s
    if any(strcmp('P_th_i__MW',GN.bus.Properties.VariableNames))
        GN.prs.P_th_ij__MW              = GN.prs.V_dot_n_ij * 1e-6 * GN.gasMixProp.H_s_n_avg;
<<<<<<< HEAD
        %         GN.prs.V_dot_n_ij               = [];
        
    elseif any(strcmp('P_th_i',GN.bus.Properties.VariableNames))
        GN.prs.P_th_ij                  = GN.prs.V_dot_n_ij * GN.gasMixProp.H_s_n_avg;
        %         GN.prs.V_dot_n_ij               = [];
        
    elseif any(strcmp('V_dot_n_i__m3_per_day',GN.bus.Properties.VariableNames))
        GN.prs.V_dot_n_ij__m3_per_day   = GN.prs.V_dot_n_ij * 60 * 60 * 24;
        %         GN.prs.V_dot_n_ij               = [];
        
    elseif any(strcmp('V_dot_n_i__m3_per_h',GN.bus.Properties.VariableNames))
        GN.prs.V_dot_n_ij__m3_per_h     = GN.prs.V_dot_n_ij * 60 * 60;
        %         GN.prs.V_dot_n_ij               = [];
        
    elseif any(strcmp('m_dot_i__kg_per_s',GN.bus.Properties.VariableNames))
        GN.prs.m_dot_ij__kg_per_s       = GN.prs.V_dot_n_ij * GN.gasMixProp.rho_n_avg;
        %         GN.prs.V_dot_n_ij               = [];
        
    end
    
    if ~GN.isothermal || GN.isothermal == 0
        %Q_dot_heater_cooler
        if any(GN.prs.T_controlled)
            GN = get_Q_dot_prs(GN, PHYMOD);
        end
        
        if any(~isnan(GN.prs.Q_dot_heater_cooler))
            % Power needed by heater or cooler
            P_el_heater = zeros(length(GN.prs.prs_ID));
            P_el_cooler = zeros(length(GN.prs.prs_ID));
            GN.prs.P_el_heater_cooler(:)=0;
            
            if any(~GN.prs.gas_powered_heater_cooler)
                
                id_electrical_heater_cooler = find(~GN.prs.gas_powered_heater_cooler);
                id_heater_temp = find(GN.prs.Q_dot_heater_cooler>0);
                id_cooler_temp = find(GN.prs.Q_dot_heater_cooler<0);
                id_heater = id_heater_temp(ismember(id_heater_temp,id_electrical_heater_cooler));
                id_cooler = id_cooler_temp(ismember(id_cooler_temp,id_electrical_heater_cooler));
                
                P_el_heater(id_heater) = abs(GN.prs.Q_dot_heater_cooler(id_heater)).*GN.prs.eta_heat(id_heater);
                P_el_cooler(id_cooler) = abs(GN.prs.Q_dot_heater_cooler(id_cooler)).*GN.prs.eta_cool(id_cooler);
                
                GN.prs.P_el_heater_cooler = P_el_heater+P_el_cooler;
            end
        end
        
        if any(GN.prs.exp_turbine)
            try
                % Entire Power of the Station
                GN.prs.P_el_tot = GN.prs.P_el_exp_turbine + GN.prs.P_el_heater_cooler;
            catch
            end
        end
=======
%         GN.prs.V_dot_n_ij               = [];
        
    elseif any(strcmp('P_th_i',GN.bus.Properties.VariableNames))
        GN.prs.P_th_ij                  = GN.prs.V_dot_n_ij * GN.gasMixProp.H_s_n_avg;
%         GN.prs.V_dot_n_ij               = [];
        
    elseif any(strcmp('V_dot_n_i__m3_per_day',GN.bus.Properties.VariableNames))
        GN.prs.V_dot_n_ij__m3_per_day   = GN.prs.V_dot_n_ij * 60 * 60 * 24;
%         GN.prs.V_dot_n_ij               = [];
        
    elseif any(strcmp('V_dot_n_i__m3_per_h',GN.bus.Properties.VariableNames))
        GN.prs.V_dot_n_ij__m3_per_h     = GN.prs.V_dot_n_ij * 60 * 60;
%         GN.prs.V_dot_n_ij               = [];
        
    elseif any(strcmp('m_dot_i__kg_per_s',GN.bus.Properties.VariableNames))
        GN.prs.m_dot_ij__kg_per_s       = GN.prs.V_dot_n_ij * GN.gasMixProp.rho_n_avg;
%         GN.prs.V_dot_n_ij               = [];
        
    end
    
    % UNDER CONSTRUCTION: Q_dot_heater
end

%% valve
if isfield(GN,'valve')
    % V_dot_n_ij
    i_valve = GN.branch.i_valve(GN.branch.valve_branch);
    GN.valve.V_dot_n_ij(i_valve) = ...
        GN.branch.V_dot_n_ij(GN.branch.valve_branch);
    
    % Get V_dot_n_ij from branch
    if any(GN.valve.V_dot_n_ij < -NUMPARAM.numericalTolerance)
        valve_ID = GN.valve.valve_ID(GN.valve.V_dot_n_ij < -NUMPARAM.numericalTolerance);
        warning(['The volume flows at these valves have the wrong direction, valve_ID: ',num2str(valve_ID')])
    end
    
    % Calculate P_th_ij__MW, P_th_ij, V_dot_n_ij__m3_per_day,
    %   V_dot_n_ij__m3_per_h or m_dot_ij__kg_per_s
    if any(strcmp('P_th_i__MW',GN.bus.Properties.VariableNames))
        GN.valve.P_th_ij__MW                = GN.valve.V_dot_n_ij * 1e-6 * GN.gasMixProp.H_s_n_avg;
%         GN.valve.V_dot_n_ij                 = [];
        
    elseif any(strcmp('P_th_i',GN.bus.Properties.VariableNames))
        GN.valve.P_th_ij                    = GN.valve.V_dot_n_ij * GN.gasMixProp.H_s_n_avg;
%         GN.valve.V_dot_n_ij                 = [];
        
    elseif any(strcmp('V_dot_n_i__m3_per_day',GN.bus.Properties.VariableNames))
        GN.valve.V_dot_n_ij__m3_per_day     = GN.valve.V_dot_n_ij * 60 * 60 * 24;
%         GN.valve.V_dot_n_ij                 = [];
        
    elseif any(strcmp('V_dot_n_i__m3_per_h',GN.bus.Properties.VariableNames))
        GN.valve.V_dot_n_ij__m3_per_h       = GN.valve.V_dot_n_ij * 60 * 60;
%         GN.valve.V_dot_n_ij                 = [];
        
    elseif any(strcmp('m_dot_i__kg_per_s',GN.bus.Properties.VariableNames))
        GN.valve.m_dot_ij__kg_per_s         = GN.valve.V_dot_n_ij * GN.gasMixProp.rho_n_avg;
%         GN.valve.V_dot_n_ij                 = [];
        
>>>>>>> Merge to public repo (#1)
    end
end

%% pipe
if isfield(GN,'pipe')
    % Get V_dot_n_ij from branch
    i_pipe = GN.branch.i_pipe(GN.branch.pipe_branch);
    GN.pipe.V_dot_n_ij(i_pipe) = ...
        GN.branch.V_dot_n_ij(GN.branch.pipe_branch);
    
<<<<<<< HEAD
    % Get rho_i
    if ~any(strcmp('rho_i',GN.bus.Properties.VariableNames))
=======
    % Get rho_ij - UNDER CONSTRCUTION: Necessary?
    if ~any(strcmp('rho_ij',GN.pipe.Properties.VariableNames))
>>>>>>> Merge to public repo (#1)
        GN = get_rho(GN);
    end
    
    % Calulate velocity v [m/s]
    iF = GN.branch.i_from_bus(GN.branch.pipe_branch);
    iT = GN.branch.i_to_bus(GN.branch.pipe_branch);
    GN.pipe.v_from_bus              = GN.pipe.V_dot_n_ij ./ GN.pipe.D_ij * GN.gasMixProp.rho_n_avg ./ GN.bus.rho_i(iF);
    GN.pipe.v_to_bus                = GN.pipe.V_dot_n_ij ./ GN.pipe.D_ij * GN.gasMixProp.rho_n_avg ./ GN.bus.rho_i(iT);
    
    % Check v
    if any(strcmp('v_max',GN.pipe.Properties.VariableNames))
        if any(GN.pipe.v_from_bus > GN.pipe.v_max) || any(GN.pipe.v_to_bus > GN.pipe.v_max)
            pipe_ID = GN.pipe.pipe_ID(GN.pipe.v_from_bus > GN.pipe.v_max | GN.pipe.v_to_bus > GN.pipe.v_max);
            warning(['Too high temperature at these nodes, bus_ID: ',num2str(pipe_ID')])
        end
    end
    
    % Get p_ij__barg
    GN.pipe.p_ij__barg = (GN.pipe.p_ij - CONST.p_n)*1e-5;
    GN.pipe.p_ij = [];
    
    % Get lambda_ij
    if any(strcmp('lambda_ij',GN.pipe.Properties.VariableNames))
        GN.pipe.lambda_ij(isinf(GN.pipe.lambda_ij)) = NaN;
    end
    
    % Calculate P_th_i__MW, P_th_i, V_dot_n_i__m3_per_day,
<<<<<<< HEAD
    %     %   V_dot_n_i__m3_per_h or m_dot_i__kg_per_s
    %     if any(strcmp('P_th_i__MW',GN.bus.Properties.VariableNames))
    %         GN.pipe.P_th_ij__MW = GN.pipe.V_dot_n_ij * 1e-6 * GN.gasMixProp.H_s_n_avg;
    % %         GN.pipe.V_dot_n_ij = [];
    %     elseif any(strcmp('P_th_i',GN.bus.Properties.VariableNames))
    %         GN.pipe.P_th_ij = GN.pipe.V_dot_n_ij * GN.gasMixProp.H_s_n_avg;
    % %         GN.pipe.V_dot_n_ij = [];
    %     elseif any(strcmp('V_dot_n_i__m3_per_day',GN.bus.Properties.VariableNames))
    %         GN.pipe.V_dot_n_ij__m3_per_day  = GN.pipe.V_dot_n_ij * 60 * 60 * 24;
    % %         GN.pipe.V_dot_n_ij = [];
    %     elseif any(strcmp('V_dot_n_i__m3_per_h',GN.bus.Properties.VariableNames))
    %         GN.pipe.V_dot_n_ij__m3_per_h    = GN.pipe.V_dot_n_ij * 60 * 60;
    % %         GN.pipe.V_dot_n_ij = [];
    %     elseif any(strcmp('m_dot_i__kg_per_s',GN.bus.Properties.VariableNames))
    %         GN.pipe.m_dot_ij__kg_per_s      = GN.pipe.V_dot_n_ij * GN.gasMixProp.rho_n_avg;
    % %         GN.pipe.V_dot_n_ij = [];
    %     end
=======
    %   V_dot_n_i__m3_per_h or m_dot_i__kg_per_s
    if any(strcmp('P_th_i__MW',GN.bus.Properties.VariableNames))
        GN.pipe.P_th_ij__MW = GN.pipe.V_dot_n_ij * 1e-6 * GN.gasMixProp.H_s_n_avg;
%         GN.pipe.V_dot_n_ij = [];
    elseif any(strcmp('P_th_i',GN.bus.Properties.VariableNames))
        GN.pipe.P_th_ij = GN.pipe.V_dot_n_ij * GN.gasMixProp.H_s_n_avg;
%         GN.pipe.V_dot_n_ij = [];
    elseif any(strcmp('V_dot_n_i__m3_per_day',GN.bus.Properties.VariableNames))
        GN.pipe.V_dot_n_ij__m3_per_day  = GN.pipe.V_dot_n_ij * 60 * 60 * 24;
%         GN.pipe.V_dot_n_ij = [];
    elseif any(strcmp('V_dot_n_i__m3_per_h',GN.bus.Properties.VariableNames))
        GN.pipe.V_dot_n_ij__m3_per_h    = GN.pipe.V_dot_n_ij * 60 * 60;
%         GN.pipe.V_dot_n_ij = [];
    elseif any(strcmp('m_dot_i__kg_per_s',GN.bus.Properties.VariableNames))
        GN.pipe.m_dot_ij__kg_per_s      = GN.pipe.V_dot_n_ij * GN.gasMixProp.rho_n_avg;
%         GN.pipe.V_dot_n_ij = [];
    end
>>>>>>> Merge to public repo (#1)
end

%% bus
if any(strcmp('p_i',GN.bus.Properties.VariableNames))
    % Get p_i__barg
    GN.bus.p_i__barg = (GN.bus.p_i - CONST.p_n)*1e-5;
    GN.bus.p_i = [];
    
    % check p_i__barg: p_i_min__barg, p_i_max__barg, T_i_min, T_i_max
<<<<<<< HEAD
    %     if any(strcmp('p_i_max__barg',GN.bus.Properties.VariableNames))
    %         if any(GN.bus.p_i__barg < GN.bus.p_i_min__barg)
    %             bus_ID = GN.bus.bus_ID(GN.bus.p_i__barg < GN.bus.p_i_min__barg);
    % %             warning(['Too low pressure at these nodes, bus_ID: ',num2str(bus_ID')])
    %         end
    %     end
    %     if any(strcmp('p_i_min__barg',GN.bus.Properties.VariableNames))
    %         if any(GN.bus.p_i__barg > GN.bus.p_i_max__barg)
    %             bus_ID = GN.bus.bus_ID(GN.bus.p_i__barg > GN.bus.p_i_max__barg);
    % %             warning(['Too high pressure at these nodes, bus_ID:
    % %             ',num2str(bus_ID')]) % UNDER CONSTRUCTION
    %         end
    %     end
    %     if any(strcmp('T_i_min',GN.bus.Properties.VariableNames))
    %         if any(GN.bus.T_i < GN.bus.T_i_min)
    %             bus_ID = GN.bus.bus_ID(GN.bus.T_i < GN.bus.T_i_min);
    %             warning(['Too low temperature at these nodes, bus_ID: ',num2str(bus_ID')])
    %         end
    %     end
    %     if any(strcmp('T_i_max',GN.bus.Properties.VariableNames))
    %         if any(GN.bus.T_i > GN.bus.T_i_max)
    %             bus_ID = GN.bus.bus_ID(GN.bus.T_i > GN.bus.T_i_max);
    %             warning(['Too high temperature at these nodes, bus_ID: ',num2str(bus_ID')])
    %         end
    %     end
    
    % Calculate P_th_i__MW, P_th_i, V_dot_n_i__m3_per_day,
    %     %   V_dot_n_i__m3_per_h or m_dot_i__kg_per_s
    %     if any(strcmp('P_th_i__MW',GN.bus.Properties.VariableNames))
    %         GN.bus.P_th_i__MW = GN.bus.V_dot_n_i * 1e-6 * GN.gasMixProp.H_s_n_avg;
    % %         GN.bus.V_dot_n_i = [];
    %     elseif any(strcmp('P_th_i',GN.bus.Properties.VariableNames))
    %         GN.bus.P_th_i = GN.bus.V_dot_n_i * GN.gasMixProp.H_s_n_avg;
    % %         GN.bus.V_dot_n_i = [];
    %     elseif any(strcmp('V_dot_n_i__m3_per_day',GN.bus.Properties.VariableNames))
    %         GN.bus.V_dot_n_i__m3_per_day  = GN.bus.V_dot_n_i * 60 * 60 * 24;
    % %         GN.bus.V_dot_n_i = [];
    %     elseif any(strcmp('V_dot_n_i__m3_per_h',GN.bus.Properties.VariableNames))
    %         GN.bus.V_dot_n_i__m3_per_h    = GN.bus.V_dot_n_i * 60 * 60;
    % %         GN.bus.V_dot_n_i = [];
    %     elseif any(strcmp('m_dot_i__kg_per_s',GN.bus.Properties.VariableNames))
    %         GN.bus.m_dot_i__kg_per_s      = GN.bus.V_dot_n_i * GN.gasMixProp.rho_n_avg;
    % %         GN.bus.V_dot_n_i = [];
    %     end
end

%% Reset valves
% GN = reset_valves(GN,GN_input);
[GN] = get_p_T_valve(GN);
GN = get_V_dot_n_ij_valves(GN);

%% valve
if isfield(GN,'valve')
    % 1) Apply results from branch
    i_valve = GN.branch.i_valve(GN.branch.valve_branch);
    GN.valve.V_dot_n_ij(i_valve) = ...
        GN.branch.V_dot_n_ij(GN.branch.valve_branch);
    
    % Calculate P_th_ij__MW, P_th_ij, V_dot_n_ij__m3_per_day,
    %   V_dot_n_ij__m3_per_h or m_dot_ij__kg_per_s
    if any(strcmp('P_th_i__MW',GN.bus.Properties.VariableNames))
        GN.valve.P_th_ij__MW                = GN.valve.V_dot_n_ij * 1e-6 * GN.gasMixProp.H_s_n_avg;
        %         GN.valve.V_dot_n_ij                 = [];
        
    elseif any(strcmp('P_th_i',GN.bus.Properties.VariableNames))
        GN.valve.P_th_ij                    = GN.valve.V_dot_n_ij * GN.gasMixProp.H_s_n_avg;
        %         GN.valve.V_dot_n_ij                 = [];
        
    elseif any(strcmp('V_dot_n_i__m3_per_day',GN.bus.Properties.VariableNames))
        GN.valve.V_dot_n_ij__m3_per_day     = GN.valve.V_dot_n_ij * 60 * 60 * 24;
        %         GN.valve.V_dot_n_ij                 = [];
        
    elseif any(strcmp('V_dot_n_i__m3_per_h',GN.bus.Properties.VariableNames))
        GN.valve.V_dot_n_ij__m3_per_h       = GN.valve.V_dot_n_ij * 60 * 60;
        %         GN.valve.V_dot_n_ij                 = [];
        
    elseif any(strcmp('m_dot_i__kg_per_s',GN.bus.Properties.VariableNames))
        GN.valve.m_dot_ij__kg_per_s         = GN.valve.V_dot_n_ij * GN.gasMixProp.rho_n_avg;
        %         GN.valve.V_dot_n_ij                 = [];
        
    end
end

%% Remove auxiliary variables
if flag_remove_auxiliary_variables == 1
    GN = remove_auxiliary_variables(GN);
end

=======
    if any(strcmp('p_i_max__barg',GN.bus.Properties.VariableNames))
        if any(GN.bus.p_i__barg < GN.bus.p_i_min__barg)
            bus_ID = GN.bus.bus_ID(GN.bus.p_i__barg < GN.bus.p_i_min__barg);
            warning(['Too low pressure at these nodes, bus_ID: ',num2str(bus_ID')])
        end
    end
    if any(strcmp('p_i_min__barg',GN.bus.Properties.VariableNames))
        if any(GN.bus.p_i__barg > GN.bus.p_i_max__barg)
            bus_ID = GN.bus.bus_ID(GN.bus.p_i__barg > GN.bus.p_i_max__barg);
%             warning(['Too high pressure at these nodes, bus_ID:
%             ',num2str(bus_ID')]) % UNDER CONSTRUCTION
        end
    end
    if any(strcmp('T_i_min',GN.bus.Properties.VariableNames))
        if any(GN.bus.T_i < GN.bus.T_i_min)
            bus_ID = GN.bus.bus_ID(GN.bus.T_i < GN.bus.T_i_min);
            warning(['Too low temperature at these nodes, bus_ID: ',num2str(bus_ID')])
        end
    end
    if any(strcmp('T_i_max',GN.bus.Properties.VariableNames))
        if any(GN.bus.T_i > GN.bus.T_i_max)
            bus_ID = GN.bus.bus_ID(GN.bus.T_i > GN.bus.T_i_max);
            warning(['Too high temperature at these nodes, bus_ID: ',num2str(bus_ID')])
        end
    end
    
    % Calculate P_th_i__MW, P_th_i, V_dot_n_i__m3_per_day,
    %   V_dot_n_i__m3_per_h or m_dot_i__kg_per_s
    if any(strcmp('P_th_i__MW',GN.bus.Properties.VariableNames))
        GN.bus.P_th_i__MW = GN.bus.V_dot_n_i * 1e-6 * GN.gasMixProp.H_s_n_avg;
%         GN.bus.V_dot_n_i = [];
    elseif any(strcmp('P_th_i',GN.bus.Properties.VariableNames))
        GN.bus.P_th_i = GN.bus.V_dot_n_i * GN.gasMixProp.H_s_n_avg;
%         GN.bus.V_dot_n_i = [];
    elseif any(strcmp('V_dot_n_i__m3_per_day',GN.bus.Properties.VariableNames))
        GN.bus.V_dot_n_i__m3_per_day  = GN.bus.V_dot_n_i * 60 * 60 * 24;
%         GN.bus.V_dot_n_i = [];
    elseif any(strcmp('V_dot_n_i__m3_per_h',GN.bus.Properties.VariableNames))
        GN.bus.V_dot_n_i__m3_per_h    = GN.bus.V_dot_n_i * 60 * 60;
%         GN.bus.V_dot_n_i = [];
    elseif any(strcmp('m_dot_i__kg_per_s',GN.bus.Properties.VariableNames))
        GN.bus.m_dot_i__kg_per_s      = GN.bus.V_dot_n_i * GN.gasMixProp.rho_n_avg;
%         GN.bus.V_dot_n_i = [];
    end
end
>>>>>>> Merge to public repo (#1)
end

