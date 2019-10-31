function [ v_d, d, d_t, t, t_Exit, d_total, t_total, d_Exit, d_Truck1 ] = platoonStrategy( v_0, v_max, a_01, a_12, d_Platoon, d_Safety )
%% Function to generate a catch up strategy for platooning scenarios
% Designed at FTM, Technical University of Munich
%-------------
% Created on: 15.04.2019
% Modified on: 09.08.2019
% ------------
% Version: Matlab2018b
%-------------
% This function generates the catch up strategy for a truck platoon break
% up and formation scenario.
% Sebastian Wolff
% ------------
% Input:      - v_0       velocity of refernce vehicle (80 km/h in Europe)
%             - v_max     maximum velocity
%             - a_01      deceleration (roll out or braking)
%             - a_12      acceleration
%             - d_Platoon distance in platoon
%             - d_Safety  Safety distance (without platooning, 50m in Europe)
% ------------
% Output:     - v_d       velocity over distance (Array)
%             - d         distance in 1 m steps (Array)
%             - d_t       distance over time (array)
%             - t         time
%             - t_Exit    Time of exit after beginning of strategy in s (scalar)
%             - d_total   Total distance of strategy in m (scalar)
%             - t_total   Total time of strategy in s (scalar)
%             - d_Exit    Distance of exit after beginning of strategy in m (scalar)
%             - d_Truck1  Distance of reference vehicle in m (scalar)
% ------------
%% Sources
% [1]	C. Mährle, S. Wolff, S. Held, G. Wachtmeister - "Influence of the Cooling System and Road Topology on Heavy Duty Truck Platooning", 2019
% 
% ------------

%% Calculate Time and Distance for break up of Platoon

v_0 = v_0 /3.6;

% a_01 = -0.6;
% a_12 = 1.1;

% a_01 = -0.5;
% a_12 = 0.5;

delta = d_Safety - d_Platoon;
x_0 = d_Platoon;

t_2 = sqrt((-delta) / ( 0.5*a_12 + (( (a_12 ^2) - a_01*a_12 ) / ( a_01 - a_12 )) + ((0.5 * (a_12^3) - 0.5 * (a_12^2) * a_01) / (a_01 - a_12)^2)));

t_1 = - ( a_12 / (a_01 - a_12)) * t_2;

v_1 = a_01 * t_1 + v_0;

v_2 = a_12 * (t_2 - t_1) + v_1;

d_1 = 0.5 * a_01 * t_1^2 + v_0*t_1;

d_2 = 0.5 * a_12*(t_2-t_1)^2 + v_2*(t_2-t_1);

sBreakupTotal = d_1 + d_2;

%% Calculate Time and Distance for reformatioan of Platoon

v_4 = v_max /3.6;

t_5 = ( ((v_0 - v_4) * (v_4-v_0) / a_01 ) + ( (v_4 - v_0)*(v_0-v_4) / a_12 ) + ( (v_4-v_0)^2/(2*a_01) ) + ( (v_4-v_0)^2/(2*a_12) ) - delta ) / (v_0-v_4);

v_5 = v_max/3.6;

t_4 = (v_4 - v_0) / a_12;

% t_5 = (delta/(v_max-v_0)) + t_4;
switchVelProfile = false;
t_2 = sqrt((-delta) / ( 0.5*a_12 + (( (a_12 ^2) - a_01*a_12 ) / ( a_01 - a_12 )) + ((0.5 * (a_12^3) - 0.5 * (a_12^2) * a_01) / (a_01 - a_12)^2)));

if t_4 >= t_5
%     t_5 = sqrt((delta-x_0) / ( 0.5*a_01 + (( (a_01 ^2) - a_01*a_12 ) / ( a_12 - a_01 )) + ((0.5 * (a_01^3) - 0.5 * (a_01^2) * a_12) / (a_12 - a_01)^2)));
    t_5 = sqrt( (delta) / ( (0.5*(a_01-a_12) ) - ( (a_12-a_01)^2 / (2*a_01) ) ) ); 

    v_5 = a_12*t_5 + v_0;
    t_4 = 0;
    switchVelProfile = true;
end

t_6 = (v_0-v_5) / a_01 + t_5;

% v_6 = a_01 * (t_6 - t_5) + v_4;

d_4 = 0.5*a_12*t_4^2 + v_0*t_4;

d_5 = v_4 * (t_5-t_4) + d_4;

d_6 = 0.5*a_01*(t_6-t_5)^2 + v_4*(t_6-t_5) + d_5;

dFormationTotal = d_6;


%% What happens during exit

l_Exit = 1000; % Length of Exit
l_Additional = 500; % Addtitional length for safety

t_23 = (l_Exit + 2*l_Additional) / v_0;

t_3 = t_2 + t_23;

% d_3 = v_0 * t_23 + d_2 + d_1;

t_Exit = t_2 + (l_Exit/2 + l_Additional) / v_0;

d_Exit = sBreakupTotal + l_Additional + l_Exit/2;

t_total = t_2 + t_23 + t_6;

d_total = sBreakupTotal + l_Additional + l_Exit + l_Additional + dFormationTotal;

d = 0:d_total;

t = linspace(0,t_total, length(d)) ;

%% Velocity Profile

v = zeros(1,length(t));
d_Truck1 = v;

for i = 1:length(t)
    v(i) = velocityProfile(t(i), t_1, t_2, t_3, t_3+t_4, t_3+t_5, t_3+t_6, a_01, a_12, v_0, v_5, switchVelProfile);
    d_Truck1(i) = v_0 * t(i);
end

d_t = cumtrapz(t, v) - x_0;
v_d = interp1(d_t, v, d);

v_d(isnan(v_d)) = v_0;

% figure
% plot(t, s_t)
% hold on
% plot(t, s_lkw1)
% line([t_1 t_1],[0 s_t(end)]);
% line([t_2 t_2],[0 s_t(end)]);
% line([t_Ausfahrt t_Ausfahrt],[0 s_t(end)]);
% line([t_3 t_3],[0 s_t(end)]);
% line([t_3+t_4 t_3+t_4],[0 s_t(end)]);
% line([t_3+t_5 t_3+t_5],[0 s_t(end)]);
% box off
% xlabel('Zeit in s')
% ylabel('Strecke in m')
% yyaxis right
% plot(t, v*3.6)
% ylabel('Geschwindigkeit in km/h')
% 
% figure
% plot(t, s_t - s_lkw1)
% 
% figure
% plot(s, v_s)

%% Function for velocity for different parts of strategy

    function [v] = velocityProfile(t, t_1, t_2, t_3, t_4, t_5, t_6, a_01, a_12, v_0, v_max, switchVelProfile)
        
        v_min = a_01 * t_1 + v_0;
        
        switch switchVelProfile
            case false % Velocity if v_max is reached
                if t < t_1
                    v = a_01 * t + v_0;
                elseif t < t_2
                    v = a_12 * (t - t_1) + v_min;
                elseif t < t_3
                    v = v_0;
                elseif t < t_4
                    v = a_12 * (t - t_3) + v_0;
                elseif t < t_5
                    v = v_max;
                elseif t <= t_6
                    v = a_01 * (t - t_5) + v_max;
                elseif t > t_6
                    v = v_0;
                end
            case true % Velocity if v_max is not reached
                if t < t_1
                    v = a_01 * t + v_0;
                elseif t < t_2
                    v = a_12 * (t - t_1) + v_min;
                elseif t < t_3
                    v = v_0;
                elseif t < t_5
                    v = a_12 * (t - t_3) + v_0;
                elseif t < t_6
                    v = a_01 * (t - t_5) + v_max;
                elseif t >= t_6
                    v = v_0;
                end
        end
    end
end

