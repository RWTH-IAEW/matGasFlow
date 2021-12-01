function [GN_temp]= getCompressorStages(GN,PHYMOD)

%% Indices
i_comp = GN.branch.i_comp(GN.branch.comp_branch);
i_comp_GP = i_comp(GN.comp.gas_powered_comp(i_comp));
i_from_bus = GN.branch.i_from_bus(GN.branch.comp_branch);
i_from_bus = i_from_bus(i_comp);
i_to_bus = GN.branch.i_to_bus(GN.branch.comp_branch);
i_to_bus = i_to_bus(i_comp);

%% Define different compressor stages
OPTION = PHYMOD.compressor_stages;

%% OPTION 1: No additional compression stages

%% OPTION 2: Additional compression stage if R>=3
% Festlegung über den 'R-Wert' (= Gesamtes Verdichtungsverhältnis)
% Quelle: https://intech-gmbh-rus.de/compr_calculation_and_selection/

if OPTION == 2
    R = GN.bus.p_i(i_to_bus)./ GN.bus.p_i(i_from_bus);
        if any(R>=3)
        
        i_comp_2_stages= find(R>=3);
        i_from_bus_2_stages = GN.branch.i_from_bus(GN.branch.comp_branch(i_comp_2_stages));
        i_to_bus_2_stages = GN.branch.i_to_bus(GN.branch.comp_branch(i_comp_2_stages));
        
        delta_p = GN.bus.p_i(i_to_bus_2_stages) - GN.bus.p_i(i_from_bus_2_stages);
        delta_p__barg = GN.bus.p_i__barg(i_to_bus_2_stages) - GN.bus.p_i__barg(i_from_bus_2_stages);
        % Create two compressor stages
        % Create a thrid bus
        GN.bus.p_i(i_to_bus_2_stages)= GN.bus.p_i(i_from_bus_2_stages)+delta_p./2;
        GN.bus.p_i__barg(i_to_bus_2_stages)= GN.bus.p_i__barg(i_from_bus_2_stages)+delta_p__barg./2;
        
        GN.bus(end+1,:) = GN.bus(i_to_bus_2_stages,:);
        GN.bus.bus_ID(end) = max(GN.bus.bus_ID)+1;
        GN.bus.P_th_i__MW(i_to_bus_2_stages)= 0;
        GN.bus.V_dot_n_i(i_to_bus_2_stages)= 0;
        GN.bus.p_i(end) = GN.bus.p_i(i_from_bus_2_stages)+delta_p;
        GN.bus.p_i__barg(end)= GN.bus.p_i__barg(i_from_bus_2_stages)+delta_p__barg;
        GN.bus.slack_bus(end) = logical(false);
        
        %Create a second compressor
        GN.comp(end+1,:)=GN.comp(i_comp_2_stages,:);
        GN.comp.branch_ID(end) = max(GN.branch.branch_ID)+1;
        GN.comp.to_bus_ID(end) = GN.bus.bus_ID(end);
        GN.comp.from_bus_ID(end) = GN.bus.bus_ID(i_to_bus_2_stages);
        GN.comp.p_out__barg(i_comp_2_stages) = GN.bus.p_i__barg(i_from_bus_2_stages)+delta_p__barg./2;
        GN.comp.comp_ID(end)=max(GN.comp.comp_ID)+1;
        end 
end 
        
%% OPTION 3: Compressor stage for each bar of Compression
if OPTION ==3
    delta_p = GN.bus.p_i(i_to_bus) - GN.bus.p_i(i_from_bus);
    delta_p__barg = GN.bus.p_i__barg(i_to_bus) - GN.bus.p_i__barg(i_from_bus);
    
    if any(delta_p__barg>1)
        number_stages = ceil(delta_p__barg);
        
        i_comp_first_stage= find(delta_p__barg>1);
        i_from_bus_first_stage = GN.branch.i_from_bus(GN.branch.comp_branch(i_comp_first_stage));
        i_to_bus_first_stage = GN.branch.i_to_bus(GN.branch.comp_branch(i_comp_first_stage));
        
        % Create n compressor stages
        
        GN.bus.p_i(i_to_bus_first_stage)= GN.bus.p_i(i_from_bus_first_stage)+(10^5);
        GN.bus.p_i__barg(i_to_bus_first_stage)= GN.bus.p_i__barg(i_from_bus_first_stage)+1;
        GN.comp.p_out__barg(i_comp_first_stage) = GN.bus.p_i__barg(i_to_bus_first_stage);
        
        for ii = 2:(number_stages)
            
            %bus
            GN.bus(end+1,:) = GN.bus(i_to_bus_first_stage,:);
            GN.bus.bus_ID(end) = max(GN.bus.bus_ID)+1;
            GN.bus.p_i(end) = GN.bus.p_i(i_from_bus_first_stage)+(ii.*10^5);
            GN.bus.p_i__barg(end)= GN.bus.p_i__barg(i_from_bus_first_stage)+ii;
            GN.bus.slack_bus(end) = logical(false);
            
            %compressor
            GN.comp(end+1,:)=GN.comp(i_comp_first_stage,:);
            GN.comp.branch_ID(end) = max(GN.branch.branch_ID)+1;
            GN.comp.to_bus_ID(end) = GN.bus.bus_ID(end);
            GN.comp.comp_ID(end)=max(GN.comp.comp_ID)+1;
            if ii == 2
                GN.comp.from_bus_ID(end) = GN.bus.bus_ID(i_to_bus_first_stage);
                GN.comp.p_out__barg(end) = GN.comp.p_out__barg(i_comp_first_stage)+1;
            else
                GN.comp.from_bus_ID(end) = GN.comp.to_bus_ID(end-1);
                GN.comp.p_out__barg(end) = GN.comp.p_out__barg(end-1)+1;
            end
            
            if ii~= (number_stages -1)
                GN.bus.P_th_i__MW(end)= 0;
                GN.bus.V_dot_n_i(end)= 0;
            end
        end
        
        GN.bus.P_th_i__MW(i_to_bus_first_stage)= 0;
        GN.bus.V_dot_n_i(i_to_bus_first_stage)= 0;
        GN.bus.p_i(end) = GN.bus.p_i(i_from_bus_first_stage)+delta_p;
        GN.bus.p_i__barg(end)= GN.bus.p_i__barg(i_from_bus_first_stage)+delta_p__barg;
        GN.comp.p_out__barg(end) = GN.bus.p_i__barg(end);
    end
end
        
%% Check and set new indicies in GN
GN  = check_and_init_GN(GN,0);


%% Determine V_dot_n_i
if any(strcmp('P_th_i__MW',GN.bus.Properties.VariableNames))
    GN.bus.V_dot_n_i(~isnan(GN.bus.P_th_i__MW)) = GN.bus.P_th_i__MW(~isnan(GN.bus.P_th_i__MW)) * 1e6 / GN.gasMixProp.H_s_n_avg; % [MW]*1e6/[Ws/m^3] = [m^3/s]
elseif any(strcmp('P_th_i',GN.bus.Properties.VariableNames))
    GN.bus.V_dot_n_i(~isnan(GN.bus.P_th_i)) = GN.bus.P_th_i(~isnan(GN.bus.P_th_i)) / GN.gasMixProp.H_s_n_avg; % [W]/[Ws/m^3] = [m^3/s]
elseif any(strcmp('V_dot_n_i__m3_per_day',GN.bus.Properties.VariableNames))
    GN.bus.V_dot_n_i(~isnan(GN.bus.V_dot_n_i__m3_per_day)) = GN.bus.V_dot_n_i__m3_per_day(~isnan(GN.bus.V_dot_n_i__m3_per_day)) / (60 * 60 * 24);
elseif any(strcmp('V_dot_n_i__m3_per_h',GN.bus.Properties.VariableNames))
    GN.bus.V_dot_n_i(~isnan(GN.bus.V_dot_n_i__m3_per_h)) = GN.bus.V_dot_n_i__m3_per_h(~isnan(GN.bus.V_dot_n_i__m3_per_h)) * 60 * 60;
elseif any(strcmp('m_dot_i__kg_per_s',GN.bus.Properties.VariableNames))
    GN.bus.V_dot_n_i(~isnan(GN.bus.m_dot_i__kg_per_s)) = GN.bus.m_dot_i__kg_per_s(~isnan(GN.bus.m_dot_i__kg_per_s)) / GN.gasMixProp.rho_n_avg; % [kg/s]/[kg/m^3] = [m^3/s]
end

%% Update of the slack node: flow rate balance to(+)/from(-) the slack node 
%(in case slack node was affected by dividing compressor stages)
GN.bus.V_dot_n_i(GN.bus.slack_bus) = -sum(GN.bus.V_dot_n_i(~GN.bus.slack_bus));
if GN.isothermal == 0
    if GN.bus.V_dot_n_i(GN.bus.slack_bus) < 0
        GN.bus.source_bus(GN.bus.slack_bus) = true;
    else
        GN.bus.source_bus(GN.bus.slack_bus) = false;
    end
end

GN = init_V_dot_n_ij(GN);

GN_temp = GN; 
end
