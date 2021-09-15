classdef VSim <handle
    %Verbrauchssimulation
    %    Klasse Verbrauchssimulation in der die zusätzlichen propertie
    %    für die Verbrauchssimulation hinterlegt sind.
    %    Änderungen werden von den Methoden berücksichtigt.
    %    Jon Schmidt, 17.05.2016

    
    propertie 
        
        Termination             % gibt an, ob die Verbrauchssimulation abgebrochen wurde
        AchslastAntrieb     % gibt die Achslast an den Antriebsachsen an                                            [kg]
        Anzeige             % gibt an, wie die Verbrauchssimulation angezeigt werden soll
        cW                  % Errechneter Luftwiderstandsbeiwert des Zuges                                          [ ]
        cycle               % Struct mit propertie des Fahrzyklus
        druck               % Eingestellte Druckabweichung(-10%=1, 0%=2, +10%=3)
        druckabw            % Druckabweichung zur Berechunung des Rollwiderstandsbeiwertes (folgt aus 'druck')      [ ]
        bDiesel     % bDiesel des Zuges                                                             [l/100km]
        Entwurf             % Gibt an ob die Verbrauchssimulation aus dem NFZ-Entwurf gestartet wird (ja=1, nein=0)
        Ergebnis            % Hier werden die weiteren Simulationsergebnisse aus der Verbrauchssimulation abgelegt
        Fahrzyklus          % Gewählter Fahrzyklus in GUI_Menue3 für Verbrauchssimulation
        Faktor_ZweiAA       % Faktor für Wirkungsgrad bei zwei angetriebenen Achsen (eine Achse: =1, zwei Achsen: =0.947 [MAN16c, S. 308]) 
        fR                  % Errechneter Rollwiderstandsbeiwert des Zuges                                          [ ]
        Gesamtgewicht       % Gesamtgewicht des beladenen Zuges                                                     [kg]
        Gasart              % CNG oder LNG              %Theisen 25.04.2016
        bGas        % bGas des Zuges                                                                [kg/100km]
        Gui_Gesetze         % Gibt an, ob das Gui_Menue3 von Gui_Gesetze (=1) oder der Verbrauchssimulation (=0) geöffnet wurde
        Nutzlast            % Nutzlast des Zuges                                                                    [kg]
        Stirnflaeche        % Stirnfläche des Zuges                                                                 [m^2]
        energyTotal      % energyTotal des Zuges                                                              [kWh/100km]
        temp                % Eingestellte Temperatur für Reifen (20°C=1, 25°C=2, 30°C=3)
        tempabw             % Temperaturabweichung zur Berechnung des Rollwiderstandsbeiwertes (folgt aus 'temp')   [°C]
        v_t                 % Zeitverlauf der Geschwindigkeit für Beschleunigung                                    [km/h]   Theisen 05.04.16
        Consumption_kWh       % gibt den Verbrauch in kWh unabhängig von der Antriebsart an                           [kWh]     
        Vorraus_Temp        % Gibt an ob ein vorrausschauender Tempomat verbaut ist (true/false), Jon Schmidt, 08.12.2015

        
        %Optimierung
        n_gen               % Anzahl der Generationen
        n_ind               % Anzahl der Individuen
        Opt_Groesse_x       % Optimierungsgroesse auf der x-Achse
        Opt_Groesse_y       % Optimierungsgroesse auf der y-Achse
        Opt=false           % Fallunterscheidung Optimierung oder Verbrauchssimulation                             [-]      Theisen 11.04.2016
        Parallel = 'no'     % Status Parallel Computing
       
       
    end
    
    methods
        % Funktion zur Bestimmung der Temperaturabweichung (theta-theta_ISO) gegenüber der Prüfnorm anhand der
        % ausgewählten Temperatur, wird zur Berechnung des Rollwiderstandsbeiwertes benötigt
        % Jon Schmidt, 16.03.2016
        function tempabw = get.tempabw(obj)    
            if (obj.temp == 1)     %Wahl der Temperatur 20 °C
                tempabw = -5;                   %[ ]
            elseif (obj.temp == 2) %Wahl der Temperatur 25 °C
                tempabw = 0;                    %[ ]
            elseif (obj.temp == 3) %Wahl der Temperatur 30 °C
                tempabw = 5;                    %[ ]
            end
        end
        % Funktion zur Bestimmung der Druckabweichung (p/p_ISO) anhand der
        % ausgewählten prozentualen Abweichung, wird zur Berechnung des
        % Rollwiderstandsbeiwertes benötigt
        % Jon Schmidt, 16.03.2016
        function druckabw = get.druckabw(obj)    
            if (obj.druck == 1)     %Wahl der Druckabweichung -10%
                druckabw = 0.9;                %[ ]
            elseif (obj.druck == 2) %Wahl der Druckabweichung 0%
                druckabw = 1.0;                %[ ]
            elseif (obj.druck == 3) %Wahl der Druckabweichung +10%
                druckabw = 1.1;                %[ ]
            end
        end
        
    % Konstruktor für GUI_Menue1        
        function obj = VSim(dimension)  %Konstruktor zur Initialisierung der Werte im Gui_Menu1
                        
            obj.druck = dimension(1);
            obj.bDiesel = dimension(2);
            obj.Fahrzyklus = dimension(3);
            obj.bGas = dimension(4);
            obj.energyTotal = dimension(5); 
            obj.temp = dimension(6); 
            obj.Vorraus_Temp = dimension(7);
            obj.Anzeige = dimension(8);
            obj.Termination = dimension(9);
            obj.Entwurf = dimension(10);
            
        end
 
    end
    
end