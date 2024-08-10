function analyze_convergence(GN, TITLE, rel_only, logarithmic_scale)
%ANALYZE_CONVERGENCE
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

%% Set default input arguments
if nargin < 4
    logarithmic_scale = 0;
    
    if nargin < 3
        rel_only = 0;
        
        if nargin < 2
            if isfield(GN,'name')
                TITLE = GN.name;
            else
                TITLE = 'GN with no name';
            end
        end
    end
end

if ~iscell(GN.CONVERGENCE.V_dot_n_ij)
    error('rungf did not converge.')
end

%%
figure
if rel_only
    subplot_number = 5;
else
    subplot_number = 8;
end

ii = 0;

ii = ii + 1;
f = [GN.CONVERGENCE.f{:}];
if size(f,2) == 1
    f = [f,f];
end
set(groot,'defaultAxesTickLabelInterpreter','latex');
hAxis(ii) = subplot(subplot_number,1,ii);
plot(abs(f'))
ylabel('$$f=\Sigma\dot{V}_{n,ij}+\dot{V}_{n,i} \left[\frac{m^3}{s}\right]$$','Interpreter','latex','FontSize', 12)
hYLabel = get(gca,'YLabel');
set(hYLabel,'rotation',0,'HorizontalAlignment','right')
xticks(size(f,2))
xlim([1 size(f,2)])
if logarithmic_scale
    set(gca, 'YScale', 'log')
end

if ~rel_only
    ii = ii + 1;
    V_dot_n_ij = [GN.CONVERGENCE.V_dot_n_ij{:}];
    V_dot_n_ij = V_dot_n_ij(V_dot_n_ij(:,end)~=0,:);
    if size(V_dot_n_ij,2) == 1
        V_dot_n_ij = [V_dot_n_ij,V_dot_n_ij];
    end
    set(groot,'defaultAxesTickLabelInterpreter','latex');
    hAxis(ii) = subplot(subplot_number,1,ii);
    plot(V_dot_n_ij')
    ylabel('$$\dot{V}_{n,ij} \left[\frac{m^3}{s}\right]$$','Interpreter','latex','FontSize', 12)
    hYLabel = get(gca,'YLabel');
    set(hYLabel,'rotation',0,'HorizontalAlignment','right')
    xticks(size(V_dot_n_ij,2));
    xlim([1 size(V_dot_n_ij,2)])
    if logarithmic_scale
        set(gca, 'YScale', 'log')
    end
end

ii = ii + 1;
V_dot_n_ij = [GN.CONVERGENCE.V_dot_n_ij{:}];
V_dot_n_ij = V_dot_n_ij(V_dot_n_ij(:,end)~=0,:);
set(groot,'defaultAxesTickLabelInterpreter','latex');
hAxis(ii) = subplot(subplot_number,1,ii);
if ~logarithmic_scale
    V_dot_n_ij_rel = V_dot_n_ij./V_dot_n_ij(:,end);
    if size(V_dot_n_ij_rel,2) == 1
        V_dot_n_ij_rel = [V_dot_n_ij_rel,V_dot_n_ij_rel];
    end
    plot(V_dot_n_ij_rel')
    ylabel('$$\dot{V}_{n,ij,rel}$$','Interpreter','latex','FontSize', 12)
else
    V_dot_n_ij_rel = V_dot_n_ij./V_dot_n_ij(:,end);
    V = [NaN(size(V_dot_n_ij)),(V_dot_n_ij(:,2:end) - V_dot_n_ij(:,1:end-1))./V_dot_n_ij(:,1:end-1)];
    if size(V,2) == 1
        V = [V,V];
    end
    semilogx(V')
    ylabel('$$(\dot{V}_{n,ij,k}-\dot{V}_{n,ij,k+1})/(\dot{V}_{n,ij,k})$$','Interpreter','latex','FontSize', 12)
end
hYLabel = get(gca,'YLabel');
set(hYLabel,'rotation',0,'HorizontalAlignment','right')
xticks(size(V_dot_n_ij_rel,2));
xlim([1 size(V_dot_n_ij_rel,2)])
if logarithmic_scale
    set(gca, 'YScale', 'log')
end

if ~rel_only
    ii = ii + 1;
    p_i = [GN.CONVERGENCE.p_i{:}];
    if size(p_i,2) == 1
        p_i = [p_i,p_i];
    end
    set(groot,'defaultAxesTickLabelInterpreter','latex');
    hAxis(ii) = subplot(subplot_number,1,ii);
    plot(p_i')
    ylabel('$$p_{i} \left[bar\right]$$','Interpreter','latex','FontSize', 12)
    hYLabel = get(gca,'YLabel');
    set(hYLabel,'rotation',0,'HorizontalAlignment','right')
    xticks(size(p_i,2))
    xlim([1 size(p_i,2)])
    if logarithmic_scale
        set(gca, 'YScale', 'log')
    end
end

ii = ii + 1;
p_i_rel = [GN.CONVERGENCE.p_i{:}]./GN.CONVERGENCE.p_i{end};
if size(p_i_rel,2) == 1
    p_i_rel = [p_i_rel,p_i_rel];
end
set(groot,'defaultAxesTickLabelInterpreter','latex');
hAxis(ii) = subplot(subplot_number,1,ii);
plot(p_i_rel')
ylabel('$$p_{i,rel}$$','Interpreter','latex','FontSize', 12)
hYLabel = get(gca,'YLabel');
set(hYLabel,'rotation',0,'HorizontalAlignment','right')
xticks(size(p_i_rel,2))
xlim([1 size(p_i_rel,2)])
if logarithmic_scale
    set(gca, 'YScale', 'log')
end

if ~rel_only
    ii = ii + 1;
    T_i = [GN.CONVERGENCE.T_i{:}];
    if size(T_i,2) == 1
        T_i = [T_i,T_i];
    end
    set(groot,'defaultAxesTickLabelInterpreter','latex');
    hAxis(ii) = subplot(subplot_number,1,ii);
    plot(T_i')
    ylabel('$$T_{i} \left[K\right]$$','Interpreter','latex','FontSize', 12)
    hYLabel = get(gca,'YLabel');
    set(hYLabel,'rotation',0,'HorizontalAlignment','right')
    xticks(size(T_i,2))
    xlim([1 size(T_i,2)])
    if logarithmic_scale
        set(gca, 'YScale', 'log')
    end
end

ii = ii + 1;
T_i_rel = [GN.CONVERGENCE.T_i{:}]./GN.CONVERGENCE.T_i{end};
if size(T_i_rel,2) == 1
    T_i_rel = [T_i_rel,T_i_rel];
end
set(groot,'defaultAxesTickLabelInterpreter','latex');
hAxis(ii) = subplot(subplot_number,1,ii);
plot(T_i_rel')
ylabel('$$T_{i,rel}$$','Interpreter','latex','FontSize', 12)
hYLabel = get(gca,'YLabel');
set(hYLabel,'rotation',0,'HorizontalAlignment','right')
xticks(1:size(T_i_rel,2))
xticklabels([GN.CONVERGENCE.tag{:}])
xtickangle(45)
xlim([1 size(T_i_rel,2)])
if logarithmic_scale
    set(gca, 'YScale', 'log')
end

%%
currentFigure = gcf;
filename = strrep(TITLE,'_',' ');
title(currentFigure.Children(end), filename);

end

