classdef weights
% Designed by Sebastian Wolff in FTM, Technical University of Munich
%-------------
% Created on: 02.03.2017
% ------------
% Version: Matlab2017b
%-------------
% Class for summarizing the component weights. In the class, all weights
% are weighted, combined and stored in the vehicle configuration (Param).
% The calculations do not take place in this class as of 03.2017.
% Weights_calculation function passes the values to this class, therefore
% all values here are initialized with 0 kg. The values in this class are
% only for analysis and will not be used in the consumption simulation.
% ------------
%% Sources
% [1]	M. Fries, “Maschinelle Optimierung der Antriebsauslegung zur Reduktion von CO2-Emissionen und Kosten im Nutzfahrzeug,” Dissertation, Lehrstuhl für Fahrzeugtechnik, Technische Universität München, München, 2018.
% 
% 
% 
% ------------
    properties
        m_Engine        =   0;      % Engine 
        m_Gearbox       =   0;      % Transmission 
        m_Retarder      =   0;      % Retarder 
        
        m_tank_system    =   0;      % Fuel tank (Diesel, LNG, CNG)
        m_Fuel          =   0;      % Fuel 
        
        m_Exhaust       =   0;      % Exhaust treatment
        
        % Hybrid components weight
        m_Bat_pouch     =   161     % Battery Weight in Wh/kg % [8]	M. Fries et al, “An Overview of Costs for Vehicle Components, Fuels, Greenhouse Gas Emissions and Total Cost of Ownership Update 2017,” 2017.
        m_Bat_cylindric =   151     % Battery Weight in Wh/kg % [8]	M. Fries et al, “An Overview of Costs for Vehicle Components, Fuels, Greenhouse Gas Emissions and Total Cost of Ownership Update 2017,” 2017.
        m_Battery       =   0;      % Battey
        m_EM            =   0;      % Electrical machine
        m_PwrElectr     =   0;      % Power Electronics
        m_Charger       =   0;      % Onboard charger
        
        % Fuel volume and weight
        v_diesel        =   0;      % Diesel in l
        v_LNG           =   0;      % LNG in l
        v_CNG           =   0;      % CNG in l
        
        % Trailer weight
        m_Trailer

        % Total weight
        m_Total;
        
        % Base weight without engine, exhaust system, fuel tank and gearbox
        m_Base
        
        % Payload
        Electric        = 0;
        Hybrid          = 0;
        max_Payload                 % Max payload
        m_Max                       % Gross vehicle weight (Fully loaded)
    end
    
    methods
        % class constructor
        % Takes Param as input and assigns parameters to class propertie
        function obj = weights(Param, init)
            if init
                % Check if field exists, Standard is set as default
                if isfield(Param.vehicle, 'long_truck') && Param.vehicle.long_truck
                    obj.m_Base =        7688;           % [kg] Optimum Concept articulated vehicle (Gliederzug)  [1]
                    obj.m_Trailer =     8600;           % [kg] Optimum Concept including trailer and dolly [1]
                else
                    obj.m_Base =        5223.2;         % [kg] [1]
                    obj.m_Trailer =     5400;           % [kg] Gewicht Schmitz-Cargobull S.CS X-LIGHT
                end
                
                obj.Electric = Param.Electric_Truck;
                obj.Hybrid = Param.Hybrid_Truck;
            end
        end
            
        function m_Max = get.m_Max(obj)
            if obj.Electric || obj.Hybrid
                m_Max = 41000;
            else
                m_Max = 40000;
            end
        end
        
        % Gross vehicle weight calculation
        function m_Total = get.m_Total(obj)
            m_Total = obj.m_Engine + obj.m_Gearbox + obj.m_Retarder...
                + obj.m_Battery + obj.m_EM + obj.m_PwrElectr + ...
                obj.m_Charger + obj.m_Exhaust + obj.m_Fuel + ...
                obj.m_tank_system + obj.m_Base;
        end
        % When Payload = 0 in the simulation then max payload is assumed
        function    max_Payload = get.max_Payload(obj)
            max_Payload = obj.m_Max - obj.m_Total - obj.m_Trailer;
        end 
    end 
end