function [engine] = Dual_fuel_engine_mapping( Motormoment, Fueltype, n_lo, n_pref )
% Designed by Jon Schmidt in FTM, Technical University of Munich
%-------------
% Created on: 27.04.2016
% ------------
% Version: Matlab2017b
%-------------
% Function that parameterizes a dual-fuel engine and is required by the
% consumption simulation.
% 94% LNG, 6% Diesel 
% ------------
% Input:    - Motormoment: a scalar that states the maximum torque of the 
%                          ICE engine
%           - Fueltype:  a scalar number that defines which type of fuel
%                          is selected
%           - n_lo:        a scalar that states the lower shifting
%                          threshold
%           - n_pref:      a scalar that states the upper shifting
%                          threshold
% ------------
% Output:   - engine:      struct array containing the ICE engine variables
% ------------
load('Kennfeld_Dual-Fuel_Tschochner.mat'); % loads the characteristics of the original engine

engine.number = 2;
engine.M_max_original = 2232; %[Nm]
engine.M_max = Motormoment; %[Nm] Maximum torque
engine.scale_factor = engine.M_max / engine.M_max_original;

engine.speed_min = 800;                 %rpm
engine.speed_max = 2100;                %rpm
engine.idle_fuel_consumption = 1.0;     %kg/h estimated value!

% Efficiency
engine.bsfc.trq = engine.scale_factor * engine.bsfc.trqorig; %Determine torque vector
engine.bsfc.M_be_min = engine.scale_factor * engine.bsfc.M_be_min_orig; %Determine torque vector with best efficiency

% Torque characteristic
engine.full_load.trq = engine.scale_factor * engine.full_load.trqorig;
%        engine.full_load.speed [rpm]
engine.full_load.power = (engine.full_load.trq .* (engine.full_load.speed * 2*pi/60)) / 1000; %[kW]

% Drag torque characteristic curve
engine.drag_torque.trq = engine.scale_factor * [-120,-260]; %[Nm]
engine.drag_torque.speed = [600,2190];  %[rpm]

engine.shift_parameter.n_lo = n_lo;
engine.shift_parameter.n_pref = n_pref;

% Shifting parameter
% engine.shift_parameter.n_lo = 1100;
% engine.shift_parameter.n_pref = 1300;

engine.shift_parameter.n1 = 600;
engine.shift_parameter.n2 = 800;
engine.shift_parameter.n3 = (engine.shift_parameter.n_lo + engine.shift_parameter.n_pref) / 2;
engine.shift_parameter.n4 = engine.speed_min;
engine.shift_parameter.n5 = engine.shift_parameter.n_pref;
engine.shift_parameter.n6 = engine.speed_max;
engine.shift_parameter.M_max = max(engine.full_load.trq);
  
    if Fueltype == 8 || Fueltype == 10
        % Dual-Fuel-CNG (hybrid)
        engine.fuel.density_diesel	     = 0.830;   %density of Diesel [kg/l]
        engine.fuel.co2_per_litre_diesel =	2.62;   %CO2 emissions per litre [kg/l] Source: LNG as an alternative fuel for the propulsion of ships and heavy commercial vehicles 
        engine.fuel.co2_per_kg_gas       = 2.66;    %CO2 emissions per kg CNG [kg/kgCNG] = 47,215 MJ/kg * 56,4 gCO2/MJ = 2,66 kg CO2/ kg CNG, [Roß04, S.6]
        engine.fuel.heat_of_combustion   = 46969.9; %Heating value [kJ/kg]: 94% CNG 47215kJ/kg, 6% Diesel 43130kJ/kg -> 46969.9kJ/kg
        engine.fuel.Gasart = 'CNG';
        
    elseif Fueltype == 9 || Fueltype == 11
        % Dual-Fuel-LNG (hybrid)
        engine.fuel.density_diesel	     = 0.830;   %density of Diesel [kg/l]
        engine.fuel.co2_per_litre_diesel =	2.62;   %CO2 emissions per litre [kg/l] Source: LNG as an alternative fuel for the propulsion of ships and heavy commercial vehicles 
        engine.fuel.co2_per_kg_gas       = 2.75;    %CO2 emissions per kg LNG [kg/kgLNG] = 50,0 MJ/kg * 55,0 gCO2/MJ = 2,75 kg CO2/ kg LNG
        engine.fuel.heat_of_combustion   = 49587.8; %Heating value [kJ/kg]: 94% LNG 50000kJ/kg, 6% Diesel 43130kJ/kg Source: LNG as an alternative fuel for the propulsion of ships and heavy commercial vehicles 
        engine.fuel.Gasart = 'LNG';
    end
% cd ../;  
% cd ../;
end