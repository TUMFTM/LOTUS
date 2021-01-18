function [em, Bat] = Electric_drivetrain(x)
% Designed by Bert Haj Ali in FTM, Technical University of Munich
%-------------
% Created on: 06.11.2018
% ------------
% Version: Matlab2017b
%-------------
% This function reads the parameters concenring the battery and electric
% motors when the vehicle is a pure EV and assigns them to their respective
% variables.
% ------------
% Input:    - x:   struct array containing all vehicle parameters
% ------------
% Output:   - em:  struct array containing electric motor variables such as
%                  torque and rotational speed
%           - Bat: struct array that contains battery variables
% ------------
    % Electric motor paremeters
    em.M_max                             = x(1);
    Temp1                                = 1000:100:5000; % Discretization of the rotational speed in 100rpm increments from 1000 to 5000rpm
    em.n_eck                             = Temp1(x(2));
    em.P_max                             = ((em.n_eck * em.M_max *2* pi)/60)/1000; %[kW] Maximum power
    em.Type                              = x(13); % Electrical machine type 1: PMSM; 2: ASM
    em.n_max                             = 10000; % Maximum rotational speed
    em.noEM                              = 1; % Default number of electric machines
    
    % Battery parameters
    %Bat.Voltage                        = x(3); % Not used in this case
    Bat.Useable_range                = x(3);
    Bat.Useable_capacity              = x(4);
    Bat.Type                             = x(12); % Battery type 1: Cylindrical; 2: Pouch
    Bat.SOC_start                        = 1;     %[-] Initial battery SOC
    Bat.Voltage                         = 800;   %[V] Battery voltage
    Bat.Efficiency_power_electronics = 0.95;  %[-] Efficiency of the power electronics converter
    Bat.Charge_cycles                       = ((Bat.Useable_range*100)/15440)^(1/-0.652); % Number of charging cycles. Source: MARKEL, T. und SIMPSON, A.: Plug-in Hybrid Electric Vehicle Energy Storage System Design. In: Advanced Automotive Battery Conference Baltimore, Maryland, 2006
    
end


