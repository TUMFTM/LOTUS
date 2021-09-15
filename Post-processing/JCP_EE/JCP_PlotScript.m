% dieselResult = load('H:\For Cluster\data\wolff\Diesel_Opti\2020-07-21_EcoEff_Diesel_Opti_49_512.mat');
% bevResult = load('H:\For Cluster\data\wolff\BEV_Opti\2020-07-28_EcoEff_BEV_Opti_100_512.mat');
% hevResult = load('H:\For Cluster\data\wolff\HEV_Opti\2020-08-19_EcoEff_HEV_Opti_5_512_10.mat');
% FCEVresult = load('H:\For Cluster\data\wolff\FCEV_Opti\2020-08-19_EcoEff_FCEV_Opti_5_160_9.mat');
% Results with updated costStruct
% dieselResult = load('C:\LOTUS\Results\CIRP LCE\OptimizationResults\2021-01-14_1008_EcoEff_1_512.mat');
% bevResult = load('C:\LOTUS\Results\CIRP LCE\OptimizationResults\2021-01-14_1032_EcoEff_7_512.mat');
% hevResult = load('C:\Truck Simulation\Results\CIRP LCE\OptimizationResults\2021-01-14_1021_EcoEff_4_512.mat');
% fcevResult = load('C:\Truck Simulation\Results\CIRP LCE\OptimizationResults\2021-01-14_1046_EcoEff_13_160.mat');
% Results with updated battery recycling costs
dieselResult = load('Post-processing\JCP_EE\Results\OptimizationResults\2021-05-04_1259_EcoEff_1_512.mat');
bevResult = load('Post-processing\JCP_EE\Results\OptimizationResults\2021-05-07_0707_EcoEff_7_520.mat');
hevResult = load('Post-processing\JCP_EE\Results\OptimizationResults\2021-05-04_1311_EcoEff_4_512.mat');
fcevResult = load('Post-processing\JCP_EE\Results\OptimizationResults\2021-05-07_0723_EcoEff_13_160.mat');
hiceResult = load('Post-processing\JCP_EE\Results\OptimizationResults\2021-05-21_0931_EcoEff_14_520.mat');


pop     = dieselResult.result.opt.popsize;
maxGen  = dieselResult.result.opt.maxGen;
numObj  = length(dieselResult.result.pops(1).obj);

objDiesel     = dieselResult.y;% vertcat(dieselResult.result.pops(maxGen,:).obj);
objBEV     = bevResult.y; %vertcat(bevResult.result.pops(maxGen,:).obj);
objHEV     = hevResult.y; %vertcat(hevResult.result.pops(end,:).obj);
objFCEV = fcevResult.y; % (FCEVresult.result.pops(end,:).obj);
objHICE = hiceResult.y;



objDiesel(:,3) = -objDiesel(:,3);
objDiesel(:,4) = 1:length(objDiesel);
objDiesel = sortrows(objDiesel, 1);

objBEV(:,3) = -objBEV(:,3);
objBEV(:,4) = 1:length(objBEV);
objBEV = sortrows(objBEV, 1);

objHEV(:,3) = -objHEV(:,3);
objHEV(:,4) = 1:length(objHEV);
objHEV = sortrows(objHEV, 1);

objFCEV(:,3) = -objFCEV(:,3);
objFCEV(:,4) = 1:length(objFCEV);
objFCEV = sortrows(objFCEV, 1);

objHICE(:,3) = -objHICE(:,3);
objHICE(:,4) = 1:length(objHICE);
objHICE = sortrows(objHICE, 1);


%%


fprintf('%.4f ', round(dieselResult.result.pops(end,objDiesel(1,4)).var,4))
fprintf('\n')
fprintf('%.4f ', round(bevResult.result.pops(end,objBEV(1,4)).var,4))
fprintf('\n')
fprintf('%.4f ', round(hevResult.result.pops(end,objHEV(1,4)).var,4))
fprintf('\n')
fprintf('%.4f ', round(fcevResult.result.pops(end,objFCEV(1,4)).var,4))
fprintf('\n')
fprintf('%.4f ', round(hiceResult.result.pops(end,objHICE(1,4)).var,4))
fprintf('\n')


%%
colorVec = tumColors;



obj3_min = min(objDiesel(:,3));
obj3_max = max(objBEV(:,3));
obj3_max = max(objFCEV(:,3));

temp = linspace(0, 1, 15);

colorMapBlue = colorVec.accent.LightBlue + (ones(3,1).*temp)'.*(colorVec.secondary.DarkBlue - colorVec.accent.LightBlue);



figure

hold on

scatter(objDiesel(:,1), objDiesel(:,2), 50, objDiesel(:,3), 'o', 'filled')
scatter(objBEV(:,1), objBEV(:,2), 50, objBEV(:,3), 's', 'filled')
scatter(objHEV(:,1), objHEV(:,2), 50, objHEV(:,3), '^', 'filled')
scatter(objFCEV(:,1), objFCEV(:,2), 50, objFCEV(:,3), 'd', 'filled')
%plot(164418, 4.4604e-06, 'LineStyle', 'none', 'LineWidth', 2, 'Marker','o','Color', colorVec.accent.Orange)



c = colorbar;
ax1 = gca;
colormap(ax1, colorMapBlue)
set(ax1, 'CLim')%, [obj3_min, obj3_max], 'XLim', [0, 2e5], 'YLim', [0, 5e-6]);
%ax1.XAxis.Exponent = 3;
xlabel(sprintf('Betriebskosten in %c/a', char(8364)))
ylabel('Eco-Impact Index')
c.Label.String = 'Reststeigfähigkeit in %';
%ylim([0; 10e-6])
c.Box = 'off';
box on
legend({'Diesel', 'BEV', 'HEV', 'FCEV', 'Reference'}, 'Location', 'SW')
legend('boxoff')
grid on

%% Some more post processing

for i=1:hevResult.result.opt.popsize
    objectives(i,1:3) = hevResult.result.pops(end,i).obj;
end
objectives(:,4) = 1:length(objectives);
sortrows(objectives,2);

round(hevResult.result.pops(end, 2).var, 4)
num2str(ans,'%.4f');

%%

m = zeros(1,size(indData,2));
t = zeros(1,size(indData,2));

for i1=1:size(indData,2)
    if max(indData(:,i1)) == 100 || (max(indData(:,i1)) - 100) <= 5
        if i1==5% || i1==15
            m(i1) = 1/(100-min(indData(:,i1)));
            t(i1) = 4 - min(indData(:,i1)) * 1 / (100-min(indData(:,i1)));
        else
            m(i1) = 4/(100-min(indData(:,i1)));
            t(i1) = 1 - min(indData(:,i1)) * 4 / (100-min(indData(:,i1)));
        end
    else
        if i1==5
            m(i1) = 1/(100-min(indData(:,i1)));
            t(i1) = 4 - min(indData(:,i1)) * 1 / (100-min(indData(:,i1)));
        else
            m(i1) = 5/(max(indData(:,i1))-100);
            t(i1) = 10 - max(indData(:,i1))*5/(max(indData(:,i1))-100);
            
        end
    end
        
        dataOut(:,i1) = m(i1)*indData(:,i1) + t(i1);
        
end


    
%% Sensitivity for elecricity mix

results.reference       = load('Results/CIRP LCE/20200821_Diesel_Reference.mat');
results.dieselResult    = load('Results/CIRP LCE/20200821_Diesel_Optimization.mat');
results.hevResults      = load('Results/CIRP LCE/20200821_PHEV_Optimization.mat');
results.bevResult       = load('Results/CIRP LCE/20200821_BEV_Optimization.mat');
results.fcevResult      = load('Results/CIRP LCE/20200821_FCEV_Optimization_SOC_Start_1.mat');

temp = cellstr(fieldnames(results));
temp2 = ["2050"; "DE"; "CN"; "EU-28"];

for i=1:length(temp)
    for i2=1:length(temp2)
    [Eco_Efficiency] = CalculateEcoEff(results.(temp{i}).Param, 10, temp2(i2), 'UsePhase Diesel', 'hydrogen from smr');
    y(1,i,i2)  = i; 
    y(2,i,i2) = Eco_Efficiency.Eco_Impact;
     y(3,i,i2) = Eco_Efficiency.Sum.Impact_Assembly;
     y(4,i,i2) = Eco_Efficiency.Sum.Impact_UsePhase;
     y(5,i,i2) = Eco_Efficiency.Sum.Impact_Recycling;
    end
end

resultsEEI = squeeze(y(2,:,:));

resultsTotal = [repmat([1:length(temp)], 1,length(temp2)); reshape(squeeze(y(2,:,:)), 1,length(temp2)*length(temp))];

scatter(resultsTotal(1,:), resultsTotal(2,:))



%% Sensitivity for weighting

results.reference       = load('Post-processing/JCP_EE/Results/20210419_Reference.mat');
results.dieselResult    = load('Post-processing/JCP_EE/Results/20210419_Diesel.mat');
results.hevResults      = load('Post-processing/JCP_EE/Results/20210419_HEV.mat');
results.bevResult       = load('Post-processing/JCP_EE/Results/20210419_BEV.mat');
results.fcevResult      = load('Post-processing/JCP_EE/Results/20210419_FCEV.mat');

temp = cellstr(fieldnames(results));
temp2 = [1 2 9 10 11];

for i=1:length(temp)
    for i2=1:length(temp2)
    [Eco_Efficiency] = CalculateEcoEff(results.(temp{i}).Param, temp2(i2), 'EU-28', 'UsePhase Diesel', 'hydrogen from smr');
    y(1,i,i2)  = i; 
    y(2,i,i2) = Eco_Efficiency.Eco_Impact;
     y(3,i,i2) = Eco_Efficiency.Sum.Impact_Assembly;
     y(4,i,i2) = Eco_Efficiency.Sum.Impact_UsePhase;
     y(5,i,i2) = Eco_Efficiency.Sum.Impact_Recycling;
     %csvwrite(strcat('H:\07_Veroeffentlichung\Paper_CIRP_LCE\Data\resultsEEI_Sens_',sprintf('%i.csv',temp2(i2))), squeeze(y(1:2,:,i2))')
    end
end

resultsEEI = squeeze(y(2,:,:));

resultsTotal = [repmat([1:length(temp)], 1,length(temp2)); reshape(squeeze(y(2,:,:)), 1,length(temp2)*length(temp))];

scatter(resultsTotal(1,:), resultsTotal(2,:))

% csvwrite('H:\07_Veroeffentlichung\Paper_CIRP_LCE\Data\resultsEEI_Sens.csv', resultsEEI)
% csvwrite('H:\07_Veroeffentlichung\Paper_CIRP_LCE\Data\resultsEEI_Sens.csv', resultsTotal)


%% Plot sensitivity for presentation

sens.EL.EU = csvread('H:\07_Veroeffentlichung\Paper_CIRP_LCE\Data\resultsEEI_Sens_EU-28.csv');
sens.EL.DE = csvread('H:\07_Veroeffentlichung\Paper_CIRP_LCE\Data\resultsEEI_Sens_DE.csv');
sens.EL.CN = csvread('H:\07_Veroeffentlichung\Paper_CIRP_LCE\Data\resultsEEI_Sens_CN.csv');
sens.EL.renewable = csvread('H:\07_Veroeffentlichung\Paper_CIRP_LCE\Data\resultsEEI_Sens_2050.csv');

sens.Weight.JRC = csvread('H:\07_Veroeffentlichung\Paper_CIRP_LCE\Data\resultsEEI_Sens_9.csv');
sens.Weight.JRCwoLU = csvread('H:\07_Veroeffentlichung\Paper_CIRP_LCE\Data\resultsEEI_Sens_10.csv');
sens.Weight.Castellani = csvread('H:\07_Veroeffentlichung\Paper_CIRP_LCE\Data\resultsEEI_Sens_1.csv');
sens.Weight.CastellaniJRC = csvread('H:\07_Veroeffentlichung\Paper_CIRP_LCE\Data\resultsEEI_Sens_11.csv');

colorOrder = [colorVec.secondary.DarkBlue; colorVec.accent.Orange; colorVec.secondary.LightBlue; colorVec.primary.Blue];
markerOrder = ['+'; 'o'; '^'; 'x'];
legendStr = {'EU-28', 'Deutschland', 'China', 'EU 2050'; 'JRC', 'JRC o. Land-Use', 'Castellani et al.', 'Castellani m. JRC Norm.'}

figure(1)
hold on

figure(2)
hold on


templist = cellstr(fieldnames(sens.EL));

templist2 = cellstr(fieldnames(sens.Weight));

for i=1:size(templist, 1)
figure(1)

plot(sens.EL.(templist{i})(:,1), sens.EL.(templist{i})(:,2), 'LineStyle', 'none', 'LineWidth', 2, 'Marker',markerOrder(i), 'MarkerSize', 10,'Color', colorOrder(i,:))

figure(2)
plot(sens.Weight.(templist2{i})(:,1), sens.Weight.(templist2{i})(:,2), 'LineStyle', 'none', 'LineWidth', 2, 'Marker',markerOrder(i), 'MarkerSize', 10,'Color', colorOrder(i,:))


end


for i=1:2
figure(i)
ax1 = gca;
ax1.YAxis.Exponent = -6;
ylabel('Eco-Impact Index')
% ylim([0; 5e-6])
xlim([0.5 5.5])
box on
xticks(1:5)
xticklabels({'Reference', 'Diesel', 'HEV', 'BEV', 'FCEV'})

legend(legendStr{i,:}, 'Location', 'NW')

legend('boxoff')
grid on
end