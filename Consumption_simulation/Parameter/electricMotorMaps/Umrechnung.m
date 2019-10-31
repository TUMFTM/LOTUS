function [vektor_Pelv, vektor_Pelr, vektor_Irmsv, vektor_Irmsr, vektor_Urms] = Umrechnung(vektor_eta, M_EM_max, n_EM_nenn, U_Bat, cos_phi, step_n, step_M)


%UMRECHNUNG des Vektors n,M,eta auf U,I

i=1;

vektor_P_mechv=zeros(length(vektor_eta),1);                               % r und v in Variablenname bezeichnen ob der Vektor die Info für Vortrieb (positive Leistung usw.) oder Reku (negative Leistung usw.) hat
vektor_P_mechr=zeros(length(vektor_eta),1);
vektor_Pelv=zeros(length(vektor_eta),1);
vektor_Pelr=zeros(length(vektor_eta),1);
vektor_Urms=zeros(length(vektor_eta),1);
vektor_Irmsv=zeros(length(vektor_eta),1);
vektor_Irmsr=zeros(length(vektor_eta),1);



Urms_str_max = U_Bat/2.34;                                                                     % maximaler RMS-Wert der Wechselspannung bei gegebener DC-Batteriespannung                                                                  


for drehzahl = 1:round(length(vektor_eta)/(2*M_EM_max/step_M + 1))                                   % somit ergibt sich die for-schleife von Drehzahl 1 bis zur maximalen Drehzahl; Einheit 1/min und Berücksichtigung der Schrittweite bei der Drehzahl; egal ob VA oder HA, da selbe Länge
    for drehmoment=1:round(M_EM_max/step_M)                                                            % Drehmomentvektor für negative Momente und damit richtige Berechnung der el. Leistung ; Berücksichtigung der Schrittweite beim Drehmoment; egal ob VA oder HA, da selbe Länge
        vektor_P_mechr(i) = (drehzahl-1)*step_n/60*2*pi * ((drehmoment-1)*step_M-M_EM_max);    % Vektor wird mit i so aufgefüllt wie der Originalvektor (bei einer Drehzahl von -M über 0 bis +M und dann nächste Drehzahl(Einheit rad/s) unter Berücksichtgung der jeweiligen Schrittweiten, damit physikalisch richtiger Wert rauskommt)           
        vektor_Pelr(i) = vektor_P_mechr(i) * vektor_eta(i);                                       % Elektrische Leistung ist hier mechanische Leistung mal Wirkungsgrad (Rekuperation)                                                         
        vektor_Urms(i) = min((drehzahl-1)*step_n/n_EM_nenn, 1) * Urms_str_max;                     % Spannung abhängig von Drehzahl, max. Spannung (s. Zeile 12) ab Nenndrehzahl erreicht; Ergebnis ist auf einen Strang bezogen
        vektor_Irmsr(i) = vektor_Pelr(i) / vektor_Urms(i) /3/cos_phi;                               % Strom berechnet sich aus elektrischer Leistung geteilt Spannung und Leistungsfaktor; nochmal geteilt 3 ergibt Strom je Strang  
        
        i=i+1;
    end
    for drehmoment=1:round(M_EM_max/step_M + 1)                                                        % Schleife für positive Momente mit 0 (entspricht Vortrieb)
        vektor_P_mechv(i) = (drehzahl-1)*step_n/60*2*pi * ((drehmoment-1)*step_M);
        vektor_Pelv(i) = vektor_P_mechv(i) / vektor_eta(i);                                 % Richtiger Zusammenhang der Leistungen mit Wirkungsgrad für Vortrieb; Rest wie oben
        vektor_Urms(i) = min((drehzahl-1)*step_n/n_EM_nenn, 1) * Urms_str_max;
        vektor_Irmsv(i) = vektor_Pelv(i) / vektor_Urms(i) /3/cos_phi;
        
        i=i+1;
    end
end

vektor_Pelv(vektor_Pelv==inf)=0;                                                                % Vermeidung von inf bei Division durch 0 (passiert wenn Wirkungsgrad = 0)
vektor_Pelv(vektor_Pelv==-inf)=0;
vektor_Pelv(isnan(vektor_Pelv)==1)=0;
vektor_Irmsv(vektor_Irmsv==inf)=0;
vektor_Irmsv(vektor_Irmsv==-inf)=0;
vektor_Irmsv(isnan(vektor_Irmsv)==1)=0;
vektor_Irmsr(isnan(vektor_Irmsr)==1)=0;

end
