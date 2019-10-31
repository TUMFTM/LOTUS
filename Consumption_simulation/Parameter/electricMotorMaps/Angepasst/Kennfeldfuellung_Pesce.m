

[a(:,1) a(:,2)]= find(K); % alle Zeilen und Spalten mit Einträgen

spalte_1 = min(a(:,2)); % entspricht erster Spalte mit Werten in K

zeile_beginn = find(K(1:100, spalte_1),1,'first'); % entspricht erster Zeile der ersten Spalte mit Wert
zeile_ende = find(K(1:100, spalte_1),1,'last'); % entspricht letzter Zeile der ersten Spalte mit Wert

matrix=K;
if spalte_1 > 1
    for zeile=zeile_beginn:zeile_ende %Alle Zeilen der ersten Spalte werden durchlaufen

            eta_neu = interp1([1 spalte_1], [0 K(zeile,spalte_1)], [1:spalte_1]);
            matrix(zeile, 1:spalte_1)=eta_neu;
            matrix((202-zeile), 1:spalte_1)=eta_neu;
    end
end


zeile_1 = min(a(:,1)); % entspricht erster Zeile mit Werten in K
spalte_beginn = find(matrix(zeile_1, :),1,'first'); % erste Spalte mit Wert erster Zeile

if (spalte_beginn-1)>1
    for spalte=2:(spalte_beginn-1)
        zeile = find(matrix(:,spalte),1,'first');
        
        eta_zwei = interp1([1 (zeile-zeile_1+2)], [0 matrix(zeile,spalte)], [1:(zeile-zeile_1+2)]);
        matrix(zeile_1:zeile, spalte)=eta_zwei(2:end)';
        eta_zwei=flipud(eta_zwei');
        matrix((202-zeile):(202-zeile_1-1+2), spalte)=eta_zwei';
    end
end

matrix(matrix<0.01&matrix~=0)=0.01;
K=matrix;
clear ('a')