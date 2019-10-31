function P_nenn = P_anpassung(M_EM_nenn, n_EM_nenn, vektor_eta, vektor_M, vektor_n)

P_nenn = M_EM_nenn*n_EM_nenn;
[row, col] = find(vektor_eta>0);
n(1) = P_nenn/abs(vektor_M(min(row)));
n(2) = P_nenn/abs(vektor_M(max(row)));
j = find(vektor_n>=min(n),1,'first')+1;
for i = j:max(col)
    % erstes und letztes Element in Spalte finden
    n(1) = find(vektor_eta(:,i)>0,1,'first');
    n(2) = find(vektor_eta(:,i)>0,1,'last');
    % Überprüfen ob Leistung zum interpolieren ausreicht
    if abs(vektor_M(n(1))*vektor_n(i))<P_nenn
        P_nenn = abs(vektor_M(n(1))*vektor_n(i));
    end
    if n(1)>1
        if abs(vektor_M(n(1)-1)*vektor_n(i-1))<P_nenn
            P_nenn = abs(vektor_M(n(1)-1)*vektor_n(i-1));
        end
    end
    if abs(vektor_M(n(2))*vektor_n(i))<P_nenn
        P_nenn = abs(vektor_M(n(2))*vektor_n(i));
    end
    if n(2)<201
        if abs(vektor_M(n(2)+1)*vektor_n(i-1))<P_nenn
            P_nenn = abs(vektor_M(n(2)+1)*vektor_n(i-1));
        end
    end
end
clear('row', 'col', 'n', 'j', 'i', 'P_neu');
P_nenn = P_nenn*2*pi/60;
end