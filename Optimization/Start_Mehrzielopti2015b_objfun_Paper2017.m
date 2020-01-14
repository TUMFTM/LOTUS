function [y, cons] = Start_Mehrzielopti2015b_objfun_Paper2017(x, Param)
% Objective function : Problem 'Mehrzieloptimierung2015b'.
%*************************************************************************

%addpath('Verbrauchssimulation');
%addpath('Funktionen');

%% Variablen NUR für Paper Fries, Wolff 2017
           
            % Funktion zur Getriebeauslegung: Variablen: 
            % Spreizung, Ganganzahl, Overdrive, DSG, Achsgetriebe. Fuer Details, s.transmission.m
            Param.transmission                      = transmission(x(1), x(2), x(3), x(4), x(5));  
            Param.final_drive.ratio                 = x(5);
             
            % Hybrid: Variablen: 
            Param.em.M_max                          = x(6);
            Param.em.n_eck                          = x(7);
            Param.Bat.Useable_capacity           = x(8); %Energie

            % Batterie DoD
            Param.Bat.Useable_range             = x(9); %DoD
            % Batterietyp
            Param.Bat.Type = x(10);      % 1: Cylindrical; 2: Pouch
            % E-Maschinen Typ
            Param.em.Type = x(11);       % 1: PSM; 2: ASM
            
%Bat.Charge_cycles = ((Bat.Useable_range*100)/103620)^(1/-0.833); % Anzahl der Ladezyklen Quelle: MARKEL, T. und SIMPSON, A.: Plug-in Hybrid Electric Vehicle Energy Storage System Design. In: Advanced Automotive Battery Conference Baltimore, Maryland, 2006
Param.Bat.Charge_cycles = ((Param.Bat.Useable_range*100)/15540)^(1/-0.652);
% Kennfelderstellung E Maschine
%[Param.em] = Kennfelderstellung_EM( Param.Fueltype, Param.em.n_eck, Param.em.M_max, Param.em.n_max, Param.Bat.Voltage, Param.em.P_max, Param.em.Type );
switch Param.em.Type
    case 1
        [em] = ASM_Kennfeld( Param.Fueltype, Param.em.n_eck, Param.em.M_max, Param.em.n_max, Param.Bat.Voltage, Param.em.P_max, Param.em.Type );
    case 2
        [em] = PSM_Kennfeld( Param.Fueltype, Param.em.n_eck, Param.em.M_max, Param.em.n_max, Param.Bat.Voltage, Param.em.P_max, Param.em.Type );
end

switch Param.Fueltype
    case {1,4}    %{'Diesel','Diesel-Hybrid'}
        Param.engine = Kennfelderstellung_Diesel( Param.engine.M_max,Param.engine.shift_parameter.n_lo,Param.engine.shift_parameter.n_pref);
    case {2,3,5,6}    %{'CNG','LNG','CNG-Hybrid','LNG-Hybrid'}
        Param.engine = Kennfelderstellung_Gas_Tschochner( Param.engine.M_max, Param.Fueltype,Param.engine.shift_parameter.n_lo, Param.engine.shift_parameter.n_pref);
    case {8,9,10,11}    %{Dual-Fuel {CNG, LNG},Dual-Fuel Hybrid {CNG, LNG}}
        Param.engine = Kennfelderstellung_Dual_Tschochner( Param.engine.M_max, Param.Fueltype, Param.engine.shift_parameter.n_lo, Param.engine.shift_parameter.n_pref);
    case {7}    % Elektro LKW
        Param.engine.number = 4;
end




%% Gewichts- und Längenfunktionen
[Param] = Gewichtsberechnung(Param);


% Radstand_berechnen( Param.Composition );
% Eigengewicht( Param.Composition );
% for i=1:length( Param.Composition )
%     AchslastenBerechnen(i, false, 0, Param.Composition); % Achslasten neu berechnen
% end

Zyklus = Param.dcycle;
for i=1:2
    Param.dcycle = 5;
     if i==2
        Param.dcycle = Zyklus;
        Param.cycle = Fahrzyklus_laden(Param.dcycle);
        Param.max_distance = max(Param.cycle.distance); %termination criterion
    end
    
    %% Verbrauchssimulation ausführen
    [ Ergebnis ] = VSim_ausfuehren(Param);
      
    %% Post-Processing
    [ Ergebnis, Param ] = VSim_auswerten( Ergebnis, Param );
    
    % Variable "Ergebnis" bei Bedarf abspeichern
    % str=datestr(now,'yyyy-mm-dd_HH-MM-SS');
    % pfad=fullfile('C:\Users\Sebastian\MA\200_Temp',str);
    % save(pfad,'Ergebnis');
    
end
%     y = [0,0,0];
%     cons = [0, 0, 0];
    y = zeros(1, Param.numObj);
    cons = zeros(1, Param.numCons);
% Wenn Simulation abgebrochen, dann Zielgrößen unendlich, gilt NUR für TCO
% und Transporteffizienz. Bei anderen Zielgrößen ggf Anpassen (-unendlich
% oder 0)
if Param.VSim.Termination == 1
    y(1)=inf;
    y(2)=inf;
    y(3)=inf;
    y(4)=inf;
    cons(1:end)=0;
else
    
    % Auswertung Kostenfunktion
    % Fueltype-Bedarf
    switch Param.Fueltype
        case {1,4}
            Param.Kosten.BK_Diesel  = Param.VSim.bDiesel;
        case {2,5}
            Param.Kosten.BK_CNG  = Param.VSim.bGas;
        case {3,6}
            Param.Kosten.BK_LNG  = Param.VSim.bGas;
        case 7
            Param.Kosten.BK_Strom  = Param.VSim.energyTotal;
        case {8,10}
            Param.Kosten.BK_Diesel  = Param.VSim.bDiesel;
            Param.Kosten.BK_CNG  = Param.VSim.bGas;
        case {9,11}
            Param.Kosten.BK_Diesel  = Param.VSim.bDiesel;
            Param.Kosten.BK_LNG  = Param.VSim.bGas;
    end
    % Auswertung Eigenschaftsfunktion
    % Beschleunigung
    
    
    switch Param.Opt_groessen
        case 1      % Durchschnittsgeschwindigkeit & Transporteffizienz
            y(1) = (-1)*(0.001*Ergebnis.OUT_summary.signals(2).values(end)/(Ergebnis.OUT_summary.time(end)/3600));     %Durchschnittsgeschwindigkeit in km/h wird durch (-1) maximiert
            y(2) =  Param.VSim.Consumption_kWh/(Param.vehicle.payload/1000);
              
        case 2      %Kosten und Eigenschaftsfunktion
            [t_0_80] = Beschleunigung_auslesen(Param.VSim);
            Param.propertie.a_0_80_ak=t_0_80;
            [ propertie ] = Eigenschaftsfunktion(Param.propertie);
            Param.propertie = propertie;
            y(1)= -propertie.EF;
            
            %[ Kosten ]= Kostenberechnung(Param.Composition{1}.Kosten);
            %Param.Composition{1}.Kosten;% = Kosten;
            y(2) = Param.Kosten.Kges;
            
        case 3      % Durchschnittsgeschwindigkeit & Verbrauch
            % Funktioniert jetzt. Problem gelöst in Zeile 73 & 89. Ergebnis
            % wurde mit Beschleunigungs-Simulation überschrieben.
            y(1) = (-1)*(0.001*Ergebnis.OUT_summary.signals(2).values(end)/(Ergebnis.OUT_summary.time(end)/3600));     %Durchschnittsgeschwindigkeit in km/h wird durch (-1) maximiert
            y(2) = (Ergebnis.OUT_summary.signals(7).values(end)-Ergebnis.V)/(Ergebnis.OUT_summary.signals(2).values(length(Ergebnis.OUT_summary.signals(2).values))/100000);  %Ausgabe Fueltypeverbrauch in l/100km.
        case 4 % Wolff 2016
            % TCO in €/km
            y(1) = Param.TCO.Total_costs/Param.TCO.Annual_mileage;
            % Transporteffizienz in gCO2/tkm
            switch Param.Fueltype
                case {1,4} % Diesel
                    y(2) = (Ergebnis.OUT_summary.signals(7).values(end)-Ergebnis.V)*Param.engine.fuel.co2_per_litre*1000/(Ergebnis.OUT_summary.signals(2).values(length(Ergebnis.OUT_summary.signals(2).values))/1000)/(Param.vehicle.payload/1000);
                case {2, 3, 5, 6} % Gas
                    y(2) = Ergebnis.OUT_summary.signals(6).values(end)/(Param.vehicle.payload/1000);
                case {8, 9, 10, 11} % Dual Fuel
                    CO2_Gas = ((Ergebnis.OUT_summary.signals(9).values(end)-Ergebnis.M)*Param.engine.fuel.co2_per_kg_lng*1000/(Ergebnis.OUT_summary.signals(2).values(length(Ergebnis.OUT_summary.signals(2).values))/1000))/(Param.vehicle.payload/1000);
                    CO2_Diesel = ((Ergebnis.OUT_summary.signals(7).values(end)-Ergebnis.V)*Param.engine.fuel.co2_per_litre_diesel*1000/(Ergebnis.OUT_summary.signals(2).values(length(Ergebnis.OUT_summary.signals(2).values))/1000))/(Param.vehicle.payload/1000);
                    y(2) = CO2_Gas + CO2_Diesel;
            end
            
        case 5 % Fries
              % TCO in €/km
            y(1) = Param.TCO.Total_costs/Param.TCO.Annual_mileage;
               % Transporteffizienz in gCO2/tkm
            switch Param.Fueltype
                case {1,4} % Diesel
                    y(2) = (Ergebnis.OUT_summary.signals(7).values(end)-Ergebnis.V)*Param.engine.fuel.co2_per_litre*1000/(Ergebnis.OUT_summary.signals(2).values(length(Ergebnis.OUT_summary.signals(2).values))/1000)/(Param.vehicle.payload/1000);
                case {2, 3, 5, 6} % Gas
                    y(2) = Ergebnis.OUT_summary.signals(6).values(end)/(Param.vehicle.payload/1000);
                case {8, 9, 10, 11} % Dual Fuel
                    CO2_Gas = ((Ergebnis.OUT_summary.signals(9).values(end)-Ergebnis.M)*Param.engine.fuel.co2_per_kg_lng*1000/(Ergebnis.OUT_summary.signals(2).values(length(Ergebnis.OUT_summary.signals(2).values))/1000))/(Param.vehicle.payload/1000);
                    CO2_Diesel = ((Ergebnis.OUT_summary.signals(7).values(end)-Ergebnis.V)*Param.engine.fuel.co2_per_litre_diesel*1000/(Ergebnis.OUT_summary.signals(2).values(length(Ergebnis.OUT_summary.signals(2).values))/1000))/(Param.vehicle.payload/1000);
                    y(2) = CO2_Gas + CO2_Diesel;
            end
               % Beschleunigung von 0 auf 80 km/h in Sekunden
            [t_0_80] = Beschleunigung_auslesen(Param.VSim);
            y(3) = t_0_80;
       
        case 6 % Fries   
              % TCO in €/km
            y(1) = Param.TCO.Total_costs/Param.TCO.Annual_mileage;
               % Transporteffizienz in gCO2/tkm
            switch Param.Fueltype
                case {1,4} % Diesel
                    y(2) = (Ergebnis.OUT_summary.signals(7).values(end)-Ergebnis.V)*Param.engine.fuel.co2_per_litre*1000/(Ergebnis.OUT_summary.signals(2).values(length(Ergebnis.OUT_summary.signals(2).values))/1000)/(Param.vehicle.payload/1000);
                case {2, 3, 5, 6} % Gas
                    y(2) = Ergebnis.OUT_summary.signals(6).values(end)/(Param.vehicle.payload/1000);
                case {8, 9, 10, 11} % Dual Fuel
                    CO2_Gas = ((Ergebnis.OUT_summary.signals(9).values(end)-Ergebnis.M)*Param.engine.fuel.co2_per_kg_lng*1000/(Ergebnis.OUT_summary.signals(2).values(length(Ergebnis.OUT_summary.signals(2).values))/1000))/(Param.vehicle.payload/1000);
                    CO2_Diesel = ((Ergebnis.OUT_summary.signals(7).values(end)-Ergebnis.V)*Param.engine.fuel.co2_per_litre_diesel*1000/(Ergebnis.OUT_summary.signals(2).values(length(Ergebnis.OUT_summary.signals(2).values))/1000))/(Param.vehicle.payload/1000);
                    y(2) = CO2_Gas + CO2_Diesel;
            end
 
              % Elastitzität von 60 auf 80 km/h in Sekunden
            [t_60_80] = Elastizitaet_auslesen(Param.VSim);
            y(3) = t_60_80;  
            
         case 7 % Fries   
              % TCO in €/km
            y(1) = Param.TCO.Total_costs/Param.TCO.Annual_mileage;
               % Transporteffizienz in gCO2/tkm
            switch Param.Fueltype
                case {1,4} % Diesel
                    y(2) = (Ergebnis.OUT_summary.signals(7).values(end)-Ergebnis.V)*Param.engine.fuel.co2_per_litre*1000/(Ergebnis.OUT_summary.signals(2).values(length(Ergebnis.OUT_summary.signals(2).values))/1000)/(Param.vehicle.payload/1000);
                case {2, 3, 5, 6} % Gas
                    y(2) = Ergebnis.OUT_summary.signals(6).values(end)/(Param.vehicle.payload/1000);
                case {8, 9, 10, 11} % Dual Fuel
                    CO2_Gas = ((Ergebnis.OUT_summary.signals(9).values(end)-Ergebnis.M)*Param.engine.fuel.co2_per_kg_lng*1000/(Ergebnis.OUT_summary.signals(2).values(length(Ergebnis.OUT_summary.signals(2).values))/1000))/(Param.vehicle.payload/1000);
                    CO2_Diesel = ((Ergebnis.OUT_summary.signals(7).values(end)-Ergebnis.V)*Param.engine.fuel.co2_per_litre_diesel*1000/(Ergebnis.OUT_summary.signals(2).values(length(Ergebnis.OUT_summary.signals(2).values))/1000))/(Param.vehicle.payload/1000);
                    y(2) = CO2_Gas + CO2_Diesel;
            end
               % Beschleunigung von 0 auf 80 km/h in Sekunden
            [t_0_80] = Beschleunigung_auslesen(Param.VSim);
            y(3) = t_0_80;  
            
                % Elastitzität von 60 auf 80 km/h in Sekunden
            [t_60_80] = Elastizitaet_auslesen(Param.VSim);
            y(4) = t_60_80;  
            
            
     case 8 % Fries   3 Zielgrößen
              % TCO in €/tkm
            y(1) = Param.TCO.Total_costs/(Param.TCO.Annual_mileage(1)*(Param.vehicle.payload/100000));
               % Transporteffizienz in gCO2/tkm
            switch Param.Fueltype
                case {1,4} % Diesel
                    y(2) = (Ergebnis.OUT_summary.signals(7).values(end)-Ergebnis.V)*Param.engine.fuel.co2_per_litre*1000/(Ergebnis.OUT_summary.signals(2).values(length(Ergebnis.OUT_summary.signals(2).values))/1000)/(Param.vehicle.payload/1000);
                case {2, 3, 5, 6} % Gas
                    y(2) = Ergebnis.OUT_summary.signals(6).values(end)/(Param.vehicle.payload/1000);
                case {8, 9, 10, 11} % Dual Fuel
                    CO2_Gas = ((Ergebnis.OUT_summary.signals(9).values(end)-Ergebnis.M)*Param.engine.fuel.co2_per_kg_lng*1000/(Ergebnis.OUT_summary.signals(2).values(length(Ergebnis.OUT_summary.signals(2).values))/1000))/(Param.vehicle.payload/1000);
                    CO2_Diesel = ((Ergebnis.OUT_summary.signals(7).values(end)-Ergebnis.V)*Param.engine.fuel.co2_per_litre_diesel*1000/(Ergebnis.OUT_summary.signals(2).values(length(Ergebnis.OUT_summary.signals(2).values))/1000))/(Param.vehicle.payload/1000);
                    y(2) = CO2_Gas + CO2_Diesel;
            end
               % Beschleunigung von 0 auf 80 km/h in Sekunden
 [t_60_80] = Elastizitaet_auslesen(Param.VSim);
            y(3) = t_60_80; 
        
 
    
    end   
    
    %% calculate the constraint violations
    
    % Minimale Gesamtübersetzung. Wird benötigt, da sonst ein Schalten in
    % höchsten Gang nicht mehr möglich ist und um "Schaltpendeln" zu
    % verhindern
    if Param.transmission.ratios(end) * Param.final_drive.ratio < 2.3
        cons(1) = Param.transmission.ratios(end) * Param.final_drive.ratio;
    end
    
    % Mindest-Anfahrsteigfähigkeit. Wert empirisch festgelgt
    if Param.transmission.q_starting < 10 % in %
        cons(2) = Param.transmission.q_starting;
    end
    
    switch Param.Fueltype
        
        case {1,2,3}    %{'Diesel','CNG','LNG'}
            
        case {4,5,6}    %{'Diesel-Hybrid','CNG-Hybrid','LNG-Hybrid'}
            % C-Rate in Abhängigkeit des Batterietyps
            switch Param.Bat.Type
                case {1}
                    if max(Ergebnis.OUT_Bat.signals(3).values) > 10.00 %interp1([2014 2020], [10 20], 2017)
                        cons(3) = max(abs(Ergebnis.OUT_Bat.signals(3).values));
                    end
                case {2}
                    if max(Ergebnis.OUT_Bat.signals(3).values) > 15
                        cons(3) = max(abs(Ergebnis.OUT_Bat.signals(3).values));
                    end
            end
            
        case 7          % Elektrisch
            
        case {8,9}      %Dual-Fuel {CNG, LNG}
            
        case {10,11}    %Dual-Fuel Hybrid {CNG, LNG}
            % C-Rate in Abhängigkeit des Batterietyps
            switch Param.Bat.Type
                case {1}
                    if max(Ergebnis.OUT_Bat.signals(3).values) > 13.00 %interp1([2014 2020], [10 20], 2017)
                        cons(3) = max(abs(Ergebnis.OUT_Bat.signals(3).values));
                    end
                case {2}
                    if max(Ergebnis.OUT_Bat.signals(3).values) > 15
                        cons(3) = max(abs(Ergebnis.OUT_Bat.signals(3).values));
                    end
            end
            
    end
    
    % Zeile zur Abtrennung zur nächsten Simulation
    fprintf('----------------------------------------------------------------------------\n');
    %cd Optimierung;
end