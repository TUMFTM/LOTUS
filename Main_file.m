% Designed by Bert Haj Ali at FTM, Technical University of Munich
%-------------
% Modified on: 17.12.2018
% ------------
% Version: Matlab2017b
%-------------
% This script combines and replaces Stand_alone_Verbrauchssimulation and
% Fahrzeuge_Iteration scripts for simplification. To run either files like
% before, change the value of the variable ifOptimized. For more
% information, refer to the Readme.m file.
% ------------
% clc;
% clear;

addpath('Classes');
addpath('Functions');
addpath(genpath('Consumption_simulation'));
addpath(genpath('Optimization'));
addpath('TCO');
addpath('Post-processing');
addpath('Results');

%%  Fuel type
%     Kraftstoff = 1;     % Diesel
%     Kraftstoff = 2;     % CNG
%     Kraftstoff = 3;     % LNG
    Kraftstoff = 4;     % Diesel Hybrid
%     Kraftstoff = 5;     % CNG Hybrid
%     Kraftstoff = 6;     % LNG Hybrid
%     Kraftstoff = 7;     % Electric
%     Kraftstoff = 8;     % Diesel & CNG
%     Kraftstoff = 9;     % Diesel & LNG    
%     Kraftstoff = 10;    % Diesel & CNG Hybrid
%     Kraftstoff = 11;    % Diesel & LNG Hybrid
%     Kraftstoff = 12;    % Electric w/WPT
%     Kraftstoff = 13;    % Hydrogen fuel cell

%% Prepare the simulation
ifOptimized = true;

if ifOptimized
    % Different drivetrains, numbered from 1 to 16
    fprintf('Running optimized values.\n');
    x.Diesel             = [0 1 15.86000 6 0 0 2.846000 2100 1000 1200];
    x.DieselHybrid       = [0 4 10.520605460 6 0 0 2.8441717180 1909.5221960 1000 1250 10 66 16 11 678.47390480 1329.6630290 28.044216340 0 0.12956916500 32.474264820 406.36894840 500 0.023589275000 1000 78.461491790 0.20089233000 0.31350623800 2 1];
    x.DieselWPT          = [0 4 21.0263405482621 8 0 0 2.75079801131642 1533.73369447105 1001.00956566108 1251.13760132476 9.98720680383947 50 18 34 1943.81328931452 1461.85060573265 77.9601927252744 0 0 30 372.237044691592 425.294982954638 0.0316723286194047 1000 69.4576203674285 0.346534291947138 0.686709186162780 2 1 0.0415562422930985 1];
    x.LNG                = [0 3 13.800882220 6 0 0 2.90 1878.8055380 1200 1304.0170190 6.7149625750 70 22 22];
    x.LNGHybrid          = [0 6 13.774204910 6 0 0 2.7224560210 1863.8839330 1121.4255780 1381.7616290 9.5093264750 62 24 25 1046.7633910 1104.4388630 17 0 0.50467893100 50.895326510 184.81336470 222.50330520 0.025920146000 6193.6814600 67.285637680 0.40768474200 0.22987773600 2 1];
    x.CNG                = [0 2 14.13997046 6 0 0 2.888423077 1884.979771 1162.158336 1328.527388 6.680368096 53 21 29];
    x.CNGHybrid          = [0 5 12.390985310 6 0 0 2.8353013110 1775.1813810 1097.5696080 1395.8710770 10 52 23 24 797.41555600 1500 22.32500 0.14335653600 0.24601746300 47.579877220 354.94236770 170.59968710 0.030822649000 2508.8086190 28.646700290 0.21682574100 0.26175081800 2 1];
    x.LNGDiesel          = [0 9 10.019228510 5 0 0 2.8396232890 2022.7543360 1022.6905600 1254.1651330 6.6841801480 12 29 33];
    x.LNGDieselHybrid    = [0 11 17.079364870 6 0 0 2.8606694640 1810.3914520 1020.2473540 1265.1440220 9.9764551570 83 4 20 658.10577830 1499.8555710 30.523987230 0 0.089152566000 33.216997240 434.94963420 500 0.030662181000 4273.3533630 39.050502600 0.26290110400 0.30288959200 2 1];
    x.CNGDiesel          = [0 8 10.019228510 5 0 0 2.8396232890 2022.7543360 1022.6905600 1254.1651330 6.6841801480 12 29 33];
    x.CNGDieselHybrid    = [0 10 17.079364870 6 0 0 2.8606694640 1810.3914520 1020.2473540 1265.1440220 9.9764551570 83 4 20 658.10577830 1499.8555710 30.523987230 0 0.089152566000 33.216997240 434.94963420 500 0.030662181000 4273.3533630 39.050502600 0.26290110400 0.30288959200 2 1];
    x.BEV                = [1 7 1563 13 1 1166 10.0500050681571 4.34242437682060 3 1 0 978 1339 2 2];
    x.BEV_Tesla          = [1 7 430*4 34 1 100/650 1 10 1 0 0 850 1421 1 2];
    x.BEV_WPT            = [1 12 1563 13 1 400 10.0500050681571 4.34242437682060 3 1 0 978 1339 2 2 0.8 0.3];
    x.BEV_OC             = [1 12 1563 13 1 400 10.0500050681571 4.34242437682060 3 1 0 978 1339 2 2 0.95 0.3];
    x.FCEV               = [1 13 1563 13 1 400 10.0500050681571 4.34242437682060 3 1 0 978 1339 2 2];

    list = fieldnames(x);
%     Choose drivetrain type in input dialog box
    DrvTrn = Drivetrains(list);
    Vehicle = DrvTrn{1};

%     Choose drivetrain type manually
%     DrvTrn = 12;
%     Vehicle = list{DrvTrn};
    
    ifElectric = x.(Vehicle)(1);

%     Create the parameters and Param array
    [ Param ] = Parameterizing(x.(Vehicle)(2), x.(Vehicle)(3:end), ifElectric, Vehicle, ifOptimized);

else 
    fprintf('Manual data entry.\n');
    Vehicle = 'empty';
    
%   Create the parameters and Param array
    [ Param ] = Parameterizing(Kraftstoff, 1, 1, Vehicle, ifOptimized);
end

%% Simulation properties
Param.VSim         = struct;
Param.VSim.Display = 2; % 1: display simulation results in figures  2: view simulation and display simulation results in figures, 3: view simulation and results in command window
Param.VSim.Entwurf = 0;
Param.VSim.Opt     = false; % Display simulation results in figures

%% Driving cycles
%     Param.Fahrzyklus = 1;             % ACEA cycle
    Param.Fahrzyklus = 2;             % Truckerrunde
%     Param.Fahrzyklus = 3;             % Long_Haul
%     Param.Fahrzyklus = 4;             % Uphill climb
%     Param.Fahrzyklus = 5;             % Startup
%     Param.Fahrzyklus = 6;             % Test drive from Neuburg to Paderborn
%     Param.Fahrzyklus = 7;             % Test drive on 23-08-2012 Truckerrunde
%     Param.Fahrzyklus = 8;             % HERE maps drive from Neuburg to Paderborn
%     Param.Fahrzyklus = 9;             % HERE maps and smoothed Truckerrunde
%     Param.Fahrzyklus = 10;            % CSHVC cycle
%     Param.Fahrzyklus = 11;            % Test drive on 23-08-2012 Truckerrunde from Holledau to Langenbruck
%     Param.Fahrzyklus = 12;            % Truck2030 for 100km [1]	M. Fries, A. Baum, M. Wittman, und M. Lienkamp, “Derivation of a real-life driving cycle from fleet testing data with the Markov-Chain-Monte-Carlo Method,” in IEEE ITSC 2018: 21st International Conference on Intelligent Transportation Systems : Mielparque Yokohama in Yokohama, Kanagawa, Japan, October 16-19, 2017, Piscataway, NJ: IEEE, 2018.
%     Param.Fahrzyklus = 13;            % Truck2030 for 200km [1]	M. Fries, A. Baum, M. Wittman, und M. Lienkamp, “Derivation of a real-life driving cycle from fleet testing data with the Markov-Chain-Monte-Carlo Method,” in IEEE ITSC 2018: 21st International Conference on Intelligent Transportation Systems : Mielparque Yokohama in Yokohama, Kanagawa, Japan, October 16-19, 2017, Piscataway, NJ: IEEE, 2018.
%     Param.Fahrzyklus = 14;            % Stationary cycle LVK
%     Param.Fahrzyklus = 15;            % Cycle for 30, 50, 60, 80 km/h
%     Param.Fahrzyklus = 16;            % Full cycle between Sorriso and Santos

%% Simulation run
Param.cycle = Driving_cycle_loading(5);
Cycle = Param.Fahrzyklus;

for Run = 1:2
    Param.Fahrzyklus = 5;
    
    if Run == 2
        Param.Fahrzyklus = Cycle;
        Param.cycle = Driving_cycle_loading(Cycle);
        Param.max_distance = max(Param.cycle.distance);
    end
    [Results] = VSim_run(Param);

    % Simulation postprocessing
    [Results, Param] = VSim_evaluation(Results, Param, Run, Cycle); 
end

%% Saving Results
if ifOptimized
    save(strcat('Results/01_Fahrzeuge/', datestr(now, 'yyyy-mm-dd'), '_', list{DrvTrn}, '.mat'), 'Param', 'Results')
    fprintf('Consumption simulation completed.\n');
    
else
    fprintf('Consumption simulation completed.\n');
end