function [y, cons] = Start_Mehrzielopti2015b_objfun(x, Param, options)
% Objective function : Problem 'Mehrzieloptimierung2015b'.
%*************************************************************************

%addpath('Verbrauchssimulation');
%addpath('Funktionen');

%% Variablen aus verherigen Optimierungen (auskommentiert von Wolff 2016 für Getriebeoptimierung)
switch Param.Fueltype
    case {1,2,3}    %{'Diesel','CNG','LNG'}
         
     
          % Funktion zur Getriebeauslegung: Variablen: 
          % Spreizung, Ganganzahl, Overdrive, DSG, Achsgetriebe. Fuer Details, s.transmission.m
            Param.transmission                      = Transmission_gearing(x(1), x(2), x(3), x(4), x(5));  
            Param.final_drive.ratio                 = x(5);
            Param.engine.M_max                      = x(6);
            Param.engine.shift_parameter.n_lo       = x(7); %untere Schaltschwelle
            Param.engine.shift_parameter.n_pref     = x(8); %obere Schaltschwelle
            
          % Funktion vorauschauender Tempomat: Variablen: 
            Param.v_PPC_delta                       = x(9)/3.6;   %Variablenname in Paper: vppc,  max. Geschwindigkeitsüberhöhung/ Unterschreitung von soll Geschwindikgeit, Standarwert bei 7 km/h  
            Temp1 = 100:10:1000;                    % Diskretisierung der Look ahead Strecke in 10m Abstände von 100 bis 1000m 
            Param.look_ahead_PPC                    = Temp1(x(10));      %Variablenname in Paper: distance_ppc_look_ahead, Range: 100 - 1000m Strecke voraus um die kritische Steiung zu suchen, untere Grenze
            Temp2 = 100:10:500;                     % Diskretisierung der Look ahead Strecke in 10m Abstände von 100 bis 500m 
            Param.distance_1_PPC                    = Temp2(x(11));      %Variablenname in Paper: distance_slope_positive, Range: 100 - 500m slope_length_positiveLänge der Steigung, legt mit look_ahead obere Grenze fest
            Temp3 = 100:10:500;                     % Diskretisierung der Look ahead Strecke in 10m Abstände von 100 bis 500m         
            Param.distance_2_PPC                    = Temp3(x(12));      %Variablenname in Paper: distance_slope_negative, Range: 200 -400m slope_length_neg Länge der Strecke vor einem kritischen Gefälle, bei der der Lkw das Gas zurücknimmt
            
          % Funktion vorauschauender Tempomat: Variablen: 
            
            %Param.IZ12                      = x(4) + Param.IZ12;
            

    case {4,5,6}    %{'Diesel-Hybrid','CNG-Hybrid','LNG-Hybrid'}
           
            % Funktion zur Getriebeauslegung: Variablen: 
            % Spreizung, Ganganzahl, Overdrive, DSG, Achsgetriebe. Fuer Details, s.transmission_function.m
            Param.transmission                      = Transmission_gearing(x(1), x(2), x(3), x(4), x(5));  
            Param.final_drive.ratio                 = x(5);
            Param.engine.M_max                      = x(6);
            Param.engine.shift_parameter.n_lo       = x(7);  %untere Schaltschwelle
            Param.engine.shift_parameter.n_pref     = x(8);  %obere Schaltschwelle
            
            % Funktion vorauschauender Tempomat: Variablen: 
            Param.v_PPC_delta                       = x(9)/3.6;   %Variablenname in Paper: vppc,  max. Geschwindigkeitsüberhöhung/ Unterschreitung von soll Geschwindikgeit, Standarwert bei 7 km/h  
            Temp1 = 100:10:1000;                    % Diskretisierung der Look ahead Strecke in 10m Abstände von 100 bis 1000m 
            Param.look_ahead_PPC                    = Temp1(x(10));      %Variablenname in Paper: distance_ppc_look_ahead, Range: 100 - 1000m Strecke voraus um die kritische Steiung zu suchen, untere Grenze
            Temp2 = 100:10:500;                     % Diskretisierung der Look ahead Strecke in 10m Abstände von 100 bis 500m 
            Param.distance_1_PPC                    = Temp2(x(11));      %Variablenname in Paper: distance_slope_positive, Range: 100 - 500m slope_length_positiveLänge der Steigung, legt mit look_ahead obere Grenze fest
            Temp3 = 100:10:500;                     % Diskretisierung der Look ahead Strecke in 10m Abstände von 100 bis 500m         
            Param.distance_2_PPC                    = Temp3(x(12));      %Variablenname in Paper: distance_slope_negative, Range: 200 -400m slope_length_neg Länge der Strecke vor einem kritischen Gefälle, bei der der Lkw das Gas zurücknimmt
            
            % Funktion Betriebsstrategie Hybrid: Variablen: 
            Param.em.M_max                          = x(13);
            Param.em.n_eck                          = x(14);
            Param.Bat.Useable_capacity           = x(15);          
            Param.SOC_target                        = x(16); %Variablenname in Paper: SOC_Target
            Param.SOC_T_EM_completely_available     = x(17); %Variablenname in Paper: SOC_Boosting_fully available, Boost vollstäandiverfügbar
            Param.M_el                              = x(18);    % Moment in Nm bis zu der rein elektrisch gefahren wird
            Param.SOC_el                            = x(19);    % SOC in % bis zu der rein elektrisch gefahren wird
            Param.T_distance_LPS_up                 = x(20); %Variablenname in Paper: T_slp_up          % Abstände zu linie des minimalen Verbrauchs in Nm
            Param.T_distance_LPS_down               = x(21); %Variablenname in Paper: T_slp_down        % Abstände zu linie des minimalen Verbrauchs in Nm
           
            % Funktion Betriebsstrategie Hybrid in Kombination mit PPC: Variablen:
            Param.addition_for_critical_slope       = x(22); %Variablenname in Paper: Slope_addition, range: 1 bis 5 %
            Param.distance_PPC_altitude_difference  = x(23);  %Variablenname in Paper: distance_altitude_difference, in m Strecke, die die PPC vorausschaut
            Param.critical_altitude_difference      = x(24);  %Variablenname in Paper: altitude_difference_critical, in m Kritische Höhendifferenz
            Param.SOC_addition                      = x(25); %Variablenname in Paper: SOC_addition wird um SOC_addition erhöht
            
            % Batterie DoD
            Param.Bat.Useable_range             = x(26);
            % Batterietyp
            Param.Bat.Type = x(27);      % 1: Cylindrical; 2: Pouch
            % E-Maschinen Typ
            Param.em.Type = x(28);       % 1: PSM; 2: ASM
            %--------------- Wireless Power Tansfer ---------------
%             Param.WPT.SOC_target = x(28);
%             Param.WPT.SOC_electric_only = x(29);% Minimaler SOC für rein elektrisches Fahren
            
    case 7         % Elektrisch
            Param.em.P_max                 = 0;
            Param.em.M_max                 = x(1);
            Temp1 = 1000:100:5000;           % Diskretisierung der Eckdrehzahl von 500 bis 5000 rpm in 10er Schritten
            Param.em.n_eck                 = Temp1(x(2));
            %Param.Bat.Voltage             = x(3);
            Param.Bat.Useable_range    = x(3);
            Param.Bat.Useable_capacity  = x(4);
            Param.final_drive.ratio        = x(5);
                       
            % Funktion zur Getriebeauslegung: Variablen: 
            % Spreizung, Ganganzahl, Overdrive, DSG, Achsgetriebe. Fuer Details, s.transmission.m
            Param.transmission                      = Transmission_gearing(x(6), x(7), x(8), x(9), x(5));  
            Param.engine.shift_parameter.n_lo       = x(10); %untere Schaltschwelle
            Param.engine.shift_parameter.n_pref     = x(11); %obere Schaltschwelle
            % Batterietyp
            Param.Bat.Type = x(12);      % 1: Cylindrical; 2: Pouch
            % E-Maschinen Typ
            Param.em.Type = x(13);       % 1: PSM; 2: ASM

    case {8,9}      %Dual-Fuel {CNG, LNG}
        
            % Funktion zur Getriebeauslegung: Variablen: 
          % Spreizung, Ganganzahl, Overdrive, DSG, Achsgetriebe. Fuer Details, s.transmission.m
            Param.transmission                      = Transmission_gearing(x(1), x(2), x(3), x(4), x(5));  
            Param.final_drive.ratio                 = x(5);
            Param.engine.M_max                      = x(6);
            Param.engine.shift_parameter.n_lo       = x(7); %untere Schaltschwelle
            Param.engine.shift_parameter.n_pref     = x(8); %obere Schaltschwelle
            
          % Funktion vorauschauender Tempomat: Variablen: 
            Param.v_PPC_delta                       = x(9)/3.6;   %Variablenname in Paper: vppc,  max. Geschwindigkeitsüberhöhung/ Unterschreitung von soll Geschwindikgeit, Standarwert bei 7 km/h  
            Temp1 = 100:10:1000;                    % Diskretisierung der Look ahead Strecke in 10m Abstände von 100 bis 1000m 
            Param.look_ahead_PPC                    = Temp1(x(10));      %Variablenname in Paper: distance_ppc_look_ahead, Range: 100 - 1000m Strecke voraus um die kritische Steiung zu suchen, untere Grenze
             Temp2 = 100:10:500;                     % Diskretisierung der Look ahead Strecke in 10m Abstände von 100 bis 500m 
            Param.distance_1_PPC                    = Temp2(x(11));      %Variablenname in Paper: distance_slope_positive, Range: 100 - 500m slope_length_positiveLänge der Steigung, legt mit look_ahead obere Grenze fest
            Temp3 = 100:10:500;                     % Diskretisierung der Look ahead Strecke in 10m Abstände von 100 bis 500m         
            Param.distance_2_PPC                    = Temp3(x(12));      %Variablenname in Paper: distance_slope_negative, Range: 200 -400m slope_length_neg Länge der Strecke vor einem kritischen Gefälle, bei der der Lkw das Gas zurücknimmt
          % Funktion vorauschauender Tempomat: Variablen:   
            

            
    case {10,11}    %Dual-Fuel Hybrid {CNG, LNG}
           % Funktion zur Getriebeauslegung: Variablen: 
            % Spreizung, Ganganzahl, Overdrive, DSG, Achsgetriebe. Fuer Details, s.transmission.m
            Param.transmission                      = Transmission_gearing(x(1), x(2), x(3), x(4), x(5));  
            Param.final_drive.ratio                 = x(5);
            Param.engine.M_max                      = x(6);
            Param.engine.shift_parameter.n_lo       = x(7);  %untere Schaltschwelle
            Param.engine.shift_parameter.n_pref     = x(8);  %obere Schaltschwelle
            
            % Funktion vorauschauender Tempomat: Variablen: 
            Param.v_PPC_delta                       = x(9)/3.6;   %Variablenname in Paper: vppc,  max. Geschwindigkeitsüberhöhung/ Unterschreitung von soll Geschwindikgeit, Standarwert bei 7 km/h  
            Temp1 = 100:10:1000;                    % Diskretisierung der Look ahead Strecke in 10m Abstände von 100 bis 1000m 
            Param.look_ahead_PPC                    = Temp1(x(10));      %Variablenname in Paper: distance_ppc_look_ahead, Range: 100 - 1000m Strecke voraus um die kritische Steiung zu suchen, untere Grenze
             Temp2 = 100:10:500;                     % Diskretisierung der Look ahead Strecke in 10m Abstände von 100 bis 500m 
            Param.distance_1_PPC                    = Temp2(x(11));      %Variablenname in Paper: distance_slope_positive, Range: 100 - 500m slope_length_positiveLänge der Steigung, legt mit look_ahead obere Grenze fest
            Temp3 = 100:10:500;                     % Diskretisierung der Look ahead Strecke in 10m Abstände von 100 bis 500m         
            Param.distance_2_PPC                    = Temp3(x(12));      %Variablenname in Paper: distance_slope_negative, Range: 200 -400m slope_length_neg Länge der Strecke vor einem kritischen Gefälle, bei der der Lkw das Gas zurücknimmt
            
            % Funktion Betriebsstrategie Hybrid: Variablen: 
            Param.em.M_max                          = x(13);
            Param.em.n_eck                          = x(14);
            Param.Bat.Useable_capacity           = x(15);
            Param.SOC_target                        = x(16); %Variablenname in Paper: SOC_Targe
            Param.SOC_T_EM_completely_available     = x(17); %Variablenname in Paper: SOC_Boosting_fully available, Boost vollstäandiverfügbar
            Param.v_max_electrical_drive_only       = x(18)/3.6;    %%Variablenname in Paper:v_eldrive, Geschwindigkeit in km/h bis zu der rein elektrisch gefahren wird
            Param.T_distance_LPS_up                 = x(19); %Variablenname in Paper: T_slp_up          % Abstände zu linie des minimalen Verbrauchs in Nm
            Param.T_distance_LPS_down               = x(20); %Variablenname in Paper: T_slp_down        % Abstände zu linie des minimalen Verbrauchs in Nm
           
            % Funktion Betriebsstrategie Hybrid in Kombination mit PPC: Variablen:
            Param.addition_for_critical_slope       = x(21); %Variablenname in Paper: Slope_addition, range: 1 bis 5 %
            Param.distance_PPC_altitude_difference  = x(22);  %Variablenname in Paper: distance_altitude_difference, in m Strecke, die die PPC vorausschaut
            Param.critical_altitude_difference      = x(23);  %Variablenname in Paper: altitude_difference_critical, in m Kritische Höhendifferenz
            Param.SOC_addition                      = x(24); %Variablenname in Paper: SOC_addition wird um SOC_addition erhöht
            
            % Batterie DoD
            Param.Bat.Useable_range             = x(25);
            % Batterietyp
            Param.Bat.Type                          = x(26);      % 1: Cylindrical; 2: Pouch
            % E-Maschinen Typ
            Param.em.Type                           = x(27);       % 1: PSM; 2: ASM
    case 12         % Elektrisch WPT
            Param.em.P_max                 = 0;
            Param.em.M_max                 = x(1);
            Temp1 = 1000:100:5000;           % Diskretisierung der Eckdrehzahl von 500 bis 5000 rpm in 10er Schritten
            Param.em.n_eck                 = Temp1(x(2));
            %Param.Bat.Voltage             = x(3);
            Param.Bat.Useable_range    = x(3);
            Param.Bat.Useable_capacity  = x(4);
            Param.final_drive.ratio        = x(5);
                       
            % Funktion zur Getriebeauslegung: Variablen: 
            % Spreizung, Ganganzahl, Overdrive, DSG, Achsgetriebe. Fuer Details, s.transmission.m
            Param.transmission                      = Transmission_gearing(x(6), x(7), x(8), x(9), x(5));  
            Param.engine.shift_parameter.n_lo       = x(10); %untere Schaltschwelle
            Param.engine.shift_parameter.n_pref     = x(11); %obere Schaltschwelle
            % Batterietyp
            Param.Bat.Type = x(12);      % 1: Cylindrical; 2: Pouch
            % E-Maschinen Typ
            Param.em.Type = x(13);       % 1: PSM; 2: ASM
            %--------------- Wireless Power Tansfer ---------------
            Param.WPT.SOC_target = x(14);
            Param.WPT.SOC_electric_only = x(15);% Minimaler SOC für rein elektrisches Fahren
end

% Kennfelderstellung E Maschine
%%Pesece
%[Param.Fueltype, Param.em.n_eck, Param.em.M_max, Param.em.n_max, Param.Bat.Voltage, Param.em.P_max, Param.em.Type]
[Param.em, ~, ~] = Electric_machine_mapping( Param.Fueltype, Param.em.n_eck, Param.em.M_max, Param.em.n_max, Param.Bat.Voltage, Param.em.P_max, Param.em.Type, false );

%%Horlbeck
% switch Param.em.Type
%     case 1
%         [em] = ASM_Kennfeld( Param.Fueltype, Param.em.n_eck, Param.em.M_max, Param.em.n_max, Param.Bat.Voltage, Param.em.P_max, Param.em.Type );
%     case 2
%         [em] = PSM_Kennfeld( Param.Fueltype, Param.em.n_eck, Param.em.M_max, Param.em.n_max, Param.Bat.Voltage, Param.em.P_max, Param.em.Type );
% end

%Bat.Charge_cycles = ((Bat.Useable_range*100)/103620)^(1/-0.833); % Anzahl der Ladezyklen Quelle: MARKEL, T. und SIMPSON, A.: Plug-in Hybrid Electric Vehicle Energy Storage System Design. In: Advanced Automotive Battery Conference Baltimore, Maryland, 2006
Param.Bat.Charge_cycles = ((Param.Bat.Useable_range*100)/15440)^(1/-0.652);

switch Param.Fueltype
    case {1,4}    %{'Diesel','Diesel-Hybrid'}
        Param.engine = Diesel_engine_mapping( Param.engine.M_max,Param.engine.shift_parameter.n_lo,Param.engine.shift_parameter.n_pref);
    case {2,3,5,6}    %{'CNG','LNG','CNG-Hybrid','LNG-Hybrid'}
        Param.engine = Gas_engine_mapping( Param.engine.M_max, Param.Fueltype,Param.engine.shift_parameter.n_lo, Param.engine.shift_parameter.n_pref);
    case {8,9,10,11}    %{Dual-Fuel {CNG, LNG},Dual-Fuel Hybrid {CNG, LNG}}
        Param.engine = Dual_fuel_engine_mapping( Param.engine.M_max, Param.Fueltype, Param.engine.shift_parameter.n_lo, Param.engine.shift_parameter.n_pref);
    case {7, 12}    % Elektro LKW
        Param.engine.M_max  = 0;
        Param.engine.number = 4;
end


% TCO-Berechnung mit/   ohne Anhänger
TCO_Trailer = true;

%% Gewichts- und Längenfunktionen
% weights initialisieren // Wolff 2017
Param.vehicle.payload = 0; % Zurücksetzen, damit maximale Nutzlast angenommen wird
Param.weights = weights(Param, true); % initialize weights
[Param] = Weights_calculation(Param); % Run weights calculation
Param.acquisitionCosts = acquisitionCosts(Param, true); % Acquisition cost initialization

% TCO initialisieren (Schatkowski)
helpStruct = load('costStruct_2030_Steuerbefreit.mat');
costStruct = helpStruct.costStruct;
Param.TCO = TCO(1+TCO_Trailer, costStruct, true);


Param.vehicle_F_brake_max = Param.vehicle.F_brake_max;  % Umbenennung fuer Stateflow
Param.em_M_max = Param.em.M_max;    % Umbenennung fuer Stateflow

% Radstand_berechnen( Param.Composition );
% Eigengewicht( Param.Composition );
% for i=1:length( Param.Composition )
%     AchslastenBerechnen(i, false, 0, Param.Composition); % Achslasten neu berechnen
% end

%% Simulation run
Param.VSim.Display = 0; % 0: command window only  1: Display figures 2: display simulation and figures, 3: display simulation
Param.VSim.Opt     = true; % Display simulation results in figures


Param.cycle = Driving_cycle_loading(5);
Cycle = Param.dcycle;

for Run = 1:2
    Param.dcycle = 5;
    
    if Run == 2     
        Param.dcycle = Cycle;
        Param.cycle = Driving_cycle_loading(Cycle);
        Param.max_distance = max(Param.cycle.distance);
    end
    [Results] = VSim_run(Param);
    %[ Results ] = VSim_ausfuehren_accelerator(Param);

    % Simulation postprocessing
    [Results, Param] = VSim_evaluation(Results, Param, Run, Cycle); 
end
%%
%     y = [0,0,0];
%     cons = [0, 0, 0];
    y = zeros(1, Param.numObj);
    cons = zeros(1, Param.numCons);
 %y = zeros(1, options.numObj);
    %cons = zeros(1, options.numCons);   
    
% Wenn Simulation abgebrochen, dann Zielgrößen unendlich, gilt NUR für TCO
% und Transporteffizienz. Bei anderen Zielgrößen ggf Anpassen (-unendlich
% oder 0)
if Param.VSim.Termination == 1
    
    y(1:end)=inf;
    cons(1:end)=0;
    
else
    
    % Auswertung Kostenfunktion
    % Fueltype-Bedarf
%     switch Param.Fueltype
%         case {1,4}
%             Param.Kosten.BK_Diesel  = Param.VSim.Diesel_consumption;
%         case {2,5}
%             Param.Kosten.BK_CNG  = Param.VSim.Gasverbrauch;
%         case {3,6}
%             Param.Kosten.BK_LNG  = Param.VSim.Gasverbrauch;
%         case 7
%             %Param.Kosten.BK_Strom  = Param.VSim.Electricity_consumption;
%         case {8,10}
%             Param.Kosten.BK_Diesel  = Param.VSim.Diesel_consumption;
%             Param.Kosten.BK_CNG  = Param.VSim.Gasverbrauch;
%         case {9,11}
%             Param.Kosten.BK_Diesel  = Param.VSim.Diesel_consumption;
%             Param.Kosten.BK_LNG  = Param.VSim.Gasverbrauch;
%     end
    % Auswertung Eigenschaftsfunktion
    % Beschleunigung
    
    
    switch Param.Opt_groessen
        case 1      % Average_speed & Transporteffizienz
            y(1) = (-1)*(0.001*Results.OUT_summary.signals(2).values(end)/(Results.OUT_summary.time(end)/3600));     %Average_speed in km/h wird durch (-1) maximiert
            y(2) =  Param.VSim.Verbrauch_kWh/(Param.vehicle.payload/1000);
            
        case 2      %Kosten und Eigenschaftsfunktion
            [t_0_80] = Beschleunigung_auslesen(Param.VSim);
            Param.propertie.a_0_80_ak=t_0_80;
            [ propertie ] = Eigenschaftsfunktion(Param.propertie);
            Param.propertie = propertie;
            y(1)= -propertie.EF;
            
            %[ Kosten ]= Kostenberechnung(Param.Composition{1}.Kosten);
            %Param.Composition{1}.Kosten;% = Kosten;
            y(2) = Param.Kosten.Kges;
            
        case 3      % Average_speed & Verbrauch
            % Funktioniert jetzt. Problem gelöst in Zeile 73 & 89. Ergebnis
            % wurde mit Beschleunigungs-Simulation überschrieben.
            y(1) = (-1)*(0.001*Results.OUT_summary.signals(2).values(end)/(Results.OUT_summary.time(end)/3600));     %Average_speed in km/h wird durch (-1) maximiert
            y(2) = (Results.OUT_summary.signals(7).values(end)-Results.V)/(Results.OUT_summary.signals(2).values(length(Results.OUT_summary.signals(2).values))/100000);  %Ausgabe Fueltypeverbrauch in l/100km.
        case 4 % Wolff 2016
            % TCO in €/km
            y(1) = Param.TCO.Total_costs/Param.TCO.Annual_mileage(1);
            % Transporteffizienz in gCO2/tkm
            switch Param.Fueltype
                case {1,4} % Diesel
                    y(2) = (Results.OUT_summary.signals(7).values(end)-Results.V)*Param.engine.fuel.co2_per_litre*1000/(Results.OUT_summary.signals(2).values(length(Results.OUT_summary.signals(2).values))/1000)/(Param.vehicle.payload/1000);
                case {2, 3, 5, 6} % Gas
                    y(2) = Results.OUT_summary.signals(6).values(end)/(Param.vehicle.payload/1000);
                case {8, 9, 10, 11} % Dual Fuel
                    CO2_Gas = ((Results.OUT_summary.signals(9).values(end)-Results.M)*Param.engine.fuel.co2_per_kg_lng*1000/(Results.OUT_summary.signals(2).values(length(Results.OUT_summary.signals(2).values))/1000))/(Param.vehicle.payload/1000);
                    CO2_Diesel = ((Results.OUT_summary.signals(7).values(end)-Results.V)*Param.engine.fuel.co2_per_litre_diesel*1000/(Results.OUT_summary.signals(2).values(length(Results.OUT_summary.signals(2).values))/1000))/(Param.vehicle.payload/1000);
                    y(2) = CO2_Gas + CO2_Diesel;
            end
            
        case 5 % Fries
            % TCO in €/km
            y(1) = Param.TCO.Total_costs/Param.TCO.Annual_mileage(1);
            % Transporteffizienz in gCO2/tkm
            switch Param.Fueltype
                case {1,4} % Diesel
                    y(2) = (Results.OUT_summary.signals(7).values(end)-Results.V)*Param.engine.fuel.co2_per_litre*1000/(Results.OUT_summary.signals(2).values(length(Results.OUT_summary.signals(2).values))/1000)/(Param.vehicle.payload/1000);
                case {2, 3, 5, 6} % Gas
                    y(2) = Results.OUT_summary.signals(6).values(end)/(Param.vehicle.payload/1000);
                case {8, 9, 10, 11} % Dual Fuel
                    CO2_Gas = ((Results.OUT_summary.signals(9).values(end)-Results.M)*Param.engine.fuel.co2_per_kg_lng*1000/(Results.OUT_summary.signals(2).values(length(Results.OUT_summary.signals(2).values))/1000))/(Param.vehicle.payload/1000);
                    CO2_Diesel = ((Results.OUT_summary.signals(7).values(end)-Results.V)*Param.engine.fuel.co2_per_litre_diesel*1000/(Results.OUT_summary.signals(2).values(length(Results.OUT_summary.signals(2).values))/1000))/(Param.vehicle.payload/1000);
                    y(2) = CO2_Gas + CO2_Diesel;
            end
            % Beschleunigung von 0 auf 80 km/h in Sekunden
            [t_0_80] = Beschleunigung_auslesen(Param.VSim);
            y(3) = t_0_80;
            
        case 6 % Fries
            % TCO in €/km
            y(1) = Param.TCO.Total_costs/Param.TCO.Annual_mileage(1);
            % Transporteffizienz in gCO2/tkm
            switch Param.Fueltype
                case {1,4} % Diesel
                    y(2) = (Results.OUT_summary.signals(7).values(end)-Results.V)*Param.engine.fuel.co2_per_litre*1000/(Results.OUT_summary.signals(2).values(length(Results.OUT_summary.signals(2).values))/1000)/(Param.vehicle.payload/1000);
                case {2, 3, 5, 6} % Gas
                    y(2) = Results.OUT_summary.signals(6).values(end)/(Param.vehicle.payload/1000);
                case {8, 9, 10, 11} % Dual Fuel
                    CO2_Gas = ((Results.OUT_summary.signals(9).values(end)-Results.M)*Param.engine.fuel.co2_per_kg_lng*1000/(Results.OUT_summary.signals(2).values(length(Results.OUT_summary.signals(2).values))/1000))/(Param.vehicle.payload/1000);
                    CO2_Diesel = ((Results.OUT_summary.signals(7).values(end)-Results.V)*Param.engine.fuel.co2_per_litre_diesel*1000/(Results.OUT_summary.signals(2).values(length(Results.OUT_summary.signals(2).values))/1000))/(Param.vehicle.payload/1000);
                    y(2) = CO2_Gas + CO2_Diesel;
            end
            
            % Elastitzität von 60 auf 80 km/h in Sekunden
            [t_60_80] = Elastizitaet_auslesen(Param.VSim);
            y(3) = t_60_80;
            
        case 7 % Fries   4 Zielgrößen
            % TCO in €/km
            y(1) = Param.TCO.Total_costs/Param.TCO.Annual_mileage(1);
            % Transporteffizienz in gCO2/tkm
            switch Param.Fueltype
                case {1,4} % Diesel
                    y(2) = (Results.OUT_summary.signals(7).values(end)-Results.V)*Param.engine.fuel.co2_per_litre*1000/(Results.OUT_summary.signals(2).values(length(Results.OUT_summary.signals(2).values))/1000)/(Param.vehicle.payload/1000);
                case {2, 3, 5, 6} % Gas
                    y(2) = Results.OUT_summary.signals(6).values(end)/(Param.vehicle.payload/1000);
                case {8, 9, 10, 11} % Dual Fuel
                    CO2_Gas = ((Results.OUT_summary.signals(9).values(end)-Results.M)*Param.engine.fuel.co2_per_kg_lng*1000/(Results.OUT_summary.signals(2).values(length(Results.OUT_summary.signals(2).values))/1000))/(Param.vehicle.payload/1000);
                    CO2_Diesel = ((Results.OUT_summary.signals(7).values(end)-Results.V)*Param.engine.fuel.co2_per_litre_diesel*1000/(Results.OUT_summary.signals(2).values(length(Results.OUT_summary.signals(2).values))/1000))/(Param.vehicle.payload/1000);
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
                    %y(2) = (Results.OUT_summary.signals(7).values(end)-Results.V)*Param.engine.fuel.co2_per_litre*1000/(Results.OUT_summary.signals(2).values(length(Results.OUT_summary.signals(2).values))/1000)/(Param.vehicle.payload/1000);
                    y(2) = (Results.OUT_summary.signals(7).values(end)*Param.engine.fuel.co2_per_litre*1000 + (-Results.delta_WPT -Results.delta_E) * Param.em.fuel.co2_per_kwh) /(Results.OUT_summary.signals(2).values(length(Results.OUT_summary.signals(2).values))/1000)/(Param.vehicle.payload/1000);
                case {2, 3, 5, 6} % Gas
                    y(2) = Results.OUT_summary.signals(6).values(end)/(Param.vehicle.payload/1000);
                case {8, 9, 10, 11} % Dual Fuel
                    CO2_Gas = ((Results.OUT_summary.signals(9).values(end)-Results.M)*Param.engine.fuel.co2_per_kg_lng*1000/(Results.OUT_summary.signals(2).values(length(Results.OUT_summary.signals(2).values))/1000))/(Param.vehicle.payload/1000);
                    CO2_Diesel = ((Results.OUT_summary.signals(7).values(end)-Results.V)*Param.engine.fuel.co2_per_litre_diesel*1000/(Results.OUT_summary.signals(2).values(length(Results.OUT_summary.signals(2).values))/1000))/(Param.vehicle.payload/1000);
                    y(2) = CO2_Gas + CO2_Diesel;
                case 7
                    y(2) = (-Results.delta_E*Param.em.fuel.co2_per_kwh/(Results.OUT_summary.signals(2).values(length(Results.OUT_summary.signals(2).values))/1000))/(Param.vehicle.payload/1000);  %Ausgabe CO2-Ausstoß in gCO2/tkm
            end
            % Beschleunigung von 60 auf 80 km/h in Sekunden
            tf = isfield(Param.VSim, 'v_t');
            if tf == 0
                y(3) = inf;
            else
                [t_60_80] = Acceleration_readout(Param.VSim);
                y(3) = t_60_80;
                if Param.VSim.Opt == false
                    fprintf('Annual_mileage in:  %2.4f  km \n', Param.TCO.Annual_mileage);
                    fprintf('TCO in:  %2.4f  EUR/100tkm \n', Param.TCO.Total_costs/(Param.TCO.Annual_mileage(1)*(Param.vehicle.payload/100000)));  %Ausgabe TCO in €/km
                end
            end
        case 9 % Fries   3 Zielgrößen
            % TCO in €/tkm
            y(1) = Param.TCO.Total_costs/(Param.TCO.Annual_mileage(1)*(Param.vehicle.payload/100000));
            % Transporteffizienz in gCO2/tkm
            switch Param.Fueltype
                case {1,4} % Diesel
                    y(2) = (Results.OUT_summary.signals(7).values(end)-Results.V)*Param.engine.fuel.co2_per_litre*1000/(Results.OUT_summary.signals(2).values(length(Results.OUT_summary.signals(2).values))/1000)/(Param.vehicle.payload/1000);
                case {2, 3, 5, 6} % Gas
                    y(2) = Results.OUT_summary.signals(6).values(end)/(Param.vehicle.payload/1000);
                case {8, 9, 10, 11} % Dual Fuel
                    CO2_Gas = ((Results.OUT_summary.signals(9).values(end)-Results.M)*Param.engine.fuel.co2_per_kg_lng*1000/(Results.OUT_summary.signals(2).values(length(Results.OUT_summary.signals(2).values))/1000))/(Param.vehicle.payload/1000);
                    CO2_Diesel = ((Results.OUT_summary.signals(7).values(end)-Results.V)*Param.engine.fuel.co2_per_litre_diesel*1000/(Results.OUT_summary.signals(2).values(length(Results.OUT_summary.signals(2).values))/1000))/(Param.vehicle.payload/1000);
                    y(2) = CO2_Gas + CO2_Diesel;
            end
            
            % Average_speed in km/h
            y(3) = (-1)*(0.001*Results.OUT_summary.signals(2).values(end)/(Results.OUT_summary.time(end)/3600));     %Average_speed in km/h wird durch (-1) maximiert
        case 10 % Fries   3 Zielgrößen
            % TCO in €/tkm
            y(1) = Param.TCO.Total_costs/(Param.TCO.Annual_mileage(1)*(Param.vehicle.payload/100000));
            % Transporteffizienz in gCO2/tkm
            switch Param.Fueltype
                case {1,4} % Diesel
                    y(2) = (Results.OUT_summary.signals(7).values(end)-Results.V)*Param.engine.fuel.co2_per_litre*1000/(Results.OUT_summary.signals(2).values(length(Results.OUT_summary.signals(2).values))/1000)/(Param.vehicle.payload/1000);
                case {2, 3, 5, 6} % Gas
                    y(2) = Results.OUT_summary.signals(6).values(end)/(Param.vehicle.payload/1000);
                case {8, 9, 10, 11} % Dual Fuel
                    CO2_Gas = ((Results.OUT_summary.signals(9).values(end)-Results.M)*Param.engine.fuel.co2_per_kg_lng*1000/(Results.OUT_summary.signals(2).values(length(Results.OUT_summary.signals(2).values))/1000))/(Param.vehicle.payload/1000);
                    CO2_Diesel = ((Results.OUT_summary.signals(7).values(end)-Results.V)*Param.engine.fuel.co2_per_litre_diesel*1000/(Results.OUT_summary.signals(2).values(length(Results.OUT_summary.signals(2).values))/1000))/(Param.vehicle.payload/1000);
                    y(2) = CO2_Gas + CO2_Diesel;
            end
            
            % Average_speed in km/h
            bandbreite = 0.05; % Angabe der Toleranzbreite+/- in, geht nicht in RMSE mit ein %
            y(3) =  RMSE_v( Ergebnis, Param, bandbreite ); %Soll-Geschwindigkeit
        case 11 % Wolff   3 Zielgrößen Elektro LKW
            if Param.vehicle.payload < 0 % Negative Nutzlast abfangen
                y(1) = inf;
                y(2) = inf;
            else
                % TCO in €/tkm
                y(1) = Param.TCO.Total_costs/(Param.TCO.Annual_mileage(1)*(Param.vehicle.payload/100000));
                % Transporteffizienz in gCO2/tkm
                y(2) = (-Results.delta_E*Param.em.fuel.co2_per_kwh/(Results.OUT_summary.signals(2).values(length(Results.OUT_summary.signals(2).values))/1000))/(Param.vehicle.payload/1000);  %Ausgabe CO2-Ausstoß in gCO2/tkm
            end
            % Beschleunigung von 60 auf 80 km/h in Sekunden
            tf = isfield(Param.VSim, 'v_t');
            if tf == 0
                y(3) = inf;
            else
                [t_60_80] = Elastizitaet_auslesen(Param.VSim);
                y(3) = t_60_80;
            end
            
    end
    %% calculate the constraint violations
    
    % Minimale Gesamtübersetzung. Wird benötigt, da sonst ein Schalten in
    % höchsten Gang nicht mehr möglich ist und um "Schaltpendeln" zu
    % verhindern
    if Param.transmission.ratios(end) * Param.final_drive.ratio < 2.3
        cons(1) = Param.transmission.ratios(end) * Param.final_drive.ratio;
    end
    
    % Mindest-Anfahrsteigfähigkeit. Wert empirisch festgelgt
    if Param.transmission.q_starting < 15 % in %
        cons(2) = Param.transmission.q_starting;
    end
    
    switch Param.Fueltype
        
        case {1,2,3}    %{'Diesel','CNG','LNG'}
            
        case {4,5,6}    %{'Diesel-Hybrid','CNG-Hybrid','LNG-Hybrid'}
            % C-Rate in Abhängigkeit des Batterietyps
            switch Param.Bat.Type
                case {1}
                    if max(Results.OUT_Bat.signals(3).values) > 13.00 %interp1([2014 2020], [10 20], 2017)
                        cons(3) = max(abs(Results.OUT_Bat.signals(3).values));
                    end
                case {2}
                    if max(Results.OUT_Bat.signals(3).values) > 15
                        cons(3) = max(abs(Results.OUT_Bat.signals(3).values));
                    end
            end
            
        case {7, 12}         % Elektrisch
            % C-Rate in Abhängigkeit des Batterietyps
            switch Param.Bat.Type
                case {1}
                    if max(Results.OUT_Bat.signals(3).values) > 3 %13.00 %interp1([2014 2020], [10 20], 2017)
                        cons(3) = max(abs(Results.OUT_Bat.signals(3).values));
                    end
                case {2}
                    if max(Results.OUT_Bat.signals(3).values) > 4 %15
                        cons(3) = max(abs(Results.OUT_Bat.signals(3).values));
                    end
            end
            if Param.weights.m_Total > Param.weights.m_Max
                cons(4) = abs(Param.weights.m_Max - Param.weights.m_Total);
            end
            % Maximale Stromstärke begrenzen auf 400 A [Wert Tesla, geschätzt]
            if max(abs(Results.OUT_Bat.signals(4).values)) > 400
                cons(5) = max(abs(Results.OUT_Bat.signals(4).values));
            end
            %Minimale Reichweite von 600 km
            if -((Param.Bat.Voltage * Param.Bat.Useable_capacity/1000) / (Param.VSim.Verbrauch_kWh/100)) > -600
                cons(6) = -((Param.Bat.Voltage * Param.Bat.Useable_capacity/1000) / (Param.VSim.Verbrauch_kWh/100));
            end
        case {8,9}      %Dual-Fuel {CNG, LNG}
            
        case {10,11}    %Dual-Fuel Hybrid {CNG, LNG}
            % C-Rate in Abhängigkeit des Batterietyps
            switch Param.Bat.Type
                case {1}
                    if max(Results.OUT_Bat.signals(3).values) > 10.00 %interp1([2014 2020], [10 20], 2017)
                        cons(3) = max(abs(Results.OUT_Bat.signals(3).values));
                    end
                case {2}
                    if max(Results.OUT_Bat.signals(3).values) > 15
                        cons(3) = max(abs(Results.OUT_Bat.signals(3).values));
                    end
            end
            
    end
    
    % Zeile zur Abtrennung zur nächsten Simulation
    fprintf('----------------------------------------------------------------------------\n');
    %cd Optimierung;
end