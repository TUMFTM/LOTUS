function [v_PPC_delta, look_ahead_PPC, distance_1_PPC, distance_2_PPC] = Active_cruise_control(x, Fueltype)
% Designed by Bert Haj Ali in FTM, Technical University of Munich
%-------------
% Created on: 06.11.2018
% ------------
% Version: Matlab2017b
%-------------
% The function creates and assigns the predictive cruise control variables
% ------------
% Input:    - x:              struct array containing all vehicle parameters
%           - Fueltype:     a scalar number that defines which type
%                             of fuel is selected
% ------------
% Output:   - v_PPC_delta:    Speed increase/fall below speed, standard value at 7 km/h  
%           - look_ahead_PPC: Look ahead to seek the critical position, lower limit
%           - distance_1_PPC: Range: 100 - 500m slope_length_positive Length of slope, sets upper limit with look_ahead
%           - distance_2_PPC: Range: 200 -400m slope_length_neg Length of the track before a critical gradient
% ------------        
    Temp1 = 100:10:1000; % Discretization of the look ahead distance in 10m increments from 100 to 1000m 
    Temp2 = 100:10:500;  % Discretization of the look ahead distance in 10m distances from 100 to 500m 
    
    switch Fueltype
        case{1} % Diesel
            v_PPC_delta    = 10/3.6;   % Speed increase/fall below speed, standard value at 7 km/h  
            look_ahead_PPC = 250;      % 100 - 1000m ahead for seeking the critical slope, lower limit
            distance_1_PPC = 175;      % 100 - 500m slope_length_positive Length of slope, sets upper limit with look_ahead
            distance_2_PPC = 200;      % 200 -400m slope_length_neg Length of the track before a critical gradient  
            
        otherwise % Rest of the drivetrains
            v_PPC_delta    = x(9)/3.6; % Speed increase/fall below speed, standard value at 7 km/h                          
            look_ahead_PPC = Temp1(x(10)); % 100 - 1000m ahead for seeking the critical slope, lower limit                    
            distance_1_PPC = Temp2(x(11)); %Variable name in Paper: distance_slope_positive
            distance_2_PPC = Temp2(x(12)); %Variable name in Paper: distance_slope_negative

            % Function for the predicive cruise control
            %IZ12 = x(4) + IZ12;
    end
end

