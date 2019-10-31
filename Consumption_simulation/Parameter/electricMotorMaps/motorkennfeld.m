function [ motor_kennfeld ] = motorkennfeld( M_EM_nenn,M_EM_max,n_EM_nenn,n_EM_max,typ_EM,U_Bat )
%UNTITLED Motorkennfeldberechnung
%   Berechnung eines beliebigen Motorkennfelds nach Tool 'Pesce'


% [Nm]
% [Nm]; sinnvolles Verhältnis Maximal- zu Nennmoment beachten
% [1/min]
% [1/min]; sinnvollen Feldschwächebereich beachten
P_EM_nenn = M_EM_nenn * n_EM_nenn/60*2*pi;
% 'ASM' oder 'PSM'

eta_mit_LE = 0;     % Wirkungsgradkennfeld mit Leistungselektronik-Wirkungsgrad dann 1 (in diesem Fall muss in DynA4 der Parameter Eff.v des "SimpleInverter"Moduls gleich 1 gesetzt werden), nur E-Maschinenkennfeld dann 0
% Batteriespannungslevel [V]
cos_phi = 0.85; % Mittlerer Leistungsfaktor





%% Berechnung des/der Kennfeldes(r)
cwd = pwd;
cd([cwd '\Erzeugung_Wirkungsgradkennfeld_Dateien\']);

[vektor_eta, step_M, step_n, vektor_M_max, vektor_M, vektor_n, M_EM_max, n_EM_nenn, m_EM, J_EM] = Interpolieren(M_EM_nenn, n_EM_nenn, M_EM_max, n_EM_max, P_EM_nenn, typ_EM, [cwd '\Erzeugung_Wirkungsgradkennfeld_Dateien\']);
    
    
% Ausführen des Umrechnung.m Skripts
[vektor_Pelv, vektor_Pelr, vektor_Irmsv, vektor_Irmsr, vektor_Urms] = Umrechnung(vektor_eta, M_EM_max, n_EM_nenn, U_Bat, cos_phi, step_n, step_M);

% Ausführen des LE_Berechnung.m Skriptes
[m_LE, eta_LE] = LE_Berechnung(P_EM_nenn, vektor_Pelv, vektor_Pelr, vektor_Irmsv, vektor_Irmsr, vektor_Urms, U_Bat, cos_phi);


%% Diverse zusammenführende Berechnungen
% Berechnung Gesamtwirkungsgrad E-M und LE
if eta_mit_LE == 1
    vektor_eta = vektor_eta .* eta_LE;
end


%% Aufbereiten der Daten für DynA4

Inrt_v = J_EM;

matrix=zeros(201,201);
for idx=1:201
    matrix(:,idx) = vektor_eta(((idx-1)*201+1):((idx-1)*201+201));
end

MaxMotorTrqCurve_x = (vektor_n /60*2*pi)';      % Umrechnung in rad/s
MaxMotorTrqCurve_v = vektor_M_max;

MaxGeneratorTrqCurve_x = (vektor_n /60*2*pi)';  % Umrechnung in rad/s
MaxGeneratorTrqCurve_v = vektor_M_max;

MotorEffMap3D_y = (vektor_n /60*2*pi)'; % Umrechnung in rad/s
MotorEffMap3D_z = vektor_M(101:201)';

GeneratorEffMap3D_y = (vektor_n /60*2*pi)'; % Umrechnung in rad/s
GeneratorEffMap3D_z = vektor_M(101:201)';

matrix = [ones(201,1)*0.001, matrix(:,2:end)]; % Drehzahl 0 erhält einen Wirkungsgrad von 0.001 (für DynA4 nötig)
%MotorEffMap3D_v( :, :, 1  ) = matrix(102,:); % Drehmoment 0 bekommt selbe Wirkungsgrade wie erstes Drehmoent (nach Vorlage von DynA4 wohl nötig)
%GeneratorEffMap3D_v( :, :, 1  ) = matrix(100,:);
for M=2:101
    MotorEffMap3D_v( :, :, M  ) = matrix (M+100,:);
    GeneratorEffMap3D_v( :, :, M  ) = matrix(102-M,:);
end

GeneratorEffMap3D_v(GeneratorEffMap3D_v==0)= 0.001; % replace 0 with 0.001 (Wirkungsgrad 0 führt bei DYNA4 zu ungültigen Ergebnissen)
MotorEffMap3D_v(MotorEffMap3D_v==0)= 0.001; % replace 0 with 0.001 (Wirkungsgrad 0 führt bei DYNA4 zu ungültigen Ergebnissen)

cd(cwd);




%save Motordata.mat MaxMotorTrqCurve_x MaxMotorTrqCurve_v MaxGeneratorTrqCurve_x MaxGeneratorTrqCurve_v MotorEffMap3D_y MotorEffMap3D_z MotorEffMap3D_v GeneratorEffMap3D_y GeneratorEffMap3D_z GeneratorEffMap3D_v Inrt_v

contourf(MotorEffMap3D_y)

end

