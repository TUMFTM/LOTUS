classdef TCO < handle

    properties
        % Vehicle basic data-----------------------------------------------
            Ratio_Trailer_Truck
            Purchase_price                                  %   €
            Price_increase_repurchase                       %   %
            Replacement_original_price                      %   €
            Residual_value                                  %   €
            bDiesel                                         %   l/(100km)
%           bDiesel_unbel                                   %   l/(100km)
            CNG_consumption                                 %   kg/(100km)
%           CNG_consumption_unbel                           %   kg/(100km)
            LNG_consumption                                 %   kg/(100km)
%           LNG_consumption_unbel                           %   kg/(100km)
            energyTotal                                     %   kWh/(100km)
            Hydrogen_consumption                            %   kWh/(100km)
%           energyTotal_unbel                               %   kWh/(100km)
            Tire_costs_set                                  %   €
            Amortization_value                              %   €
            Toll_rate                                       %   €/km
        % Personnel_costs---------------------------------------------------
            Daily_working_time                              %   h
            Other_works_day                                 %   h/Tag
            Gross_hourly_wage_driver                        %   €
            Operating_days_year                             %   Days
            Annual_gross_wage_driver                        %   €
            Personnel_factor                                %   %
            Annual_gross_wage_truck                         %   €
            Social_costs_percent                            %   %
            Social_costs_EUR                                %   €
            Back_up_driver                                  %   €
            Fees_day                                        %   €
            Fees_year                                       %   €
            Driver_costs_other                              %   €
            Driving_personnel_costs_total                   %   €
        % Key_assumptions----------------------------------------------------
            Diesel_price                                    %   €/l
            Diesel_price_external                           %   €/l
            Adblue_price                                    %   €/l
            CNG_price                                       %   €/kg
            LNG_price                                       %   €/kg
            Electricity_price                               %   €/kWh
            Hydrogen_price                                  %   €/kg
            Interest_current_asset                          %   % of HK
            Interest_fixed_asset                            %   % of HK
            Administrative_costs                            %   % of HK
        % Calculation_assumptions---------------------------------------------
            Driving_distance                                %   km
            Ratio_toll_route                                %   %
            Loading_time_combination                        %   h
            Unloading_time_combination                      %   h
            Ratio_empty_trips                               %   %
            Average_speed                                   %   km/h
%           Average_speed_unbel                             %   km/h
            Daily_driving_time                              %   h
            rangeElectric                                   %   km
            Annual_mileage                                  %   km
            Operating_life                                  %   Years
            Tire_mileage                                    %   km
            Ratio_inhouse_tanking_diesel                    %   %
            Lubricant_consumption                           %   %
            Adblue_consumption                              %   %
            Afa_time_dependent                              %   %
            Afa_power_dependent                             %   %
            Current_asset                                   %   %
            Taxes                                           %   €/Year
            Insurance_vehicle                               %   €/Year
            Insurance_transport                             %   €/Year
            Communication                                   %   €/Year
            Repair_maintenance_care                         %   €/Year
            
        % Kalkulation zeitabhängige Fahrzeugkosten-------------------------
            Amortisation_time_dependent                            %   €
            Current_assets_interest_bearing                        %   €
            Fixed_assets_interest_bearing                        %   €
            Insurance                                    %   €
            Sum_vehicle_costs                                %   €
            Sum_fix_costs                               %   €
            
        % Kalkulation leistungsabhängige Fahrzeugkosten--------------------
            Amortisation_performance_related                       %   €
            Fuel_costs                                %   €
            Lubricant_costs                              %   €
            Adblue_costs                                    %   €
            Repair_costs                                 %   €
            Tire_costs                                    %   €
            Lebensdauer_Batteriepack                         %   Jahr
            Anschaffungspreis_Akkupack                       %   €
            Verschleisskosten_Batteriepack                   %   €
            residualValueBattery                             %   €
            %Verschleissbatteriepack                         %   1/km
            Sum_variable_costs                           %   €
            
            
            Sum_fix_variable_costs                      %   €
            Overhead_costs                                    %   €
            Toll_costs                                      %   €
            
            Total_costs                                    %   €
        
        % Auswahl für Resultsdiagramm
            Results
            
        % Nach erfolgreicher Simulation wird das Gesamtgewicht der
        % aktuellen Composition gespeichert. Sofern der Nutzer anschließend
        % die Konfiguration ändert (und sich das Gewicht ändert) muss die
        % Simualtion erneut durchgeführt werden, bevor die TCO-Übersicht
        % eingesehen/angepasst werden kann.
            Gewicht_Comp = 0
    end
    
    methods
       %% TCO initialisieren (class Constructor)
        function obj = TCO(Composition, costStruct, init)
            % TCO initialisieren (Initialwerte aus costStruct)
             if init == true
                %c_obj = size(Composition, 2);
                c_obj = Composition;
                
                
                % Vehicle basic data---------------------------------------
                    % Verhältnis Aufl./Anh zu Lkw
                obj.Ratio_Trailer_Truck = [1, ones(1,c_obj-(1))* ...
                    costStruct.TCO.Basic_data. ...
                    Initialvalue('Ratio_Trailer_Truck')];
                    % Replacement_original_price (Veränd. % zu Purchase_price)
                obj.Price_increase_repurchase = ones(1,c_obj)* ...
                    costStruct.TCO.Basic_data. ...
                    Initialvalue('Price_increase_repurchase');
                
                
                % Personnel_costs-------------------------------------------
                    % Daily_working_time
                obj.Daily_working_time = costStruct.TCO.Personnel_costs. ...
                    Initialvalue('Daily_working_time');
                    % Zeit für sonstige Arbeiten am Tag (z.B. Wartung, 
                    % Reinigung)
                obj.Other_works_day = costStruct.TCO. ...
                    Personnel_costs.Initialvalue('Other_works_day');
                    % Bruttostundenlohn Fahrer
                obj.Gross_hourly_wage_driver = costStruct.TCO. ...
                    Personnel_costs. ...
                    Initialvalue('Gross_hourly_wage_driver');
                    % Einsatztage pro Jahr
                obj.Operating_days_year = costStruct.TCO. ...
                    Personnel_costs.Initialvalue('Operating_days_year');
                    % Personnel_factor
                obj.Personnel_factor = costStruct.TCO.Personnel_costs. ...
                    Initialvalue('Personnel_factor');
                    % Sozialaufwendungen in %
                obj.Social_costs_percent = costStruct.TCO. ...
                    Personnel_costs.Initialvalue('Social_costs_percent');   
                    % Back_up_driver
                obj.Back_up_driver = costStruct.TCO.Personnel_costs. ...
                    Initialvalue('Back_up_driver');
                    % Spesen/Tag
                obj.Fees_day = costStruct.TCO.Personnel_costs. ...
                    Initialvalue('Fees_day');
                    % sonstige Fahrerkosten
                obj.Driver_costs_other = costStruct.TCO. ...
                    Personnel_costs.Initialvalue('Driver_costs_other');
                
                
                % Key_assumptions--------------------------------------------
                    % Diesel_price Eigenbetankung
                obj.Diesel_price = costStruct.TCO.Key_assumptions. ...
                    Initialvalue('Diesel_price');
                    % Diesel_price Fremdbetankung
                obj.Diesel_price_external = costStruct.TCO.Key_assumptions. ...
                    Initialvalue('Diesel_price_external');
                    % Adblue-Preis
                obj.Adblue_price = costStruct.TCO.Key_assumptions. ...
                    Initialvalue('Adblue_price');
                    % CNG-Preis
                obj.CNG_price = costStruct.TCO.Key_assumptions. ...
                    Initialvalue('CNG_price');    
                    % LNG-Preis
                obj.LNG_price = costStruct.TCO.Key_assumptions. ...
                    Initialvalue('LNG_price');    
                    % Electricity_price
                obj.Electricity_price = costStruct.TCO.Key_assumptions. ...
                    Initialvalue('Electricity_price');
                    % Hydrogen_price
                obj.Hydrogen_price = costStruct.TCO.Key_assumptions. ...
                    Initialvalue('Hydrogen_price');
                    % Verzinsung Umlaufvermögen/Herstellkosten
                obj.Interest_current_asset = costStruct.TCO. ...
                    Key_assumptions.Initialvalue('Interest_current_asset');
                    % Verzinsung Anlagevermögen/Herstellkosten
                obj.Interest_fixed_asset = costStruct.TCO. ...
                    Key_assumptions.Initialvalue('Interest_fixed_asset');
                    % Administrative_costs/Herstellkosten
                obj.Administrative_costs = costStruct.TCO.Key_assumptions. ...
                    Initialvalue('Administrative_costs');    
            
                    
                % Calculation_assumptions-------------------------------------
                    % Driving_distance
                obj.Driving_distance = costStruct.TCO. ...
                    Calculation_assumptions. ...
                    Initialvalue_towing_vehicle('Driving_distance');
                    % Anteil Mautstrecke
                obj.Ratio_toll_route = costStruct.TCO. ...
                    Calculation_assumptions. ...
                    Initialvalue_towing_vehicle('Ratio_toll_route');
                    % Beladezeit/Entladezeit setzt sich zusammen aus einem
                    % Grundwert (Zeit für Anmeldung, Warten, Anfahrt Rampe)
                    % und festem Wert für jedes Element des Gespanns, das
                    % einen Aufbau besitzt (nicht SZM und DOL)
                obj.Loading_time_combination = costStruct.TCO. ...
                    Calculation_assumptions. ...
                        Initialvalue_towing_vehicle('Loading_time_combination');
                obj.Unloading_time_combination = costStruct.TCO. ...
                    Calculation_assumptions. ...
                        Initialvalue_towing_vehicle('Unloading_time_combination');
                    % Anhänger
                for k = 1:c_obj
                        % Beladezeit
                    obj.Loading_time_combination = obj.Loading_time_combination + ...
                        isprop(Composition, 'Aufbau')*costStruct. ...
                        TCO.Calculation_assumptions. ...
                        Initialvalue_trailer('Loading_time_combination');
                        % Entladezeit
                    obj.Unloading_time_combination = obj.Unloading_time_combination + ...
                        isprop(Composition, 'Aufbau')*costStruct. ...
                        TCO.Calculation_assumptions. ...
                        Initialvalue_trailer('Unloading_time_combination');
                end
                    % Anteil Leerfahrten
                obj.Ratio_empty_trips = costStruct.TCO. ...
                    Calculation_assumptions. ...
                    Initialvalue_towing_vehicle('Ratio_empty_trips');
                    % Operating_life ab Kaufdatum (Abschreibungszeitraum)
                obj.Operating_life = [costStruct.TCO. ...
                    Calculation_assumptions. ...
                    Initialvalue_towing_vehicle('Operating_life'), ...
                    ones(1,c_obj-1)*costStruct.TCO. ...
                    Calculation_assumptions. ...
                    Initialvalue_trailer('Operating_life')];
                    % Tire_mileage
                obj.Tire_mileage = [costStruct.TCO. ...
                    Calculation_assumptions. ...
                    Initialvalue_towing_vehicle('Tire_mileage'), ...
                    ones(1,c_obj-1)*costStruct.TCO. ...
                    Calculation_assumptions. ...
                    Initialvalue_trailer('Tire_mileage')];
                    % Anteil Eigentankung (Diesel)
                obj.Ratio_inhouse_tanking_diesel = costStruct.TCO. ...
                    Calculation_assumptions. ...
                    Initialvalue_towing_vehicle(['Ratio_inhouse_'...
                    'tanking_diesel']);
                    % Schmierstoff/Fuel_costs
                obj.Lubricant_consumption = costStruct.TCO. ...
                    Calculation_assumptions. ...
                    Initialvalue_towing_vehicle('Lubricant_consumption');
                    % Adblue/bDiesel
                obj.Adblue_consumption = costStruct.TCO. ...
                    Calculation_assumptions. ...
                    Initialvalue_towing_vehicle('Adblue_consumption');
                    % Afa (zeitabhängig)
                obj.Afa_time_dependent = [costStruct.TCO. ...
                    Calculation_assumptions. ...
                    Initialvalue_towing_vehicle('Afa_time_dependent'), ...
                    ones(1,c_obj-1)*costStruct.TCO. ...
                    Calculation_assumptions. ...
                    Initialvalue_trailer('Afa_time_dependent')];
                    % Current_asset
                obj.Current_asset = [costStruct.TCO. ...
                    Calculation_assumptions. ...
                    Initialvalue_towing_vehicle('Current_asset'), ...
                    ones(1,c_obj-1)*costStruct.TCO. ...
                    Calculation_assumptions. ...
                    Initialvalue_trailer('Current_asset')];
                    % Insurance_vehicle
                obj.Insurance_vehicle = [costStruct.TCO. ...
                    Calculation_assumptions. ...
                    Initialvalue_towing_vehicle('Insurance_vehicle'), ...
                    ones(1,c_obj-1)*costStruct.TCO. ...
                    Calculation_assumptions. ...
                    Initialvalue_trailer('Insurance_vehicle')];
                    % Insurance_transport
                obj.Insurance_transport = costStruct.TCO. ...
                    Calculation_assumptions. ...
                    Initialvalue_towing_vehicle('Insurance_transport');
                    % Communication
                obj.Communication = costStruct.TCO. ...
                    Calculation_assumptions. ...
                    Initialvalue_towing_vehicle('Communication');
                    % Repair_maintenance_care
                obj.Repair_maintenance_care = [costStruct.TCO. ...
                    Calculation_assumptions. ...
                    Initialvalue_towing_vehicle(['Repair'...
                    '_maintenance_care']), ones(1,c_obj-1)*costStruct.TCO. ...
                    Calculation_assumptions. ...
                    Initialvalue_trailer('Repair_maintenance_care')];
                
                % Table mit TCO-Results-----------------------------------
                obj.Results = ...
                    costStruct.TCO.Results;
            end
        end
        
        
        % Vehicle basic data-----------------------------------------------
            % Replacement_original_price = Purchase_price(1 +
            % proz. Preisanstieg für Wiederbeschaffung)
        function Replacement_original_price = ...
                get.Replacement_original_price(obj)
            Replacement_original_price = round(obj.Purchase_price - ...
                obj.Tire_costs_set - obj.Residual_value);
        end
            % Residual_value in Abhängigkeit der Operating_life/
            % des Abschreibungszeitraum
        function Residual_value = get.Residual_value(obj)
                Residual_value = round(max(0,(obj.Purchase_price)*0.8- ...
                    ((obj.Operating_life- ...
                    ones(1,length(obj.Operating_life))).* ...
                    (obj.Purchase_price)*0.1)) + obj.residualValueBattery,0);
        end
            
            % Amortization_value = Replacement_original_price - Residual_value -
            % Tire_costs (inkl. Verhältnis Aufl./Anh. Lkw)
        function Amortization_value = get.Amortization_value(obj)
            Amortization_value = round(obj.Replacement_original_price.* ...
                obj.Ratio_Trailer_Truck.*(1+1/100* ...
                obj.Price_increase_repurchase).^obj.Operating_life,0);
        end
        
        % Auskommentiert, da in VSim_auswerten übergeben
%             % bDiesel in l/100km
%         function bDiesel = get.bDiesel(~)
%             global Param
%             bDiesel = Param.VSim.bDiesel;
%         end
%             % CNG-Verbrauch in kg/100km
%         function CNG_consumption = get.CNG_consumption(~)
%             global Composition
%             if strcmp(Composition{1,1}.VSim.Gasart, 'CNG')
%                 CNG_consumption = Composition{1,1}.VSim.Gasverbrauch;
%             else
%                 CNG_consumption = 0;
%             end
%         end
%             % LNG-Verbrauch in kg/100km
%         function LNG_consumption = get.LNG_consumption(~)
%             global Composition
%             if strcmp(Composition{1,1}.VSim.Gasart, 'LNG')
%                 LNG_consumption = Composition{1,1}.VSim.Gasverbrauch;
%             else
%                 LNG_consumption = 0;
%             end
%         end
%             % energyTotal in kWh/100km
%         function energyTotal = get.energyTotal(~)
%             global Composition
%             energyTotal = Composition{1,1}.VSim.energyTotal;
%         end
        
        % Personnel_costs---------------------------------------------------
            % Jahresbruttolohn Fahrer = Daily_working_time * 
            % Bruttostundenlohn * Einsatztage/Jahr
        function Annual_gross_wage_driver = get.Annual_gross_wage_driver(obj)
            Annual_gross_wage_driver = round(obj.Daily_working_time* ...
                obj.Gross_hourly_wage_driver*obj.Operating_days_year,0);
        end
            % Jahresbruttolohn Fahrzeug = Jahresbruttolohn Fahrer *
            % Personnel_factor
        function Annual_gross_wage_truck = get.Annual_gross_wage_truck(obj)
            Annual_gross_wage_truck = round(obj.Annual_gross_wage_driver* ...
                obj.Personnel_factor,0);
        end
            % Sozialaufwendungen in Euro = Soz.-Aufw. in Proz *
            % Jahresbruttolohn Fahrzeug
        function Social_costs_EUR = get.Social_costs_EUR(obj)
            Social_costs_EUR = round(obj.Annual_gross_wage_truck* ...
                obj.Social_costs_percent/100,0);
        end
            % Spesen/Jahr = Spesen/Tag*Einsatztage/Jahr
        function Fees_year = get.Fees_year(obj)
            Fees_year = round(obj.Fees_day*obj.Operating_days_year,0);
        end
            % Summe Fahrpersonalkosten
        function Driving_personnel_costs_total = ...
                get.Driving_personnel_costs_total(obj)
            Driving_personnel_costs_total = round(obj.Annual_gross_wage_truck + ...
                obj.Social_costs_EUR + obj.Back_up_driver + ...
                obj.Fees_year + obj.Driver_costs_other,0);
        end
        % Calculation_assumptions---------------------------------------------
            % Daily_driving_time (max. 9h)
        function Daily_driving_time = get.Daily_driving_time(obj)
            Daily_driving_time = max(min(round((obj.Daily_working_time - ...
                obj.Other_works_day)/(1+(obj.Loading_time_combination + ...
                obj.Unloading_time_combination)* ...
                (1-obj.Ratio_empty_trips/100)* ...
                obj.Average_speed/ ...
                obj.Driving_distance),2),9),0);
        end
            % Annual_mileage = Average_speed *
            % Daily_driving_time * Einsatztage/Jahr
        function Annual_mileage = get.Annual_mileage(obj)
            if obj.rangeElectric >= obj.Average_speed*obj.Daily_driving_time
                Annual_mileage = round(obj.Average_speed* ...
                obj.Daily_driving_time*obj.Operating_days_year* ...
                ones(1,length(obj.Purchase_price)),0);
            else
                Annual_mileage = round(obj.rangeElectric*...
                    obj.Operating_days_year*...
                    ones(1,length(obj.Purchase_price)),0);
            end
        end
            % Afa (leistungsabhängig)
        function Afa_power_dependent = get.Afa_power_dependent(obj)
            Afa_power_dependent = 100-obj.Afa_time_dependent;
        end
        
        % -----------------------------------------------------------------
        % Kalkulation zeitabhängige Fahrzeugkosten ( Kosten pro Jahr):
        % bei Unterscheidung Zugmaschine/Anhänger werden die
        % nachfolgenden Properties als Array Vektor gespeichert
            % zeitabhängige Abschreibungen
        function Amortisation_time_dependent = get.Amortisation_time_dependent(obj)
            Amortisation_time_dependent = round(obj.Amortization_value.* ...
                obj.Afa_time_dependent/100./obj.Operating_life,0);
        end
            % Verzinsung Umlaufvermögen
        function Current_assets_interest_bearing = ...
                get.Current_assets_interest_bearing(obj)
            Current_assets_interest_bearing = round(sum(obj.Current_asset)* ...
                obj.Interest_current_asset/100,0);
        end
            % Verzinsung Anlagevermögen
        function Fixed_assets_interest_bearing = ...
                get.Fixed_assets_interest_bearing(obj)
            Fixed_assets_interest_bearing = round(obj.Purchase_price/2* ...
                obj.Interest_fixed_asset/100,0);
        end
            % Taxes in Results-Table übernehmen
        function Taxes = get.Taxes(obj)
            Taxes = round(obj.Taxes,0);
        end
            % Insurance
        function Insurance = get.Insurance(obj)
            Insurance = round(obj.Insurance_vehicle + ...
                [obj.Insurance_transport, ...
                zeros(1,length(obj.Amortisation_time_dependent)-1)],0);
        end
            % Communication in Results-Table übernehmen
        function Communication = get.Communication(obj)
            Communication = round(obj.Communication,0);
        end
        % Summe Fahrzeug Kosten (ohne Fahrpersonalkosten)
        function Sum_vehicle_costs = get.Sum_vehicle_costs(obj)
            Sum_vehicle_costs = round(obj.Amortisation_time_dependent + ...
                [obj.Current_assets_interest_bearing, ...
                zeros(1,length(obj.Amortisation_time_dependent)-1)] + ...
                obj.Fixed_assets_interest_bearing + obj.Taxes + ...
                obj.Insurance + [obj.Communication, ...
                zeros(1,length(obj.Amortisation_time_dependent)-1)],0);
        end
        % Summe fixe Kosten (inkl. Fahrpersonalkosten) = leistungsabhängige
        % Fahrzeugkosten
        function Sum_fix_costs = get.Sum_fix_costs(obj)
            Sum_fix_costs = round(obj.Sum_vehicle_costs + ...
                [obj.Driving_personnel_costs_total, ...
                zeros(1,length(obj.Sum_vehicle_costs)-1)],0);
        end
        
        % -----------------------------------------------------------------
        % Kalkulation leistungsabhängige Fahrzeugkosten ( Kosten pro Jahr):
        % bei Unterscheidung Zugmaschine/Anhänger werden die
        % nachfolgenden Properties als Array Vektor gespeichert
        
            % leistungsabhängige Abschreibungen
        function Amortisation_performance_related = ...
                get.Amortisation_performance_related(obj)
            Amortisation_performance_related = round(obj.Amortization_value.* ...
                obj.Afa_power_dependent/100./obj.Operating_life,0);
        end
            % Summe Fuel_costs
        function Fuel_costs = get.Fuel_costs(obj)
            % Durchschnittlicher Diesel_price (Eigen-/Fremdbetankung)
            Diesel_price_avg = (obj.Diesel_price* ...
                obj.Ratio_inhouse_tanking_diesel/100 + ...
                obj.Diesel_price_external*...
                (1-obj.Ratio_inhouse_tanking_diesel/100));
            % Dieselkosten in €/km
            Dieselkosten = obj.bDiesel*Diesel_price_avg/100;
            % CNG-Kosten in €/km
            CNGkosten = obj.CNG_consumption*obj.CNG_price/100;
            % LNG-Kosten in €/km
            LNGkosten = obj.LNG_consumption*obj.LNG_price/100;
            % Stromkosten in €/km
            Stromkosten = obj.energyTotal*obj.Electricity_price/100;
            % Wasserstoffkosten in €/km
            Wasserstoffkosten = obj.Hydrogen_consumption*obj.Hydrogen_price/100;
            % Fuel_costs in €/km
            Fuel_costs_km = Dieselkosten + CNGkosten + ...
                LNGkosten + Stromkosten + Wasserstoffkosten;
            % Fuel_costs in €/Jahr
            Fuel_costs = round(Fuel_costs_km* ...
                obj.Annual_mileage(1),0);
        end
            % Lubricant_costs pro Fuel_costs
        function Lubricant_costs = get.Lubricant_costs(obj)
            Lubricant_costs = round((obj.Fuel_costs - ...
                round(obj.energyTotal*obj.Electricity_price/100* ...
                obj.Annual_mileage(1),0))* ...
                obj.Lubricant_consumption/100,0);
        end
            % Adblue_costs pro bDiesel
        function Adblue_costs = get.Adblue_costs(obj)
            Adblue_costs = round(obj.bDiesel/100*...
                obj.Adblue_price*obj.Adblue_consumption/100* ...
                obj.Annual_mileage(1),0);
        end
        % Repair_costs
        function Repair_costs = get.Repair_costs(obj)
            Repair_costs = round(obj.Annual_mileage.* ...
                obj.Repair_maintenance_care,0);
        end
        % Akkupackverschleisskosten
        function Verschleisskosten_Batteriepack = ...
                get.Verschleisskosten_Batteriepack(obj) 
            
            if obj.Lebensdauer_Batteriepack == 0
                Verschleisskosten_Batteriepack = 0;
            else
                Verschleisskosten_Batteriepack = ...
                    round(ceil(obj.Operating_life(1)/ ...
                    (obj.Lebensdauer_Batteriepack))* ...
                    obj.Anschaffungspreis_Akkupack - ...
                    obj.Anschaffungspreis_Akkupack); 
            end
        end   
        % Tire_costs
        function Tire_costs = get.Tire_costs(obj)
            Tire_costs = round(obj.Tire_costs_set.* ...
                obj.Annual_mileage./obj.Tire_mileage,0);
        end
        % Summe variable Kosten
        function Sum_variable_costs = get.Sum_variable_costs(obj)
            Sum_variable_costs = round(obj.Amortisation_performance_related ...
                + [obj.Fuel_costs, ...
                zeros(1,length(obj.Amortisation_performance_related)-1)] + ...
                [obj.Lubricant_costs, ...
                zeros(1,length(obj.Amortisation_performance_related)-1)] + ...
                [obj.Adblue_costs, ...
                zeros(1,length(obj.Amortisation_performance_related)-1)] + ...
                obj.Repair_costs + ...
                [obj.Verschleisskosten_Batteriepack, ...
                zeros(1,length(obj.Amortisation_performance_related)-1)] + ...
                obj.Tire_costs,0);
        end
        
        % Summe fixe und variable Kosten
        function Sum_fix_variable_costs = ...
                get.Sum_fix_variable_costs(obj)
            Sum_fix_variable_costs = round(obj.Sum_fix_costs + ...
                obj.Sum_variable_costs,0);
        end
        
        % Overhead_costs
        function Overhead_costs = get.Overhead_costs(obj)
            Overhead_costs = round(sum(obj.Sum_fix_variable_costs)* ...
                (1/(1-obj.Administrative_costs/100)-1) ,0);
        end
        
        % Toll_costs = Toll_rate * Anteil_Maut * Annual_mileage
        function Toll_costs = get.Toll_costs(obj)
            Toll_costs = obj.Toll_rate*obj.Ratio_toll_route/100* ...
                obj.Annual_mileage(1);
        end
        % Total_costs
        function Total_costs = get.Total_costs(obj)
            Total_costs = round(sum(obj.Sum_fix_variable_costs),0) ...
                + obj.Overhead_costs + obj.Toll_costs;
            for k = 1:size(obj.Results,1)-1
                row = obj.Results.Properties.RowNames{k};
                if ~strcmp(row, 'Time_dependent_vehicle_costs') && ...
                    ~strcmp(row, 'Performance_related_vehicle_costs') && ...
                    ~strcmp(row, 'Sum_costs')
                
                    obj.Results.Euro_Jahr{row} = ...
                        sum(obj.(row));
                    obj.Results.Euro_km{row} = ...
                        sum(obj.(row))/obj.Annual_mileage(1);
                end
            end
            obj.Results.Euro_Jahr{'Total_costs'} = Total_costs;
            obj.Results.Euro_km{'Total_costs'} = Total_costs/ ...
                obj.Annual_mileage(1);
        end
    end   
end