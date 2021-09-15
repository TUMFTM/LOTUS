%% add folders
addpath('Classes');
addpath('Functions');
addpath(genpath('Consumption_simulation'));
addpath(genpath('Optimization'));
addpath('TCO'); 
addpath('Post-processing');
addpath('GaBiTables');
addpath('WeightingTable');

%% Save results?
ifSave = false;

%% Load Vehicle Concepts
results.reference       = load('Results/20210419_Reference.mat');
results.dieselResult    = load('Results/20210419_Diesel.mat');
results.hevResults      = load('Results/20210419_HEV.mat');
results.bevResult       = load('Results/20210419_BEV.mat');
results.fcevResult      = load('Results/20210419_FCEV.mat');
temp = cellstr(fieldnames(results));

%% Set Gabi and Weighting Tables
% These tables were used in the publication.
% In the main file, a different set is used that distinguishes different
% energy sources (PV and wind) for hydrogen and e-diesel production. Thus,
% some names changed and the new sets do not work with this script. The
% intention of using the old ones is to reproduce the content of the paper.
% Feel free to update to newer version.
assemblyPath = "GaBiTables\AssemblyTable20210108.mat";
usePhasePath = "GaBiTables\UsePhaseTable20210113.mat";
recyclingPath = "GaBiTables\RecyclingTable20210108.mat";
weightingPath = "WeightingTable\WeightingTable20210120.mat";

%% Define Scenarios
load('TCO\Scenarios.mat', 'scenarios');

% select Scenario
scenarioSelect = '2030Optimistic';

%% Define cost scenario
helpStruct = load('costStruct_2020_exclTax.mat');
costStruct = helpStruct.costStruct;
% Set Diesel/E Diesel Price
costStruct.TCO.Key_assumptions.Initialvalue('Diesel_price') = scenarios.DieselPrice(scenarioSelect);
costStruct.TCO.Key_assumptions.Initialvalue('Diesel_price_external') = costStruct.TCO.Key_assumptions.Initialvalue('Diesel_price');
% Set Hydrogen Price
costStruct.TCO.Key_assumptions.Initialvalue('Hydrogen_price') = scenarios.HydrogenPrice(scenarioSelect);

costStruct.TCO.Key_assumptions.Initialvalue('Electricity_price') = scenarios.ElectricityPrice(scenarioSelect);


%% Define Diesel Path
dieselPath = scenarios.DieselPath(scenarioSelect);

%% Define Hydrogen Path
hydrogenPath = scenarios.HydrogenPath(scenarioSelect); %'hydrogen from electrolysis Wind' 'hydrogen from electrolysis EU';

%% Define Electricity mix
electricityMix = scenarios.ElectricityMix(scenarioSelect);

%% Output results for Break Down Plots
% set variables for sensitivity
temp2 = {'Reference', '2030Optimistic'};

for i2 = 1:length(temp2)
    clear yOut
    scenarioSelect = temp2{i2};
    % Set cost scenario
    helpStruct = load('costStruct_2020_exclTax.mat');
    costStruct = helpStruct.costStruct;
    % Set Diesel/E Diesel Price
    costStruct.TCO.Key_assumptions.Initialvalue('Diesel_price') = scenarios.DieselPrice(scenarioSelect);
    costStruct.TCO.Key_assumptions.Initialvalue('Diesel_price_external') = costStruct.TCO.Key_assumptions.Initialvalue('Diesel_price');
    % Set Hydrogen Price
    costStruct.TCO.Key_assumptions.Initialvalue('Hydrogen_price') = scenarios.HydrogenPrice(scenarioSelect);
    costStruct.TCO.Key_assumptions.Initialvalue('Electricity_price') = scenarios.ElectricityPrice(scenarioSelect);
    % Define Diesel Path
    dieselPath = scenarios.DieselPath(scenarioSelect);
    % Define Hydrogen Path
    hydrogenPath = scenarios.HydrogenPath(scenarioSelect); %'hydrogen from electrolysis Wind' 'hydrogen from electrolysis EU';
    % Define Electricity mix
    electricityMix = scenarios.ElectricityMix(scenarioSelect);
    for i=1:length(temp)
        results.(temp{i}).Param.VSim.Display = 0;
        results.(temp{i}).Param.VSim.Opt = true;
        results.(temp{i}).Param.GaBiFiles.Assembly = assemblyPath;
        results.(temp{i}).Param.GaBiFiles.UsePhase = usePhasePath;
        results.(temp{i}).Param.GaBiFiles.Recycling = recyclingPath;
        results.(temp{i}).Param.WeightingFiles.File = weightingPath;
        results.(temp{i}).Param.TCO = TCO(1+results.(temp{i}).Param.TCO_Trailer, costStruct, true);
        results.(temp{i}).Param.TCO.Operating_life(1) = 10;
        results.(temp{i}).Param.acquisitionCosts.Bat_VK_Pouch = scenarios.BatteryCosts(scenarioSelect);
        results.(temp{i}).Param.acquisitionCosts.Bat_VK_Cyl = results.(temp{i}).Param.acquisitionCosts.Bat_VK_Pouch;
        results.(temp{i}).Param.acquisitionCosts.KTFC_VK = scenarios.HydrogenTankCosts(scenarioSelect);
%         results.(temp{i}).Param.TCO.Lebensdauer_Batteriepack = 11;
        
        [results.(temp{i}).Results, results.(temp{i}).Param] = VSim_evaluation(results.(temp{i}).Results, results.(temp{i}).Param, 2, results.(temp{i}).Param.dcycle);
        y(1,i) = results.(temp{i}).Param.TCO.Total_costs;
        
        [results.(temp{i}).Eco_Efficiency] = CalculateEcoEff(results.(temp{i}).Param, 10, electricityMix, dieselPath, hydrogenPath);
        %     [results.(temp{i}).Eco_Efficiency] = CalculateEcoEff(results.(temp{i}).Param, 10, temp2{i2}, dieselPath, temp3{i2});
        
        y(2,i) = results.(temp{i}).Eco_Efficiency.Eco_Impact;
        yOut(i,:) = [i, y(1,i), y(2,i)];
        
    end
    
    % Convert to life-cycle phases with vehicles as rows and IC as cols
    vehicleNames = {'Reference', 'Diesel', 'HEV', 'BEV', 'FCEV'};
    for i3=1:length(temp)
        temp3 = [results.(temp{i3}).Eco_Efficiency.Sum.weightedAssembly; results.(temp{i3}).Eco_Efficiency.Sum.weightedUsePhase; results.(temp{i3}).Eco_Efficiency.Sum.weightedRecycling];
        temp3(:,end+1) =  ones(3,1).*results.(temp{i3}).Param.TCO.Total_costs;
        % Calculate acquistion costs
        acqCosts(i3,:) = results.(temp{i3}).Param.TCO.Purchase_price(1);
        % Calculate acquistion costs
        annMilaege(i3,:) = results.(temp{i3}).Param.TCO.Annual_mileage(1);
        if ifSave
        csvwrite(strcat('H:', filesep,'__Diss', filesep,'02_Daten', filesep,'OptiResults', filesep, scenarioSelect, vehicleNames{i3}, '_EcoEff.csv'), temp3)
        run('H:\__Diss\02_Daten\OptiResults\results2tikz.m')
        end
    end
    
    
end



%% Perform Sensitivity for Electricity mix
% select Scenario
scenarioSelect = 'Reference';

% Set variables for senstitivity
temp2 = {'DE', 'EU-28', '2050', 'CN'};
temp3 = {'hydrogen from electrolysis DE', 'hydrogen from electrolysis EU', 'hydrogen from electrolysis Wind', 'hydrogen from electrolysis CN'};

% Remove reference vehicle as its not used for sensitivity
results = rmfield(results, 'reference');
temp = cellstr(fieldnames(results));

for i2 = 1:length(temp2)
clear yOut
for i=1:length(temp)
    results.(temp{i}).Param.VSim.Display = 0;
    results.(temp{i}).Param.VSim.Opt = true;
    results.(temp{i}).Param.GaBiFiles.Assembly = assemblyPath;
    results.(temp{i}).Param.GaBiFiles.UsePhase = usePhasePath;
    results.(temp{i}).Param.GaBiFiles.Recycling = recyclingPath;
    results.(temp{i}).Param.WeightingFiles.File = weightingPath;
    results.(temp{i}).Param.TCO = TCO(1+results.(temp{i}).Param.TCO_Trailer, costStruct, true);
    results.(temp{i}).Param.TCO.Operating_life(1) = 10;
    results.(temp{i}).Param.acquisitionCosts.Bat_VK_Pouch = scenarios.BatteryCosts(scenarioSelect);
    results.(temp{i}).Param.acquisitionCosts.Bat_VK_Cyl = results.(temp{i}).Param.acquisitionCosts.Bat_VK_Pouch;
    results.(temp{i}).Param.acquisitionCosts.KTFC_VK = scenarios.HydrogenTankCosts(scenarioSelect);

    [results.(temp{i}).Results, results.(temp{i}).Param] = VSim_evaluation(results.(temp{i}).Results, results.(temp{i}).Param, 2, results.(temp{i}).Param.dcycle);
    y(1,i) = results.(temp{i}).Param.TCO.Total_costs;
    
    [results.(temp{i}).Eco_Efficiency] = CalculateEcoEff(results.(temp{i}).Param, 10, temp2{i2}, dieselPath, temp3{i2});

    y(2,i) = results.(temp{i}).Eco_Efficiency.Eco_Impact;
    yOut(i,:) = [i, y(1,i), y(2,i)];
end
% Save output
yOut = array2table(yOut, 'VariableNames', {'MetaIdx', 'TCO', 'EEI'}, 'RowNames', {'Diesel', 'HEV', 'BEV', 'FCEV'});
if ifSave
writetable(yOut, strcat('H:', filesep,'__Diss', filesep,'02_Daten', filesep,'Sensitivity', filesep, 'resultsEEI_', temp2{i2}, '.csv'),'WriteRowNames',true)
end
end


%% Perform sensitivity for weighting/normalisation
% select Scenario
scenarioSelect = 'Reference';

% set variables for sensitivity
temp2 = [1 2 10 11];

for i2 = 1:length(temp2)
clear yOut
for i=1:length(temp)
    results.(temp{i}).Param.VSim.Display = 0;
    results.(temp{i}).Param.VSim.Opt = true;
    results.(temp{i}).Param.GaBiFiles.Assembly = assemblyPath;
    results.(temp{i}).Param.GaBiFiles.UsePhase = usePhasePath;
    results.(temp{i}).Param.GaBiFiles.Recycling = recyclingPath;
    results.(temp{i}).Param.WeightingFiles.File = weightingPath;
    results.(temp{i}).Param.TCO = TCO(1+results.(temp{i}).Param.TCO_Trailer, costStruct, true);
    results.(temp{i}).Param.TCO.Operating_life(1) = 10;
    results.(temp{i}).Param.acquisitionCosts.Bat_VK_Pouch = scenarios.BatteryCosts(scenarioSelect);
    results.(temp{i}).Param.acquisitionCosts.Bat_VK_Cyl = results.(temp{i}).Param.acquisitionCosts.Bat_VK_Pouch;
    results.(temp{i}).Param.acquisitionCosts.KTFC_VK = scenarios.HydrogenTankCosts(scenarioSelect);

    [results.(temp{i}).Results, results.(temp{i}).Param] = VSim_evaluation(results.(temp{i}).Results, results.(temp{i}).Param, 2, results.(temp{i}).Param.dcycle);
    y(1,i) = results.(temp{i}).Param.TCO.Total_costs;
    
    [results.(temp{i}).Eco_Efficiency] = CalculateEcoEff(results.(temp{i}).Param, temp2(i2), electricityMix, dieselPath, hydrogenPath);
%     [results.(temp{i}).Eco_Efficiency] = CalculateEcoEff(results.(temp{i}).Param, 10, temp2{i2}, dieselPath, temp3{i2});

    y(2,i) = results.(temp{i}).Eco_Efficiency.Eco_Impact;
    yOut(i,:) = [i, y(1,i), y(2,i)];
end

% Save output
yOut = array2table(yOut, 'VariableNames', {'MetaIdx', 'TCO', 'EEI'}, 'RowNames', {'Diesel', 'HEV', 'BEV', 'FCEV'});
% writetable(yOut, strcat('H:', filesep,'__Diss', filesep,'02_Daten', filesep,'Scenarios', filesep, 'resultsEEI_', temp2{i2}, '.csv'),'WriteRowNames',true)
if ifSave
    writetable(yOut, strcat('H:', filesep,'__Diss', filesep,'02_Daten', filesep,'Sensitivity', filesep, 'resultsEEI_', mat2str(temp2(i2)), '.csv'),'WriteRowNames',true)
end
end


%% Output results for scenario comparison

% set variables for comparison
temp2 = {'Reference', '2030Optimistic'};

% Define two weightings (JRC and JRC w/o RD)
temp4 = [10, 12];

for i3 = 1:length(temp4)
for i2 = 1:length(temp2)
clear yOut
scenarioSelect = temp2{i2};
% Set cost scenario
helpStruct = load('costStruct_2020_exclTax.mat');
costStruct = helpStruct.costStruct;
% Set Diesel/E Diesel Price
costStruct.TCO.Key_assumptions.Initialvalue('Diesel_price') = scenarios.DieselPrice(scenarioSelect);
costStruct.TCO.Key_assumptions.Initialvalue('Diesel_price_external') = costStruct.TCO.Key_assumptions.Initialvalue('Diesel_price');
% Set Hydrogen Price
costStruct.TCO.Key_assumptions.Initialvalue('Hydrogen_price') = scenarios.HydrogenPrice(scenarioSelect);
costStruct.TCO.Key_assumptions.Initialvalue('Electricity_price') = scenarios.ElectricityPrice(scenarioSelect);
% Define Diesel Path
dieselPath = scenarios.DieselPath(scenarioSelect);
% Define Hydrogen Path
hydrogenPath = scenarios.HydrogenPath(scenarioSelect); %'hydrogen from electrolysis Wind' 'hydrogen from electrolysis EU';
% Define Electricity mix
electricityMix = scenarios.ElectricityMix(scenarioSelect);

for i=1:length(temp)
    results.(temp{i}).Param.VSim.Display = 0;
    results.(temp{i}).Param.VSim.Opt = true;
    results.(temp{i}).Param.GaBiFiles.Assembly = assemblyPath;
    results.(temp{i}).Param.GaBiFiles.UsePhase = usePhasePath;
    results.(temp{i}).Param.GaBiFiles.Recycling = recyclingPath;
    results.(temp{i}).Param.WeightingFiles.File = weightingPath;
    results.(temp{i}).Param.TCO = TCO(1+results.(temp{i}).Param.TCO_Trailer, costStruct, true);
    results.(temp{i}).Param.TCO.Operating_life(1) = 10;
    results.(temp{i}).Param.acquisitionCosts.Bat_VK_Pouch = scenarios.BatteryCosts(scenarioSelect);
    results.(temp{i}).Param.acquisitionCosts.Bat_VK_Cyl = results.(temp{i}).Param.acquisitionCosts.Bat_VK_Pouch;
    results.(temp{i}).Param.acquisitionCosts.KTFC_VK = scenarios.HydrogenTankCosts(scenarioSelect);

    [results.(temp{i}).Results, results.(temp{i}).Param] = VSim_evaluation(results.(temp{i}).Results, results.(temp{i}).Param, 2, results.(temp{i}).Param.dcycle);
    y(1,i) = results.(temp{i}).Param.TCO.Total_costs;
    
    [results.(temp{i}).Eco_Efficiency] = CalculateEcoEff(results.(temp{i}).Param, temp4(i3), electricityMix, dieselPath, hydrogenPath);
%     [results.(temp{i}).Eco_Efficiency] = CalculateEcoEff(results.(temp{i}).Param, 10, temp2{i2}, dieselPath, temp3{i2});

    y(2,i) = results.(temp{i}).Eco_Efficiency.Eco_Impact;
    yOut(i,:) = [i, y(1,i), y(2,i)];
end

% Save output
yOut = array2table(yOut, 'VariableNames', {'MetaIdx', 'TCO', 'EEI'}, 'RowNames', {'Diesel', 'HEV', 'BEV', 'FCEV'});
    if ifSave
    writetable(yOut, strcat('H:', filesep,'__Diss', filesep,'02_Daten', filesep,'Scenarios', filesep, 'resultsEEI_Scenario', scenarioSelect,'_', mat2str(temp4(i3)), '.csv'),'WriteRowNames',true)
    end
end
end




