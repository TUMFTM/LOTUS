% Designed by Bert Haj Ali at FTM, Technical University of Munich
%-------------
% Modified on: 17.12.2018
% ------------
% Version: Matlab2017b
%-------------
% This script combines and replaces Stand_alone_Consumption_simulation and
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
    

%% Prepare the simulation
ifOptimized = true; % ifOptimized simulates using an optimized vehicle, the fuel type and drivetrain can be chosen in a GUI
                    % else, you need to chose a fuel type in FuelOptimisation
                    
[Fuel_type, vehicle_param, ifElectric, Vehicle] = FuelOptimisation(ifOptimized); % FuelOptimisation creats an all the parameters needed to start Prametrizing
 
[ Param ] = Parameterizing(Fuel_type, vehicle_param, ifElectric, Vehicle, ifOptimized); % Parameterizing creates the parameters and Param array

%% Simulation propertie
Param.VSim         = struct;
Param.VSim.Display = 3; % 0: command window only  1: Display figures 2: display simulation and figures, 3: display simulation
Param.VSim.Opt     = false; % Display simulation results in figures

%% Driving cycles
%     Param.dcycle = 1;             % ACEA cycle
     Param.dcycle = 2;             % Truckerrunde
%     Param.dcycle = 3;             % Long_Haul
%     Param.dcycle = 4;             % Uphill climb
%     Param.dcycle = 5;             % Startup
%     Param.dcycle = 6;             % Test drive from Neuburg to Paderborn
%     Param.dcycle = 7;             % Test drive on 23-08-2012 Truckerrunde
%     Param.dcycle = 8;             % HERE maps drive from Neuburg to Paderborn
%     Param.dcycle = 9;             % HERE maps and smoothed Truckerrunde
%     Param.dcycle = 10;            % CSHVC cycle
%     Param.dcycle = 11;            % Test drive on 23-08-2012 Truckerrunde from Holledau to Langenbruck
%     Param.dcycle = 12;            % Truck2030 for 100km [1]	M. Fries, A. Baum, M. Wittman, und M. Lienkamp, “Derivation of a real-life driving cycle from fleet testing data with the Markov-Chain-Monte-Carlo Method,” in IEEE ITSC 2018: 21st International Conference on Intelligent Transportation Systems : Mielparque Yokohama in Yokohama, Kanagawa, Japan, October 16-19, 2017, Piscataway, NJ: IEEE, 2018.
%     Param.dcycle = 13;            % Truck2030 for 200km [1]	M. Fries, A. Baum, M. Wittman, und M. Lienkamp, “Derivation of a real-life driving cycle from fleet testing data with the Markov-Chain-Monte-Carlo Method,” in IEEE ITSC 2018: 21st International Conference on Intelligent Transportation Systems : Mielparque Yokohama in Yokohama, Kanagawa, Japan, October 16-19, 2017, Piscataway, NJ: IEEE, 2018.
%     Param.dcycle = 14;            % Stationary cycle LVK
%     Param.dcycle = 15;            % Cycle for 30, 50, 60, 80 km/h
%     Param.dcycle = 16;            % Full cycle between Sorriso and Santos

%% Simulation run
Param.cycle = Driving_cycle_loading(5);
Cycle = Param.dcycle;

for Run = 1:2
    Param.dcycle = 5;
    
    if Run == 2     
        Param.dcycle = Cycle;
        Param.cycle = Driving_cycle_loading(Cycle);
        Param.max_distance = max(Param.cycle.distance);
    end
    [Results] = VSim_run(Param);
    %[ Results ] = VSim_ausfuehren_accelerator(Param);

    % Simulation postprocessing
    [Results, Param] = VSim_evaluation(Results, Param, Run, Cycle); 
end

%% Saving Results
% if ifOptimized
%     save(strcat('Results/01_Fahrzeuge/', datestr(now, 'yyyy-mm-dd'), '_', list{DrvTrn}, '.mat'), 'Param', 'Results')
%     fprintf('Consumption simulation completed.\n');
%     
% else
    fprintf('Consumption simulation completed.\n');
% end