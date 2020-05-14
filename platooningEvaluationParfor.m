%% Script to run different evaluations for platooning
% Designed at FTM, Technical University of Munich
%-------------
% Created on: 15.04.2019
% Modified on: 10.10.2019
% ------------
% Version: Matlab2018b
%-------------
% This script is for evaluating different scenarios for heavy-duty truck
% platooning.
% Sebastian Wolff
% ------------
% Input:    - none
% ------------
% Output:   - Param: struct array containing all simulation parameters
%           - Results: struct array containing all simulation results
% ------------
%% Sources
% [1]	C. Mährle, S. Wolff, S. Held, G. Wachtmeister - "Influence of the Cooling System and Road Topology on Heavy Duty Truck Platooning", 2019
% 
% ------------

delete(gcp('nocreate')) % delete parallel pool if exists

save_data = false; % Save results, uncomment next line to define filename
%filename = strcat(datestr(now,'yymmdd'),{'_myPlatooningReults'},{'.mat'});

%% Add folders
% ------------------
% genpath includes all necessary folders for running the simulation
% ------------------
addpath('Classes');
addpath('Functions');
addpath(genpath('Consumption_simulation'));
addpath(genpath('Optimization'));
addpath('TCO');
addpath('Post-processing');
addpath('Results');

%%  Select Fuel type
Fueltype = 1;     % Diesel
%     Fueltype = 2;     % CNG
%     Fueltype = 3;     % LNG
%     Fueltype = 4;     % Diesel Hybrid
%     Fueltype = 5;     % CNG Hybrid
%     Fueltype = 6;     % LNG Hybrid
%     Fueltype = 7;     % Electric
%     Fueltype = 8;     % Diesel & CNG
%     Fueltype = 9;     % Diesel & LNG
%     Fueltype = 10;    % Diesel & CNG Hybrid
%     Fueltype = 11;    % Diesel & LNG Hybrid
%     Fueltype = 12;    % Electric w/WPT
%     Fueltype = 13;    % Hydrogen fuel cell

%% Prepare the simulation
Vehicle = 'empty';

%   Create the parameters and Param array
[ Param ] = Parameterizing(Fueltype, 1, 1, Vehicle, false);
% Predictive cruise control [3]
Param.prospective_cruise_control = false;      % Active cruise control 1 = ON 0 = OFF

% Cruising [3]
Param.Sailing_without_drag_torque = false;    % ON or OFF

Param.VSim.Display = 0; % Supress output
Param.VSim.Opt = true; % Enable parallel support

% Assign Platooning Simulink file
Param.name = 'HDVSim_Hybrid_Truck_Platooning';


Param_temp = Param;

%% Parameter

% Load CFD results for cD
load('Consumption_simulation\Parameter\ITSC Paper Platooning\Platooning_cD_Map.mat')

% Assign standard cD for reference vehicle
cWDataRef = ones(length(cD_Data.d_T12),length(cD_Data.d_T12)) .* 0.527; % Reference: single vehicle with constant c_W || With 25 m distance: 0.474

cWData(1,:,:) = cD_Data.cD_T1;
cWData(2,:,:) = cD_Data.cD_T2;
cWData(3,:,:) = cD_Data.cD_T3;

cycleData = [17; 18; 19];

% Load cooling simulation results to include in HDVSim
load('Consumption_simulation\Parameter\ITSC Paper Platooning\Power_Slope_NoExits.mat')

%% Scenarios
distanceData = 5:5:50; % constant distances between vehicles in platoon between 5-50 m
noExits = 1:6; % Number of exits (i.e. break up and reformation of platoon)
% v_max_Data = 81:1:100; % Different maximum velocity for catch up strategies
% a_accel = 0.05:0.05:0.3; % Variation of acceleration for catch up strategy
% a_brake = -1:0.1:-0.5; % Variation of decelaration for catch up strategy
% slopeData = (-0.5:0.25:1.25) * 1e-2; % Variation of road gradient
% slopeData = (-0.5:0.25:3) * 1e-2;

% The following lines can be used to simulate all possible combinations of
% two scenario parameters
% param_data = combvec(a_brake, a_accel);
param_data = combvec(distanceData, noExits);
% paramData = combvec(noExits, slopeData);

% Set number of parameters
n1 = size(cWData,1); % Driving Cycles (4 in total: Reference, Truck 1-3)
n2 = length(distanceData);



%% Preallocate struct

Param = cell(n1,n2);
Results = cell(n1,n2);
Consumption = zeros(n1, n2);
t_sim = zeros(n1, n2);

%% Run Reference simulation

platooningCycle(50000, 85, 92, 5, 50, 0, -0.005, -0.5, 0.3)

fprintf('--------------------------------------------\n')
fprintf('Reference Simulation\n')
fprintf('--------------------------------------------\n')

% Pass Variables because of parfor
Param_ref = Param_temp;
Param_ref.VSim.Display = 3; % Supress output
Param_ref.VSim.Opt = false;
Zyklus = 18;
Param_ref.vehicle.air_drag_coeff = cWDataRef;

% Assign cooling system power
Param_ref.auxiliary_consumers.coolingSystem = Power_Slope_NoExit{1,2}(:,7);

% Run Simulation
for j=1:2
    Param_ref.dcycle = 5;
    Param_ref.cycle = Driving_cycle_loading(5);
    if j==2
        Param_ref.dcycle = Zyklus;
        Param_ref.cycle = Driving_cycle_loading(Zyklus);
        Param_ref.max_distance = max(Param_ref.cycle.distance);
    end
    
    Results_ref = VSim_run(Param_ref);
    
    % Evaluate Simulation
    [ Results_ref, Param_ref ] = VSim_evaluation( Results_ref, Param_ref , j, Param_ref.dcycle);
    
end

%% Run Simulation
poolobj = parpool('local');

% Run addpath on every worker
pctRunOnAll        addpath('Classes');
pctRunOnAll        addpath('Functions');
pctRunOnAll        addpath(genpath('Consumption_simulation'));
pctRunOnAll        addpath(genpath('Optimization'));
pctRunOnAll        addpath('TCO')

tempCounter = repmat(1:8,1,6);
paramData(3,:) = sort(tempCounter);

for ii = 1:n2
%     exits = linspace(5000, 40000, ii);
    
    platooningCycle(50000, 80, 92, 5, 50, linspace(3000,45000, paramData(1,ii)), paramData(2,ii), -0.5, 0.3)
%     platooningCycle(50000, 80, 92, 5, 50, 0, 0, -0.5, 0.3)

    parfor i = 1:n1
        
        fprintf('--------------------------------------------\n')
        fprintf('Simulation %d of %d || Parameterset %d of %d\n', i, n1, ii, n2)
        fprintf('--------------------------------------------\n')
        
        % Pass Variables because of parfor
        Param{i, ii} = Param_temp;
        
        % Zu untersuchender Parameter
        Zyklus = cycleData(i);
        Param{i, ii}.vehicle.air_drag_coeff = squeeze(cWData(i,:,:));
        
        % Assign cooling system power

        Param{i, ii}.auxiliary_consumers.coolingSystem = Power_Slope_NoExit{i, 1}(:,7);
        
        
        % Run Simulation
        for j=1:2
            Param{i, ii}.dcycle = 5;
            Param{i, ii}.cycle = Driving_cycle_loading(5);
            if j==2
                Param{i, ii}.dcycle = Zyklus;
                Param{i, ii}.cycle = Driving_cycle_loading(Zyklus);
                Param{i, ii}.max_distance = max(Param{i, ii}.cycle.distance);
            end
            
            Results{i, ii} = VSim_run(Param{i, ii});
            
            % Evaluate Simulation
            [ Results{i, ii}, Param{i, ii} ] = VSim_evaluation( Results{i, ii}, Param{i, ii} , j, Param{i, ii}.dcycle);
            
        end
    end
end

fprintf('Finished\n')

%% Save results
if save_data == true
    
    fprintf('Saving Results\n')
    save(filename{1}, 'Param', 'Results');
    
end







