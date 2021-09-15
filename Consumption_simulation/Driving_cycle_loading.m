function [cycle] = Driving_cycle_loading(Driving_cylce)
% Designed by FTM, Technical University of Munich
%-------------
% Created on: 01.11.2018
% ------------
% Version: Matlab2018a
%-------------
% Function that loads a selected driving cycle
% Required by the consumption simulation
% Will be loaded from an appropriate mat file
% The xlsx files, converted to mat files, can be found under \NFZ-Entwurf\Daten\Fahrzyklen
% Bert Haj Ali
% ------------
% Input:    - Driving_cylce: a scalar number that defines which driving
%                            cycle to choose from
% ------------
% Output:   - cycle:         struct array containing the driving cycle parameters
% ------------

% Select driving cycle according to drop-down menu in Gui_Menue3
fprintf('Loading driving cycle%2.0f \n',Driving_cylce);
switch Driving_cylce
    case 1
        load(['cycle_ACEA' '.mat']); % European Automobile Manufacturers' Association cycle
    case 2
        load(['cycle_Truckerrunde' '.mat']);
    case 3
        load(['cycle_Long_Haul' '.mat']);
    case 4
        load(['cycle_Berg' '.mat']); % driving up an incline
    case 5
        load(['cycle_Anfahren' '.mat']); % start up
    case 6
        load(['cycle_Messfahrt_Neuburg_Paderborn' '.mat']); % test drive between Neuburg and Paderborn
    case 7
        load(['cycle_Messfahrt_23_08_2012_Truckerrunde' '.mat']); % test drive on 23-08-2012        
    case 8
        load(['cycle_Nokia_here_Neuburg_Paderborn' '.mat']); % HERE maps drive from Neuburg to Paderborn
    case 9
        load(['cycle_Nokia_here_glatt_Truckerrunde' '.mat']); % HERE maps and smoothed Truckerrunde
    case 10
        load(['cycle_CSHVC' '.mat']); % emission test cycle
    case 11
        load(['cycle_Messfahrt_23_08_2012_Truckerrunde_Holledau_Langenbruck' '.mat']); % test drive highway     
    case 12
        load(['cycle_T2030_100km' '.mat']);  % Truck2030 for 100km
    case 13
        load(['cycle_T2030_200km' '.mat']);  % Truck2030 for 200km
    case 14
        load(['cycle_Stationaerzyklus' '.mat']); % stationary cycle
    case 15
        load(['cycle_30_50_60_80' '.mat']) % Cycle for 30, 50, 60, 80 km/h
    case 16
        load(['cycle_Gesamtfahrzyklus_Sorriso_Santos' '.mat']) % Full cycle between Sorriso and Santos
    case 17
        load(['cycle_Platooning_leadTruck' '.mat'])
    case 18
        load(['cycle_Platooning_middleTruck' '.mat'])
    case 19
        load(['cycle_Platooning_trailingTruck' '.mat'])
        %edited by MSe to implement the Tractor cycle
    case 20
        load(['cycle_Tractor' '.mat'])
    case 21
        load(['cycle_VECTO_Long_Haul' '.mat'])
    case 22
        load(['cycle_VECTO_Regional_Delivery' '.mat'])
    case 23
        load(['cycle_VECTO_Regional_Delivery_short' '.mat']);
    %edit end
end

if ~isfield(cycle, 'delta12')
    cycle.delta12(1:length(cycle.speed)) = 0;
    cycle.delta23(1:length(cycle.speed)) = 0;
end

end