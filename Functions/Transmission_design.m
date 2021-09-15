function [transmission, final_drive, engine] = Transmission_design(x, Fueltype)
% Designed by Bert Haj Ali in FTM, Technical University of Munich
%-------------
% Created on: 06.11.2018
% ------------
% Version: Matlab2017b
%-------------
% The function Transmission_design() reads the needed parameters of the
% vehicles and assigns the variables concerning transmission, gearing and
% shifting strategies
% ------------
% Input:    - Fueltype:   a scalar number that defines which type of fuel
%                           is selected
%           - x:            struct array containing all vehicle parameters
% ------------
% Output:   - transmission: struct array containing transmission variables
%           - final_drive:  a cell array that contains the differential
%                           variables
%           - engine:       a struct array that contains the ICE engine
%                           variables such as torque and power
% ------------    
    switch Fueltype
        case {1,2,3,14} % {'Diesel','CNG','LNG','H2ICE'}
            transmission                      = Transmission_gearing(x(1), x(2), x(3), x(4), x(5));  
            final_drive.ratio                 = x(5);
            engine.M_max                      = x(6);
            engine.shift_parameter.n_lo       = x(7); % lower shifting threshold
            engine.shift_parameter.n_pref     = x(8); % upper shifting threshold
        
        case {4,5,6,15} % {'Diesel-Hybrid','CNG-Hybrid','LNG-Hybrid','H2-Hybrid'}
            transmission                      = Transmission_gearing(x(1), x(2), x(3), x(4), x(5));  
            final_drive.ratio                 = x(5);
            engine.M_max                      = x(6);
            engine.shift_parameter.n_lo       = x(7);
            engine.shift_parameter.n_pref     = x(8); 
            
       case {7, 13} % {Electric, Fuell cell}
            transmission                      = Transmission_gearing(x(6), x(7), x(8), x(9), x(5));  
            final_drive.ratio                 = x(5);
            engine.shift_parameter.n_lo       = x(10); 
            engine.shift_parameter.n_pref     = x(11);
            
        case {8,9,16} % Dual-Fuel {CNG, LNG, H2}
            transmission                      = Transmission_gearing(x(1), x(2), x(3), x(4), x(5));  
            final_drive.ratio                 = x(5);
            engine.M_max                      = x(6);
            engine.shift_parameter.n_lo       = x(7); 
            engine.shift_parameter.n_pref     = x(8); 
            
        case {10,11,17} % Dual-Fuel Hybrid {CNG, LNG, H2}
            transmission                      = Transmission_gearing(x(1), x(2), x(3), x(4), x(5));  
            final_drive.ratio                 = x(5);
            engine.M_max                      = x(6);
            engine.shift_parameter.n_lo       = x(7); 
            engine.shift_parameter.n_pref     = x(8); 
            
        case 12 % Fully electric with WPT
            transmission                      = Transmission_gearing(x(6), x(7), x(8), x(9), x(5));  
            final_drive.ratio                 = x(5);
            engine.shift_parameter.n_lo       = x(10); % lower shifting limit
            engine.shift_parameter.n_pref     = x(11); % upper shifting limit
    end
    
    final_drive.trq_eff                       = 0.98;  %[-] Efficiency of the differential
end

