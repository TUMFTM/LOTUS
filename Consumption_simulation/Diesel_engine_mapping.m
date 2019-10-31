function [engine] = Diesel_engine_mapping( maxTorque, n_lo, n_pref)
% Designed by Jon Schmidt in FTM, Technical University of Munich
%-------------
% Created on: 27.04.2016
% ------------
% Version: Matlab2017b
%-------------
% Function that parameterizes a diesel engine and is required by the
% consumption simulation
% Original engine: 440hp Euro 5 EEV SCR 
% ------------
% Input:    - maxTorque: a scalar that states the maximum torque of the 
%                          ICE engine
%           - n_lo:        a scalar that states the lower shifting
%                          threshold
%           - n_pref:      a scalar that states the upper shifting
%                          threshold
% ------------
% Output:   - engine:      struct array containing the ICE engine variables
% ------------
%load('engineMap_Diesel.mat'); % characteristics of the original engine
%load('engineMap_Diesel_Euro_VI_1stufig.mat'); 
%load('engineMap_Diesel_Euro_VI_2stufig'); 
% load('engineMap_Diesel_Euro_VI'); 
load('engineMap_Diesel_Euro_VI_Truck2030')
engine.number = 1;
% engine.M_max_original = 2100; %[Nm]
% engine.M_max_original = 2231;  %[Nm] Maximum torque of the original engine
engine.M_max_original = 2400;  %[Nm] Maximum torque of the original engine
engine.M_max = maxTorque;    %[Nm] Maximum torque

engine.scale_factor = engine.M_max / engine.M_max_original;

engine.fuel.density	= 830;              %density of fuel [g/l]
engine.fuel.co2_per_litre =	2.62;       %CO2 emissions per litre [kg/l] Source: LNG as an alternative fuel for the propulsion of ships and heavy commercial vehicles 
engine.fuel.heat_of_combustion = 42500; %lower heating value	[kJ/kg]
engine.fuel.LHV = 35.8;                 %lower heating value [MJ/l]

% engine.speed_min = 800;                 %[rpm]
% engine.speed_max = 1800;                %[rpm]

engine.speed_min = 600;                 %[rpm]
engine.speed_max = 2100;                %[rpm]

engine.idle_fuel_consumption = 1.5;     %[L/h]

%torque (rows) [Nm], speed (columns) [rpm], be [g/kWh]
engine.bsfc.trq = engine.scale_factor * engine.bsfc.trqorig;
engine.bsfc.M_be_min = engine.scale_factor * engine.bsfc.M_be_min_orig;
    
%full load curve (max open throttle)
engine.full_load.trq = engine.scale_factor * engine.full_load.trqorig; %[Nm]
engine.full_load.power = (engine.full_load.trq .* (engine.full_load.speed * 2*pi/60)) / 1000; %[kW]

% %drag torque curve EuroV (which is a line here:) (closed throttle)
% engine.drag_torque.trq = engine.scale_factor * [-120,-260]; %[Nm]
% engine.drag_torque.speed = [600,2190];  %[rpm]

%drag torque curve EuroVI (which is a line here:) (closed throttle)
engine.drag_torque.trq = engine.scale_factor * [0, -65.6,	-98.9,	-123.3,	-134.32	-156.04,	-176.72,	-217.28,	-234.63,	-256.02,	-273.98,	-301.74,	-324,	-353.92,	-376.32,	-421.26,	-450]; %[Nm]
engine.drag_torque.speed = [0, 450,	600,	700,	800,	1000,	1200,	1500,	1600,	1700,	1800,	1900,	2000,	2100,	2200,	2300,	2400];  %[rpm]

engine.rated_power = (440/1.359622)*1000; %W

engine.shift_parameter.n_lo = n_lo;
engine.shift_parameter.n_pref = n_pref;

%Shifting parameter for ACEA based shifting
%---------------------------------------% EuroV
%engine.shift_parameter.n_lo = 1100;
%engine.shift_parameter.n_pref = 1300;
%---------------------------------------% EuroVI
% engine.shift_parameter.n_lo = 1000;
% engine.shift_parameter.n_pref = 1200;

engine.shift_parameter.n1 = 600;%-400;
engine.shift_parameter.n2 = 800;
engine.shift_parameter.n3 = (engine.shift_parameter.n_lo + engine.shift_parameter.n_pref) / 2;
engine.shift_parameter.n4 = engine.speed_min;
engine.shift_parameter.n5 = engine.shift_parameter.n_pref;
engine.shift_parameter.n6 = engine.speed_max;%-400;
engine.shift_parameter.M_max = max(engine.full_load.trq);

% cd ../;
% cd ../;
end