function [engine] = Gas_engine_mapping( Motormoment, Fueltype, n_lo, n_pref )
% Designed by Jon Schmidt in FTM, Technical University of Munich
%-------------
% Created on: 27.04.2016
% ------------
% Version: Matlab2017b
%-------------
% Function that parameterizes a natural gas engine and is required by the
% consumption simulation
% Original engine: Mercedes-Benz M936G 299hp Euro 6, adapted with map of
%                  Tschochner 
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
load('Kennfeld_Gas_Tschochner.mat'); % loads the characteristics of the original engine

engine.number = 3;
engine.M_max_original = 1120; %[Nm]
engine.M_max = Motormoment;                          %[Nm] Maximum torque
engine.scale_factor = engine.M_max / engine.M_max_original;


engine.speed_min = 800;                 %rpm (best results 19,44t:800) (fully loaded:800)
engine.speed_max = 1900;                %rpm (best results:1900) (fully loaded: 1900)
engine.idle_fuel_consumption = 1.5;     %kg/h Estimated value!

% Efficiency
engine.bsfc.trq = engine.scale_factor * engine.bsfc.trqorig; %Determine torque vector
engine.bsfc.M_be_min = engine.scale_factor * engine.bsfc.M_be_min_orig; %Determine torque vector with best efficiency

% Torque characteristic
engine.full_load.trq = engine.scale_factor * engine.full_load.trqorig; %[Nm]
%        engine.full_load.speed [rpm]
engine.full_load.power = (engine.full_load.trq .* (engine.full_load.speed * 2*pi/60)) / 1000; %[kW]

% Drag torque characteristic curve (Taken from MAN euro5 EEV 2100Nm 440PS)
engine.drag_torque.trq = engine.scale_factor * [-120,-260]; %[Nm]
engine.drag_torque.speed = [600,2190];  %[rpm]

engine.shift_parameter.n_lo = n_lo;
engine.shift_parameter.n_pref = n_pref;
% Shifting parameter
% engine.shift_parameter.n_lo = 1100; %Slanted upshift
% engine.shift_parameter.n_pref = 1400;    %Vertical upshift, 1400 oder 1500 at best

engine.shift_parameter.n1 = 600;    %Slanted downshift, best results 700 (fully loaded: 600)
engine.shift_parameter.n2 = 800;    %Vertical downshift, best results  800 (fully loaded: 800)
engine.shift_parameter.n3 = (engine.shift_parameter.n_lo + engine.shift_parameter.n_pref) / 2;      %1250
engine.shift_parameter.n4 = engine.speed_min;                                                       %best results: 800
engine.shift_parameter.n5 = engine.shift_parameter.n_pref;                                          %1400 or 1500 at best
engine.shift_parameter.n6 = engine.speed_max;                                                       %best result in an estate car with driving time: 1900
engine.shift_parameter.M_max = max(engine.full_load.trq);

    if Fueltype == 2 || Fueltype == 5
        % CNG(hybrid)
            engine.fuel.density            = 170;   %density of fuel [g/l], [Bas15b, S.905]
            engine.fuel.co2_per_kg         = 2.66;  %CO2 emissions per kg CNG [kg/kgCNG] = 47,215 MJ/kg * 56,4 gCO2/MJ = 2,66 kg CO2/ kg CNG, [Roﬂ04, S.6]
            engine.fuel.heat_of_combustion = 47215; %Heating value [kJ/kg]: 100% CNG 47215kJ/kg, [Roﬂ04, S.6]
            engine.fuel.Gasart = 'CNG';
            
    elseif Fueltype == 3 || Fueltype == 6  
        % LNG(hybrid)
            engine.fuel.density	           = 424;   %density of fuel [g/l], [Bas15a, S.354]
            engine.fuel.co2_per_kg         = 2.75;  %CO2 emissions per kg LNG [kg/kgLNG] = 50,0 MJ/kg * 55,0 gCO2/MJ = 2,75 kg CO2/ kg LNG
            engine.fuel.heat_of_combustion = 50000; %Heating value [kJ/kg]: 100% LNG 50000kJ/kg, Source :LNG as an alternative fuel for the propulsion of ships and heavy commercial vehicles 49587.8
            engine.fuel.Gasart = 'LNG';
    end
% cd ../;
% cd ../;
end