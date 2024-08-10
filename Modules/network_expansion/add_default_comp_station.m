function GN = add_default_comp_station(GN, bus_IDs)
%add_default_comp_station
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 2020-2024, High Voltage Equipment and Grids,
%       Digitalization and Energy Economics (IAEW),
%       RWTH Aachen University, Marcel Kurth
%   All rights reserved.
%   Contact: Marcel Kurth (marcel.kurth@rwth-aachen.de)
%   This script is part of matGasFlow.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

bus_ID_offset       = 10^ceil(log10(max(GN.bus.bus_ID)));

for ii = 1:length(bus_IDs)
    if isfield(GN, 'prs') && (any(GN.prs.from_bus_ID == bus_IDs(ii)) || any(GN.prs.to_bus_ID == bus_IDs(ii)))
        error(['The bus_ID ',num2str(bus_IDs(ii)),' is connected to prs. It may only be connected to pipes.'])
    end
    if isfield(GN, 'valve') && (any(GN.valve.from_bus_ID == bus_IDs(ii)) || any(GN.valve.to_bus_ID == bus_IDs(ii)))
        error(['The bus_ID ',num2str(bus_IDs(ii)),' is connected to valve. It may only be connected to pipes.'])
    end
    if ~isfield(GN,'pipe')
        error(['GN has no pipe. To add a compressor station at bus_ID ',num2str(bus_IDs(ii)),', the bus must be connected to at least two pipes.'])
    end
    i_pipe_bus_ID_is_from_bus   = find(GN.pipe.from_bus_ID == bus_IDs(ii));
    i_pipe_bus_ID_is_to_bus     = find(GN.pipe.to_bus_ID == bus_IDs(ii));
    i_pipe                      = [i_pipe_bus_ID_is_from_bus, i_pipe_bus_ID_is_to_bus];
    if length(i_pipe) == 1
        error(['The bus ',num2str(bus_IDs(ii)),' (bus_ID) is only connected to one pipe. To add a compressor station, the bus must be connected to at least two pipes.'])
    end
    
    %% new bus IDs
    to_bus_ID_comp      = ii*bus_ID_offset + bus_IDs(ii);
    new_bus_IDs_pipes   = ii*bus_ID_offset + bus_IDs(ii) + (1:length(i_pipe))';
    
    %% Change bus IDs at pipes
    GN.pipe.from_bus_ID(i_pipe_bus_ID_is_from_bus)  = new_bus_IDs_pipes(1:length(i_pipe_bus_ID_is_from_bus));
    GN.pipe.to_bus_ID(i_pipe_bus_ID_is_to_bus)      = new_bus_IDs_pipes(length(i_pipe_bus_ID_is_from_bus)+1:length(new_bus_IDs_pipes));
    
    %% Add busses
    i_new_busses                    = (size(GN.bus,1)+1 : size(GN.bus,1)+1+length(new_bus_IDs_pipes))';
    GN.bus = [GN.bus; repelem(GN.bus(GN.bus.bus_ID == bus_IDs(ii),:),length(i_new_busses),1)];
    GN.bus.bus_ID(i_new_busses)     = [to_bus_ID_comp; new_bus_IDs_pipes];
    
    if ismember('P_th_i__MW',GN.bus.Properties.VariableNames)
        GN.bus.P_th_i__MW(i_new_busses) = 0;
    elseif ismember('P_th_i',GN.bus.Properties.VariableNames)
        GN.bus.P_th_i(i_new_busses) = 0;
    elseif ismember('V_dot_n_i__m3_per_day',GN.bus.Properties.VariableNames)
        GN.bus.V_dot_n_i__m3_per_day(i_new_busses) = 0;
    elseif ismember('V_dot_n_i__m3_per_h',GN.bus.Properties.VariableNames)
        GN.bus.V_dot_n_i__m3_per_h(i_new_busses) = 0;
    elseif ismember('m_dot_i__kg_per_s',GN.bus.Properties.VariableNames)
        GN.bus.m_dot_i__kg_per_s(i_new_busses) = 0;
    elseif ismember('V_dot_n_i',GN.bus.Properties.VariableNames)
        GN.bus.V_dot_n_i(i_new_busses) = 0;
    end
    
    GN.bus.x_coord(i_new_busses)    = GN.bus.x_coord(i_new_busses) + rand(length(i_new_busses),1); % TODO
    GN.bus.y_coord(i_new_busses)    = GN.bus.y_coord(i_new_busses) + rand(length(i_new_busses),1); % TODO
    
    %% Comp
    if isfield(GN,'comp')
        comp_ID = max(GN.comp.comp_ID) + 1;
    else
        comp_ID = 1;
    end
    from_bus_ID = bus_IDs(ii);
    to_bus_ID   = to_bus_ID_comp;
    comp        = table(comp_ID, from_bus_ID, to_bus_ID);
    if isfield(GN,'comp')
        GN.comp = [GN.comp;comp];
    else
        GN.comp = comp;
    end
    
    %% PRS
    if isfield(GN,'prs')
        prs_ID = max(GN.prs.prs_ID) + (1:2*length(i_pipe))';
    else
        prs_ID = (1:2*length(i_pipe))';
    end
    from_bus_ID         = [ones(length(new_bus_IDs_pipes),1) * to_bus_ID_comp; new_bus_IDs_pipes];
    to_bus_ID           = [new_bus_IDs_pipes; ones(length(new_bus_IDs_pipes),1) * bus_IDs(ii)];
    associate_prs_ID    = [prs_ID(length(prs_ID)/2+1:end);prs_ID(1:length(prs_ID)/2)];
    prs                 = table(prs_ID, from_bus_ID, to_bus_ID, associate_prs_ID);
    if isfield(GN,'prs')
        GN.prs = [GN.prs;prs];
    else
        GN.prs = prs;
    end
    
end
GN = check_and_init_GN(GN);

end

