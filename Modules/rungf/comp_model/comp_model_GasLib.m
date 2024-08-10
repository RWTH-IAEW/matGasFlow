%%      FROM:
%       Copyright (C) 2013
%       FAU Erlangen-Nuremberg, HU Berlin, LU Hannover, TU Darmstadt,
%       University Duisburg-Essen, WIAS Berlin, Zuse Institute Berlin
%       Contact: Thorsten Koch (koch@zib.de)
%       All rights reserved.
%
%       This work is licensed under the Creative Commons Attribution 3.0 Unported License.
%       To view a copy of this license, visit http://creativecommons.org/licenses/by/3.0/
%       or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View,
%       California, 94041, USA.
%
%       Pfetsch et al. (2012) "Validation of Nominations in Gas Network Optimization: Models, Methods, and Solutions", ZIB-Report 12-41
%%

clc
clear all
% close all
save_figures    = true;

%%
mlStruct = parseXML('compressorStations.xml');
% mlStruct = parseXML('GasLib-582-v2-20211129.xml');

%%
clc
clearvars -except mlStruct
compressors = struct();
I_compressorStation = 1:(length(mlStruct(23).Children)-1)/2;
i_comp = 0;
for ll = 1:length(I_compressorStation)
    i_compressorStation = I_compressorStation(ll);
    I_compressor = 1:(length(mlStruct(23).Children(i_compressorStation*2).Children(2).Children)-1)/2;

    for kk = 1:length(I_compressor)

        i_compressor    = I_compressor(kk);
        i_comp          = i_comp + 1;
        comp_temp       = mlStruct(23).Children(i_compressorStation*2).Children(2).Children(i_compressor*2).Children;
        comp_id         = mlStruct(23).Children(i_compressorStation*2).Children(2).Children(i_compressor*2).Attributes(2).Value;

        if strcmp(mlStruct(23).Children(i_compressorStation*2).Children(2).Children(i_compressor*2).Name,'turboCompressor')
            
            A_n = [...
                str2double(comp_temp(6).Attributes.Value),     str2double(comp_temp(8).Attributes.Value),     str2double(comp_temp(10).Attributes.Value); ...
                str2double(comp_temp(12).Attributes.Value),    str2double(comp_temp(14).Attributes.Value),    str2double(comp_temp(16).Attributes.Value); ...
                str2double(comp_temp(18).Attributes.Value),    str2double(comp_temp(20).Attributes.Value),    str2double(comp_temp(22).Attributes.Value); ...
                ];

            A_eta_ad = [...
                str2double(comp_temp(24).Attributes.Value),    str2double(comp_temp(26).Attributes.Value),    str2double(comp_temp(28).Attributes.Value); ...
                str2double(comp_temp(30).Attributes.Value),    str2double(comp_temp(32).Attributes.Value),    str2double(comp_temp(34).Attributes.Value); ...
                str2double(comp_temp(36).Attributes.Value),    str2double(comp_temp(38).Attributes.Value),    str2double(comp_temp(40).Attributes.Value); ...
                ];

            surgeline_coeff = [str2double(comp_temp(42).Attributes.Value),    str2double(comp_temp(44).Attributes.Value),    str2double(comp_temp(46).Attributes.Value)];
            chokeline_coeff = [str2double(comp_temp(48).Attributes.Value),    str2double(comp_temp(50).Attributes.Value),    str2double(comp_temp(52).Attributes.Value)];
            efficiencyOfChokeline = str2double(comp_temp(54).Attributes.Value);

            n_speed                 = (length(comp_temp(56).Children)-1)/2;
            n_adiabaticEfficiency   = (length(comp_temp(58).Children)+1)/2;
            speed                   = NaN(1,n_speed);
            adiabaticEfficiency     = NaN(n_adiabaticEfficiency,1);
            adiabaticHead           = NaN(n_adiabaticEfficiency,n_speed);
            volumetricFlowrate      = NaN(n_adiabaticEfficiency,n_speed);

            for ii = 2:n_adiabaticEfficiency
                adiabaticEfficiency(ii) = str2double(comp_temp(58).Children((ii-1)*2).Attributes.Value);
            end

            for ii = 1:n_speed
                speed(ii)                   = str2double(comp_temp(56).Children(ii*2).Children(2).Attributes(2).Value);
                adiabaticHead(1,ii)         = str2double(comp_temp(56).Children(ii*2).Children(4).Attributes(2).Value);
                volumetricFlowrate(1,ii)    = str2double(comp_temp(56).Children(ii*2).Children(6).Attributes(2).Value);

                for jj = 2:n_adiabaticEfficiency
                    volumetricFlowrate(jj,ii) = str2double(comp_temp(58).Children((jj-1)*2).Children(ii*2).Children(6).Attributes(2).Value);
                    adiabaticHead(jj,ii) = str2double(comp_temp(58).Children((jj-1)*2).Children(ii*2).Children(4).Attributes(2).Value);
                end
            end
            volumetricFlowrate(volumetricFlowrate==0) = NaN;
            adiabaticHead(adiabaticHead==0) = NaN;
            
            compressor = [];
            compressor.comp_id = comp_id;
            compressor.A_n = A_n;
            compressor.A_eta_ad = A_eta_ad;
            compressor.surgeline_coeff = surgeline_coeff;
            compressor.chokeline_coeff = chokeline_coeff;
            compressor.efficiencyOfChokeline = efficiencyOfChokeline;
            compressor.speed = speed;
            compressor.adiabaticEfficiency = adiabaticEfficiency;
            compressor.adiabaticHead = adiabaticHead;
            compressor.volumetricFlowrate = volumetricFlowrate;

            

        elseif strcmp(mlStruct(23).Children(i_compressorStation*2).Children(2).Children(i_compressor*2).Name,'pistonCompressor')
            compressor = [];
            compressor.comp_id                      = comp_id;
            compressor.speedMin                     = str2double(comp_temp(2).Attributes(2).Value);
            compressor.speedMax                     = str2double(comp_temp(4).Attributes(2).Value);
            compressor.operatingVolume              = str2double(comp_temp(6).Attributes(2).Value);
            compressor.maximalTorque                = str2double(comp_temp(8).Attributes(2).Value);
            compressor.maximalCompressionRatio      = str2double(comp_temp(10).Attributes.Value);
            compressor.adiabaticEfficiency          = str2double(comp_temp(12).Attributes.Value);
            compressor.additionalReductionVolFlow   = str2double(comp_temp(14).Attributes.Value);
        end

        compressors(i_comp).Value = compressor;
    end
end


%% GasLib-4197 - compressor_1 - turboCompressor
%
% speed:                per_min
% adiabaticHead:        kJ_per_kg
% volumetricFlowrate:   m_cube_per_s
%
% A_n                     = ...
%     [-190.759571322   0.0772865132496  -7.59106748684e-06; ...
%        90.3515687416 -0.0266710526962   3.39112590646e-06; ...
%       -22.2044156634  0.00480988340213 -4.2872113465e-07];
% 
% A_eta_ad                = ...
%      [1.92662677697  -0.000603411239138  4.11618537812e-08; ...
%      -0.0576070740743 0.000275668515201 -2.83343221336e-08; ...
%      -0.25991929629   3.300000599e-05   -5.35440702059e-10];
% 
% surgeline_coeff         = [-75.7999202863 75.0846962322 -6.63021036552];
% chokeline_coeff         = [-10.222850716 7.88471503267 1.36990892472];
% efficiencyOfChokeline   = 0.72;
% 
% speed                   = [4340 5360 5800 6200 6500 6825];
% 
% adiabaticEfficiency     = [ NaN; ... % surgeline
%     0.78; ...
%     0.8 ; ...
%     0.8 ; ...
%     0.78 ; ...
%     0.76 ; ...
%     0.74 ; ...
%     0.72]; % Chokeline
% 
% adiabaticHead           = ...
%     [ 41.6 62.7 74.3 84.7 93.1 101.6; ... % surgeline
%       41.3 63   73.3 83.5 91.7  99.8 ; ...
%       40   61   71.3 80.7 88.7  NaN   ; ...
%       36.7 55.7 65.4 80.7 88.7  NaN   ; ...
%       34.3 51.8 61.2 70.2 78.1  87.3 ; ...
%       32.3 49.3 58.2 65.9 73.8  82.5 ; ...
%       30.8 46.2 54.7 63.1 70    78.1 ; ...
%       30.8 44.9 51.5 58   61.7  71.2]; % Chokeline
% 
% volumetricFlowrate      = ...
%     [ 1.88 2.3  2.6  2.87 3.1  3.35; ... % surgeline
%       1.94 2.52 2.81 3.05 3.3  3.72; ...
%       2.28 2.92 3.25 3.6  3.8  NaN   ; ...
%       2.69 3.49 3.8  3.6  3.8  NaN   ; ...
%       2.9  3.68 4.05 4.32 4.56 4.71; ...
%       3.02 3.82 4.18 4.52 4.73 4.99; ...
%       3.1  3.9  4.28 4.63 4.89 5.1 ; ...
%       3.1  4    4.4  4.8  5.09 5.3 ]; % Chokeline


%%
GN = import_GN('Belgium');
% GN.gasMix = 'H2';
% GN = check_and_init_GN(GN);
GN = rungf(GN);
V_dot_n_ij  = GN.comp.V_dot_n_ij__m3_per_day/(24*60*60);
V_dot_ij    = V_dot_n_ij * GN.gasMixProp.rho_n_avg / GN.bus.rho_i(GN.branch.i_from_bus(GN.comp.i_branch(1)));
h_ad        = GN.comp.Delta_h_S;


%%
clearvars -except compressors mlStruct GN V_dot_n_ij V_dot_ij h_ad
save_figures    = true;
clc

for jj = 1:22%10%9 %[1,3:9]
    compressor = compressors(jj).Value;
    A_n                     = compressor.A_n;
    A_eta_ad                = compressor.A_eta_ad;
    surgeline_coeff         = compressor.surgeline_coeff;
    chokeline_coeff         = compressor.chokeline_coeff;
    efficiencyOfChokeline   = compressor.efficiencyOfChokeline;
    speed                   = compressor.speed;
    adiabaticEfficiency     = compressor.adiabaticEfficiency;
    adiabaticHead           = compressor.adiabaticHead;
    volumetricFlowrate      = compressor.volumetricFlowrate;
    
    n = NaN(size(h_ad));
    
    PlotFontSize = 8;
    figure_position = [1,1,2.86,2];
    h1 = figure('units','inch','position',figure_position);
    hold on
    plot(volumetricFlowrate,adiabaticHead)
    plot(volumetricFlowrate(1,:),adiabaticHead(1,:))
    plot(volumetricFlowrate(end,:),adiabaticHead(end,:))
    if all(~isnan(volumetricFlowrate))
        plot(volumetricFlowrate',adiabaticHead',':k')
    end
    
    xlabel('$\dot{V},/\,\mathrm{\frac{m^3}{s}}$','Interpreter','latex','FontSize',PlotFontSize)
    ylabel('$\Delta h_S,/\,\mathrm{\frac{kWs}{kg}}$','Interpreter','latex','FontSize',PlotFontSize)
    
    % xlim([0 6])
    % xticks(0:6)
    % ylim([20 110])
    % yticks(20:10: 110)
    % ytickformat('%,.0f')
    
    ax1 = gca;
    ax1.TickLabelInterpreter  = 'latex';
    ax1.FontSize = PlotFontSize;
    grid on
    
    if all(A_n(:,3)==0)
        for ii = 1:length(V_dot_ij)
            x = [1 V_dot_ij(ii) V_dot_ij(ii).^2];
            xA_n = x*A_n;
            n(ii) = (h_ad(ii)/1000-xA_n(1))/xA_n(2);
            scatter(V_dot_ij(ii),h_ad(ii)/1000)
        end
    else
        for ii = 1:length(V_dot_ij)
            x = [1 V_dot_ij(ii) V_dot_ij(ii).^2];
            xA_n = x*A_n;
            n(ii) = -xA_n(2)/2/xA_n(3) + sqrt((xA_n(2)/2/xA_n(3))^2-xA_n(1)/xA_n(3)+h_ad(ii)/xA_n(3)/1000);
            scatter(V_dot_ij(ii),h_ad(ii)/1000)
        end
    end
    
    leg = legend(strcat('$',strcat(num2str(speed'),'$')),'Location','eastoutside','Interpreter','latex','FontSize',PlotFontSize);
    title(leg,'$\mathrm{n}\,/\,\mathrm{\frac{1}{s}}$','Interpreter','latex','FontSize',PlotFontSize)
    title(num2str(jj))

    if save_figures
        PATH            = '..\diss_kurth\images\chapter_3\';
        FILENAME        = ['centrifugal_comp_',num2str(jj)];
        exportgraphics(h1, [PATH,FILENAME,'.pdf'])
        exportgraphics(h1, [PATH,FILENAME,'.jpg'])
    end
end
%%

% psi_surgeline   = get_psi_comp(V_dot_n_ij,surgeline_coeff);
% psi_chokeline   = get_psi_comp(V_dot_n_ij,chokeline_coeff);
% psi_speedMin    = get_psi_comp(V_dot_n_ij,surgeline_coeff);
% psi_speedMax    = get_psi_comp(V_dot_n_ij,surgeline_coeff);
% 
% figure
% hold on
% % xi(x,y,A) = x'*A*y
% % x = V_dot_ij(1);
% % X = [1 x x^2];
% V_dot_ij    = 2:0.5:5;
% xi_h_ad     = NaN(length(speed), length(V_dot_ij));
% xi_eta_ad   = NaN(length(speed), length(V_dot_ij));
% for jj = 1:length(V_dot_ij)
%     for ii = 1:length(speed)
%         x = V_dot_ij(jj);
%         X = [1 x x^2];
%         y = speed(ii);
%         Y = [1; y; y^2];
%         A = A_n;
%         xi_h_ad(ii,jj) = X*A*Y;
%         scatter(V_dot_ij(jj), xi_h_ad(ii,jj))
% 
%         x = [1 V_dot_ij(jj) V_dot_ij(jj).^2];
%         xA_n = x*A_n;
%         n(ii) = -xA_n(2)/2/xA_n(3) - sqrt((xA_n(2)/2/xA_n(3))^2-xA_n(1)/xA_n(3)+xi_h_ad(ii,jj)/xA_n(3));
%         scatter(V_dot_ij(ii),h_ad(ii)/1000)
% 
%         A = A_eta_ad;
%         xi_eta_ad(ii,jj) = X*A*Y;
%     end
%     P =xi_h_ad(:,jj)./xi_eta_ad(:,jj).*V_dot_ij(jj);
% 
%     scatter(V_dot_ij(jj), xi_h_ad(xi_eta_ad(:,jj) == max(xi_eta_ad(:,jj)),jj),'d','filled')
%     scatter(V_dot_ij(jj), xi_h_ad(P == min(P),jj),'x')
% 
% end
% 
% plot(volumetricFlowrate,adiabaticHead)
% plot(volumetricFlowrate(1,:),adiabaticHead(1,:))
% plot(volumetricFlowrate(end,:),adiabaticHead(end,:))
% 
% P =xi_h_ad./xi_eta_ad.*V_dot_ij;
% max(P)
% min(P)
% 
 
