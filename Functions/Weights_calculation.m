function [Param] = Weights_calculation(Param, Vehicle)
% Designed by Sebastian Wolff in FTM, Technical University of Munich
%-------------
% Created on: 27.06.2016 
% ------------
% Version: Matlab2016b
%-------------
% This function calculates the weight of individual components of
% the vehicles' powertrain and adds them together to the total weight
% Only components that are relevant for optimization are calculated. The
% components weights are added to the total weight.
% ------------
% Input:    - Param:   struct array containing all simulation parameters
%           - Vehicle: a string which indicate the type of vehicle used
%                      in the simulation. It is one of the fieldnames of
%                      the 'x' matrix
% ------------
% Output:   - Param:  struct array containing all simulation parameters. The
%                     weights calculated in this function added to Param
% ------------
%% Sources
% [1]	M. Fries, M. Lehmeyer, und M. Lienkamp, “Multi-criterion optimization of heavy-duty powertrain design for the evaluation of transport efficiency and costs,” in IEEE ITSC 2017: 20th International Conference on Intelligent Transportation Systems : Mielparque Yokohama in Yokohama, Kanagawa, Japan, October 16-19, 2017, Piscataway, NJ: IEEE, 2017, S. 1–8.
% [2]	M. Fries, “Maschinelle Optimierung der Antriebsauslegung zur Reduktion von CO2-Emissionen und Kosten im Nutzfahrzeug,” Dissertation, Lehrstuhl für Fahrzeugtechnik, Technische Universität München, München, 2018.
% [3]	The Fuel Cell | Powercell Sweden AB. [Online] Verfügbar: http://www.powercell.se/technology_head/the-fuel-cell. Gefunden am: Feb. 23 2018.
% [4]	M. Fries, S. Wolff, und M. Lienkamp, “Optimization of Hybrid Electric Drive System Components in Long-Haul Vehicles for Evaluation of Transport Efficicency and TCO,” Technische Universität München, München, 2017.
% [5]	M. Wietschel und et. al, “Machbarkeitsstudie zur Ermittlung der Potentiale des Hybrid-Oberleitungs-Lkw,” Fraunhofer Institut für System und, Karlsruhe, 2017.
% [6]	O. Olsson, “Slide-in Electric Road System: Inductive project report,” Viktoria Swedish ICT, Göteborg, Okt. 2013. Gefunden am: Nov. 29 2017.
% [7]	L. Horlbeck et al, “Description of the modelling style and parameters for electric vehicles in the concept phase,” Technische Universität München, München, 2014. Gefunden am: Nov. 21 2016.
% [8]	M. Fries et al, “An Overview of Costs for Vehicle Components, Fuels, Greenhouse Gas Emissions and Total Cost of Ownership Update 2017,” 2017.
% [9]	W. Artl, “Wasserstoff und Speicherung im Schwerlastverkehr: Machbarkeitsstudie,” Friedrich-Alexander Universität Erlangen-Nürnberg, Erlangen, 2018. [Online] Verfügbar: https://www.tvt.cbi.uni-erlangen.de/LOHC-LKW_Bericht_final.pdf. Gefunden am: Mai. 02 2018.
% 
% ------------

%% Engine weight excluding the fuel [1, 2, 3, 4]
switch Param.Fueltype
    case {1, 4, 8, 9, 10, 11} % All variants with diesel engine (also for Dual Fuel)
        % EURO VI class
        %m_engine = 0.429 * Param.engine.M_max + 183.92; % [kg] [1, 2]
        m_engine = 0.4061 * Param.engine.M_max + 147.65; % [kg] source: SAE paper, Fries
        diesel_abgas = 203.4; % [kg] Weight of exhaust treatment incl. AdBlue. Source: Ramon Tengel
        gas_abgas = 0; % [kg] Weight of exhaust treatment incl. AdBlue. Source: Ramon Tengel
        
        % EURO V class
        %m_engine = 0.3441 * Param.engine.M_max + 153.64; % [kg] Source: SA Danninger S. 8
        
    case {7, 12} % Pure electric
        m_engine = 0;
        diesel_abgas = 0;
        gas_abgas = 0;
        
    case {13} % FCEV [3]
        diesel_abgas = 0;
        gas_abgas = 0;
        m_engine = Param.FuelCell.P_nom / 1.02; % Source: PowerCell MS-100
        
    otherwise % All variants with gas engines. Type of gas does not matter
        m_engine = 0.4702 * Param.engine.M_max + 141.4; % [kg] Source: SA Jon Schmidt S. 34
        diesel_abgas = 0; % [kg] Weight of exhaust treatment incl. AdBlue. Source: Ramon Tengel
        gas_abgas = 118.57; % [kg] Weight of exhaust treatment incl. AdBlue. Source: Ramon Tengel
end
%% Transmission weight [4]
% Retarder weight (ZF Intarder)
m_retarder = 82;

% Total drive torque
M_engine_total = Param.engine.M_max * (1 - Param.Electric_Truck) + Param.Hybrid_Truck * Param.em.M_max;

if ~isfield(Param.transmission, 'z')
    Param.transmission.z = length(Param.transmission.ratios);
end

switch Param.transmission.shift_time
    case {0} % weight of double clutch transmission 
        m_gearbox = max([125.31 * log(Param.transmission.z * M_engine_total) + 922.85; 125]); % [kg] source: Wolff
        
    case {1} % Weight for sequential transmission, (automated manual transmission)
        m_gearbox =  max([75.082 * log(Param.transmission.z * M_engine_total) - 510; 125]);   % [kg] source: Wolff
end

%% Weight of fuel and AdBlue tanks and exhaust treatment [2, 9]
% Fuel source: Wikipedia
% rho_diesel = 0.85;
% rho_cng = 0.00081;
% rho_lng = 0.54;

[m_kraftstoff, m_tank] = Fuel_tank_weights(Param);


%% Weight of hybrid and electric components

if ~isfield(Param, 'WPT')
    Param.WPT.Voltage = 0;
end

switch Param.Fueltype
    case{4, 5, 6, 7, 10, 11, 12, 13} % Hybrid & electric drivetrains
        m_LE = Param.em.P_max / 10.8; % Power electronics [7]
        
        if Param.WPT.Voltage % Inductive charging weight
            switch Vehicle
                case 'BEV_OC'
                    m_On_Board_Charger = 600; % Zusatzgewicht System[5]
                
                otherwise
                    m_On_Board_Charger = 591; % Inductive charging prototype weight [6]
            end
            
        else
            m_On_Board_Charger = 15; % Brusa LG6 on-board fast charger for three-phase current
            %m_On_Board_Charger = 150; % Additional weight for overhead line system
        end
        
        switch Param.em.Type % Electric motor weight
            case {1}
                m_EM = Param.em.P_max / 2; % [kg] [7]
                
            case {2}
                m_EM = Param.em.P_max / 0.9; % [kg] [7]
                
            otherwise
                error('Please provide a valid machine type')
        end
        
        switch Param.Bat.Type % 
            case {1} % Cylindrical
                Bat_Wh = (Param.Bat.Voltage * (Param.Bat.Useable_capacity / Param.Bat.Useable_range));
                m_Bat = Bat_Wh * (1 / Param.weights.m_Bat_cylindric); % [kg] 21700 cells [8]
                %m_Bat = Bat_Wh * (1 / 322.5);
                
            case {2} % Pouch
                Bat_Wh = (Param.Bat.Voltage * (Param.Bat.Useable_capacity / Param.Bat.Useable_range));
                m_Bat = Bat_Wh * (1 / Param.weights.m_Bat_pouch); % [kg] Pouch cells [8]               
                
            otherwise
                error('Please provide a valid battery type')
        end
        
    otherwise % If the vehicle is neither hybrid nor electric
        m_Bat              = 0;
        m_EM               = 0;
        m_On_Board_Charger = 0;
        m_LE               = 0;
end

%% Output
Param.vehicle.mass = Param.weights.m_Base + m_gearbox + m_retarder + m_engine + ...
    diesel_abgas + gas_abgas + m_tank + m_Bat + m_EM + m_On_Board_Charger...
    + m_LE + m_kraftstoff  + Param.weights.m_Trailer; % [kg]

if ~Param.vehicle.payload
    Param.vehicle.payload = Param.weights.m_Max - Param.vehicle.mass; % [kg]
end

% Transfer to weights class for later visualization (weight calculation will be done in
% future version completely in weights class)

Param.weights.m_Engine        =   m_engine;      % Engine
Param.weights.m_Gearbox       =   m_gearbox;      % Transmission
Param.weights.m_Retarder      =   m_retarder;      % Retarder
Param.weights.m_tank_system    =   m_tank;      % Fuel system (Diesel, LNG, CNG)
Param.weights.m_Fuel          =   m_kraftstoff;      % Fuel
Param.weights.m_Battery       =   m_Bat;      % Battery
Param.weights.m_EM            =   m_EM;      % Electric machine
Param.weights.m_PwrElectr     =   m_LE;      % Power Electronics
Param.weights.m_Charger       =   m_On_Board_Charger;      % On-board charger
Param.weights.m_Exhaust       =   gas_abgas + diesel_abgas; % Exhaust treatment

end