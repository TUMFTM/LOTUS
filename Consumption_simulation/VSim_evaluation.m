function [ Results, Param ] = VSim_evaluation(Results, Param, Run, Cycle)
% Designed at FTM, Technical University of Munich
%-------------
% Created on: 01.11.2018
% ------------
% Version: Matlab2017b
%-------------
% This function post-processes the simulation results and visualizes them
% ------------
% Input:    - Param:   struct array containing all vehicle parameters
%           - Results: struct array containing the raw outputs of the
%                      consumption simulation
%           - Run:     a scalar number either 1 or 2 to determine if the
%                      vehile is in the acceleration cycle or another
%           - Cycle:   a scalar variable that indicates which driving cylce
%                      is running 
% ------------
% Output:   - Results: struct array containing the post-processed results
%                      of the consumption simulation
%           - Param:   struct array containing all vehicle parameters
% ------------
%     if Param.VSim.Opt == false
%         cd ../;
%         addpath('Klassen');
%         cd Verbrauchssimulation;
%         fprintf('\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b'); %Deletes last line
%     end

    % if simulation aborted because of significant speed deviation
    if Results.OUT_summary.signals(2).values(end) <  (Param.max_distance - 50)
        Param.VSim.Termination = 1;
        fprintf('Simulation aborted because of significant speed deviation.\n');
        fprintf('Please check the vehicle configurations.\n');
        
    else % continue with the post-processing
        if Param.dcycle == 5
            for i = 1:length(Results.OUT_summary.signals(4).values)
                if Results.OUT_summary.signals(4).values(i) > 80
                    Param.VSim.v_t(i) = Results.OUT_summary.signals(4).values(i);
                    if Results.OUT_summary.signals(4).values(i-10) > 80
                        break
                    end
                else
                    Param.VSim.v_t(i)=Results.OUT_summary.signals(4).values(i);
                end
            end
        else
%         for i = 1:length(Results.OUT_summary.signals(4).values)
%             if Results.OUT_summary.signals(4).values(i) > 80
%                 Param.VSim.v_t(i) = Results.OUT_summary.signals(4).values(i);
%                 if Results.OUT_summary.signals(4).values(i-10) > 80
%                     break
%                 end
%             else
%                 Param.VSim.v_t(i) = Results.OUT_summary.signals(4).values(i);
%             end
%         end
            fprintf('Starting with postprocessing.\n');
            if ~Param.VSim.Opt
                fprintf('Starting with postprocessing.\n');
                fprintf('%s \n',Param.name); %Output the name of the simulation
                if Run == 1
                    fprintf('---------------------Driving cycle%2.0f--------------------- \n', Param.dcycle);
                else
                    fprintf('---------------------Driving cycle%2.0f--------------------- \n', Cycle);
                end
            end
            Param.VSim.Termination = 0;
            
            %% Results output
            switch Param.Fueltype
                case {1,4} %Diesel(hybrid)
                    %Calculations in advance
                    Results.verbrauch = Results.OUT_summary.signals(6).values(length(Results.OUT_summary.signals(6).values));    %Fuel consumption at the end of the simulation
                    Results.duration  = max(Results.OUT_summary.time)/60;    %Driving time in minutes
                    Results.distance  = max(Results.OUT_summary.signals(2).values)/1000; %Distance in kilometers
                    Results.delta_E   = (Results.OUT_Bat.signals(1).values(length(Results.OUT_Bat.signals(1).values)) - Param.Bat.SOC_start)*Param.Bat.Voltage*Param.Bat.Useable_capacity * Param.Hybrid_Truck/1000;   %Energy difference in the battery between the beginning and end of the cycle
                    Results.V         = Results.delta_E*188/0.95/0.95/0.95/830;     %The energy difference corresponding to fuel volume

                    %Transfer of results to commercial vehicle design
                    Param.VSim.bDiesel = (Results.OUT_summary.signals(7).values(end))/(Results.OUT_summary.signals(2).values(length(Results.OUT_summary.signals(2).values))/100000); % l/100km
                    Param.VSim.bGas    = 0;
                    %Param.VSim.energyTotal = 0; % The energy difference in hybrids is included in other fuel consumption, Jon Schmidt, 22.03.2016

                    if Param.WPT.Voltage
                        Results.delta_WPT = Results.OUT_WPT.signals(1).values(end); % Consumed energy by charging in kWh
                        Param.VSim.energyTotal_Bat = -Results.delta_E * Param.Hybrid_Truck/(Results.OUT_summary.signals(2).values(length(Results.OUT_summary.signals(2).values))/100000); % in kWh/100km
                        Param.VSim.energyTotal_WPT = -Results.delta_WPT /(Results.OUT_summary.signals(2).values(length(Results.OUT_summary.signals(2).values))/100000);  % in kWh/100km
                        Param.VSim.energyTotal     = Param.VSim.energyTotal_Bat + Param.VSim.energyTotal_WPT;
                        
                    else
                        Results.delta_WPT = 0;
                        Param.VSim.energyTotal_Bat = -Results.delta_E * Param.Hybrid_Truck/(Results.OUT_summary.signals(2).values(length(Results.OUT_summary.signals(2).values))/100000); % in kWh/100km
                        Param.VSim.energyTotal_WPT = 0;
                        Param.VSim.energyTotal     = Param.VSim.energyTotal_Bat + Param.VSim.energyTotal_WPT;
                    end

                    Param.VSim.Consumption_kWh      = Param.VSim.bDiesel*9.97 + Param.VSim.energyTotal; %[Bun14] und [Sta12]
                    Param.vehicleProperties.CO2_EM_ak =((Results.OUT_summary.signals(7).values(end))*Param.engine.fuel.co2_per_litre*1000/(Results.OUT_summary.signals(2).values(length(Results.OUT_summary.signals(2).values))/1000))/(Param.vehicle.payload/1000);       %Theisen 05.04.2016

                    % Transfer to TCO class (Wolff 12.11.16)
                    Param.TCO.bDiesel      = Param.VSim.bDiesel;
                    Param.TCO.CNG_consumption        = Param.VSim.bGas;
                    Param.TCO.LNG_consumption        = Param.VSim.bGas;
                    Param.TCO.energyTotal       = Param.VSim.energyTotal;
                    Param.TCO.Hydrogen_consumption = 0;

                    %Output in Command Window
                    if Param.VSim.Opt == false
                        fprintf('Fuel consumption:      %2.4f l Diesel \n',Results.OUT_summary.signals(7).values(end));  %Output fuel consumption in liters
                        fprintf('Fuel economy:          %2.4f l/100km Diesel \n',Param.VSim.bDiesel);  %Output fuel consumption in l/100km
                        fprintf('Normalized economy:    %2.4f l/100tkm \n', (Results.OUT_summary.signals(7).values(end))/(Results.OUT_summary.signals(2).values(length(Results.OUT_summary.signals(2).values))/100000)/(Param.vehicle.payload/1000));  %Output fuel consumption in l/100tkm
                        fprintf(' \n');
                        fprintf('Energy consumption:    %2.4f kWh,        of which %2.4f kWh battery', Results.OUT_summary.signals(7).values(end)*9.97, -Results.delta_E); %Output battery capacity consumption in kWh

                        if Param.WPT.Voltage
                            fprintf(' and %2.4f kWh WPT\n', -Results.delta_WPT);
                        else
                            fprintf('\n');
                        end

                        fprintf('Energy:                %2.4f kWh/100km,  of which %2.4f kWh/100km battery', Param.VSim.Consumption_kWh , Param.VSim.energyTotal_Bat); %Output battery capacity consumption in kWh/100km
                        if Param.WPT.Voltage
                            fprintf(' and %2.4f kWh/100km in WPT\n', Param.VSim.energyTotal_WPT);
                        else
                            fprintf('\n');
                        end

                        fprintf('Normalized energy:     %2.4f kWh/100tkm,  of which %2.4f kWh/100tkm battery', ((Param.VSim.Consumption_kWh)/(Param.vehicle.payload/1000)), Param.VSim.energyTotal_Bat/(Param.vehicle.payload/1000));  %Output battery capacity consumption in kWh/100tkm (per 100km and per tonn of cargo)
                        if Param.WPT.Voltage
                            fprintf(' and %2.4f kWh/100tkm WPT\n', Param.VSim.energyTotal_WPT/(Param.vehicle.payload/1000));  %Output consumption of WPT in kWh/100tkm (per 100km and per tonn of cargo)
                        else
                            fprintf('\n');
                        end

                        fprintf(' \n');
                        fprintf('Emission:              %2.4f gCO2/km,    of which %2.4f gCO2/km battery', (Results.OUT_summary.signals(7).values(end)*Param.engine.fuel.co2_per_litre*1000 + (-Results.delta_WPT -Results.delta_E) * Param.em.fuel.co2_per_kwh) /(Results.OUT_summary.signals(2).values(length(Results.OUT_summary.signals(2).values))/1000), (-Results.delta_E * Param.em.fuel.co2_per_kwh) /(Results.OUT_summary.signals(2).values(length(Results.OUT_summary.signals(2).values))/1000));  %Output fuel emission in gCO2/km
                        if Param.WPT.Voltage
                            fprintf(' and %2.4f gCO2/km WPT\n', -Results.delta_WPT * Param.em.fuel.co2_per_kwh/(Results.OUT_summary.signals(2).values(length(Results.OUT_summary.signals(2).values))/1000));
                        else
                            fprintf('\n');
                        end

                        fprintf('Normalized emission:   %2.4f gCO2/tkm,    of which %2.4f gCO2/tkm battery', (Results.OUT_summary.signals(7).values(end)*Param.engine.fuel.co2_per_litre*1000 + (-Results.delta_WPT -Results.delta_E) * Param.em.fuel.co2_per_kwh) /(Results.OUT_summary.signals(2).values(length(Results.OUT_summary.signals(2).values))/1000)/(Param.vehicle.payload/1000), (-Results.delta_E * Param.em.fuel.co2_per_kwh) /(Results.OUT_summary.signals(2).values(length(Results.OUT_summary.signals(2).values))/1000)/(Param.vehicle.payload/1000));  %Ausgabe Fueltypeverbrauch in gCO2/tkm
                        if Param.WPT.Voltage
                            fprintf(' and %2.4f gCO2/tkm WPT\n', -Results.delta_WPT * Param.em.fuel.co2_per_kwh/(Results.OUT_summary.signals(2).values(length(Results.OUT_summary.signals(2).values))/1000)/(Param.vehicle.payload/1000));  %Ausgabe Verbrauch WPT in kWh/100tkm (pro 100km und pro Tonne Ladungsmasse)
                        else
                            fprintf('\n');
                        end

                        fprintf(' \n');
                        fprintf('Distance:                         %2.4f km \n', Results.distance); %Distance in kilometers
                        fprintf('Duration:                         %2.4f minutes \n',Results.duration);  %Output driving time in minutes
                        fprintf('Average speed:                    %2.4f km/h \n',0.001*Results.OUT_summary.signals(2).values(end)/(Results.OUT_summary.time(end)/3600))  %Output average speed in km/h

                        [t_0_80] = Acceleration_readout(Param.VSim);
                        fprintf('Acceleration from 0 to 80 km/h:   %2.4f seconds \n', t_0_80);  %Output acceleration in seconds
                        [t_60_80] = Acceleration(Param.VSim);
                        fprintf('Acceleration from 60 to 80 km/h:  %2.4f seconds \n', t_60_80);  %Output acceleration in seconds
                        
                        fprintf(' \n');
%                         fprintf('Acquisition cost:  %2.4f EUR\n', Param.acquisitionCosts.KA_ZM );  %Output acquisition cost in €
                    end

                case {8,9,10,11} %Dual-Fuel & Dual Fuel Hybrid
                    %Calculations in advance
                    Results.verbrauch_d = Results.OUT_summary.signals(6).values(length(Results.OUT_summary.signals(6).values));    %Diesel consumption at the end of the simulation
                    Results.verbrauch_lng = Results.OUT_summary.signals(8).values(length(Results.OUT_summary.signals(8).values));    %LNG consumption at the end of the simulation
                    Results.duration = max(Results.OUT_summary.time)/60;    %Driving time in minutes
                    Results.distance = max(Results.OUT_summary.signals(2).values)/1000; %Distance in kilometers
                    Results.delta_E = (Results.OUT_Bat.signals(1).values(length(Results.OUT_Bat.signals(1).values))-Param.Bat.SOC_start)*Param.Bat.Voltage*Param.Bat.Useable_capacity/1000;   %Energy difference in the battery between the beginning and end of the cycle [kWh]
                    Results.V = Results.delta_E*3600/0.41/0.95/0.95/0.95/Param.engine.fuel.heat_of_combustion*0.06/Param.engine.fuel.density_diesel;     %The energy difference corresponding to diesel volume [l]
                    Results.M = Results.delta_E*3600/0.41/0.95/0.95/0.95/Param.engine.fuel.heat_of_combustion*0.94;     %The energy difference corresponding to LNG mass [kg]

                    %Transfer of results to commercial vehicle design
                    Param.VSim.bDiesel = (Results.OUT_summary.signals(7).values(end))/(Results.OUT_summary.signals(2).values(length(Results.OUT_summary.signals(2).values))/100000);
                    Param.VSim.bGas = (Results.OUT_summary.signals(9).values(end))/(Results.OUT_summary.signals(2).values(length(Results.OUT_summary.signals(2).values))/100000);
                    Param.VSim.energyTotal_Bat = -Results.delta_E * Param.Hybrid_Truck/(Results.OUT_summary.signals(2).values(length(Results.OUT_summary.signals(2).values))/100000); % in kWh/100km
                    Param.VSim.energyTotal = Param.VSim.energyTotal_Bat;

                    switch Param.engine.fuel.Gasart
                        case 'LNG'
                            Param.VSim.Consumption_kWh=Param.VSim.bDiesel*9.97+Param.VSim.bGas*13.98 + Param.VSim.energyTotal_Bat; %[Bun14], [Sta12]
                            % Transfer to TCO class (Wolff 12.11.16)
                            Param.TCO.LNG_consumption = Param.VSim.bGas;
                            Param.TCO.CNG_consumption = 0;

                        case 'CNG'
                            Param.VSim.Consumption_kWh=Param.VSim.bDiesel*9.97+Param.VSim.bGas*12.87 +Param.VSim.energyTotal_Bat; %[Sta12]
                            % Transfer to TCO class (Wolff 12.11.16)
                            Param.TCO.CNG_consumption = Param.VSim.bGas;
                            Param.TCO.LNG_consumption = 0;
                    end

                    Param.vehicleProperties.CO2_EM_ak=(((Results.OUT_summary.signals(7).values(end)-Results.V)*Param.engine.fuel.co2_per_litre_diesel*1000/(Results.OUT_summary.signals(2).values(length(Results.OUT_summary.signals(2).values))/1000))+((Results.OUT_summary.signals(9).values(end)-Results.M)*Param.engine.fuel.co2_per_kg_gas*1000/(Results.OUT_summary.signals(2).values(length(Results.OUT_summary.signals(2).values))/1000)))/(Param.vehicle.payload/1000);

                    % Transfer to TCO class (Wolff 12.11.16)
                    Param.TCO.bDiesel = Param.VSim.bDiesel;
                    Param.TCO.energyTotal = Param.VSim.energyTotal;
                    Param.TCO.Hydrogen_consumption = 0;

                    %Output in command window
                    if Param.VSim.Opt == false
                        fprintf('Fuel consumption:      %2.4f l Diesel        and ',Results.OUT_summary.signals(7).values(end)-Results.V);  %Output diesel consumption in l
                        fprintf('%2.4f kg ', Results.OUT_summary.signals(9).values(end)-Results.M);  %Output LNG consumption in kg
                        fprintf([Param.engine.fuel.Gasart, '\n']);
                        fprintf('Fuel economy:          %2.4f l/100km Diesel  and ',Param.VSim.bDiesel);  %Output diesel consumption in l/100km
                        fprintf('%2.4f kg/100km ' ,Param.VSim.bGas);  %Output LNG consumption in kg/100km
                        fprintf([Param.engine.fuel.Gasart, '\n']);
                        fprintf('Normalized economy:    %2.4f l/100tkm Diesel and ', (Results.OUT_summary.signals(7).values(end)-Results.V)/(Results.OUT_summary.signals(2).values(length(Results.OUT_summary.signals(2).values))/100000)/(Param.vehicle.payload/1000));  %Output diesel consumption in l/100tkm
                        fprintf('%2.4f kg/100tkm ', (Results.OUT_summary.signals(9).values(end)-Results.M)/(Results.OUT_summary.signals(2).values(length(Results.OUT_summary.signals(2).values))/100000)/(Param.vehicle.payload/1000));  %Output LNG consumption in kg/100tkm
                        fprintf([Param.engine.fuel.Gasart, '\n']);
                        
                        fprintf(' \n');
                        fprintf('Energy:                %2.4f kWh/100km \n' , Param.VSim.Consumption_kWh);  %Output consumption in kWh/100km
                        fprintf('Normalized energy:     %2.4f kWh/100tkm \n' , Param.VSim.Consumption_kWh/(Param.vehicle.payload/1000));  %Output consumption in kWh/100tkm
                        
                        fprintf(' \n');
                        fprintf('Emissions:             %2.4f gCO2/km of Diesel and ', (Results.OUT_summary.signals(7).values(end)-Results.V)*Param.engine.fuel.co2_per_litre_diesel*1000/(Results.OUT_summary.signals(2).values(length(Results.OUT_summary.signals(2).values))/1000));  %Output diesel consumption in gCO2/km
                        fprintf('%2.4f gCO2/km ', (Results.OUT_summary.signals(9).values(end)-Results.M)*Param.engine.fuel.co2_per_kg_gas*1000/(Results.OUT_summary.signals(2).values(length(Results.OUT_summary.signals(2).values))/1000));  %Output LNG consumption in gCO2/km
                        fprintf([Param.engine.fuel.Gasart, '\n']);
                        fprintf('Normalized emissions:  %2.4f gCO2/tkm of Diesel and ', ((Results.OUT_summary.signals(7).values(end)-Results.V)*Param.engine.fuel.co2_per_litre_diesel*1000/(Results.OUT_summary.signals(2).values(length(Results.OUT_summary.signals(2).values))/1000))/(Param.vehicle.payload/1000));  %Output diesel emissions in gCO2/tkm
                        fprintf('%2.4f gCO2/tkm ', ((Results.OUT_summary.signals(9).values(end)-Results.M)*Param.engine.fuel.co2_per_kg_gas*1000/(Results.OUT_summary.signals(2).values(length(Results.OUT_summary.signals(2).values))/1000))/(Param.vehicle.payload/1000));  %Output LNG emissions in gCO2/tkm
                        fprintf([Param.engine.fuel.Gasart, '\n']);
                        
                        CO2_Gas = ((Results.OUT_summary.signals(9).values(end)-Results.M)*Param.engine.fuel.co2_per_kg_gas*1000/(Results.OUT_summary.signals(2).values(length(Results.OUT_summary.signals(2).values))/1000))/(Param.vehicle.payload/1000);
                        CO2_Diesel = ((Results.OUT_summary.signals(7).values(end)-Results.V)*Param.engine.fuel.co2_per_litre_diesel*1000/(Results.OUT_summary.signals(2).values(length(Results.OUT_summary.signals(2).values))/1000))/(Param.vehicle.payload/1000);
                        CO2_kombiniert = CO2_Gas + CO2_Diesel;
                        fprintf('Combined emissions:    %2.4f gCO2/km of Diesel and ', CO2_kombiniert);
                        fprintf([Param.engine.fuel.Gasart, '\n']);
                        
                        fprintf(' \n');
                        fprintf('Distance:                          %2.4f km \n', Results.distance); %Distance in kilometers
                        fprintf('Driving time:                      %2.4f  Minutes \n',Results.duration);  %Driving time in minutes
                        fprintf('Average speed:                     %2.4f km/h \n',0.001*Results.OUT_summary.signals(2).values(end)/(Results.OUT_summary.time(end)/3600))  %Output average speed in km/h

                        [t_0_80] = Acceleration_readout(Param.VSim);
                        fprintf('Acceleration from 0 to 80 km/h:    %2.4f seconds \n', t_0_80);  %Output acceleration in seconds
                        [t_60_80] = Acceleration(Param.VSim);
                        fprintf('Acceleration from 60 to 80 km/h:   %2.4f seconds \n', t_60_80);  %Output acceleration in seconds
                        
                        fprintf(' \n');
%                         fprintf('Acquisition cost: %2.4f EUR\n', Param.acquisitionCosts.KA_ZM );  %Output costs in €
                    end
                    
                case {2,3,5,6} %Gas & Gas Hybrid
                    %Calculations in advance
                    Results.verbrauch_lng = Results.OUT_summary.signals(8).values(length(Results.OUT_summary.signals(8).values));    %LNG consumption at the end of the simulation
                    Results.duration = max(Results.OUT_summary.time)/60;    %Driving time in minutes
                    Results.distance = max(Results.OUT_summary.signals(2).values)/1000; %Distance in kilometers
                    Results.delta_E = (Results.OUT_Bat.signals(1).values(length(Results.OUT_Bat.signals(1).values))-Param.Bat.SOC_start)*Param.Bat.Voltage*Param.Bat.Useable_capacity/1000;   %Energy difference in the battery between the beginning and end of the simulation.
                    Results.M = Results.delta_E*3600/0.41/0.95/0.95/0.95/Param.engine.fuel.heat_of_combustion*1;     %The energy difference corresponding to LNG mass [kg]

                    %Transfer of results to commercial vehicle design
                    Param.VSim.bDiesel = 0;
                    Param.VSim.bGas = (Results.OUT_summary.signals(9).values(end))/(Results.OUT_summary.signals(2).values(length(Results.OUT_summary.signals(2).values))/100000);
                    Param.VSim.energyTotal_Bat = -Results.delta_E * Param.Hybrid_Truck/(Results.OUT_summary.signals(2).values(length(Results.OUT_summary.signals(2).values))/100000); % in kWh/100km
                    Param.VSim.energyTotal = Param.VSim.energyTotal_Bat;

                    switch Param.engine.fuel.Gasart
                        case 'LNG'
                            Param.VSim.Consumption_kWh=Param.VSim.bGas*13.98 + Param.VSim.energyTotal_Bat; %[Bun14]
                            % Transfer to TCO class (Wolff 12.11.16)
                            Param.TCO.LNG_consumption = Param.VSim.bGas;
                            Param.TCO.CNG_consumption = 0;

                        case 'CNG'
                            Param.VSim.Consumption_kWh=Param.VSim.bGas*12.87 + Param.VSim.energyTotal_Bat; %[Sta12]
                            % Transfer to TCO class (Wolff 12.11.16)
                            Param.TCO.CNG_consumption = Param.VSim.bGas;
                            Param.TCO.LNG_consumption = 0;
                    end

                    % Transfer to TCO class (Wolff 12.11.16)
                    Param.TCO.bDiesel = Param.VSim.bDiesel;
                    Param.TCO.energyTotal = Param.VSim.energyTotal;
                    Param.TCO.Hydrogen_consumption = 0;
                    Param.vehicleProperties.CO2_EM_ak = (Results.OUT_summary.signals(6).values(end))/(Param.vehicle.payload/1000);

                    %Output in Command Window
                    if Param.VSim.Opt == false
                        fprintf('Fuel consumption:     %2.4f kg ',Results.OUT_summary.signals(9).values(end)-Results.M);  %Output natural gas consumption in kg
                        fprintf([Param.engine.fuel.Gasart, '\n']);
                        fprintf('Fuel economy:         %2.4f kg/100km \n',Param.VSim.bGas);  %Output natural gas consumption in kg/100km
%                         fprintf([Param.engine.fuel.Gasart, '\n']);
                        fprintf('Nomralized economy:   %2.4f kg/100tkm \n', (Results.OUT_summary.signals(9).values(end)-Results.M)/(Results.OUT_summary.signals(2).values(length(Results.OUT_summary.signals(2).values))/100000)/(Param.vehicle.payload/1000));  %Output natural gas consumption in kg/100tkm
%                         fprintf([Param.engine.fuel.Gasart, '\n']);
                        
                        fprintf(' \n');
                        fprintf('Energy:               %2.4f kWh/100km \n' , Param.VSim.Consumption_kWh);  %Output consumption in kWh/100km
                        fprintf('Nomralized energy:    %2.4f kWh/100tkm \n' , Param.VSim.Consumption_kWh/(Param.vehicle.payload/1000));  %Output consumption in kWh/100tkm
                        
                        fprintf(' \n');
                        fprintf('Emissions:            %2.4f kgCO2 \n', Results.OUT_summary.signals(6).values(end)/1000*Results.OUT_summary.signals(2).values(end)/1000);  %Output consumption in gCO2/km
                        fprintf('Emissions:            %2.4f gCO2/km \n',Results.OUT_summary.signals(6).values(end));  %Output CO2 emissions in g/km
                        fprintf('Normalized emissions: %2.4f gCO2/tkm \n',Results.OUT_summary.signals(6).values(end)/(Param.vehicle.payload/1000));  %Output CO2 emissions in g/tkm
                        
                        fprintf(' \n');
                        fprintf('Distance:                        %2.4f km \n', Results.distance); %Distance in kilometers
                        fprintf('Driving time:                    %2.4f minutes \n',Results.duration);  %Ausgabe Fahrzeit in Minuten
                        fprintf('Average speed:                   %2.4f km/h \n',0.001*Results.OUT_summary.signals(2).values(end)/(Results.OUT_summary.time(end)/3600))  %Output average speed in km/h

                        [t_0_80] = Acceleration_readout(Param.VSim);
                        fprintf('Acceleration from 0 to 80 km/h:  %2.4f seconds \n', t_0_80);  %Output acceleration in seconds
                        [t_60_80] = Acceleration(Param.VSim);
                        fprintf('Acceleration from 60 to 80 km/h: %2.4f seconds \n', t_60_80);  %Output acceleration in seconds
                        fprintf(' \n');
%                         fprintf('Acquisition cost: %2.4f EUR\n', Param.acquisitionCosts.KA_ZM );  %Output costs in €
                    end
                    
                case {7, 12} %Electric truck, Jon Schmidt, 30.11.2015
                    Results.duration = max(Results.OUT_summary.time)/60;    %Driving time in minutes
                    Results.distance = max(Results.OUT_summary.signals(2).values)/1000; %Distance in kilometers
                    Results.delta_E = (Results.OUT_Bat.signals(1).values(length(Results.OUT_Bat.signals(1).values))-Param.Bat.SOC_start)*Param.Bat.Voltage*Param.Bat.Useable_capacity/1000;   %Energy difference in the battery between the beginning and end of the driving cycle in kWh

                    %Transfer of results to commercial vehicle design 
                    Param.VSim.bDiesel = 0;
                    Param.VSim.bGas = 0;
                    Param.VSim.energyTotal = -Results.delta_E/(Results.OUT_summary.signals(2).values(length(Results.OUT_summary.signals(2).values))/100000); % in kWh/100km

                    if Param.Fueltype == 12
                        Results.delta_WPT = Results.OUT_WPT.signals(1).values(end); % Consumed energy during charging in kWh
                        Param.VSim.energyTotal_Bat = -Results.delta_E/(Results.OUT_summary.signals(2).values(length(Results.OUT_summary.signals(2).values))/100000); % in kWh/100km
                        Param.VSim.energyTotal_WPT = -Results.delta_WPT /(Results.OUT_summary.signals(2).values(length(Results.OUT_summary.signals(2).values))/100000);  % in kWh/100km
                        Param.VSim.energyTotal = Param.VSim.energyTotal_Bat + Param.VSim.energyTotal_WPT;
                    else
                        Results.delta_WPT = 0;
                        Param.VSim.energyTotal_Bat = -Results.delta_E/(Results.OUT_summary.signals(2).values(length(Results.OUT_summary.signals(2).values))/100000); % in kWh/100km
                        Param.VSim.energyTotal_WPT = 0;
                        Param.VSim.energyTotal = Param.VSim.energyTotal_Bat + Param.VSim.energyTotal_WPT;
                    end
                    Param.VSim.Consumption_kWh = Param.VSim.energyTotal;
                    Param.vehicleProperties.CO2_EM_ak = (-Results.delta_E*Param.em.fuel.co2_per_kwh/(Results.OUT_summary.signals(2).values(length(Results.OUT_summary.signals(2).values))/1000))/(Param.vehicle.payload/1000);

                    % Transfer to TCO class (Wolff 12.11.16)
                    Param.TCO.bDiesel = Param.VSim.bDiesel;
                    Param.TCO.CNG_consumption = Param.VSim.bGas;
                    Param.TCO.LNG_consumption = Param.VSim.bGas;
                    Param.TCO.energyTotal = Param.VSim.energyTotal;
                    Param.TCO.Hydrogen_consumption = 0;

                    if Param.VSim.Opt == false
                        %Output in Command Window
                        fprintf('Energy:                          %2.4f kWh', -Results.delta_E - Results.delta_WPT); %Output consumption of battey capacity in kWh
                        if Param.Fueltype == 12
                            fprintf('      of which %2.4f kWh WPT\n', -Results.delta_WPT);
                        else
                            fprintf('\n');
                        end
                        fprintf('Energy:                          %2.4f kWh/100km', Param.VSim.Consumption_kWh); %Output consumption of battey capacity in kWh/100km
                        if Param.Fueltype == 12
                            fprintf(' of which %2.4f kWh/100km WPT\n', Param.VSim.energyTotal_WPT);
                        else
                            fprintf('\n');
                        end
                        fprintf('Normalized energy:               %2.4f kWh/100tkm', (-Results.delta_E - Results.delta_WPT)/(Results.OUT_summary.signals(2).values(length(Results.OUT_summary.signals(2).values))/100000)/(Param.vehicle.payload/1000));  %Output consumption of battey capacity in kWh/100tkm (pro 100km und pro Tonne Ladungsmasse)
                        if Param.Fueltype == 12
                            fprintf(' of which %2.4f kWh/100tkm WPT\n', -Results.delta_WPT/(Results.OUT_summary.signals(2).values(length(Results.OUT_summary.signals(2).values))/100000)/(Param.vehicle.payload/1000));  %Output consumption of WPT in kWh/100tkm (per 100km and per tonne of cargo)
                        else
                            fprintf('\n');
                        end
                        
                        fprintf(' \n');
                        fprintf('Equivalent emissions:            %2.4f gCO2/km \n', -Results.delta_E*Param.em.fuel.co2_per_kwh/(Results.OUT_summary.signals(2).values(length(Results.OUT_summary.signals(2).values))/1000));  %Output CO2 emissions in gCO2/km
                        fprintf('Normalized equivalent emissions: %2.4f gCO2/tkm \n', (-Results.delta_E*Param.em.fuel.co2_per_kwh/(Results.OUT_summary.signals(2).values(length(Results.OUT_summary.signals(2).values))/1000))/(Param.vehicle.payload/1000));  %Output CO2 emissions in gCO2/tkm
                        
                        fprintf(' \n');
                        fprintf('Distance:                        %2.4f km \n', Results.distance); %Distance in kilometers
                        fprintf('Driving time:                    %2.4f  minutes \n',Results.duration);  %Output driving time in minutes
                        fprintf('Average speed:                   %2.4f km/h\n',0.001*Results.OUT_summary.signals(2).values(end)/(Results.OUT_summary.time(end)/3600))  %Output average speed in km/h
                        
                        [t_0_80] = Acceleration_readout(Param.VSim);
                        fprintf('Acceleration from 0 to 80 km/h:  %2.4f seconds \n', t_0_80);  %Output acceleration in seconds
                        [t_60_80] = Acceleration(Param.VSim);
                        fprintf('Acceleration from 60 to 80 km/h: %2.4f seconds \n', t_60_80);  %Output acceleration in seconds
                        fprintf(' \n');
%                         fprintf('Acquisition cost: %2.4f  EUR\n', Param.acquisitionCosts.KA_ZM );  %Output costs in €
                    end

                case {13} % Fuel cell
                    Results.duration = max(Results.OUT_summary.time)/60;    %Driving time in minutes
                    Results.distance = max(Results.OUT_summary.signals(2).values)/1000; %Distance in kilometers
                    %Ergebnis.delta_E = (Ergebnis.OUT_Bat.signals(1).values(length(Ergebnis.OUT_Bat.signals(1).values))-Param.Bat.SOC_start)*Param.Bat.Voltage*Param.Bat.Useable_capacity/1000;   %Energieunterschied in der Batterie zw. Zyklusanfang und -ende in kWh
                    Results.delta_E = 0;

                    %Transfer of results to commercial vehicle design 
                    Param.VSim.bDiesel = 0;
                    Param.VSim.bGas = 0;
                    Param.VSim.energyTotal = 0;
                    Param.VSim.energyTotal_Bat = 0;
                    Param.VSim.Hydrogen_consumption = Results.OUT_FC.signals(2).values(end); % H2 consumption in kg/100km
                    Param.VSim.Consumption_kWh = Results.OUT_FC.signals(2).values(end) * 33.33;  % Consumption in kWh/100km
                    %Param.vehicleProperties.CO2_EM_ak = (-Ergebnis.delta_E*Param.em.fuel.co2_per_kwh/(Ergebnis.OUT_summary.signals(2).values(length(Ergebnis.OUT_summary.signals(2).values))/1000))/(Param.vehicle.payload/1000);

                    % Transfer to TCO class (Wolff 12.11.16)
                    Param.TCO.bDiesel = Param.VSim.bDiesel;
                    Param.TCO.CNG_consumption = Param.VSim.bGas;
                    Param.TCO.LNG_consumption = Param.VSim.bGas;
                    Param.TCO.energyTotal = Param.VSim.energyTotal;
                    Param.TCO.Hydrogen_consumption = Param.VSim.Hydrogen_consumption;

                    if Param.VSim.Opt == false
                        %Output in Command Window
                        fprintf('Hydrogen consumption:            %2.4f kg H2 \n', Results.OUT_FC.signals(1).values(end));  %Output natural gas consumption in kg
                        fprintf('Hydrogen economy:                %2.4f kg/100km \n',Param.VSim.Hydrogen_consumption);  %Output natural gas consumption in kg/100km
                        fprintf('Normalized hydrogen consumption: %2.4f kg/100tkm \n', Param.VSim.Hydrogen_consumption/(Param.vehicle.payload/1000));  %Output natural gas consumption in kg/100tkm
                        
                        fprintf(' \n');
                        fprintf('Energy:                          %2.4f kWh/100km \n' , Param.VSim.Consumption_kWh);  %Output consumption in kWh/100km
                        fprintf('Normalized energy:               %2.4f kWh/100tkm \n' , Param.VSim.Consumption_kWh/(Param.vehicle.payload/1000));  %Output consumption in kWh/100tkm
                        
                        fprintf(' \n');
                        fprintf('Distance:                        %2.4f km \n', Results.distance); %Distance in kilometers
                        fprintf('Driving time:                    %2.4f minutes \n',Results.duration);  %Output driving time in minutes
                        fprintf('Average speed:                   %2.4f km/h \n',0.001*Results.OUT_summary.signals(2).values(end)/(Results.OUT_summary.time(end)/3600))  %Output average speed in km/h
                        [t_0_80] = Acceleration_readout(Param.VSim);
                        fprintf('Acceleration from 0 to 80 km/h:  %2.4f seconds \n', t_0_80);  %Output acceleration in seconds
                        [t_60_80] = Acceleration(Param.VSim);
                        fprintf('Acceleration from 60 to 80 km/h: %2.4f seconds \n', t_60_80);  %Output acceleration in seconds
                        fprintf(' \n');
%                         fprintf('Acquisition cost: %2.4f  EUR\n', Param.acquisitionCosts.KA_ZM );  %Output costs in €
                    end
            end

            %% Calculate transmission characteristics
            Param.transmission = Transmission_properties(Param); % Calculate transmission characteristics

            %% Update TCO classes
            Param.TCO.Driving_distance = Results.distance;
            Param.TCO.Average_speed = 0.001*Results.OUT_summary.signals(2).values(end)/(Results.OUT_summary.time(end)/3600);
            helpStruct = load('costStruct_2030_Steuerbefreit.mat');
            costStruct = helpStruct.costStruct;
            Param = calcPrice(Param, costStruct);

            if (Param.Fueltype ~= 7 && Param.Fueltype ~= 12 && Param.Fueltype ~= 13) && Results.OUT_Bat.signals(5).values(end) == 0
                Param.TCO.Lebensdauer_Batteriepack = 0;
    %         if (Param.Fueltype == 7 && Param.Fueltype == 12 && Param.Fueltype == 13) && Results.OUT_Bat.signals(5).values(end) ~= 0
            else
                switch Param.Fueltype
                    case {7, 12, 13} % Battery life of the electric truck
                        Param.TCO.Lebensdauer_Batteriepack = (Param.Bat.Charge_cycles * Param.Bat.Voltage * Param.Bat.Useable_capacity/1000)/ (Results.Elektro_LKW.signals(12).values(end)*Param.TCO.Annual_mileage(1)); % Battery life in years
    %                     Param.TCO.Verschleissbatteriepack = (Param.Bat.Charge_cycles * Param.Bat.Voltage * Param.Bat.Useable_capacity/1000)/ (Ergebnis.Elektro_LKW.signals(12).values(end)); % Wear per km, in TCO class to €/km
    %                     Param.Bat.SOH = interp1([0 Param.TCO.Lebensdauerbatteriepack], [100 80], Param.TCO.Operating_life(1), 'linear', 'extrap');

                        if ~Param.VSim.Opt
    %                         fprintf('Verschleissdauer Batteriepack in:  %2.4f  Jahren \n', Param.TCO.Lebensdauerbatteriepack);
    %                         fprintf('benötigte Batteriepacks in:  %2.4f  Stück \n', ((Param.TCO.Nutzungsdauer(1) / Param.TCO.Lebensdauerbatteriepack)) );
                            fprintf('Pure electric Range: %.2f km \n', (Param.Bat.Voltage * Param.Bat.Useable_capacity/1000) / (Param.VSim.Consumption_kWh/100));
                        end

                    otherwise
                        Param.TCO.Lebensdauer_Batteriepack = (Param.Bat.Charge_cycles * Param.Bat.Voltage * Param.Bat.Useable_capacity/1000)/ (Results.OUT_Bat.signals(5).values(end)*Param.TCO.Annual_mileage(1));
    %                     Param.TCO.Verschleissbatteriepack = (Param.Bat.Charge_cycles * Param.Bat.Voltage * Param.Bat.Useable_capacity/1000)/ (Ergebnis.OUT_Bat.signals(5).values(end)); % Wear per km, in TCO class to €/km
                         %Param.Bat.SOH = interp1([0 Param.TCO.Lebensdauerbatteriepack], [100 80], Param.TCO.Operating_life(1), 'linear', 'extrap');
                        if ~Param.VSim.Opt
    %                         fprintf('Verschleissdauer Batteriepack in:  %2.4f  Jahren \n', Param.TCO.Lebensdauerbatteriepack);
    %                         fprintf('benötigte Batteriepacks in:  %2.4f  Stück \n', ((Param.TCO.Nutzungsdauer(1) / Param.TCO.Lebensdauerbatteriepack)) );
                            fprintf('Pure electric Range: %.2f km \n', ((Param.Bat.Voltage * Param.Bat.Useable_capacity) / Param.VSim.Consumption_kWh * 100 / 1000));
                        end
                end
            end

            %% Output TCO
            if ~Param.VSim.Opt
                fprintf('Annual milage:       %2.4f km \n', Param.TCO.Annual_mileage(1)); %Output annal milage in km/a
                fprintf('Acquisition cost:    %2.4f EUR\n', Param.acquisitionCosts.KA_ZM );
                fprintf('TCO:                 %2.4f EUR/100tkm \n', Param.TCO.Total_costs/(Param.TCO.Annual_mileage(1)*(Param.vehicle.payload/100000)));  %Output TCO in EUR/km

            end

            %Results are saved, complete saving of all values increases
            %runtime -> additionally desired values can be specified via
            %transfer of results to commercial vehicle design; therefore
            %commented out:
            %Composition{1}.VSim.Ergebnis=Ergebnis;

            %Param.Kosten.v_avg = 0.001*Ergebnis.OUT_summary.signals(2).values(end)/(Ergebnis.OUT_summary.time(end)/3600);              %Theisen    04.04.2016
            %Param.Composition{1}.VSim.v_t=[0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 85 85 85 85 85 85 85 85 85 85 85 85];

            % If displaying results is desired by the user
            if (Param.VSim.Display == 1 || Param.VSim.Display == 2)  && Param.VSim.Opt == 0

                %% Results of the transmission design
                Transmission_evaluation(Param, Results);

                %% Overall cost structure and powertrain
                Production_costs(Param);

                %% Represent weight fractions
                Components_weights(Param);

                % Diesel, Hybrid Diesel
                if Param.Fueltype == 1 || Param.Fueltype == 4

                    %-----Diesel engine mapping-----
                    figure('units','normalized','outerposition',[0 0 1 1],'Name','3');
                    subplot(1,2,1);
                    hold on;
                    clabel (contour (Param.engine.bsfc.speed, Param.engine.bsfc.trq, Param.engine.bsfc.be, 'LevelList',[160 170 180 187 188 189 190 191 195 200 210 220 230 250 300 400 500 700]));
                    plot (Param.engine.full_load.speed, Param.engine.full_load.trq, 'k', 'LineWidth', 2);
                    plot (Param.engine.drag_torque.speed, Param.engine.drag_torque.trq, 'k', 'LineWidth', 2);
                    plot ([Param.engine.speed_min Param.engine.speed_max], [0 0], 'k');
                    plot (Param.engine.bsfc.speed, Param.engine.bsfc.M_be_min, 'r');
                    ylim ([min(Param.engine.drag_torque.trq), Param.engine.M_max+300]);
                    xlim ([Param.engine.speed_min, Param.engine.speed_max]);
                    xlabel ('Speed [rpm]');
                    ylabel ('Torque [Nm]');
                    title ('Consumption map in g/kWh with torque curve and switching devices');

                    % Switching devices
                    plot ([Param.engine.shift_parameter.n2, Param.engine.shift_parameter.n2], [0, Param.engine.M_max], 'g');
                    plot (Param.engine.bsfc.speed, Param.engine.M_max/(Param.engine.shift_parameter.n3-Param.engine.shift_parameter.n1)*(Param.engine.bsfc.speed-Param.engine.shift_parameter.n1), 'g');
                    plot ([Param.engine.shift_parameter.n5, Param.engine.shift_parameter.n5], [0, Param.engine.M_max], 'g');
                    plot (Param.engine.bsfc.speed, Param.engine.M_max/(Param.engine.shift_parameter.n6-Param.engine.shift_parameter.n2)*(Param.engine.bsfc.speed-Param.engine.shift_parameter.n2), 'g');
                end

                % CNG, Hybrid CNG, LNG, Hybrid LNG
                if Param.Fueltype == 2 || Param.Fueltype == 5 || Param.Fueltype == 3 || Param.Fueltype == 6

                    %-----Gas engine mapping-----
                    figure('units','normalized','outerposition',[0 0 1 1],'Name','3');
                    subplot(1,2,1);
                    a = [0.2 0.25 0.3 0.31 0.32 0.33 0.34 0.35 0.36 0.37 0.38 0.39 0.395 0.4]; %Vector of efficiency lines to display
                    hold on;
                    clabel (contour (Param.engine.bsfc.speed, Param.engine.bsfc.trq, Param.engine.bsfc.be, a)) %Plot efficiency mapping
                    plot (Param.engine.full_load.speed, Param.engine.full_load.trq, 'k', 'LineWidth', 2);
                    plot (Param.engine.drag_torque.speed, Param.engine.drag_torque.trq, 'k', 'LineWidth', 2);
                    plot ([Param.engine.speed_min 2200], [0 0], 'k');     %plot ([Param.engine.speed_min Param.engine.speed_max], [0 0], 'k');
                    plot (Param.engine.bsfc.speed, Param.engine.bsfc.M_be_min, 'r'); %Plot torque characteristics
                    ylim ([min(Param.engine.drag_torque.trq), 1.1*(Param.engine.M_max)]);
                    xlim ([800, 2200]);   %xlim ([Param.engine.speed_min, Param.engine.speed_max]);
                    xlabel ('Speed [rpm]');
                    ylabel ('Torque [Nm]');
                    title ('Consumption map in g/kWh with torque curve and switching devices');

                    % Switching devices
                    plot ([Param.engine.shift_parameter.n2, Param.engine.shift_parameter.n2], [0, Param.engine.M_max], 'g');
                    plot (Param.engine.bsfc.speed, Param.engine.M_max/(Param.engine.shift_parameter.n3-Param.engine.shift_parameter.n1)*(Param.engine.bsfc.speed-Param.engine.shift_parameter.n1), 'g');
                    plot ([Param.engine.shift_parameter.n5, Param.engine.shift_parameter.n5], [0, Param.engine.M_max], 'g');
                    plot (Param.engine.bsfc.speed, Param.engine.M_max/(Param.engine.shift_parameter.n6-Param.engine.shift_parameter.n2)*(Param.engine.bsfc.speed-Param.engine.shift_parameter.n2), 'g');
                end

                % Dual-Fuel CNG, Hybrid Dual-Fuel CNG, Dual-Fuel LNG, Hybrid Dual-Fuel LNG
                if Param.Fueltype == 8 || Param.Fueltype == 9 || Param.Fueltype == 10 || Param.Fueltype == 11

                    %-----Dual fuel engine mapping-----
                    figure('units','normalized','outerposition',[0 0 1 1],'Name','3');
                    subplot(1,2,1);
                    a = [0.2 0.22 0.25 0.3 0.35 0.36 0.37 0.38 0.39 0.4 0.41 0.42]; %Vector of efficiency lines to display
                    hold on;
                    clabel (contour (Param.engine.bsfc.speed, Param.engine.bsfc.trq, Param.engine.bsfc.be, a)) %Plot efficiency mapping
                    plot (Param.engine.full_load.speed, Param.engine.full_load.trq, 'k', 'LineWidth', 2);
                    plot (Param.engine.drag_torque.speed, Param.engine.drag_torque.trq, 'k', 'LineWidth', 2);
                    plot ([Param.engine.speed_min Param.engine.speed_max], [0 0], 'k');
                    plot (Param.engine.bsfc.speed, Param.engine.bsfc.M_be_min, 'r'); %Plot torque characteristics 
                    ylim ([min(Param.engine.drag_torque.trq), Param.engine.M_max]);
                    xlim ([Param.engine.speed_min, Param.engine.speed_max]);
                    xlabel ('Speed [rpm]');
                    ylabel ('Torque [Nm]');
                    title ('Consumption map in g/kWh with torque curve and switching devices');

                    % Switching devices
                    plot ([Param.engine.shift_parameter.n2, Param.engine.shift_parameter.n2], [0, Param.engine.M_max], 'g');
                    plot (Param.engine.bsfc.speed, Param.engine.M_max/(Param.engine.shift_parameter.n3-Param.engine.shift_parameter.n1)*(Param.engine.bsfc.speed-Param.engine.shift_parameter.n1), 'g');
                    plot ([Param.engine.shift_parameter.n5, Param.engine.shift_parameter.n5], [0, Param.engine.M_max], 'g');
                    plot (Param.engine.bsfc.speed, Param.engine.M_max/(Param.engine.shift_parameter.n6-Param.engine.shift_parameter.n2)*(Param.engine.bsfc.speed-Param.engine.shift_parameter.n2), 'g');
                end

                % ICE available
                if Param.Electric_Truck == 0

                    % -----ICE Operating points-----
                    Anzahl_Lastpunkte = length(Results.OUT_engine.signals(1).values);

                    Raster.Drehzahl = 800:100:2000;
                    Raster.Drehmoment = fliplr(Param.engine.M_max:-100:min(Param.engine.drag_torque.trq));
                    Raster.Drehmoment(1) = min(Param.engine.drag_torque.trq);

                    Haeufigkeitsverteilung = zeros(length(Raster.Drehmoment)-1, length(Raster.Drehzahl)-1);

                    for k=1:1:Anzahl_Lastpunkte
                        Lastpunkt = [Results.OUT_engine.signals(1).values(k),Results.OUT_engine.signals(2).values(k)];

                        for i=1:1:length(Raster.Drehmoment)-1
                            for j= 1:1:length(Raster.Drehzahl)-1
                                if Lastpunkt(1) >= Raster.Drehmoment(i) && Lastpunkt(1) < Raster.Drehmoment(i+1) && Lastpunkt(2) >= Raster.Drehzahl(j) && Lastpunkt(2) < Raster.Drehzahl(j+1)
                                    Haeufigkeitsverteilung(i,j) = Haeufigkeitsverteilung(i,j)+1;
                                end
                            end
                        end
                    end

                    Haeufigkeitsverteilung = Haeufigkeitsverteilung/Anzahl_Lastpunkte*100;
                    Haeufigkeitsverteilung = flipud (Haeufigkeitsverteilung);

                    subplot(1,2,2);
                    bar3(Haeufigkeitsverteilung);
                    title('Operating point distribution of ICE engine');
                    xlabel('Speed [rpm]');
                    ylabel('Torque [Nm]');
                    zlabel('Frequency [%]');

                    % Change the x and y axis tick labels
                    %set(gca, 'XTick', 1:1:length(Raster.Drehzahl)-1);
                    set(gca, 'XTick', 1:2:length(Raster.Drehzahl)-1);
                    %set(gca, 'YTick', 1:1:length(Raster.Drehmoment)-1);
                    set(gca, 'YTick', 1:2:length(Raster.Drehmoment)-1);
                    %set(gca, 'XTickLabel', num2str(Raster.Drehzahl'+50));
                    set(gca, 'XTickLabel', num2str((800:200:2000)'+50));
                    %set(gca, 'YTickLabel', num2str(flipud(Raster.Drehmoment'+50)));
                    set(gca, 'YTickLabel', num2str(flipud((fliplr(Param.engine.M_max:-200:min(Param.engine.drag_torque.trq)))'-50)));
                end

                % Hybridization available
                if Param.Hybrid_Truck == 1

                    % -----Electric machine efficiency-----
                    figure('units','normalized','outerposition',[0 0 1 1],'name','1');
                    subplot(1,2,1);
                    hold on;
                    v=[0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,0.95];
                    clabel (contour (Param.em.efficiency.speed, Param.em.efficiency.torque , Param.em.efficiency.characteristic_map, v));
                    %plot ([0  n_EM_max], 0.2*[M_EM_nenn M_EM_nenn]);
                    plot (Param.em.speed, Param.em.trq, 'k', 'LineWidth', 2);

                    % Elektro
                    if Param.Electric_Truck == 1

                        % Switching devices
                        plot ([Param.em.shift_parameter.n2, Param.em.shift_parameter.n2], [0, Param.em.M_max], 'g');
                        plot (Param.em.speed, Param.em.M_max/(Param.em.shift_parameter.n6-Param.em.shift_parameter.n2)*(Param.em.speed-Param.em.shift_parameter.n2), 'g:');
                    end

                    axis([0 max(Param.em.speed) 0 max(Param.em.trq) 0 1])
                    xlabel ('Speed [rpm]');
                    ylabel ('Torque [Nm]');
                    zlabel ('Eta');

                    % Möglichkeit, das Wirkungsgradkennfeld der E-Maschine in 3D zu
                    % visualisieren, derzeit nicht im Einsatz
                    %             subplot (1,3,2);
                    %             surf(Param.em.efficiency.speed, Param.em.efficiency.torque , Param.em.efficiency.characteristic_map);
                    %
                    %             xlabel ('n [U/min]');
                    %             ylabel ('M [Nm]');
                    %             zlabel ('Eta');

                    % -----Electric machine operating points-----
                    Anzahl_Lastpunkte = length(Results.Out_EM.signals(1).values);

                    %Raster.Drehzahl = 0:100:Param.em.n_max;
                    Raster.Drehzahl = linspace(0,Param.em.n_max, 15);
                    Raster.Drehmoment = -(Param.em.M_max):100:Param.em.M_max;
                    Raster.Drehmoment(length(Raster.Drehmoment)) = Param.em.M_max;

                    Haeufigkeitsverteilung = zeros(length(Raster.Drehmoment)-1, length(Raster.Drehzahl)-1);

                    for k=1:1:Anzahl_Lastpunkte
                        Lastpunkt = [Results.Out_EM.signals(1).values(k),Results.Out_EM.signals(2).values(k)];

                        for i=1:1:length(Raster.Drehmoment)-1
                            for j= 1:1:length(Raster.Drehzahl)-1
                                if Lastpunkt(1) >= Raster.Drehmoment(i) && Lastpunkt(1) < Raster.Drehmoment(i+1) && Lastpunkt(2) >= Raster.Drehzahl(j) && Lastpunkt(2) < Raster.Drehzahl(j+1)
                                    Haeufigkeitsverteilung(i,j) = Haeufigkeitsverteilung(i,j)+1;
                                end
                            end
                        end
                    end

                    Haeufigkeitsverteilung = Haeufigkeitsverteilung/Anzahl_Lastpunkte*100;
                    Haeufigkeitsverteilung = flipud (Haeufigkeitsverteilung);

                    subplot(1,2,2);
                    [~, col] = find(Haeufigkeitsverteilung, 1, 'last');
                    bar3(Haeufigkeitsverteilung(:,1:col));
                    title('Operating point distribution of electrical machine');
                    xlabel('Speed [rpm]');
                    ylabel('Torque [Nm]');
                    zlabel('Frequency [%]');

                    % Change the x and y axis tick labels
                    % set(gca, 'XTick', 1:1:length(Raster.Drehzahl)-1);
                    % set(gca, 'YTick', 1:1:length(Raster.Drehmoment)-1);
                    % set(gca, 'XTickLabel', num2str(Raster.Drehzahl'+50));
                    % set(gca, 'YTickLabel', num2str(flipud(Raster.Drehmoment'-50)));

                    set(gca, 'XTick', 1:2:length(Raster.Drehzahl)-1);
                    set(gca, 'YTick', 1:2:length(Raster.Drehmoment)-1);
                    set(gca, 'XTickLabel', num2str((0:200:Param.em.n_max)'+50));
                    set(gca, 'YTickLabel', num2str((Param.em.M_max-50:-200:-Param.em.M_max)'));

                    % -----Plots_SOC_C_Rate-----
                    hold on;
                    figure('units','normalized','outerposition',[0 0 1 1],'name','2'); % SOC
                    subplot(1,2,1);
                    plot (Results.OUT_Bat.signals(2).values/1000, Results.OUT_Bat.signals(1).values);
                    xlabel ('Distance in km')
                    ylabel ('SOC');
                    ylim ([0 1]);

                    subplot(1,2,2); % C-Rate
                    plot (Results.OUT_Bat.signals(2).values/1000, Results.OUT_Bat.signals(3).values);
                    xlabel ('Distance in km')
                    ylabel ('C Rate');
                end
            end
        end 
    end
    fprintf('--------------------------------------------------------- \n');
end