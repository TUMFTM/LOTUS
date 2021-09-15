function [ transmission ] = Transmission_gearing(range, z_int, overdrive, dsg, final_drive)
% Designed by FTM, Technical University of Munich
%-------------
% Created on: 01.11.2018
% ------------
% Version: Matlab2017b
%-------------
% Function for the design of gears for the consumption simulation and optimization
% ------------
% Input:    - range:        spread (i_g_max / i_g_min)
%                           is selected
%           - z_int:        Number of gears, discrete variable between 1 and 8
%           - overdrive:    Binary value 0 or 1, turn ON or OFF the
%                           overdrive function in the transmission
%           - dsg:          Binary (0 or 1), determines if there is a
%                           dual-clutch transmission 
%           - final_drive:  Final drive ratio of the rear differential
% ------------
% Output:   - transmission: struct array containing transmission variables
% ------------
%% Assign transferred variables
% Needed for optimization using discrete parameters
gears = [1 2 4 6 8 10 12 16]; % Possible gears: 8, 10 12 or 16 gears
z = gears(z_int); % Assign gear number to the discrete variable needed for optimization

%% Preallocate Transmission Struct
if dsg == 1
    shift_time = 0; % Shifting time = 0 in order to simulate a DSG
else
    shift_time = 1; % Standard shifing time
end

transmission = struct('init_gear', 1, 'shift_time', shift_time, 'ratios', 1:z, 'trq_eff', 1:z, 'lamda', 1:z);

%% Calculate gearing
ratios_out = zeros(1,z); % Preallocation
phi_th = (range)^(1/(z-1)); % Calculation of the geometric increment

if overdrive == 0
    for i = 1:z % Calculation of the translations of the individual gears
        ratios_out (1,i) = 1*phi_th^(z-i);
    end
    
else
    for i = 2:z+1 % Calculation of the translations of the individual gears for overdrive
        ratios_out (1,i-1) = 1*phi_th^(z-i);
    end
end

%% Calculate efficiencies
eta_ges = 1:z;            % Preallocation

if overdrive == 0
    switch z
        case {8}
            eta_ges = [0.96 0.96 0.96 0.98 0.97 0.97 0.97 0.99];   %[-] Efficiency of the gears  
        case {10}
            eta_ges = [0.96 0.96 0.96 0.96 0.98 0.97 0.97 0.97 0.97 0.99];   %[-] Efficiency of the gears
        case {12}
            eta_ges = [0.96 0.96 0.96 0.96 0.96 0.98 0.97 0.97 0.97 0.97 0.97 0.99];   %[-] Efficiency of the gears
        case {16}
            eta_ges = [0.96 0.96 0.96 0.96 0.96 0.96 0.96 0.98 0.97 0.97 0.97 0.97 0.97 0.97 0.97 0.99];   %[-] Efficiency of the gears
        otherwise
            eta_ges = linspace(0.96, 0.99, z);
    end
    
else % Overdrive -> Highest gear, worse efficiency
    switch z
        case {8}
            eta_ges = [0.96 0.96 0.96 0.98 0.97 0.97 0.99 0.97];   %[-] Efficiency of the gears   
        case {10}
            eta_ges = [0.96 0.96 0.96 0.96 0.98 0.97 0.97 0.97 0.99 0.97];   %[-] Efficiency of the gears 
        case {12}
            eta_ges = [0.96 0.96 0.96 0.96 0.96 0.98 0.97 0.97 0.97 0.97 0.99 0.97];   %[-] Efficiency of the gears 
        case {16}
            eta_ges = [0.96 0.96 0.96 0.96 0.96 0.96 0.96 0.98 0.97 0.97 0.97 0.97 0.97 0.97 0.99 0.97];   %[-] Efficiency of the gears 
        otherwise
            eta_ges = linspace(0.96, 0.99, z);
    end
end

% Plotting the efficiencies of each gear
%plot([1:z], eta_ges, '+')

%% Input gearbox for electric truck
if z == 1
    ratios_out = [range range];
    eta_ges = [0.99 0.99];
end

%% Values to interpolate
lambda = [1.23, 1.12, 1.07, 1.04, 1.024, 1.019, 1.013, 1.011, 1.009, 1.008, 1.007, 1.006]; % Lambda
i_k = [45.1376 35.1091 27.3087 21.2414 16.5221 12.8513 9.9960 7.7752 6.0477 4.7040 3.6589 2.8460]; % total translation: i_g * i_achsgetriebe

% Overall ratio of the gearbox
i_ges = ratios_out * final_drive;

% Interpolate lambda
lambda_out = interp1(i_k, lambda, i_ges,'spline', 'extrap');

%% Output
transmission.shift_time = shift_time;%[s] shifting time
transmission.ratios =  ratios_out;   %[-] Ratios of the individual gears
transmission.trq_eff = eta_ges;      %[-] Efficiency of the gears
transmission.lamda = lambda_out;     %[-] Factor to account for the rotating mass
transmission.z = z;                  %[-] Number of gears in the transmission

end