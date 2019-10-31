function [tank] = Tank_sizes(Fueltype)
% Designed by Bert Haj Ali in FTM, Technical University of Munich
%-------------
% Created on: 14.12.2018
% ------------
% Version: Matlab2017b
%-------------
% This function assigns the tank sizes or volume in liters for the
% different drivetrains
% ------------
% Input:    - Fueltype: a scalar number that defines which type of fuel
%                         is selected
% ------------
% Output:   - tank:       a cell array that contains the sizes of all
%                         available tanks used in the simulation. Even if
%                         the tank is not present, its value is need for
%                         the Simulink models to run
% ------------    
    switch Fueltype
        case {1,4} % All variants with diesel engines
            tank.v_diesel = 500; % Tank volume [l]
            tank.v_cng    = 0;
            tank.v_lng    = 0;
            tank.m_h2     = 0;   % Tank volume [kgH2]
        
        case {3,6} % All variants with LNG
            tank.v_diesel = 0; 
            tank.v_cng    = 0;
            tank.v_lng    = 400;
            tank.m_h2     = 0;

        case {2,5} % All variants with CNG
            tank.v_diesel = 0; 
            tank.v_cng    = 200;
            tank.v_lng    = 0;
            tank.m_h2     = 0;

        case {7,12} % Electric truck
            tank.v_diesel = 0;
            tank.v_lng    = 0;
            tank.v_cng    = 0;
            tank.m_h2     = 0;

        case {8,10} % Dual Fuel, Diesel + CNG (Composite Tank)
            tank.v_diesel = 300; 
            tank.v_cng    = 150;
            tank.v_lng    = 0;
            tank.m_h2     = 0;

        case {9,11} % Dual Fuel, Diesel + LNG
            tank.v_diesel = 300; 
            tank.v_cng    = 0;
            tank.v_lng    = 300;
            tank.m_h2     = 0;

        case 13 % Hydrogen vehicle
            tank.v_diesel = 0; 
            tank.v_cng    = 0;
            tank.v_lng    = 0;
            tank.m_h2     = 30;     
    end
end

