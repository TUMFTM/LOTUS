function [m_LE, eta_LE] = LE_Berechnung(P_EM_nenn, vektor_Pelv, vektor_Pelr, vektor_Irmsv, vektor_Irmsr, vektor_Urms, U_Bat, cos_phi)

%% Leistungselektronik _ ini

% Parametrisierung
%  Daten des Leistungselektronik-Moduls SKiM406GD066HD
U_CEO = 0.9;               % [V]                                           Kollektor-Emitter-Spannung
r_CE  = 1.4 * 10^(-3);     % [Ohm]                                         Kollektor-Emitter-Widerstand
E_on_0  = 8 * 10^(-3);       % [J]                                           Einschaltverlustenergie 
E_off_0 = 25 * 10^(-3);      % [J]                                           Ausschaltverlustenergie 
I_ref = 400;               % [A]                                           Referenzstromstärke
U_ref = 300;               % [V]                                           Referenzspannung

U_D  = 1;                  % [V]                                           Diodenspannung
r_D  = 1.3 * 10^(-3);      % [Ohm]                                         Diodenwiderstand
E_rr_0 = 12 * 10^(-3);       % [J]                                           Sperrverzögerungsenergie

%  Schaltungsparameter
f_s = 8000;                % [Hz]                                          Schaltfrequenz

% Berechnung der Masse    
m_LE = 0.0982*P_EM_nenn/1000 + 2.0983;                 %Formel auf W bezogen; Ergebnis in kg


%% Verlustberechnungen für die VA
% Berechnung der Wirkungsgrade

vektor_Upeak = vektor_Urms * sqrt(2);
vektor_mod = vektor_Upeak/(U_Bat/2);

vektor_Ipeak = vektor_Irmsv * sqrt(2);                               % Verwendung des Stromvektors der nur positven Strom für Vortrieb enthält (Größe für einen Strang)

% Leitungsverluste für Wechselrichten IGBT & Diode

vektor_Pcond_igbt_ac = ( 1/(2*pi) + vektor_mod*cos_phi/8 ) .* U_CEO.*vektor_Ipeak + ( 1/8 + vektor_mod*cos_phi/(3*pi) ) .* r_CE.*vektor_Ipeak.^2;
vektor_Pcond_diode_ac = ( 1/(2*pi) - vektor_mod*cos_phi/8 ) .* U_D.*vektor_Ipeak + ( 1/8 - vektor_mod*cos_phi/(3*pi) ) .* r_D.*vektor_Ipeak.^2;

% Schaltverluste für Wechselrichten IGBT & Diode
vektor_Eon = E_on_0 * U_Bat/U_ref * vektor_Ipeak/I_ref;       % Lineare Skalierung aus Bierhoff bzw. Semikron Applikationshandbuch
vektor_Eoff = E_off_0 * U_Bat/U_ref * vektor_Ipeak/I_ref;
vektor_Err = E_rr_0 * U_Bat/U_ref * vektor_Ipeak/I_ref;

vektor_Psw_igbt = (vektor_Eon+vektor_Eoff)*f_s/pi;            % Formel aus Bierhoff bzw. Semikron Applikationshandbuch
vektor_Psw_diode = vektor_Err * f_s/pi;

% Leitungsverluste für Gleichrichten Diode
vektor_Pcond_diode_dc = r_D*vektor_Irmsr.^2;                      % Verwendung des Stromvektors, der nur negativen Strom aus der Rekuperation enthält; durch Quadrat sind Verluste positiv

% Summe Verluste Wechselrichten/Vortrieb
vektor_Pv_ac = 6*(vektor_Pcond_igbt_ac+vektor_Psw_igbt + vektor_Pcond_diode_ac+vektor_Psw_diode);

% Summe Verluste Gleichrichten/Reku
vektor_Pv_dc = 6 * vektor_Pcond_diode_dc;

% Wirkungsgrad Vortrieb, Reku und Gesamt
eta_LEv = vektor_Pelv ./ (vektor_Pelv+vektor_Pv_ac);
eta_LEr = (vektor_Pelr+vektor_Pv_dc) ./ vektor_Pelr;             % Leistungsfluss von LE zu Bat; da Verluste positiv und Leistung negativ wird Zähler kleiner als Nenner und eta<1 und positiv
eta_LEv(isnan(eta_LEv)==1)=0;                                           % Nan entfernen, die bei Division durch 0 entstanden sind
eta_LEr(isnan(eta_LEr)==1)=0;
eta_LE = eta_LEv + eta_LEr;


end

