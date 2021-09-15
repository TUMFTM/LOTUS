function [engine] = Hydrogen_engine_mapping( maxTorque, n_lo, n_pref)
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
%load('engineMap_Hydrogen') %aus Truck2030 Kennfeld
load('engineMap_Hydrogen22') %aus Truck2030 Kennfeld, double speed, half trq
engine.number = 1;
scaleHydrogen = 44/48;
% engine.M_max_original = 2100; %[Nm]
% engine.M_max_original = 2231;  %[Nm] Maximum torque of the original engine
 engine.M_max_original = 2400/2; %[Nm] Maximum torque of the original engine
 engine.bsfc.be=engine.bsfc.be.*(48/44);
engine.M_max = maxTorque;    %[Nm] Maximum torque

engine.scale_factor = engine.M_max / engine.M_max_original;

engine.fuel.density	= 1000;%42              %density of fuel [g/kg]
engine.fuel.co2_per_litre =	0.438*33.268;         % WtW CO2 emissions per kg nach Status Elektromobilität 2020 "Referenz-Szenario 2020"
%engine.fuel.co2_per_litre = 0.144*33.268;         % WtW CO2 emissions per kg nach Status Elektromobilität 2020 "Realistisches Szenario 2030"
% engine.fuel.heat_of_combustion = 42500; %lower heating value	[kJ/kg]
engine.fuel.LHV = 119.83;                 %lower heating value [MJ/kg]

% engine.speed_min = 800;                 %[rpm]
% engine.speed_max = 1800;                %[rpm]

engine.speed_min = 600*2;                 %[rpm]
engine.speed_max = 2100*2;                %[rpm]

engine.idle_fuel_consumption = 1.0;     %[kg/h] estimated value!

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
engine.drag_torque.trq = engine.scale_factor * [0, -65.6,	-98.9,	-123.3,	-134.32	-156.04,	-176.72,	-217.28,	-234.63,	-256.02,	-273.98,	-301.74,	-324,	-353.92,	-376.32,	-421.26,	-450]/2; %[Nm]
engine.drag_torque.speed = [0, 450,	600,	700,	800,	1000,	1200,	1500,	1600,	1700,	1800,	1900,	2000,	2100,	2200,	2300,	2400]*2;  %[rpm]

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

engine.shift_parameter.n1 = 600*2;%-400;                          %langsamer darf nicht
engine.shift_parameter.n2 = 800*2;                                %runterschalten wird empfohlen
engine.shift_parameter.n3 = (engine.shift_parameter.n_lo + engine.shift_parameter.n_pref) / 2; %optimale Drehzahl
engine.shift_parameter.n4 = engine.speed_min;                   %langsamer darf nicht
engine.shift_parameter.n5 = engine.shift_parameter.n_pref;      %hochschalten wird empfohlen, wenn mit M vereinbar
engine.shift_parameter.n6 = engine.speed_max;%-400;             %schneller darf nicht
engine.shift_parameter.M_max = max(engine.full_load.trq);

% cd ../;
% cd ../;
end