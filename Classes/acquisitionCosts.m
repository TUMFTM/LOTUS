classdef acquisitionCosts < handle
% Designed by Sebastian Wolff in FTM, Technical University of Munich
%-------------
% Created in: 2016
% ------------
% Version: Matlab2016b
%-------------
% Class for the acquisition cost of a Euro Transport tractor unit. Costs
% for the individual components engine, gearbox, Hybrid components, tank
% and exhaust treatment will be added to the base price in order to
% calculate the acquisition cost of a tractor unit. The acquisition cost is
% reused for the TCO calculations.
% ------------
%% Sources
% [1]	M. Fries et al, “An Overview of Costs for Vehicle Components, Fuels, Greenhouse Gas Emissions and Total Cost of Ownership Update 2017,” 2017.
% [2]	M. Fries, “Maschinelle Optimierung der Antriebsauslegung zur Reduktion von CO2-Emissionen und Kosten im Nutzfahrzeug,” Dissertation, Lehrstuhl für Fahrzeugtechnik, Technische Universität München, München, 2018.
% [3]	L. C. den Boer, Zero Emissions Trucks: An Overview of State-of-the-art Technologies and Their Potential : Report: CE Delft, 2013.
% [4]	Jason Marcinkoski, Jacob Spendelow, Adria Wilson, and Dimitrios Papageorgopoulos, U.S. Department of Energy, “DOE Fuel Cell Technologies Office Record: Fuel Cell System Cost,” Washington DC, USA, 2015. [Online] Verfügbar: https://www.hydrogen.energy.gov/pdfs/15015_fuel_cell_system_cost_2015.pdf. Gefunden am: Feb. 08 2018.
% [5]	W. Artl, “Wasserstoff und Speicherung im Schwerlastverkehr: Machbarkeitsstudie,” Friedrich-Alexander Universität Erlangen-Nürnberg, Erlangen, 2018. [Online] Verfügbar: https://www.tvt.cbi.uni-erlangen.de/LOHC-LKW_Bericht_final.pdf. Gefunden am: Mai. 02 2018.
% 
%
%
% ------------

    properties
        % Tractor unit, Wolff 2016 [1]
        KA_ZM                                       % Tractor unit cost [€]
        ZM_sockelpreis  =   31698;                  % Production cost without engine, transmission, exhaust treatment & fuel tank [€]
        OEM_Rendite     =   1.064;                  % Return [%]
        Haendlermarge   =   1.15;                   % Dealer sale margin [%]
        Overhead_costs    =   1.3429;                 % Overheads [%] 
        
        % Transmission [1]
        KG                                          % Cost [€]
        Getr_m          =   0;                      % Weight [kg]
        Getr_VK         =   16.64;                  % Production cost [€/kg], source: Wolff 2016
        DSG_VK          =   30.37;                  % DCT production cost [€/kg], source: Wolff 2016
        DSG             =   0;                      % 1 or 0
        Intarder_VK     =   1667.00;                % Intarder production cost in [€], source: Wolff 2016
        
        % Engine [1]
        KMot                                        % Cost [€]
        Motor_Mmax      =   0;                      % Torque [Nm]
        Motor_m         =   0;                      % Weight [kg]
        Motor_VK        =   3.172;                  % Production cost [€/Nm], source: Schaller & Maierhofer
        Motor_VK_Base   =   4272;                   % Base price for Euro VI Diesel engine [€]
        Faktor_Gas      =   1.05;                   % Surcharge for gas engine [%], source: Schaller & Maierhofer       
        Mehrkosten_Dual =   2;                      % Extra cost for Dual-Fuel engine [€]
        Kosten_Kuehler  =   300;
        Kosten_Luefter  =   100;
        
        % Hybrid components according to Kerler/Kochhan
        KH                                          % Extra cost [€]
        Hybrid          =   0;                      % Discrete 1 or 0
        Elektro         =   0;                      % Discrete 1 or 0
        
        % Battery [2]
        Bat                                         % Cost [€]
        Bat_type                                    % Battery type
        Bat_m           =   0;                      % Weight [kg]
        Bat_kWh         =   0;                      % Energy capacity [Wh]
        Bat_VK_Pouch    =   176;                    % Production cost of PHEV battery pack 124*1.42 (BeV2PHEV = 1.42) [€/kWh] // Source: Kostenpaper Kerler 2017
        Bat_VK_Cyl      =   210;                    % Production cost of PHEV battery pack 148*1.42 (BeV2PHEV = 1.42) [€/kWh] // Source: Kostenpaper Kerler 2017
        Bat_ZK          =   200;                    % Additional costs, source: Kostenpaper Kerler 2017
        Ratio_BEV2PHEV                              % Ratio of battery prices
        
        % Electrical machine [2]
        EM                                          % Cost [€]
        EM_Type                                     % Machine type, PMSM or ASM
        EM_P_max         =   0;                     % Power [kW]
        ASM_VK           =   10.29;                 % Retail price of ASM [€/kW]
        PSM_VK           =   12.86;                 % Retail price of PMSM [€/kW]
        
        % Power electronics [2, 3]
        LE                                          % Cost [€]
        LE_VK           =   4.5;                    % Retail price [€/kW]
        Conv            =   181.43;                 % Converter cost [€]
        LS              =   500;                    % Onboard charger cost
        WPT             =   0;                      % WPT availability, ON/OFFF
        KWPT            =   7800;                   % Additional cost for WPT in 2017 [€]: interp1([2012; 2020; 2030], [9250; 8252; 7800], 2017, 'spline')
        %KWPT            =   10000;                 % Additional cost for catenary wires in 2017 [€]: interp1([2012; 2020; 2030], [40000; 23333; 10000], 2017, 'spline')
        
        % Fuel cell [4, 5]
        FC
        P_FC
        FC_VK           =   54;                    % Production cost [€/kW], source: DOE Fuel Cell Technologies Office Record - Fuel Cell System Cost, 100.000 units/year, 2015
        KTFC_VK         =   608;                   % Production cost of hydrogen tanks [€/kgH2]
        
        % Exhaust treatment [1]
        KA                                         % Cost [€]
        KAD             =  6181;                   % Production cost of exhaust treatment for Diesel including AdBlue [€]
        KAG             =  1563;                   % Production cost of exhaust treatment for gas [€]
        
        % Fuel tanks
        v_diesel       % = 0;                        % Volume in l
        v_cng          % = 0;                        % Volume in l
        v_lng          % = 0;                        % Volume in l
        m_h2
        
        KT                                          % Production cost of fuel tank [€]
        KTD                                         % Production cost of diesel tank in [€]
        KTCNG                                       % Production cost of CNG tank [€]
        KTLNG                                       % Production cost of LNG tank [€]
        KTFC                                        % Production cost of hydrogen tank [€]
    end
    
    methods
        %% Class Constructor
        function obj = acquisitionCosts(Param, init)
            if init
                obj.Getr_m      = Param.weights.m_Gearbox;
                obj.Motor_m     = Param.weights.m_Engine;
                obj.Bat_m       = Param.weights.m_Battery;
                obj.EM_P_max    = Param.em.P_max;
                obj.Hybrid      = Param.Hybrid_Truck;
                obj.Elektro     = Param.Electric_Truck;
                obj.DSG         = 1 - Param.transmission.shift_time;              %[-] Discrete DCT "ON" or "OFF", when shift_time = 0 then DCT is ON
                obj.Motor_Mmax  = Param.engine.M_max;
                obj.Bat_kWh     = (Param.Bat.Voltage * (Param.Bat.Useable_capacity / Param.Bat.Useable_range))/1000;
                obj.Bat_type    = Param.Bat.Type;
                obj.EM_Type     = Param.em.Type;
                obj.v_diesel    = Param.tank.v_diesel;    % Volume of Diesel in l
                obj.v_lng       = Param.tank.v_lng;       % Volume of LNG in l
                obj.v_cng       = Param.tank.v_cng;       % Volume of CNG in l
                
                if ~isfield(Param, 'FuelCell')
                    obj.m_h2        = 0;
                    obj.P_FC        = 0;
                    
                else
                    obj.m_h2        = Param.tank.m_h2;
                    obj.P_FC        = Param.FuelCell.P_nom;     % Fuel cell power
                end
                
                if ~isfield(Param, 'WPT') || ~Param.WPT.Voltage
                    obj.WPT = 0;
                    
                else
                    obj.WPT = 1;
                end
                
%                 switch Vehicle
%                     case 'BEV_OC'
                        obj.KWPT = 10000;
%                 end
            end
        end
        %% Calculations
        function KG = get.KG(obj) % Transmission cost [€]
            KG = obj.Getr_VK * obj.Getr_m * (1 - obj.DSG) + ...
                obj.DSG_VK * obj.Getr_m * (obj.DSG) + obj.Intarder_VK;
        end
        
        function KMot = get.KMot(obj) % Engine cost [€]
                % Gas engine
            if (obj.v_lng ~= 0 || obj.v_cng ~= 0) && obj.v_diesel == 0
                KMot = (obj.Motor_Mmax * obj.Motor_VK + obj.Motor_VK_Base) * obj.Faktor_Gas  + obj.Kosten_Kuehler ...
                    + obj.Kosten_Luefter;
                
                % Dual Fuel engine
            elseif (obj.v_lng ~= 0 || obj.v_cng ~= 0) && obj.v_diesel ~= 0
                KMot = ((obj.Motor_Mmax * obj.Motor_VK + obj.Motor_VK_Base) + 400)* obj.Mehrkosten_Dual + obj.Kosten_Kuehler ...
                    + obj.Kosten_Luefter;
                
                % EURO VI diesel engine 
            elseif (obj.v_lng == 0 && obj.v_cng ~= 0) || obj.v_diesel ~= 0
                KMot = obj.Motor_Mmax * obj.Motor_VK + obj.Motor_VK_Base + obj.Kosten_Kuehler ...
                    + obj.Kosten_Luefter;
                
                % Electric truck
            else
                KMot = 0;
            end
        end
        
        % Hybrid system cost [€]
        % Convert the cost of BEV, source: Kostenpaper 2017
        function Ratio_BEV2PHEV = get.Ratio_BEV2PHEV(obj)
            if obj.Elektro
                Ratio_BEV2PHEV = 1.42;
                
            else
                Ratio_BEV2PHEV = 1;
            end
        end
        
        % Battery cost [€]
        function Bat = get.Bat(obj)
            if obj.Bat_m ~= 0
                switch obj.Bat_type
                    case {1}
                        Bat = obj.Bat_kWh * (obj.Bat_VK_Cyl/obj.Ratio_BEV2PHEV) + obj.Bat_ZK;
                        
                    case {2}
                        Bat = obj.Bat_kWh * (obj.Bat_VK_Pouch/obj.Ratio_BEV2PHEV) + obj.Bat_ZK;
                        
                    otherwise
                        error('Please indicate a valid battery type')
                end
            else
                Bat = 0;
            end
        end
        
        %% Electric machine cost [€]
        function EM = get.EM(obj)
            switch obj.EM_Type
                case {1}
                    EM = (obj.EM_P_max * obj.PSM_VK) * obj.Hybrid;
                    
                case {2}
                    EM = (obj.EM_P_max * obj.ASM_VK) * obj.Hybrid;
                    
                otherwise
                    error('Please indicate a valid machine type')
            end
        end
        
        %% Power electronics cost [€]
        function LE = get.LE(obj)
            LE = (obj.EM_P_max * obj.LE_VK) * obj.Hybrid;
        end
        
        % Additional cost for hybrid [€]
        function KH = get.KH(obj)
            KH = (obj.Bat + obj.EM + obj.LE  + obj.Conv + obj.LS) * obj.Hybrid;
        end
        
        %% Fuel tank cost
        function KTD = get.KTD(obj)
            if obj.v_diesel ~= 0
                KTD = (0.5547 * obj.v_diesel + 126.4);
                
            else
                KTD = 0;
            end
        end
        
        function KTCNG = get.KTCNG(obj)
            if obj.v_cng ~= 0
                KTCNG = (1124.8 * log(obj.v_cng) - 3112.8);
                
            else
                KTCNG = 0;
            end
        end
        
        function KTLNG = get.KTLNG(obj)
            if obj.v_lng ~= 0
                KTLNG = (8.0305 * obj.v_lng + 1480.2);
                
            else
                KTLNG = 0;
            end
        end
        
        function KTFC = get.KTFC(obj)
            if obj.m_h2 ~= 0
                KTFC = (8.0305 * obj.v_lng + 1480.2);
                
            else
                KTFC = 0;
            end
        end
        
        function KT = get.KT(obj)
            KT = obj.KTD + obj.KTCNG + obj.KTLNG + obj.KTFC;
        end
        
        %% Exhaust treatment cost
        function KA = get.KA(obj)
                % Cost for gas engine
            if (obj.v_lng ~= 0 || obj.v_cng ~= 0) && obj.v_diesel == 0
                KA = obj.KAG;
                
                % Cost ofr duel-fuel engine
            elseif (obj.v_lng ~= 0 || obj.v_cng ~= 0) && obj.v_diesel ~= 0
                KA = obj.KAD;
                
                % Cost for EURO VI diesel engine
            elseif (obj.v_lng == 0 && obj.v_cng ~= 0) || obj.v_diesel ~= 0
                KA = obj.KAD;
            else
                KA = 0;
            end
        end
        
        function KFC = get.FC(obj)
            KFC = obj.FC_VK * obj.P_FC;
        end
        
        % Tractor unit additional cost
        function KA_ZM = get.KA_ZM(obj)
            KA_ZM = ((obj.ZM_sockelpreis + obj.KMot + obj.KG + obj.KT...
                + obj.KA  + obj.KH + obj.FC) * obj.Overhead_costs) * ...
                (obj.OEM_Rendite * obj.Haendlermarge)  + obj.KWPT * obj.WPT;
        end
    end
 end