function [ FuelCell ] = FuelCell_Auslegung( P_nom, V_nom )
% %Funktion zur Berechnung der Parameter für Fuel Cell Block in Simulink
% %   Detailed explanation goes here
%  
%% Parameter für Polarisationskurve auf Zellebene
% V_nom           =  800;
% P_nom           =  120;
% Wirkungsgrad
eta_nom         =   0.55;       % [-]
% Innenwiderstand
R_i             =  0.66404/900; % [Ohm], empirisch Matlab 50 kW, seriell verschalteter Widerstand mit 900 Zellen
% Durchsetzungsfaktor
% alpha           =   0.27574;    % [-], T=80 °C Quelle: Simulink 50 kW Stack
alpha           =   0.26402;   % [-], T=65 °C 
% Austauschstrom
I_0             =  0.91636;     % [A], Quelle: Fuel Cell Stack 50 kW 
% Betriebstemperatur
T_nom           =   338;        % [K] (65°C)
% T_nom           =   353;        % [K] (80°C)
% Konstanten
% Faraday
F = 96485.3365;                 % [C/mol]
% umgesetzte Elektronen
z = 2;                          % [-]
% ideale Gaskonstante
R = 8.3144621;                  % [J/(Kmol)]
% (unterer) Heizwert
LHV = 241.83*10^3;              % [J/mol]
% Stromdichte Zelle
i_nom_zelle = 0.215;            % [A/cm2] Quelle: TUM Praktikum (Dummy) !Für 25 °C! --> Tendenziell höhere Dichte zu erwarten
i_zelle_end = 0.7;              % [A/cm2]
i_0 = I_0/80*i_nom_zelle;       % [A/cm2] I_0/A für A=(80 A)/(0.175 A/cm2) Daten aus Fuel Cell Stack 50 kW; Überprüft mit experimentalen Daten, Quelle: https://d-nb.info/988134268/34 S.64
% Spannung Zelle
V_nom_zelle = LHV*eta_nom/(z*F);% nominale Zellspannung, bei eta_nom
%% Auslegung

I_nom = P_nom*1000/(V_nom);                             % Nennstrom [A]
N = floor(V_nom/V_nom_zelle);

% Test: Nernstspannung pro Zelle
V_ner_zelle = 1.229 - (T_nom-298)*(44.43/(z*F)) + R*T_nom/(z*F)*log(1.5/0.21^0.5); % Quelle: Matlab Doku


% Konstanten Berechnungen
A = I_nom/i_nom_zelle;                                  % Zellfläche [cm2]
I_0 = A*i_0;                                            % Austauschstrom neue PEMFC, wichtig für weitere Formeln
A_tafel = R*T_nom/(z*F*alpha);                          % Tafelsteigung
R_ohm = R_i*N;                                          % Ohm'sche Wirkungsgrad der gesamten PEMFC, nur seriell verschaltete Zellen

% Bestimmung charakteristische Punkte auf Polarisationskurve
V_1 = V_nom + abs(N*A_tafel*log(I_nom)) + R_ohm*(I_nom-1);   % Quelle: Paper aus Matlab-Hilfe (https://ieeexplore.ieee.org/stamp/stamp.jsp?tp=&arnumber=5289692)
V_0 = V_1 - N*A_tafel*log(I_0) + R_ohm;                 % Quelle: Paper aus Matlab-Hilfe (https://ieeexplore.ieee.org/stamp/stamp.jsp?tp=&arnumber=5289692)

I_max = min([A * i_zelle_end, 450]);                    % Maximaler Strom [A], Quelle: Matlab 50 kW Stack, selbe max. Werte, weil keine Stacks parallel genommen. i_zelle_end müsste angepasst werden, weil Modell nicht mehr verwendet werden kann
V_min = V_0 - N*A_tafel*log(I_max/I_0)-R_ohm*I_max;     % Quelle: Paper aus Matlab-Hilfe (https://ieeexplore.ieee.org/stamp/stamp.jsp?tp=&arnumber=5289692)

% Punkt, ab dem Konzentrationsüberspannungen nicht mehr vernachlässigbar sind, empirisch
I_end = min([A * 0.25, 450]);                           % Abschätzung, aus alten Daten Praktikum mit 0.25 A/cm^2 (Dummy) (Grafik, siehe Arbeit, Abb. )
V_end = V_0 - N*A_tafel*log(I_end/I_0)-R_ohm*I_end;     % Quelle: Paper aus Matlab-Hilfe (https://ieeexplore.ieee.org/stamp/stamp.jsp?tp=&arnumber=5289692)

% Volumenstrom Luft
V_lpm_air = (60000*R*T_nom*N*I_nom)/(2*z*F*1e5*0.5*0.21); % Quelle Matlab Doku

I_reg2 = I_nom*0.75;                                    % [A], empirischer Regelpunkt
V_reg2 = V_0 - N*A_tafel*log(I_reg2/I_0)-R_ohm*I_reg2;  % [V]

I_reg3 = I_nom*0.5;                                     % [A], empirischer Regelpunkt
V_reg3 = V_0 - N*A_tafel*log(I_reg3/I_0)-R_ohm*I_reg3;  % [V]
 
I_reg4 = I_nom*0.25;                                    % [A], empirischer Regelpunkt
V_reg4 = V_0 - N*A_tafel*log(I_reg4/I_0)-R_ohm*I_reg4;  % [V]

I_reg5 = 2;                                             % [A], empirischer Regelpunkt
V_reg5 = V_0 - N*A_tafel*log(I_reg5/I_0)-R_ohm*I_reg5;  % [V]
%% Output

FuelCell.P_nom              =    P_nom;
FuelCell.NernstVoltage      =    [V_0 V_1];
FuelCell.OperatingPoint     =    [I_nom V_nom];
FuelCell.MaximumPoint       =    [I_end V_end];
FuelCell.NoCells            =    N;
FuelCell.Eta                =    eta_nom;
FuelCell.OperatingTemp      =    T_nom - 273;
FuelCell.AirFlow            =    V_lpm_air;
FuelCell.Pressure           =    [1.5 1];
FuelCell.Composition        =    [99.95 21 1];
FuelCell.regV               =    [V_nom V_reg2 V_reg3 V_reg4 V_reg5];
FuelCell.regI               =    [I_nom I_reg2 I_reg3 I_reg4 I_reg5];
FuelCell.regulation1        =    [I_nom V_nom];
FuelCell.regulation2        =    [I_reg2 V_reg2];
FuelCell.regulation3        =    [I_reg3 V_reg3];
FuelCell.regulation4        =    [I_reg4 V_reg4];
FuelCell.regulation5        =    [I_reg5 V_reg5];
FuelCell.Hysterese1         =    [0.35 0.3];
FuelCell.Hysterese2         =    [0.55 0.45];
FuelCell.Hysterese3         =    [0.7 0.6];
FuelCell.Hysterese4         =    [0.8 0.75];
FuelCell.Hysterese5         =    [0.93 0.9];
end

