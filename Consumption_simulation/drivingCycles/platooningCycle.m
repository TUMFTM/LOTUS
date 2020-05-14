function [] = platooningCycle(d_cycle, v_0, v_max, delta_platoon, delta_safety, d_exit_ref, slope, a01, a12)
%% Function to generate a catch up strategy for platooning scenarios
% Designed at FTM, Technical University of Munich
%-------------
% Created on: 15.04.2019
% Modified on: 09.08.2019
% ------------
% Version: Matlab2018b
%-------------
% This function generates the driving cycles as input for HDVSim for
% different platooning scenarios. It includes single and multiple break ups
% and formations for a three vehicle heavy-duty truck platoon.
% Sebastian Wolff
% ------------
% Input:      - d_cycle         Total distance of cycle in m (scalar)
%             - v_0             Reference velocity in km/h (scalar)
%             - v_max           Maximum velocity in km/h (scalar)
%             - delta_platoon   Distance betw. vehicles in platoon in m(scalar)
%             - delta_safety    Safety Distance betw. vehicles in m (scalar)
%             - d_exit_ref      Distance of exits on track (scalar [single exit] or array [Multiple exits)
%             - slope           Slope of cycle in decimal (eg. 0.01 for 1% slope)
%             - a01             Decceleration during break up in m/s2
%             - a12             Acceleration during reformation in m/s2
% ------------
% Output:   - none, files are saved
% ------------
%% Sources
% [1]	C. Mährle, S. Wolff, S. Held, G. Wachtmeister - "Influence of the Cooling System and Road Topology on Heavy Duty Truck Platooning", 2019
% 
% ------------
%% Not used anymore - input of function
% Parameters
% d_ref = 50000;      % Total distance in m
% v_ref = 85;         % Velocity in kph
% v_max = 92;         % Maximum velocity in kph

% delta_platoon = 5;      % Distance betw. trucks in platoon in m
% delta_exit = 50;        % Distance betw. trucks during exit in m

% a_brake = -0.5;         % Rolling deccelartion in m/s2
% a_max = 0.5;            % Max. acceleration in m/s2

% d_exit_ref(i) = 45000;   % Center of highway exit in m

%% Default values
cycleLead.stop_end = 5;
cycleLead.stop_start = 5;
cycleLead.speed_init = 0;


%% 80 km/h w/o slope
cycleLead.distance = 1:d_cycle;
cycleLead.speed(1:d_cycle) = v_0/3.6;
cycleLead.slope(1:d_cycle) = slope;
cycleLead.altitude(1:d_cycle) = 0.00;
cycleLead.delta12(1:d_cycle) = delta_platoon;
cycleLead.delta23(1:d_cycle) = delta_platoon;
cycleLead.stop_time(1:d_cycle) = 0;

cycleMiddle = cycleLead;
cycleTrail = cycleLead;

%% Velocity for platoon

% Middle vehicle
[ v_ref_platoon, ~, d_t_platoon, t_platoon_1, ~, d_total, ~, d_exit_platoon, d_platoon_12] = platoonStrategy( v_0, v_max, a01, a12, delta_platoon, delta_safety );
% Trailing vehicle
[ v_ref_platoon_2, ~, d_t_platoon_2, t_platoon_2, ~, d_total_2, ~, d_exit_platoon_2, ~] = platoonStrategy( v_0, v_max, a01, a12, delta_platoon*2, delta_safety*2 );

%% Check if cycle is possible

if d_cycle <= d_exit_ref + (d_total_2 - d_exit_platoon_2)
    error('Cycle is too short. Please use longer cycle distance')
end

%% Calculate distance
delta_12 = d_platoon_12 - d_t_platoon;
delta_23 = interp1(t_platoon_1, d_t_platoon, t_platoon_2, 'linear', 'extrap') - d_t_platoon_2;

%% Merge cycle and platoon Middle Truck
for i = 1:length(d_exit_ref)
    if d_exit_ref(i) ~= 0
        % Opening Platoon
        cycleMiddle.speed( (d_exit_ref(i) - (length(v_ref_platoon) - int64(d_exit_platoon)) ):d_exit_ref(i)-1) = v_ref_platoon(1:(length(v_ref_platoon) - int64(d_exit_platoon)));
        cycleMiddle.delta12( (d_exit_ref(i) - (length(v_ref_platoon) - int64(d_exit_platoon)) ):d_exit_ref(i)-1) = delta_12(1:(length(v_ref_platoon) - int64(d_exit_platoon)));
        
        % Closing Platoon
        k = length(( d_exit_ref(i):int64(d_exit_ref(i)+(d_total - d_exit_platoon )) )) - length(v_ref_platoon(int64(d_exit_platoon):end));
        cycleMiddle.speed( d_exit_ref(i):int64(d_exit_ref(i)+(d_total - d_exit_platoon - k)) ) = v_ref_platoon(int64(d_exit_platoon):end);
        cycleMiddle.delta12( d_exit_ref(i):int64(d_exit_ref(i)+(d_total - d_exit_platoon - k)) ) = delta_12(int64(d_exit_platoon):end);
        

    end
    
end
for i = 1:length(d_exit_ref)
    if d_exit_ref(i) ~= 0
                %% Merge cycle and platoon Trailing Truck
                % Opening Platoon
                cycleTrail.speed( (d_exit_ref(i) - (length(v_ref_platoon_2) - int64(d_exit_platoon_2)) ):d_exit_ref(i)-1) = v_ref_platoon_2(1:(length(v_ref_platoon_2) - int64(d_exit_platoon_2)));
                cycleTrail.delta23( (d_exit_ref(i) - (length(v_ref_platoon_2) - int64(d_exit_platoon_2)) ):d_exit_ref(i)-1) = delta_23(1:(length(v_ref_platoon_2) - int64(d_exit_platoon_2)));
        
                % Closing Platoon
                k = length(( d_exit_ref(i):int64(d_exit_ref(i)+(d_total_2 - d_exit_platoon_2 )) )) - length(v_ref_platoon_2(int64(d_exit_platoon_2):end));
                cycleTrail.speed( d_exit_ref(i):int64(d_exit_ref(i)+(d_total_2 - d_exit_platoon_2 - k)) ) = v_ref_platoon_2(int64(d_exit_platoon_2):end);
                cycleTrail.delta23( d_exit_ref(i):int64(d_exit_ref(i)+(d_total_2 - d_exit_platoon_2 - k)) ) = delta_23(int64(d_exit_platoon_2):end);
    end
end
clear cycle
cycleLead.delta12 = cycleMiddle.delta12;
cycleLead.delta23 = cycleTrail.delta23;
cycleMiddle.delta23 = cycleTrail.delta23;
%% Work around REMOVE LATER
cycleTrail.delta12 = cycleTrail.delta23;
%-------

cycle = cycleLead;
%save('C:\Users\Max\Desktop\HiWi\Sebastian Wolff\Truck_Simulation_Publication_git\Consumption_simulation\Fahrzyklen\cycle_Platooning_leadTruck.mat', 'cycle')
save('\Truck Simulation\Consumption_simulation\drivingCycles\cycle_Platooning_leadTruck.mat', 'cycle')
cycle = cycleMiddle;
%save('C:\Users\Max\Desktop\HiWi\Sebastian Wolff\Truck_Simulation_Publication_git\Consumption_simulation\Fahrzyklen\cycle_Platooning_middleTruck.mat', 'cycle')
save('\Truck Simulation\Consumption_simulation\drivingCycles\cycle_Platooning_middleTruck.mat', 'cycle')
cycle = cycleTrail;
%save('C:\Users\Max\Desktop\HiWi\Sebastian Wolff\Truck_Simulation_Publication_git\Consumption_simulation\Fahrzyklen\cycle_Platooning_trailingTruck.mat', 'cycle')
save('\Truck Simulation\Consumption_simulation\drivingCycles\cycle_Platooning_trailingTruck.mat', 'cycle')



% %% delete variables
% clearvars -except cycle
