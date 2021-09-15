function [amountEleAssembly, sumAssembly, amountEleRecycling, sumRecycling] = calculateElectricityShare(Eco_Efficiency, Param, Phase)
%% Script for calculating the share of electricity for the assmbly and recycling phase

% This is necessary due to the fact that electricity was dealt model intern
% in GaBi and was not extractet separatly in the first run.

% Assumption: Electricity changes direct-proportionally with the dimension of
% a component, in this case the weight

% This script takes the generic vehicle modelled in GaBi as a basis for
% calculation. The electricity-Block was extracted from the intern
% component-level models returning the emissions caused by the electricity
% usage of the production of the components. The amount of electricity for
% each component was extracted manually and will be implemented by
% hard-code for the sake of simplicity.
% The data results from the amount of electricity needed for the component
% of a vehicle devided by the weight of the generic component. This results
% in the amount of electricity per kg / piece of a component and can be
% scaled with the "real" weights in a next step.
%% Data
% Data extracted manually from GaBi and scaled by the mass of the generic
% vehicle
% fix parameter
scaled = struct;
scaled.Cabin = 2.142;
scaled.Suspension = 0.133;
scaled.Frame_Saddle_Clutch_Blank = 0;
scaled.Tires_and_Wheels = 5.911;
scaled.Retarder = 1.706;
scaled.BatteryEV = 363.29;
scaled.BatteryHEV = 363.29;
scaled.BatteryFCEV = 363.29;
scaled.BatteryLeadAcid = 4.72;
scaled.DieselTank = 0;
scaled.ExhaustSys = 0;
scaled.OtherICE = 0;
scaled.OthersEV = 0;
scaled.OthersHEV = 0;
scaled.OthersFCEV = 0;
scaled.PwrEle = 10.19;

% Parameters that vary for each vehicle
switch Param.Fueltype
    case 1
        scaled.EngineICE = 0.240;
        scaled.Transmission = 11.866;
    case 4
        scaled.E_EngineHEV = 4.977;
        scaled.EngineHEV = 2.562;
        scaled.Transmission = 11.866;
    case {7, 12}
        scaled.E_EngineEV = 5.028;
        scaled.Transmission = 4.0344;
    case 13
        scaled.E_EngineFCEV = 5.028;
        scaled.Transmission = 4.0344;
        scaled.H2Tank = 0.015;
        scaled.Stack = 1;
    case 14
        scaled.EngineICE = 0.240;
        scaled.Transmission = 11.866;
        scaled.H2Tank = 0.015;
    otherwise
        warning('in function caclucalteElectricityMix: no switch statement was entered, data may be missed')
end


%Recycling data
recy = struct;
recy.Steel = 1.5;
recy.Copper = 0.995;
recy.Aluminium = 0.228;
recy.Duroplast = 0;
recy.Thermoplast = 3.352;
recy.Rubber = 0;
recy.Glass = 5.9478;
recy.Ceramic = 0; %check this
recy.Wood = 0;
recy.Organic = 0;
recy.Oil = 0;
recy.Paint = 0;
recy.Coolant = 0;
recy.ElectricalScrap = 0;
recy.LiIonBattery = 1.325;
recy.LeadAcidBattery = 33.12; %this accounts for one 45 kg lead acid battery
%% Assembly
if Phase == 1
    amountEleRecycling = 0;
    sumRecycling = 0;
    
    amountEleAssembly = struct;
    
    fnMW = fieldnames(Eco_Efficiency.MatlabWeight);
    for i=1:numel(fnMW)
        amountEleAssembly.(fnMW{i}(3:end)) = Eco_Efficiency.MatlabWeight.(fnMW{i})*scaled.(fnMW{i}(3:end));
    end
    % add Assembly manually
    amountEleAssembly.Assembly = 2703.6;
    
    sumAssembly = sum(struct2array(amountEleAssembly));
end
%% Recycling
if Phase == 2
    amountEleAssembly = 0;
    sumAssembly = 0;
    
    amountEleRecycling = struct;
    fnRecy = fieldnames(Eco_Efficiency.Recycling.Materials);
    for i = 1:numel(fnRecy)
        amountEleRecycling.(fnRecy{i}) = Eco_Efficiency.Recycling.Materials.(fnRecy{i})*recy.(fnRecy{i});
    end
    
    sumRecycling = sum(struct2array(amountEleRecycling));
end


end

