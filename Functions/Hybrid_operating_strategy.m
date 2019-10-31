function [SOC_addition,critical_altitude_difference,distance_PPC_altitude_difference, addition_for_critical_slope, em, Bat, SOC_target, SOC_T_EM_completely_available, v_max_electrical_drive_only, T_distance_LPS_up, T_distance_LPS_down] = Hybrid_operating_strategy(x, Fueltype)
% Designed by Bert Haj Ali in FTM, Technical University of Munich
%-------------
% Created on: 06.11.2018
% ------------
% Version: Matlab2017b
%-------------
% This function reads hybrid-related parameters from the hybrid vehicles
% and assigns the variables related to battery and electric motors to
% create the hybrid operating strategy when hyberdization is present
% ------------
% Input:    - x:           struct array containing all vehicle parameters
%           - Fueltype:  a scalar number that defines which type
%                          of fuel is selected
% ------------
% Output:   - em:          struct array containing electric motor variables such as
%                          torque and rotational speed
%           - Bat:         struct array that contains battery variables
%           - Other electric driving parameters explained below
% ------------    
    switch Fueltype
        case{4,5,6,10,11} % All hybrid drivetrains
            % Electric motor parameters
            em.M_max                             = x(13);
            em.n_eck                             = x(14);
            em.Type                              = x(27); %Electrical machine type, 1: PMSM; 2: ASM
            em.P_max                             = ((em.n_eck * em.M_max *2* pi)/60)/1000; %[kW] Maximum power
            em.n_max                             = 2000;  %[rpm] Maximum rotational speed

            % Battery parameters 
            Bat.Useable_capacity              = x(15); %[Ah] Battery capacity        
            Bat.Useable_range                = x(25); %Battery DoD
            Bat.Type                             = x(26); %Battery type, 1: Cylindrical; 2: Pouch
            Bat.SOC_start                        = 1;     %[-] Initial battery SOC
            Bat.Voltage                         = 800;   %Battery voltage
            Bat.Charge_cycles                       = ((Bat.Useable_range*100)/15440)^(1/-0.652); % Number of charging cycles. Source: MARKEL, T. und SIMPSON, A.: Plug-in Hybrid Electric Vehicle Energy Storage System Design. In: Advanced Automotive Battery Conference Baltimore, Maryland, 2006
            Bat.Efficiency_power_electronics = 0.95;  %[-] Efficiency of the power electronics converter

            % Electric driving parameters
            SOC_target                           = x(16); %Variable name in Paper: SOC_Target
            SOC_T_EM_completely_available        = x(17); %Variable name in Paper: SOC_Boosting_fully available
            v_max_electrical_drive_only          = x(18)/3.6; %Variable name in Paper: v_eldrive, maximum speed up to which the vehicle is driven purey electrically
            T_distance_LPS_up                    = x(19); %Variable name in Paper: T_slp_up, Distance to the line of minimal consumption in Nm 
            T_distance_LPS_down                  = x(20); %Variable name in Paper: T_slp_down, Distance to the line of minimal consumption in Nm 
            addition_for_critical_slope          = x(21); %Variable name in Paper: Slope_addition, range: 1 to 5 %
            distance_PPC_altitude_difference     = x(22); %Variable name in Paper: distance_altitude_difference. The distance ahead in m that the active cruise control can see
            critical_altitude_difference         = x(23); %Variable name in Paper: altitude_difference_critical, critical height distance in m
            SOC_addition                         = x(24); %Variable name in Paper: SOC_addition is incremented by SOC_addition
            
        case{1,2,3,8,9} % Non-hybrid drivetrains
            % All the parameters below are generic and not used in
            % non-hybrid vhicles. However, they are required for the
            % Simulink models to run
            
            % Electric motor parameters
            em.Type                              = 1;                                 
            em.n_eck                             = 1300;                      
            em.M_max                             = 1050;                              
            em.n_max                             = 2000;  
            em.P_max                             = 0;
            
            % Battery parameters 
            Bat.SOC_start                        = 1;    
            Bat.Voltage                         = 650;                          
            Bat.Useable_range                = 0.8;                 
            Bat.Charge_cycles                       = ((Bat.Useable_range*100)/15540)^(1/-0.652);
            Bat.Useable_capacity              = 30;               
            Bat.Efficiency_power_electronics = 0.95;  
            Bat.Type                             = 1;
            
            % Electric driving parameters
            SOC_target                           = 0.1;
            SOC_T_EM_completely_available        = 0.5; 
            v_max_electrical_drive_only          = 50/3.6; 
            T_distance_LPS_up                    = 250;    
            T_distance_LPS_down                  = 250;
            addition_for_critical_slope          = 0.01;
            distance_PPC_altitude_difference     = 10000;
            critical_altitude_difference         = 50;
            SOC_addition                         = 0.4; 
    end
end

