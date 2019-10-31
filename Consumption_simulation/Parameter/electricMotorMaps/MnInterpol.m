% Kennfeld interpolieren
function K_neu = MnInterpol(drehmoment_neu, drehzahl_neu, drehmoment_alt, drehzahl_alt, WGK)
    % WGK initialisieren
    K_neu = zeros(length(drehmoment_neu),length(drehzahl_alt));
    % Drehmomentvektor halbieren um  nicht über null zu interpolieren
    drehmoment = zeros(length(drehmoment_alt),2);
    for i = 1:length(drehmoment_alt)/2
        drehmoment(i,1) = drehmoment_alt(i);
        drehmoment(end+1-i,2) = drehmoment_alt(end+1-i);
    end
    % Drehmomentstützstellen anpassen
    for j = 1:2
        for i = 1:length(drehzahl_alt)
            eta(:,1) = drehmoment(:,j);
            eta(:,2) = WGK(:,i);
            eta(eta(:,2)==0,:)=[];
            eta(eta(:,1)==0,:)=[];
            if isempty(eta)
                eta = [-1 0; 1 0];
            end
            eta_new = interp1(eta(:,1), eta(:,2), drehmoment_neu);
            eta_new(isnan(eta_new)) = 0;
            K_neu(:,i) = K_neu(:,i) + eta_new;
            clear('eta');
        end
    end
    WGK = K_neu;
    WGK(isnan(WGK)) = 0;
    % Drehzahlstützstellen anpassen
    K_neu = zeros(length(drehmoment_neu),length(drehzahl_neu));
    for i = 1:length(drehmoment_neu)
        eta(:,1) = drehzahl_alt;
        eta(:,2) = WGK(i,:)';
        eta(eta(:,2)==0,:)=[];
        eta = [0 0; eta];
        if length(eta(:,1)) <= 1
            K_neu(i,:) = 0;
        else
            K_neu(i,:) = interp1(eta(:,1), eta(:,2), drehzahl_neu);
        end
        clear('eta');
    end
    clear('i');
    K_neu(isnan(K_neu)) = 0; 

    K_neu(K_neu<0.01&K_neu~=0) = 0.01;
end

