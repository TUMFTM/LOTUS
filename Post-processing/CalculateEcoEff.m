%% Calculate Eco-Efficiency
function [ Eco_Efficiency ] = CalculateEcoEff(Param, indx, ElectricityType, DieselType, HydrogenType)

% The following will be separeted into three parts for the assembly,
% use-phase and recycling respectivly.

% All necessary data is stored in the Param-Struct, the Gabi- and the
% WeightingTables

% Param is the vehicle configuration.
% indx refers to the weighting and normalization set. Available sets are:
% 	1	CastellaniEtAl_2016WFsA
% 	2	CastellaniEtAl_2016WFsB
% 	3	EDIP2003_StranddorfEtAl__2005_
% 	4	TuomistoEtAl_2012
% 	5	Bj_rn_HauschildEuropean2015
% 	6	Bj_rn_HauschildGlobal2015
% 	7	Ponsioen_Goedkoop2016
% 	8	HubbesEtAl_2012
% 	9	Recommended EF Weighting
% 	10	Recommended EF Weightign without landuse and combined resource depletion
% 	11	Castellani with EU Norm
%   12	Recommended EF Weightign without landuse and resource depletion

% ElectricityType sets the electricity source and/or mix defined as string.
% Available are:  
%     "UsePhase Diesel"         Conventional Diesel
%     "UsePhase E-Fuel PV"      E-Diesel with photovoltaic
%     "UsePhase E-Fuel Wind"    E-Diesel with Wind Energy
% 
% DieselType switches between conventional, fossil diesel and synthetic 
% diesel produced via Fischer-Tropsch all defined as string. Available are:
%     "CN"        China 2019
%     "UCTE"      UCTE (Europe) Mix
%     "DE"        German mix 2019
%     "2050"      Forecast Europe 2050
%     "EU-28"     Europe EU-28, 2019
%     The following are scenarios for a German mix from DENA Integrated 
%     Energy Transition (2018) [2]:
%     "RF15"      Reference, year 2015
%     "RF30"      Reference, year 2030
%     "RF50"      Reference, year 2050
%     "E8015"     Electrification 80% Fulfillment of Paris agreement, 2015
%     "E8030"     Electrification 80% Fulfillment of Paris agreement, 2030
%     "E8050"     Electrification 80% Fulfillment of Paris agreement, 2050
%     "E9515"     Electrification 95% Fulfillment of Paris agreement, 2015
%     "E9530"     Electrification 95% Fulfillment of Paris agreement, 2030
%     "E9550"     Electrification 95% Fulfillment of Paris agreement, 2050
%     "TM8015"    Technology mix, 80% Fulfillment of Paris agreement, 2015
%     "TM8030"    Technology mix, 80% Fulfillment of Paris agreement, 2030
%     "TM8095"    Technology mix, 80% Fulfillment of Paris agreement, 2050
%     "TM9515"    Technology mix, 95% Fulfillment of Paris agreement, 2015
%     "TM9530"    Technology mix, 95% Fulfillment of Paris agreement, 2030
%     "TM9550"    Technology mix, 95% Fulfillment of Paris agreement, 2050

% HydrogenType sets the source of hydrogen and, for electrolysis, the
% different energy sources all defined as string. Available are:
%     "hydrogen from electrolysis"    
%     "hydrogen from pv no loss"  
%     "hydrogen from pv with loss"    
%     "hydrogen from wind no loss"    
%     "hydrogen from wind with loss"  
%     "hydrogen from smr"             

% Note: Matlabs "Gearbox" is related to "Transmission". Cleaning this up is
% a task for another day.
% Source:
% [1]: https://www.isi.fraunhofer.de/content/dam/isi/dokumente/cce/2017/4-346-17_Gnann.pdf
% [2]: https://www.dena.de/fileadmin/dena/Dokumente/Pdf/9261_dena-Leitstudie_Integrierte_Energiewende_lang.pdf


%% Define weights of the GaBi Elements
% The weights can be imported automatically later, but for now they will be
% hard-coded. The values refer to the weights which are used in GaBi, that
% match up with the LCI values from several excel sheets.

%check for existing values and delete them
% if isfield(Eco_Efficiency,'MatlabWeight')
%     Eco_Efficiency = rmfield(Eco_Efficiency, 'MatlabWeight');
% end

%% select electricity type
Eco_Efficiency.ElectricityType = ElectricityType;
%   Eco_Efficiency.ElectricityType = "2050";
%    Eco_Efficiency.ElectricityType = "DE";
%   Eco_Efficiency.ElectricityType = "CN";
%   Eco_Efficiency.ElectricityType = "UCTE";
%   Eco_Efficiency.ElectricityType = "EU-28";
%% select Diesel Type
Eco_Efficiency.DieselType = DieselType; % possible: 'Use Phase Diesel' or 'Use Phase E Diesel'

%% select hydrogen type
Eco_Efficiency.HydrogenType = HydrogenType; %possible: 'hydrogen from electrolysis Wind', 'hydrogen from electrolysis EU', or 'SMR hydrogen'



% parts scaling per piece
Eco_Efficiency.MatlabWeight.m_Cabin = 1386.68;
Eco_Efficiency.MatlabWeight.m_Suspension = 1600;
Eco_Efficiency.MatlabWeight.m_Frame_Saddle_Clutch_Blank = 854; %"+"-sign is not accepted by matlab as it results in a parsing error
Eco_Efficiency.MatlabWeight.m_Tires_and_Wheels = 94.114; %ONE wheel
Eco_Efficiency.MatlabWeight.m_Retarder = 82;

switch Param.Fueltype
    
    case {7, 12}
        Eco_Efficiency.MatlabWeight.m_Transmission = Param.weights.m_Gearbox;
        %Eco_Efficiency.MatlabWeight.m_Coolant = 54.34;
        Eco_Efficiency.MatlabWeight.m_BatteryEV = Param.weights.m_Battery * (1+floor(Param.TCO.Operating_life(1)/Param.TCO.Lebensdauer_Batteriepack));
        Eco_Efficiency.MatlabWeight.m_PwrEle = Param.weights.m_PwrElectr;
        Eco_Efficiency.MatlabWeight.m_E_EngineEV = Param.weights.m_EM;
        Eco_Efficiency.MatlabWeight.m_OthersEV = 897.2600; % includes oil but motor oil and coolants
        
    case {1}
        Eco_Efficiency.MatlabWeight.m_Transmission = Param.weights.m_Gearbox;
        Eco_Efficiency.MatlabWeight.m_ExhaustSys = Param.weights.m_Exhaust;
        Eco_Efficiency.MatlabWeight.m_EngineICE = Param.weights.m_Engine;
        Eco_Efficiency.MatlabWeight.m_DieselTank = Param.weights.m_tank_system;
        %Eco_Efficiency.MatlabWeight.m_Coolant = 54.34;
        %Eco_Efficiency.MatlabWeight.m_OilMotor = 36.022;
        Eco_Efficiency.MatlabWeight.m_OtherICE = 771.2380;
        Eco_Efficiency.MatlabWeight.m_BatteryLeadAcid = 90;
        
    case 4
        Eco_Efficiency.MatlabWeight.m_Transmission = Param.weights.m_Gearbox;
        Eco_Efficiency.MatlabWeight.m_ExhaustSys = Param.weights.m_Exhaust;
        Eco_Efficiency.MatlabWeight.m_EngineHEV = Param.weights.m_Engine;
        Eco_Efficiency.MatlabWeight.m_DieselTank = Param.weights.m_tank_system;
        %Eco_Efficiency.MatlabWeight.m_Coolant = 54.34;
        %Eco_Efficiency.MatlabWeight.m_OilMotor = 36.022;
        Eco_Efficiency.MatlabWeight.m_OthersHEV = 771.2380;
        Eco_Efficiency.MatlabWeight.m_BatteryHEV = Param.weights.m_Battery * (1+floor(Param.TCO.Operating_life(1)/Param.TCO.Lebensdauer_Batteriepack));
        Eco_Efficiency.MatlabWeight.m_BatteryLeadAcid = 90;
        Eco_Efficiency.MatlabWeight.m_PwrEle = Param.weights.m_PwrElectr;
        Eco_Efficiency.MatlabWeight.m_E_EngineHEV = Param.weights.m_EM;
        
    case 13
        Eco_Efficiency.MatlabWeight.m_Transmission = Param.weights.m_Gearbox;
        %Eco_Efficiency.MatlabWeight.m_Coolant = 54.34;
        Eco_Efficiency.MatlabWeight.m_BatteryFCEV = Param.weights.m_Battery * (1+floor(Param.TCO.Operating_life(1)/Param.TCO.Lebensdauer_Batteriepack));
        Eco_Efficiency.MatlabWeight.m_H2Tank = Param.weights.m_tank_system;
        Eco_Efficiency.MatlabWeight.m_Stack = Param.weights.m_Stack;
        Eco_Efficiency.MatlabWeight.m_PwrEle = Param.weights.m_PwrElectr;
        Eco_Efficiency.MatlabWeight.m_E_EngineFCEV = Param.weights.m_EM;
        Eco_Efficiency.MatlabWeight.m_OthersFCEV = 897.2600; % assumption same as EV - need to checked by time.
        
    case 14
        Eco_Efficiency.MatlabWeight.m_Transmission = Param.weights.m_Gearbox;
        Eco_Efficiency.MatlabWeight.m_ExhaustSys = Param.weights.m_Exhaust;
        Eco_Efficiency.MatlabWeight.m_EngineICE = Param.weights.m_Engine;
        Eco_Efficiency.MatlabWeight.m_H2Tank = Param.weights.m_tank_system;
        %Eco_Efficiency.MatlabWeight.m_Coolant = 54.34;
        %Eco_Efficiency.MatlabWeight.m_OilMotor = 36.022;
        Eco_Efficiency.MatlabWeight.m_OtherICE = 771.2380;
        Eco_Efficiency.MatlabWeight.m_BatteryLeadAcid = 90;
end



%% Get data from Matlab Simulation

Matlab_weight_list = Param.weights;

%% Set up GabiTable
%  Aim is to only set up Tables for the components required to calculate
%  the Environmental Impact for this certain vehicle.
list = ([]);
fn=fieldnames(Matlab_weight_list);

%get rid of all zero entries in the struct
for k=1:numel(fn)
    if Matlab_weight_list.(fn{k}) ~= 0
        list.(fn{k}) = Matlab_weight_list.(fn{k});
        %list = setfield(list,string(fn(k)),weight_list.(fn{k}));
    end
end

%for the basic parts:
% m_Ref = 7320;

% m_Ref = Param.weights.m_Base;
% m_Frame = m_Ref*0.05;
% m_Wheels = m_Ref*0.09;      % fit for T&W
% m_Cab = m_Ref*0.19;         % fit for Cabin
% m_Coupling = m_Ref*0.03;    % Part of Suspension
% m_Chassis = m_Ref*0.2;      % Part of Suspension
% m_Others = m_Ref*0.13;

%name_buff = "";
%name_buff = string(Param.Vehicle);


% this can be solved more elegant for sure..
switch Param.Fueltype
    case 14
        name_buff = "HICE";
    case {7, 12}
        name_buff = "EV";
    case 4
        name_buff = "HEV";
    case 13
        name_buff = "FCEV";
    case 1
        name_buff = "ICE";
end

%create GaBiTables for base-parts
% name_buff selects the vehicle-type, the mass is passed for weighting
% purpose
Eco_Efficiency.GaBiTables.gtCabin             =      GaBiTable("Cabin",name_buff,Eco_Efficiency.MatlabWeight.m_Cabin,0,0,Param.GaBiFiles.Assembly);
Eco_Efficiency.GaBiTables.gtTiresandWheels    =      GaBiTable("Tires and wheels",name_buff, Eco_Efficiency.MatlabWeight.m_Tires_and_Wheels,0,0,Param.GaBiFiles.Assembly);
Eco_Efficiency.GaBiTables.gtSuspension        =      GaBiTable("Suspension", name_buff, Eco_Efficiency.MatlabWeight.m_Suspension,0,0,Param.GaBiFiles.Assembly);
Eco_Efficiency.GaBiTables.gtFrame             =      GaBiTable("Frame+Saddle Clutch+Blanks", name_buff, Eco_Efficiency.MatlabWeight.m_Frame_Saddle_Clutch_Blank,0,0,Param.GaBiFiles.Assembly);

% Additional Assembly Steps all scaled by 1, but transportation
% scale intern transportation emissions down to 1tkm, then scale by weight
Eco_Efficiency.Transportation = 100 * Param.weights.m_Total / 1000;

Eco_Efficiency.GaBiTables.gtAsssemblyTransport =      GaBiTable("RER: transport, lorry 16-32t, EURO5", name_buff, Eco_Efficiency.Transportation, 0, 0, Param.GaBiFiles.Assembly);

[Eco_Efficiency.Assembly.ElectricityShare, Eco_Efficiency.Assembly.ElectricityTotal,~,~] = calculateElectricityShare(Eco_Efficiency,Param,1);


assemblyString = strcat(name_buff," Truck Assembly <e-ep>");
%Eco_Efficiency.GaBiTables.gtAsssembly         =      GaBiTable(assemblyString, name_buff, Eco_Efficiency.Assembly.ElectricityTotal/2703.6, 0, 0, Param.GaBiFiles.Assembly);
%Eco_Efficiency.GaBiTables.gtBatteryElAl       =     GaBiTable(Eco_Efficiency.ElectricityType,"Electricity",Eco_Efficiency.Assembly.ElectricityShare.BatteryEV,0,0,Param.GaBiFiles.UsePhase);
Eco_Efficiency.GaBiTables.gtAsssembly         =     GaBiTable(Eco_Efficiency.ElectricityType,"Electricity",Eco_Efficiency.Assembly.ElectricityTotal,0,0,Param.GaBiFiles.UsePhase);
if  ~strcmp(name_buff,"FCEV")
Eco_Efficiency.GaBiTables.gTAssemblyTapWater  =      GaBiTable("RER: tap water, at user", name_buff, 1, 0, 0, Param.GaBiFiles.Assembly);
Eco_Efficiency.GaBiTables.gtAsssemblyUPWater  =      GaBiTable("GLO: water, ultrapure, at plant", name_buff, 1, 0, 0, Param.GaBiFiles.Assembly);
end

if strcmp(name_buff,"FCEV")
    Eco_Efficiency.GaBiTables.gtAsssemblyHeat     =      GaBiTable("RER: natural gas, burned in industrial furnace low-NOx >100kW", name_buff, 1, 0, 0, Param.GaBiFiles.Assembly);
else
    Eco_Efficiency.GaBiTables.gtAsssemblyHeat     =      GaBiTable("RER: heat, natural gas, at industrial furnace low-NOx >100kW", name_buff, 1, 0, 0, Param.GaBiFiles.Assembly);
end



switch Param.Fueltype
    
    case {7, 12}
        Eco_Efficiency.GaBiTables.gtBatteryElAl       =     GaBiTable(Eco_Efficiency.ElectricityType,"Electricity",Eco_Efficiency.Assembly.ElectricityShare.BatteryEV,0,0,Param.GaBiFiles.UsePhase);
        Eco_Efficiency.GaBiTables.gtAsssembly         =     GaBiTable(Eco_Efficiency.ElectricityType,"Electricity",Eco_Efficiency.Assembly.ElectricityTotal-Eco_Efficiency.Assembly.ElectricityShare.BatteryEV,0,0,Param.GaBiFiles.UsePhase);
        Eco_Efficiency.GaBiTables.gtTransmission = GaBiTable("Transmission",name_buff,Eco_Efficiency.MatlabWeight.m_Transmission,0,0,Param.GaBiFiles.Assembly);
        %gtCoolandandOil = GaBiTable("",name_buff,m_CoolantandOil);
        %maybe part of others. need to be checked
        Eco_Efficiency.GaBiTables.gtBatteryEV = GaBiTable("Battery Dai [1000kWh]",name_buff,Eco_Efficiency.MatlabWeight.m_BatteryEV,0,0,Param.GaBiFiles.Assembly);
        Eco_Efficiency.GaBiTables.gtPwrEle = GaBiTable("Power el.",name_buff,Eco_Efficiency.MatlabWeight.m_PwrEle,0,0,Param.GaBiFiles.Assembly);
        Eco_Efficiency.GaBiTables.gtE_EngineEV = GaBiTable("E-Engine EV",name_buff,Eco_Efficiency.MatlabWeight.m_E_EngineEV,0,0,Param.GaBiFiles.Assembly);
        Eco_Efficiency.GaBiTables.gtOthersEV = GaBiTable("Others EV",name_buff,Eco_Efficiency.MatlabWeight.m_OthersEV,0,0,Param.GaBiFiles.Assembly);
        
    case 1
        Eco_Efficiency.GaBiTables.gtTransmission = GaBiTable("Transmission", name_buff, Eco_Efficiency.MatlabWeight.m_Transmission,0,0,Param.GaBiFiles.Assembly);
        Eco_Efficiency.GaBiTables.gtExhaustSys = GaBiTable("Exhaust system", name_buff,Eco_Efficiency.MatlabWeight.m_ExhaustSys,0,0,Param.GaBiFiles.Assembly);
        Eco_Efficiency.GaBiTables.gtEngineICE = GaBiTable("Engine", name_buff, Eco_Efficiency.MatlabWeight.m_EngineICE,0,0,Param.GaBiFiles.Assembly);
        Eco_Efficiency.GaBiTables.gtDieselTank = GaBiTable("Diesel Tank", name_buff, Eco_Efficiency.MatlabWeight.m_DieselTank,0,0,Param.GaBiFiles.Assembly);
        Eco_Efficiency.GaBiTables.gtOthersICE = GaBiTable("Others ICE", name_buff, Eco_Efficiency.MatlabWeight.m_OtherICE,0,0,Param.GaBiFiles.Assembly);
        Eco_Efficiency.GaBiTables.gtBatteryLeadAcid = GaBiTable("Battery Lead Acid", name_buff, Eco_Efficiency.MatlabWeight.m_BatteryLeadAcid,0,0,Param.GaBiFiles.Assembly);
        
    case 4
        Eco_Efficiency.GaBiTables.gtBatteryElAl       =     GaBiTable(Eco_Efficiency.ElectricityType,"Electricity",Eco_Efficiency.Assembly.ElectricityShare.BatteryHEV,0,0,Param.GaBiFiles.UsePhase);
        Eco_Efficiency.GaBiTables.gtAsssembly         =     GaBiTable(Eco_Efficiency.ElectricityType,"Electricity",Eco_Efficiency.Assembly.ElectricityTotal-Eco_Efficiency.Assembly.ElectricityShare.BatteryHEV,0,0,Param.GaBiFiles.UsePhase);
        Eco_Efficiency.GaBiTables.gtTransmission = GaBiTable("Transmission", name_buff, Eco_Efficiency.MatlabWeight.m_Transmission,0,0,Param.GaBiFiles.Assembly);
        Eco_Efficiency.GaBiTables.gtExhaustSysHEV = GaBiTable("Exhaust system HEV", name_buff,Eco_Efficiency.MatlabWeight.m_ExhaustSys,0,0,Param.GaBiFiles.Assembly);
        Eco_Efficiency.GaBiTables.gtEngineHEV = GaBiTable("Engine HEV", name_buff, Eco_Efficiency.MatlabWeight.m_EngineHEV,0,0,Param.GaBiFiles.Assembly);
        Eco_Efficiency.GaBiTables.gtDieselTank = GaBiTable("Diesel Tank", name_buff, Eco_Efficiency.MatlabWeight.m_DieselTank,0,0,Param.GaBiFiles.Assembly);
        Eco_Efficiency.GaBiTables.gtOthersHEV = GaBiTable("Others ICE", name_buff, Eco_Efficiency.MatlabWeight.m_OthersHEV,0,0,Param.GaBiFiles.Assembly);
        Eco_Efficiency.GaBiTables.gtBatteryLeadAcid = GaBiTable("Battery Lead Acid", name_buff, Eco_Efficiency.MatlabWeight.m_BatteryLeadAcid,0,0,Param.GaBiFiles.Assembly);
        Eco_Efficiency.GaBiTables.gtBatteryHEV = GaBiTable("Battery Dai [1000kWh]",name_buff, Eco_Efficiency.MatlabWeight.m_BatteryHEV,0,0,Param.GaBiFiles.Assembly);
        Eco_Efficiency.GaBiTables.gtPwrEle = GaBiTable("Power el.",name_buff,Eco_Efficiency.MatlabWeight.m_PwrEle,0,0,Param.GaBiFiles.Assembly);
        Eco_Efficiency.GaBiTables.gtE_EngineHEV = GaBiTable("E-Engine EV", name_buff, Eco_Efficiency.MatlabWeight.m_E_EngineHEV,0,0,Param.GaBiFiles.Assembly);
        
    case 13
        Eco_Efficiency.GaBiTables.gtBatteryElAl       =     GaBiTable(Eco_Efficiency.ElectricityType,"Electricity",Eco_Efficiency.Assembly.ElectricityShare.BatteryFCEV,0,0,Param.GaBiFiles.UsePhase);
        Eco_Efficiency.GaBiTables.gtAsssembly         =     GaBiTable(Eco_Efficiency.ElectricityType,"Electricity",Eco_Efficiency.Assembly.ElectricityTotal-Eco_Efficiency.Assembly.ElectricityShare.BatteryFCEV,0,0,Param.GaBiFiles.UsePhase);
        Eco_Efficiency.GaBiTables.gtTransmission = GaBiTable("Transmission",name_buff, Eco_Efficiency.MatlabWeight.m_Transmission,0,0,Param.GaBiFiles.Assembly);
        Eco_Efficiency.GaBiTables.gtBatteryFCEV = GaBiTable("Battery Dai [1000kWh]", name_buff, Eco_Efficiency.MatlabWeight.m_BatteryFCEV,0,0,Param.GaBiFiles.Assembly);
        Eco_Efficiency.GaBiTables.gtH2Tank = GaBiTable("Hydrogen tank",name_buff, Eco_Efficiency.MatlabWeight.m_H2Tank,0,0,Param.GaBiFiles.Assembly);
        Eco_Efficiency.GaBiTables.gtStack = GaBiTable("Stack + BoP",name_buff, Eco_Efficiency.MatlabWeight.m_Stack,0,0,Param.GaBiFiles.Assembly);
        Eco_Efficiency.GaBiTables.gtPwrEle = GaBiTable("Power el.",name_buff, Eco_Efficiency.MatlabWeight.m_PwrEle,0,0,Param.GaBiFiles.Assembly);
        Eco_Efficiency.GaBiTables.gtE_EngineFCEV = GaBiTable("E-Engine EV",name_buff, Eco_Efficiency.MatlabWeight.m_E_EngineFCEV,0,0,Param.GaBiFiles.Assembly);
        Eco_Efficiency.GaBiTables.gtOthersFCEV = GaBiTable("Others EV", name_buff, Eco_Efficiency.MatlabWeight.m_OthersFCEV,0,0,Param.GaBiFiles.Assembly);
        
    case 14
        Eco_Efficiency.GaBiTables.gtTransmission = GaBiTable("Transmission", name_buff, Eco_Efficiency.MatlabWeight.m_Transmission,0,0,Param.GaBiFiles.Assembly);
        Eco_Efficiency.GaBiTables.gtExhaustSys = GaBiTable("Exhaust system", name_buff,Eco_Efficiency.MatlabWeight.m_ExhaustSys,0,0,Param.GaBiFiles.Assembly);
        Eco_Efficiency.GaBiTables.gtEngineICE = GaBiTable("Engine", name_buff, Eco_Efficiency.MatlabWeight.m_EngineICE,0,0,Param.GaBiFiles.Assembly);
        Eco_Efficiency.GaBiTables.gtH2Tank = GaBiTable("Hydrogen Tank",name_buff, Eco_Efficiency.MatlabWeight.m_H2Tank,0,0,Param.GaBiFiles.Assembly);
        Eco_Efficiency.GaBiTables.gtOthersICE = GaBiTable("Others ICE", name_buff, Eco_Efficiency.MatlabWeight.m_OtherICE,0,0,Param.GaBiFiles.Assembly);
        Eco_Efficiency.GaBiTables.gtBatteryLeadAcid = GaBiTable("Battery Lead Acid", name_buff, Eco_Efficiency.MatlabWeight.m_BatteryLeadAcid,0,0,Param.GaBiFiles.Assembly);
        
          
end

% Additional impacts such as Assembly, Water-usage, Heat, Transport

%check for NaN values and replace them by zero
fnG = fieldnames(Eco_Efficiency.GaBiTables);

for i=1:numel(fnG)
    fnW = fieldnames(Eco_Efficiency.GaBiTables.(fnG{i}));
    for j=7:numel(fnW)
        if isnan(Eco_Efficiency.GaBiTables.(fnG{i}).(fnW{j}))
            Eco_Efficiency.GaBiTables.(fnG{i}).(fnW{j}) = 0;
        end
    end
    
end


%% Set up WeightingTable

%indx = 1; %CastellaniEtAl_2016WFsA
% indx = 2; %CastellaniEtAl_2016WFsB
% indx = 3; %EDIP2003_StranddorfEtAl__2005_
% indx = 4; %TuomistoEtAl_2012
% indx = 5; %Bj_rn_HauschildEuropean2015
% indx = 6; %Bj_rn_HauschildGlobal2015
% indx = 7; %Ponsioen_Goedkoop2016
% indx = 8; %HubbesEtAl_2012
% indx = 9; % Recommended EF Weighting
%  indx = 10; % Recommended EF Weightign without landuse and combined
% resource depletion
% indx = 11; % Castellani with EU Norm
% indx = 12; % Recommended EF Weightign without landuse and resource depletion

Eco_Efficiency.WeightingTable = WeightingTable(indx,Param.WeightingFiles.File);


%% Assembly

Eco_Efficiency.Impacts.GWP = 0;
Eco_Efficiency.Impacts.AP = 0;
Eco_Efficiency.Impacts.EcoToxFW = 0;
Eco_Efficiency.Impacts.EutrophFW = 0;
Eco_Efficiency.Impacts.EutrophMar = 0;
Eco_Efficiency.Impacts.EutrophTerr = 0;
%Eco_Efficiency.Impacts.EutrophComb = 0;
Eco_Efficiency.Impacts.HumToxCan = 0;
Eco_Efficiency.Impacts.HumToxNonCan = 0;
Eco_Efficiency.Impacts.IonRad = 0;
Eco_Efficiency.Impacts.OzDep = 0;
Eco_Efficiency.Impacts.PartMat = 0;
Eco_Efficiency.Impacts.PhotoOz = 0;
Eco_Efficiency.Impacts.ResWater = 0;
Eco_Efficiency.Impacts.ResMinFosRen = 0;
Eco_Efficiency.Impacts.ResFosNonRen = 0;
%{'GWP','AP','EcoToxFW','EutrophFW','EutrophMar','EutrophTer',...

%'EutrophComb','HumToxCan','HumToxNonCan','IonRad','OzDep','PartMat','PhotoOz',...
%   'ResWat','ResMinFosRen'};

fn = fieldnames(Eco_Efficiency.GaBiTables);
for i = 1 : numel(fieldnames(Eco_Efficiency.GaBiTables))
    Eco_Efficiency.Impacts.GWP = Eco_Efficiency.Impacts.GWP +...
        Eco_Efficiency.GaBiTables.(fn{i}).GWP;
    
    Eco_Efficiency.Impacts.AP = Eco_Efficiency.Impacts.AP +...
        Eco_Efficiency.GaBiTables.(fn{i}).AP;
    
    Eco_Efficiency.Impacts.EcoToxFW = Eco_Efficiency.Impacts.EcoToxFW +...
        Eco_Efficiency.GaBiTables.(fn{i}).EcoToxFW ;
    
    Eco_Efficiency.Impacts.EutrophFW = Eco_Efficiency.Impacts.EutrophFW +...
        Eco_Efficiency.GaBiTables.(fn{i}).EutrophFW;
    
    Eco_Efficiency.Impacts.EutrophMar = Eco_Efficiency.Impacts.EutrophMar +...
        Eco_Efficiency.GaBiTables.(fn{i}).EutrophMar;
    
    Eco_Efficiency.Impacts.EutrophTerr = Eco_Efficiency.Impacts.EutrophTerr +...
        Eco_Efficiency.GaBiTables.(fn{i}).EutrophTerr;
    
%     Eco_Efficiency.Impacts.EutrophComb = Eco_Efficiency.Impacts.EutrophComb +...
%         Eco_Efficiency.GaBiTables.(fn{i}).EutrophComb;
%     
    Eco_Efficiency.Impacts.HumToxCan = Eco_Efficiency.Impacts.HumToxCan +...
        Eco_Efficiency.GaBiTables.(fn{i}).HumToxCan;
    
    Eco_Efficiency.Impacts.HumToxNonCan = Eco_Efficiency.Impacts.HumToxNonCan +...
        Eco_Efficiency.GaBiTables.(fn{i}).HumToxNonCan;
    
    Eco_Efficiency.Impacts.IonRad = Eco_Efficiency.Impacts.IonRad +...
        Eco_Efficiency.GaBiTables.(fn{i}).IonRad;
    
    Eco_Efficiency.Impacts.OzDep = Eco_Efficiency.Impacts.OzDep +...
        Eco_Efficiency.GaBiTables.(fn{i}).OzDep;
    
    Eco_Efficiency.Impacts.PartMat = Eco_Efficiency.Impacts.PartMat +...
        Eco_Efficiency.GaBiTables.(fn{i}).PartMat;
    
    Eco_Efficiency.Impacts.PhotoOz = Eco_Efficiency.Impacts.PhotoOz +...
        Eco_Efficiency.GaBiTables.(fn{i}).PhotoOz;
    
    Eco_Efficiency.Impacts.ResWater = Eco_Efficiency.Impacts.ResWater +...
        Eco_Efficiency.GaBiTables.(fn{i}).ResWater;
    
    Eco_Efficiency.Impacts.ResMinFosRen = Eco_Efficiency.Impacts.ResMinFosRen +...
        Eco_Efficiency.GaBiTables.(fn{i}).ResMinFosRen;

    Eco_Efficiency.Impacts.ResFosNonRen = Eco_Efficiency.Impacts.ResFosNonRen +...
        Eco_Efficiency.GaBiTables.(fn{i}).ResFosNonRen;    
end

% save intermediate result
fnI = fieldnames(Eco_Efficiency.Impacts);
for i = 1 : numel(fnI)
    Eco_Efficiency.Sum.Assembly.(fnI{i}) = Eco_Efficiency.Impacts.(fnI{i});
end


%% Use-Phase
% Assumptions
rho_diesel = 0.85;

%Eco_Efficiency.Annual_Milage = 104752;
Eco_Efficiency.Annual_Milage = Param.TCO.Annual_mileage(1);
% Eco_Efficiency.Annual_Milage = 114000; %in km       Source: [1]
%Eco_Efficiency.Annual_Milage = 122088; % Karim's Thesis
% alternative: working days / year * working hours / day * average speed
% but this depends on the cycle which is driven, therefore fix value is
% used
%Eco_Efficiency.LifeTime = 6; % in years
Eco_Efficiency.LifeTime = Param.TCO.Operating_life(1);
Eco_Efficiency.Total_Milage = Eco_Efficiency.Annual_Milage * Eco_Efficiency.LifeTime; % in km

% following are the same for all:
% #tires = 7*round((distance_year*years/140000-1)+0,49;1)
Eco_Efficiency.UsePhase.numTires = 7* ceil(Eco_Efficiency.Total_Milage/Param.TCO.Tire_mileage(1));
%7*round((Eco_Efficiency.Total_Milage/140000-1)+0.49,1); % in number of tires
Eco_Efficiency.UsePhase.MatlabWeight.m_Tires_and_Wheels = Eco_Efficiency.MatlabWeight.m_Tires_and_Wheels * Eco_Efficiency.UsePhase.numTires;
Eco_Efficiency.GaBiTables.UsePhase.gtTiresandWheels = GaBiTable("Tires and wheels","EV", Eco_Efficiency.UsePhase.MatlabWeight.m_Tires_and_Wheels,0,0,Param.GaBiFiles.Assembly);

% oil: (2*years-1)*10
%Eco_Efficiency.UsePhase.amountOil = (2+Eco_Efficiency.LifeTime) * 10; % in liter
% add 10 liters after 60000km
Eco_Efficiency.UsePhase.amountOil = (fix(Eco_Efficiency.Total_Milage/60000)) * 10; % in liter
Eco_Efficiency.GaBiTables.UsePhase.gtMotorOil = GaBiTable("UsePhase MotorOil","MotorOil",Eco_Efficiency.UsePhase.amountOil,0,0,Param.GaBiFiles.UsePhase);

% Cooling: round(distance_year*years/500000-1+0,49;1)*54
Eco_Efficiency.UsePhase.amountCooling = round(Eco_Efficiency.Total_Milage/500000-1+0.49,1)*54;
Eco_Efficiency.GaBiTables.UsePhase.gtCooling = GaBiTable("UsePhase Coolant","Coolant",Eco_Efficiency.UsePhase.amountCooling,0,0,Param.GaBiFiles.UsePhase);

%initialize rest
Eco_Efficiency.UsePhase.numBatLiIon = 0;
Eco_Efficiency.UsePhase.numBatLeadAcid = 0;

switch Param.Fueltype
    case {7, 12}
        % EV
        % GaBi values are dependend on: years in action, distance per year,
        % consumption in kW/100km, duration battery
        % N_bat = round(years/duration_bat+0,49;1)-1
        %   18 Jahre haltbarkeit Batterie % Bennjamin Mustafic
        %
        %Eco_Efficiency.UsePhase.numBatEV = round(Eco_Efficiency.LifeTime/Param.TCO.Lebensdauer_Batteriepack+0.49,1)-1;
        Eco_Efficiency.UsePhase.numBatLiIon = floor((Eco_Efficiency.LifeTime*Param.TCO.Annual_mileage(1))./(Param.TCO.Lebensdauer_Batteriepack * Param.TCO.Annual_mileage(1))); % Benni!
        Eco_Efficiency.UsePhase.MatlabWeight.m_BatteryEV = Eco_Efficiency.UsePhase.numBatLiIon * Param.weights.m_Battery;
        Eco_Efficiency.GaBiTables.UsePhase.gtBatteryEV = GaBiTable("Battery Dai [1000kWh]",name_buff,Eco_Efficiency.UsePhase.MatlabWeight.m_BatteryEV,0,0,Param.GaBiFiles.Assembly);
            
        %Comsumption Electricity, Electricity: years*distance_year*consumption/100*10^-6
        Param.VSim.Consumption_kWh = Param.TCO.energyTotal;
        %-Results.delta_E/(Results.OUT_summary.signals(2).values(length(Results.OUT_summary.signals(2).values))/100000); % in kWh/100km
        Eco_Efficiency.UsePhase.amountElectricity = Param.VSim.Consumption_kWh * 3.6 * Eco_Efficiency.Total_Milage/100; % in [kWh] * 3,6 -> [MJ]
        Eco_Efficiency.GaBiTables.UsePhase.gtElectricity = GaBiTable(Eco_Efficiency.ElectricityType,"Electricity",Eco_Efficiency.UsePhase.amountElectricity,0,0,Param.GaBiFiles.UsePhase);
        
    case 1
        % ICE
        % GaBi values are dependet on: years in action, distance per year,
        % consumption in l/100km / consumtion in kW/100km, emission CO2 per liter,
        % CH4: 0,5*cons_KW*distance_year*years/1000
        % CO: 4*cons_KW*distance_year*years/1000
        % CO2_emission: diesel*CO2_per_litre
        % Diesel: years*distance_year*consumption/100
        % NMHC: 0,16*cons_KW*distance_year*years/1000
        % NOx: 0,46*cons_KW*distance_year*years/1000
        % PM: 0,01*cons_KW*distance_year*years/1000
        Param.VSim.bDiesel = Param.TCO.bDiesel;
        %(Results.OUT_summary.signals(7).values(end))/(Results.OUT_summary.signals(2).values(length(Results.OUT_summary.signals(2).values))/100000); % l/100km
        Eco_Efficiency.UsePhase.amountDiesel = Param.VSim.bDiesel * Eco_Efficiency.Total_Milage / 100 *rho_diesel; % VSim.bDiesel comes in Liter -> *rho_diesel
        Eco_Efficiency.GaBiTables.UsePhase.gtDiesel = GaBiTable(Eco_Efficiency.DieselType,"Diesel",Eco_Efficiency.UsePhase.amountDiesel,0,0,Param.GaBiFiles.UsePhase);
        
    case 4
        
        % HEV
        % CH4: 0,5*cons_KW*distance_year*years/1000
        % CO: 4*cons_KW*distance_year*years/1000
        % CO2_Emissions: diesel*CO2_per_litre
        % Diesel: years*distance_year*consumption_die/100
        % Electricity: years*distance_year*consumption_ele/100*10^-6
        % N_Bat: round(years/duration_bat+0,49;1)-1
        % NMHC: 0,16*cons_KW*distance_year*years/1000
        % NOx: 0,46*cons_KW*distance_year*years/1000
        % PM: 0,01*cons_KW*distance_year*years/1000
        % Emissions included in GaBiModel for Diesel
        
        %Battery
        %Eco_Efficiency.UsePhase.numBatHEV = 0;%round(Eco_Efficiency.LifeTime/Param.TCO.Lebensdauer_Batteriepack+0.49,1)-1;
        Eco_Efficiency.UsePhase.numBatLiIon = floor((Eco_Efficiency.LifeTime*Param.TCO.Annual_mileage(1))./(Param.TCO.Lebensdauer_Batteriepack * Param.TCO.Annual_mileage(1))); % Benni!

        Eco_Efficiency.UsePhase.MatlabWeight.m_BatteryHEV = Eco_Efficiency.UsePhase.numBatLiIon * Param.weights.m_Battery;
        Eco_Efficiency.GaBiTables.UsePhase.gtBatteryHEV = GaBiTable("Battery Dai [1000kWh]",name_buff,Eco_Efficiency.UsePhase.MatlabWeight.m_BatteryHEV,0,0,Param.GaBiFiles.Assembly);
        
        %Electricity
        Param.VSim.Consumption_kWh = Param.TCO.energyTotal; 
        %-Results.delta_E; %Output battery capacity consumption in kWh
        Eco_Efficiency.UsePhase.amountElectricity = Param.VSim.Consumption_kWh * 3.6 * Eco_Efficiency.Total_Milage / 100; % in [kWh] * 3,6 -> [MJ]
        Eco_Efficiency.GaBiTables.UsePhase.gtElectricity = GaBiTable(Eco_Efficiency.ElectricityType,"Electricity",Eco_Efficiency.UsePhase.amountElectricity,0,0,Param.GaBiFiles.UsePhase);
        
        %Diesel
        Param.VSim.Consumption_kWh = Param.TCO.bDiesel;
        %Results.OUT_summary.signals(7).values(end)*9.97; %
        Eco_Efficiency.UsePhase.amountDiesel = Param.VSim.bDiesel * Eco_Efficiency.Total_Milage / 100 *rho_diesel; % VSim.bDiesel comes in Liter -> *rho_diesel
        Eco_Efficiency.GaBiTables.UsePhase.gtDiesel = GaBiTable(Eco_Efficiency.DieselType,"Diesel",Eco_Efficiency.UsePhase.amountDiesel,0,0,Param.GaBiFiles.UsePhase);
        
        
    case 13
        % N_Bat: round(years/duration_bat+0,49;1)-1
        %Eco_Efficiency.UsePhase.numBatFCEV = round(Eco_Efficiency.LifeTime/Param.TCO.Lebensdauer_Batteriepack+0.49,1)-1;
        Eco_Efficiency.UsePhase.numBatLiIon = floor((Eco_Efficiency.LifeTime*Param.TCO.Annual_mileage(1))./(Param.TCO.Lebensdauer_Batteriepack * Param.TCO.Annual_mileage(1))); % Benni!
        Eco_Efficiency.UsePhase.MatlabWeight.m_BatteryFCEV = Eco_Efficiency.UsePhase.numBatLiIon * Param.weights.m_Battery;
        Eco_Efficiency.GaBiTables.UsePhase.gtBatteryFCEV = GaBiTable("Battery Dai [1000kWh]",name_buff,Eco_Efficiency.UsePhase.MatlabWeight.m_BatteryFCEV,0,0,Param.GaBiFiles.Assembly);
        % Hydrogen
        Eco_Efficiency.UsePhase.amountHydrogen = Param.TCO.Hydrogen_consumption * Eco_Efficiency.Total_Milage / 100;
        %Param.VSim.Hydrogen_consumption; %Matlab weight in kg
        Eco_Efficiency.GaBiTables.UsePhase.gtHydrogen = GaBiTable(Eco_Efficiency.HydrogenType, "Hydrogen", Eco_Efficiency.UsePhase.amountHydrogen,0,0,Param.GaBiFiles.UsePhase); %scaled by Matlab weight

    case 14
        % Hydrogen
        Eco_Efficiency.UsePhase.amountHydrogen = Param.TCO.Hydrogen_consumption * Eco_Efficiency.Total_Milage / 100;
        %Param.VSim.Hydrogen_consumption; %Matlab weight in kg
        Eco_Efficiency.GaBiTables.UsePhase.gtHydrogen = GaBiTable(Eco_Efficiency.HydrogenType, "Hydrogen", Eco_Efficiency.UsePhase.amountHydrogen,0,0,Param.GaBiFiles.UsePhase); %scaled by Matlab weight

        
end
fnUse = fieldnames(Eco_Efficiency.GaBiTables.UsePhase);
for i = 1 : numel(fnUse)
    Eco_Efficiency.Impacts.GWP = Eco_Efficiency.Impacts.GWP +...
        Eco_Efficiency.GaBiTables.UsePhase.(fnUse{i}).GWP;
    
    Eco_Efficiency.Impacts.AP = Eco_Efficiency.Impacts.AP +...
        Eco_Efficiency.GaBiTables.UsePhase.(fnUse{i}).AP;
    
    Eco_Efficiency.Impacts.EcoToxFW = Eco_Efficiency.Impacts.EcoToxFW +...
        Eco_Efficiency.GaBiTables.UsePhase.(fnUse{i}).EcoToxFW ;
    
    Eco_Efficiency.Impacts.EutrophFW = Eco_Efficiency.Impacts.EutrophFW +...
        Eco_Efficiency.GaBiTables.UsePhase.(fnUse{i}).EutrophFW;
    
    Eco_Efficiency.Impacts.EutrophMar = Eco_Efficiency.Impacts.EutrophMar +...
        Eco_Efficiency.GaBiTables.UsePhase.(fnUse{i}).EutrophMar;
    
    Eco_Efficiency.Impacts.EutrophTerr = Eco_Efficiency.Impacts.EutrophTerr +...
        Eco_Efficiency.GaBiTables.UsePhase.(fnUse{i}).EutrophTerr;
    
%     Eco_Efficiency.Impacts.EutrophComb = Eco_Efficiency.Impacts.EutrophComb +...
%         Eco_Efficiency.GaBiTables.UsePhase.(fnUse{i}).EutrophComb;
%     
    Eco_Efficiency.Impacts.HumToxCan = Eco_Efficiency.Impacts.HumToxCan +...
        Eco_Efficiency.GaBiTables.UsePhase.(fnUse{i}).HumToxCan;
    
    Eco_Efficiency.Impacts.HumToxNonCan = Eco_Efficiency.Impacts.HumToxNonCan +...
        Eco_Efficiency.GaBiTables.UsePhase.(fnUse{i}).HumToxNonCan;
    
    Eco_Efficiency.Impacts.IonRad = Eco_Efficiency.Impacts.IonRad +...
        Eco_Efficiency.GaBiTables.UsePhase.(fnUse{i}).IonRad;
    
    Eco_Efficiency.Impacts.OzDep = Eco_Efficiency.Impacts.OzDep +...
        Eco_Efficiency.GaBiTables.UsePhase.(fnUse{i}).OzDep;
    
    Eco_Efficiency.Impacts.PartMat = Eco_Efficiency.Impacts.PartMat +...
        Eco_Efficiency.GaBiTables.UsePhase.(fnUse{i}).PartMat;
    
    Eco_Efficiency.Impacts.PhotoOz = Eco_Efficiency.Impacts.PhotoOz +...
        Eco_Efficiency.GaBiTables.UsePhase.(fnUse{i}).PhotoOz;
    
    Eco_Efficiency.Impacts.ResWater = Eco_Efficiency.Impacts.ResWater +...
        Eco_Efficiency.GaBiTables.UsePhase.(fnUse{i}).ResWater;
    
    Eco_Efficiency.Impacts.ResMinFosRen = Eco_Efficiency.Impacts.ResMinFosRen +...
        Eco_Efficiency.GaBiTables.UsePhase.(fnUse{i}).ResMinFosRen;
    
    Eco_Efficiency.Impacts.ResFosNonRen = Eco_Efficiency.Impacts.ResFosNonRen +...
        Eco_Efficiency.GaBiTables.UsePhase.(fnUse{i}).ResFosNonRen;
    
end % update Eco-Impacts

% save intermediate result
fnI = fieldnames(Eco_Efficiency.Impacts);
for i = 1 : numel(fnI)
    Eco_Efficiency.Sum.UsePhase.(fnI{i}) = Eco_Efficiency.Impacts.(fnI{i})-Eco_Efficiency.Sum.Assembly.(fnI{i});
end


%% Recycling
% pseudo-code:
% variable is weight of assembly components // existing!
% for each components:
%   look in table to get material composition
% add them up
% -> now we have all recycleable materials combined
% Do this in a seperate function!
[Eco_Efficiency.Recycling.Materials] = calculateMaterialMix(Param,Eco_Efficiency);
% for each material in component_materials_list

% Add Transport part for recycling, distance set to 770tkm (more precisly 100km * mass of vehice)

Eco_Efficiency.GaBiTables.Recycling.gtTransport = GaBiTable("RER: transport, lorry 16-32t, EURO5", name_buff, Eco_Efficiency.Transportation, 0, 0, Param.GaBiFiles.Assembly);
% adding more data manually
Eco_Efficiency.Recycling.Materials.Coolant = Eco_Efficiency.UsePhase.amountCooling;
Eco_Efficiency.Recycling.Materials.Oil = Eco_Efficiency.UsePhase.amountOil;

switch Param.Fueltype
    case {7, 12}
        Eco_Efficiency.Recycling.Materials.LiIonBattery = (Eco_Efficiency.UsePhase.numBatLiIon + 1) * Eco_Efficiency.MatlabWeight.m_BatteryEV;
    case 4
        Eco_Efficiency.Recycling.Materials.LiIonBattery = (Eco_Efficiency.UsePhase.numBatLiIon + 1) * Eco_Efficiency.MatlabWeight.m_BatteryHEV;
    case 13
        Eco_Efficiency.Recycling.Materials.LiIonBattery = (Eco_Efficiency.UsePhase.numBatLiIon + 1) * Eco_Efficiency.MatlabWeight.m_BatteryFCEV;
    case {1, 14}
        Eco_Efficiency.Recycling.Materials.LiIonBattery = 0;
end


switch Param.Fueltype
    case {1, 4, 14}
        Eco_Efficiency.Recycling.Materials.LeadAcidBattery = 2; % number of batteries
    otherwise
        Eco_Efficiency.Recycling.Materials.LeadAcidBattery = 0;
end

fnMaterials = fieldnames(Eco_Efficiency.Recycling.Materials);

for i=1:length(fnMaterials)
    materialName = strcat("Recycling ",fnMaterials(i));
    Eco_Efficiency.GaBiTables.Recycling.(fnMaterials{i}) = GaBiTable(materialName,fnMaterials{i}, Eco_Efficiency.Recycling.Materials.(fnMaterials{i}),0,0,Param.GaBiFiles.Recycling);
end
% correction for electricity
% first delete generic electricity impacts, then add electricity with
% certain mix again
% caluculate amount of electricity
[~,~,Eco_Efficiency.Recycling.ElectricityShare,Eco_Efficiency.Recycling.ElectricityTotal] = calculateElectricityShare(Eco_Efficiency, Param, 2);
% negative scaled generic electricity part
Eco_Efficiency.GaBiTables.Recycling.negEle = GaBiTable(Eco_Efficiency.ElectricityType,"Electricity",-Eco_Efficiency.Recycling.ElectricityTotal,0,0,Param.GaBiFiles.UsePhase);
% postive part
Eco_Efficiency.GaBiTables.Recycling.posEle = GaBiTable(Eco_Efficiency.ElectricityType,"Electricity",Eco_Efficiency.Recycling.ElectricityTotal,0,0,Param.GaBiFiles.UsePhase);


%   create GaBiRecycleObjects with scaling factor of combined weight of the
%   material TIMES a factor that discribes how much of the material is
%   recycled at all.
% cummulate negative emissions out of gabifiles
% add these of to the combined ones

fnRec = fieldnames(Eco_Efficiency.GaBiTables.Recycling);
for i = 1 : numel(fnRec)
    Eco_Efficiency.Impacts.GWP = Eco_Efficiency.Impacts.GWP +...
        Eco_Efficiency.GaBiTables.Recycling.(fnRec{i}).GWP;
    
    Eco_Efficiency.Impacts.AP = Eco_Efficiency.Impacts.AP +...
        Eco_Efficiency.GaBiTables.Recycling.(fnRec{i}).AP;
    
    Eco_Efficiency.Impacts.EcoToxFW = Eco_Efficiency.Impacts.EcoToxFW +...
        Eco_Efficiency.GaBiTables.Recycling.(fnRec{i}).EcoToxFW ;
    
    Eco_Efficiency.Impacts.EutrophFW = Eco_Efficiency.Impacts.EutrophFW +...
        Eco_Efficiency.GaBiTables.Recycling.(fnRec{i}).EutrophFW;
    
    Eco_Efficiency.Impacts.EutrophMar = Eco_Efficiency.Impacts.EutrophMar +...
        Eco_Efficiency.GaBiTables.Recycling.(fnRec{i}).EutrophMar;
    
    Eco_Efficiency.Impacts.EutrophTerr = Eco_Efficiency.Impacts.EutrophTerr +...
        Eco_Efficiency.GaBiTables.Recycling.(fnRec{i}).EutrophTerr;
    
%     Eco_Efficiency.Impacts.EutrophComb = Eco_Efficiency.Impacts.EutrophComb +...
%         Eco_Efficiency.GaBiTables.Recycling.(fnRec{i}).EutrophComb;
%     
    Eco_Efficiency.Impacts.HumToxCan = Eco_Efficiency.Impacts.HumToxCan +...
        Eco_Efficiency.GaBiTables.Recycling.(fnRec{i}).HumToxCan;
    
    Eco_Efficiency.Impacts.HumToxNonCan = Eco_Efficiency.Impacts.HumToxNonCan +...
        Eco_Efficiency.GaBiTables.Recycling.(fnRec{i}).HumToxNonCan;
    
    Eco_Efficiency.Impacts.IonRad = Eco_Efficiency.Impacts.IonRad +...
        Eco_Efficiency.GaBiTables.Recycling.(fnRec{i}).IonRad;
    
    Eco_Efficiency.Impacts.OzDep = Eco_Efficiency.Impacts.OzDep +...
        Eco_Efficiency.GaBiTables.Recycling.(fnRec{i}).OzDep;
    
    Eco_Efficiency.Impacts.PartMat = Eco_Efficiency.Impacts.PartMat +...
        Eco_Efficiency.GaBiTables.Recycling.(fnRec{i}).PartMat;
    
    Eco_Efficiency.Impacts.PhotoOz = Eco_Efficiency.Impacts.PhotoOz +...
        Eco_Efficiency.GaBiTables.Recycling.(fnRec{i}).PhotoOz;
    
    Eco_Efficiency.Impacts.ResWater = Eco_Efficiency.Impacts.ResWater +...
        Eco_Efficiency.GaBiTables.Recycling.(fnRec{i}).ResWater;
    
    Eco_Efficiency.Impacts.ResMinFosRen = Eco_Efficiency.Impacts.ResMinFosRen +...
        Eco_Efficiency.GaBiTables.Recycling.(fnRec{i}).ResMinFosRen;
    
    Eco_Efficiency.Impacts.ResFosNonRen = Eco_Efficiency.Impacts.ResFosNonRen +...
        Eco_Efficiency.GaBiTables.Recycling.(fnRec{i}).ResFosNonRen;
    
end
% update Eco-Impacts

% save intermediate result
fnI = fieldnames(Eco_Efficiency.Impacts);
for i = 1 : numel(fnI)
    Eco_Efficiency.Sum.Recycling.(fnI{i}) = Eco_Efficiency.Impacts.(fnI{i})-Eco_Efficiency.Sum.Assembly.(fnI{i})-Eco_Efficiency.Sum.UsePhase.(fnI{i});
end

%% Normalisation
% Eco_Efficiency.Norm.GWP = 5.35e+13;
% Eco_Efficiency.Norm.AP = 3.83e+11;
% Eco_Efficiency.Norm.EcoToxFW = 8.15e+13;
% Eco_Efficiency.Norm.EutrophFW = 5.06e+09;
% Eco_Efficiency.Norm.EutrophMar = 1.95e+11;
% Eco_Efficiency.Norm.EutrophTerr = 1.22e+12;
% Eco_Efficiency.Norm.HumToxCan = 2.66e+05;
% Eco_Efficiency.Norm.HumToxNonCan = 3.27e+06;
% Eco_Efficiency.Norm.IonRad = 2.04e+12;
% Eco_Efficiency.Norm.OzDep = 1.61e+08;
% Eco_Efficiency.Norm.PartMat = 4.28e+06;
% Eco_Efficiency.Norm.PhotoOz = 2.80e+11;
% Eco_Efficiency.Norm.ResWater = 7.91e+13;
% Eco_Efficiency.Norm.ResMinFosRen = (4.3e+14 + 3.99e+8)/2; % assumption
% 
% 
% Eco_Efficiency.Norm.Cast.GWP = 4.60e+12;
% Eco_Efficiency.Norm.Cast.AP = 2.36e+10;
% Eco_Efficiency.Norm.Cast.EcoToxFW = 3.78e+13;
% Eco_Efficiency.Norm.Cast.EutrophFW = 7.41e+8;
% Eco_Efficiency.Norm.Cast.EutrophMar = 8.44e+9;
% Eco_Efficiency.Norm.Cast.EutrophTerr = 8.76e+10;
% Eco_Efficiency.Norm.Cast.HumToxCan = 1.88e+4;
% Eco_Efficiency.Norm.Cast.HumToxNonCan = 2.69e+5;
% Eco_Efficiency.Norm.Cast.IonRad = 5.64e+11;
% Eco_Efficiency.Norm.Cast.OzDep = 1.08e+07;
% Eco_Efficiency.Norm.Cast.PartMat = 1.93e+09;
% Eco_Efficiency.Norm.Cast.PhotoOz = 1.58e+10;
% Eco_Efficiency.Norm.Cast.ResWater = 4.06e+10;
% Eco_Efficiency.Norm.Cast.ResMinFosRen = 5.03e+07;



%% Weighting
impacts = zeros(1,size(fnI,1)); % not covering LandUse for now
weights = zeros(1,size(fnI,1));
%weights = [1.16 1.18 1.1 1.01 1.13 1.14 1.12 1.01 1 1.05 1.21 1.28 6.38 0.65];

for i = 1 : size(fnI,1)
    impacts(i) = Eco_Efficiency.Sum.Assembly.(fnI{i});
    %impacts(i) = Eco_Efficiency.Sum.Assembly.(fnI{i}) / Eco_Efficiency.Norm.Cast.(fnI{i});
    %impacts(i) = Eco_Efficiency.Sum.Assembly.(fnW{i+6});
    weights(i) = Eco_Efficiency.WeightingTable.(fnI{i});
    
end
Eco_Efficiency.Sum.Impact_Assembly = dot(impacts,weights');

Eco_Efficiency.Sum.weightedAssembly = impacts.*weights;


for i = 1 : size(fnI,1)
    impacts(i) = Eco_Efficiency.Sum.UsePhase.(fnI{i});
    %impacts(i) = Eco_Efficiency.Sum.UsePhase.(fnI{i}) / Eco_Efficiency.Norm.Cast.(fnI{i});
    weights(i) = Eco_Efficiency.WeightingTable.(fnI{i});
end
Eco_Efficiency.Sum.Impact_UsePhase = dot(impacts,weights');

Eco_Efficiency.Sum.weightedUsePhase = impacts.*weights;

for i = 1 : size(fnI,1)
    impacts(i) = Eco_Efficiency.Sum.Recycling.(fnI{i});
    %impacts(i) = Eco_Efficiency.Sum.Recycling.(fnI{i}) / Eco_Efficiency.Norm.Cast.(fnI{i});
    %impacts(i) = Eco_Efficiency.Sum.Assembly.(fnW{i+6});
    weights(i) = Eco_Efficiency.WeightingTable.(fnI{i});
    
end
Eco_Efficiency.Sum.Impact_Recycling = dot(impacts,weights');

Eco_Efficiency.Sum.weightedRecycling = impacts.*weights;

% temp = [temp ones(3,1).*Param.TCO.Total_costs];

% csvwrite(strcat('H:', filesep,'07_Veroeffentlichung', filesep,'Paper_CIRP_LCE', filesep,'Data', filesep, Param.Vehicle,'_EcoEff.csv'), temp)
% csvwrite(strcat('H:', filesep,'__Diss', filesep,'02_Daten', filesep,'OptiResults', filesep, Param.Vehicle, '_EcoEff.csv'), temp)



% Alternativ calculation // leads to same result
% for i = 1 : 14
%     impacts(i) = Eco_Efficiency.Sum.Assembly.(fnI{i}) + ...
%         Eco_Efficiency.Sum.UsePhase.(fnI{i}) + Eco_Efficiency.Sum.Recycling.(fnI{i});
%     weights(i) = Eco_Efficiency.WeightingTable.(fnI{i});
% end
% Eco_Efficiency.Eco_Impact = dot(impacts,weights');


Eco_Efficiency.Eco_Impact = (Eco_Efficiency.Sum.Impact_Assembly + ...
    Eco_Efficiency.Sum.Impact_UsePhase + Eco_Efficiency.Sum.Impact_Recycling)...
    /(Param.TCO.Annual_mileage(1)*Param.TCO.Operating_life(1)*(Param.vehicle.payload/1000));

%% Return results

%Eco_Efficiency.Efficiency = Eco_Efficiency.Eco_Impact /
%Param.TCO.Total_costs;)

% store reuslts
%ifStore = false;

% Function to store results (Param, Eco_Efficiency);

% plot results

%plotEcoEfficiencyAnalysis(Eco_Efficiency, Param, 0);




%clear GaBiTables. It remains to be seen, if for simulation purpose keeping
%these tables alive will result in a better performance.
%clearvars gt*;

% clear not necessary variables
% clearvars gt* fn fnG fnW i j k name_buff impacts weights indx list ;
% clearvars gt*;
end
