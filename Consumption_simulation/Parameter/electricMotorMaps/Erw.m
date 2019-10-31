function vektor_eta = Erw(vektor_eta, vektor_M, vektor_n, Choice, Ri)
% Kennfelderweiterung

    function Koeff = etafit(daten)
        options = fitoptions('Method','LinearLeastSquares','Weights', (1:9/(length(daten(:,2))-1):10));
        [cfun] = fit(daten(:,1),daten(:,2),'poly2',options);
        % Koeffizienten speichern
        Koeff(1,1) = cfun.p1;
        Koeff(1,2) = cfun.p2;
        Koeff(1,3) = cfun.p3;
    end


% alle Stellen mit WGK Eintrag finden
[a(:,1) a(:,2)]= find(vektor_eta);
z(1) = min(a(:,1)); % erste Zeile mit Wert
z(2) = max(a(:,1)); % letzte Zeile mit Wert
b(1) = min(a(:,2)); % erste Spalte mit Wert
c = max(a(:,2));    %letzte Spalte mit Wert
b(2) = find(vektor_eta(z(1),:),1,'last'); %Spalte in der ersten besetzten Zeile, ab der Drehmoment abfällt
b(3) = find(vektor_eta(z(2),:),1,'last'); %Spalte in der letzten besetzten Zeile, ab der Drehmoment abfällt

if strcmp(Ri,'M')
    if vektor_eta(1,2)~=0 && vektor_eta(201,2)~=0  %bedeutet: in erster Spalte und erster und letzter Zeile sind Werte, dann keine Erweiterung in M-Richtung nötig (Symmetrischer Fall +M und -M)
    else
        % Kennfelderweiterung in Richtung größerem Drehmoment (Voraussetzung:
        % symmetrisches Kennfeld)
        for M = -1:2:1
            clear('d', 'e', 'f', 'g', 'h', 'j', 'k', 'K', 'l');
            for i = b(1):b(2)
                % daten_vektor bestimmen für +M oder -M
                d(:,1) = vektor_M*M;
                d(:,2) = vektor_eta(:,i);
                d(d(:,1)<0,:) = [];
                if M>0
                    d = flipud(d);
                end
                % Wieviele Stellen müssen befüllt werden (Stellen mit Nullen)
                e = find(d(:,2),1,'first')-1;
                % Nullen löschen
                d(d(:,2)==0,:)=[];
                % Vektor bis zum maximalen Wirkungsgrad erstellen jedoch nicht mehr
                % wie 50 Werte (TP 20 Werte)
                
                f = d(1,:);
                j = 1;
                while and(f(j,2) < d(1+j,2), and(j<length(d),j<20))
                    j = j+1;
                    f(j,:) = d(j,:);
                end
                % Vektor umdrehen, da Erweiterung nach unten (Gewichtungsfaktoren!)
                f = flipud(f);
                if length(f(:,2))>=3
                    % Koeffizienten bestimmen und WGK auffüllen
                    K = etafit(f);
                    for k = 1:e
                        j = (1+M)*101-k*M;
                        g = K(1)*(vektor_M(j))^2+K(2)*(vektor_M(j)*M)+K(3);
                        %if and(g<1, abs(vektor_M(j)*vektor_n(i))<=1.1)
                        vektor_eta(j,i) = g;
                        %end
                    end
                else
                    for k = 1:e
                        j = (1+M)*101-(e-k+1)*M;
                        g = vektor_eta(j-M,i) + vektor_eta(j,i-1) - vektor_eta(j-M,i-1);
                        if and(g<1, abs(vektor_M(j)*vektor_n(i))<=1.1)
                            vektor_eta(j,i) = g;
                        end
                    end
                end
                clear('d', 'e', 'f', 'g', 'h', 'j', 'k', 'K', 'l');
            end
        end
    end
elseif strcmp(Ri,'n')
    % Kennfelderweiterung in Richtung höherer Drehzahlen
    %     if strcmp(Choice,'PSM')
    if Choice == 1
        % für PSM
        for n = -1:2:1
            clear('d', 'e', 'f', 'g', 'h', 'j', 'k', 'K', 'l');
            for i = 1:100
                % daten_vektor bestimmen
                d(:,1) = vektor_n;
                d(:,2) = vektor_eta(101+i*n,:)';
                e = find(vektor_eta(101+i*n,:),1,'last');
                if isempty(e)
                else
                    % Nullen löschen
                    d(d(:,2)==0,:)=[];
                    d = flipud(d);
                    % Vektor bis zum maximalen Wirkungsgrad erstellen jedoch nicht mehr
                    % wie 50 Werte (TP 20)
                    f = d(1,:);
                    j = 1;
                    %while and(f(j,2) < d(1+j,2), and(j<length(d),j<20))
                    while and(j<length(d),j<20) %TP
                        j = j+1;
                        f(j,:) = d(j,:);
                    end
                    % Vektor umdrehen, da Erweiterung nach unten (Gewichtungsfaktoren!)
                    f = flipud(f);
                    if length(f(:,2))>=5
                        % Koeffizienten bestimmen und WGK auffüllen
                        K = etafit(f);
                        for j = e+1:201
                            g = K(1)*(vektor_n(j))^2+K(2)*(vektor_n(j))+K(3);
                            if and(g<1, abs(vektor_M(101+i*n)*vektor_n(j))<=1.05) %TP Änderung auf Faktor 1.05 (vorher 1.1)
                                if g>vektor_eta(101+i*n,j-1)
                                    vektor_eta(101+i*n,j) = 2*vektor_eta(101+i*n,j-1)-vektor_eta(101+i*n,j-1);
                                else
                                    vektor_eta(101+i*n,j) = g;
                                end
                            end
                        end
                    end
                end
                clear('d', 'e', 'f', 'g', 'h', 'j', 'k', 'K', 'l');
            end
        end
    elseif Choice == 2
        % für ASM
        for n = -1:2:1
            for i = 1:100
                f = zeros(40,2);
                % Datenvektor bestimmen
                d(:,1) = vektor_n;
                d(:,2) = vektor_eta(101+n*i,:);
                % Wieviele Stellen müssen befüllt werden (Stellen mit Nullen)
                e = find(d(:,2),1,'last');
                % in welcher Zeile befindet sich das Maximum?
                [~, c] = max(d(:,2));
                if isempty(e)
                    % Wenn c == e, dann steigt Wirkungsgrad noch an
                elseif c == e
                    d(d(:,2)==0,:)=[];
                    f(1,:) = d(end,:);
                    % nur im FSB Werte nehmen
                    for j = 1:b(2)
                        % nicht mehr als 50 Werte (TP 20)
                        if j<21
                            f(j+1,:) = d(end-j,:);
                        end
                    end
                    f = flipud(f);
                    % Koeffizienten bestimmen und Kennfeld füllen
                    K = etafit(f);
                    for j = e+1:201
                        g = K(1)*(vektor_n(j))^2+K(2)*(vektor_n(j))+K(3);
                        if and(g<1, abs(vektor_M(101+i*n)*vektor_n(j))<=1.05)  %TP Änderung auf Faktor 1.05 (vorher 1.1)
                            vektor_eta(101+i*n,j) = g;
                        end
                    end
                    % Wenn c < e, dann fällt Wirkungsgrad bereits wieder
                elseif c < e
                    d(d(:,2)==0,:)=[];
                    for j = 1:(e-c+1)
                        f(j,:) = d(end-j+1,:);
                    end
                    f = flipud(f);
                    if length(f)>=3
                        % Koeffizienten bestimmen und Kennfeld füllen
                        K = etafit(f);
                        for j = e+1:201
                            g = K(1)*(vektor_n(j))^2+K(2)*(vektor_n(j))+K(3);
                            if and(g<1, abs(vektor_M(101+i*n)*vektor_n(j))<=1.05)   %TP Änderung auf Faktor 1.05 (vorher 1.1)
                                vektor_eta(101+i*n,j) = g;
                            end
                        end
                    end
                end
                clear('K', 'd', 'e', 'f', 'g', 'j', 'c')
            end
        end
    end
elseif strcmp(Ri,'M0')
    % Kennfelderweiterung in Richtung 0Nm Drehmoment
    if sum(vektor_eta(100,:)~=0) == 200 %Zeile bei kleinstem Drehmoment voll gefüllt, dann keine Erweiterung in M0 nötig
    else
        for M = -1:2:1
            k = true;
            for i = b(1):201
                % Datenvektor bestimmen
                y(:,1) = vektor_M*M;
                y(:,2) = vektor_eta(:,i);
                y(y(:,1)<0,:) = [];
                if M>0
                    y = flipud(y);
                end
                % Wieviele Stellen müssen befüllt werden? -> z
                z = length(y(:,2)) - find(y(:,2),1,'last') - 1;
                y(y(:,2)==0,:)=[];
                x(1,:) = y(length(y(:,2)),:);
                j = 0;
                %Werte bis zum Maximum nehmen jedoch nicht mehr als 6 sonst
                %stimmt Polynom 2. Ordnung nicht mehr
                while and(x(1+j,2)<=y(length(y(:,2))-(j+1),2),j<6)
                    j = j+1;
                    x(j+1,:) = y(length(y(:,2))-j,:);
                end
                x = flipud(x);
                
                if length(x(:,2))>=3
                    K = etafit(x);
                    for j = 1:z
                        g = K(1)*(M*vektor_M(101+j*M))^2+K(2)*(M*vektor_M(101+j*M))+K(3);
                        %                         if g < 1
                        vektor_eta(101+j*M,i) = g;
                        %                         elseif j == z
                        %                             k = false;
                        %                         end
                    end
                end
                %                 if k == false
                %                     clear('x', 'y', 'K', 'j', 'g', 'r', 'z');
                %                     break;
                %                 end
                clear('x', 'y', 'K', 'j', 'g', 'r', 'z');
            end
        end
    end
elseif strcmp(Ri,'n0')
    if sum(vektor_eta(:,2)~=0) == 200   % bedeutet vollbesetze Spalte 2, deswegen keine Erweiterung in n0 nötig
    else
        % Kennfelderweiterung in Richtung 0U/min Drehzahl
        zeile_beginn = find(vektor_eta(:,2)==0,1,'first'); %erste Zeile in Spalte 2 (bei Erweiterung n0, alles andere schon befüllt) mit Eintrag 0
        zeile_ende = find(vektor_eta(:,2)==0,1,'last');
        for i = zeile_beginn:zeile_ende
            % nur weitermachen wenn in erster Spalte mit mindestens einem Wert bei
            % aktueller Drehmomentstützstelle auch ein Wert ~= 0 vorliegt
            %außerdem wird die Drehmomentstützstelle 0 ausgelassen, da eta = Null
            if  i==101
            else
                % Datenvektor bestimmen
                y(:,1) = vektor_n;
                y(:,2) = vektor_eta(i,:);
                % Wieviel Stellen sind zu befüllen?
                z = find(y(:,2)>0,1,'first')-2;
                y(y(:,2)==0,:)=[];
                x = zeros(50,2);
                k = 0;
                j = 0;
                if isempty(y)
                else
                    % Werte bis zum Maximum suchen jedoch nicht mehr als 10
                    while and(j < 10, k==j)
                        j = j+1;
                        x(j,:) = y(j,:);
                        [~, k] = max(x(:,2));
                    end
                end
                x(x(:,2)==0,:)=[];
                x = flipud(x);
                % Wenn nur zwei Stützstellen vorhanden, dann auf Gradient
                % benachbarter Stützstellen zurückgreifen
                if length(x)==2
                    j = z+1;
                    if i==1 %Vermeidung von i-1=0 wenn erste Zeile für g (Z. 263)
                        q=i+1;
                    else
                        q=i-1;
                    end
                    g = vektor_eta(q,j) - vektor_eta(q,j+1) + vektor_eta(i,j+1);
                    while and(j > 1, g<1)
                        vektor_eta(i,j) = g;
                        j = j-1;
                        g = vektor_eta(q,j) - vektor_eta(q,j+1) + vektor_eta(i,j+1);
                    end
                elseif isempty(x)
                elseif length(x)>2
                    K = etafit(x);
                    for j = 1:z
                        g = K(1)*(vektor_n(j))^2+K(2)*(vektor_n(j))+K(3);
                        vektor_eta(i,j+1) = g;
                    end
                end
                clear('x', 'y', 'z', 'j', 'k', 'K');
            end
        end
    end
end

clear('a', 'b', 'c', 'i', 'f');
end