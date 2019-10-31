function [vektor_eta, step_M, step_n, vektor_M_max, vektor_M, vektor_n, M_EM_max, n_EM_nenn, m_EM, J_EM] = Interpolieren(M_EM_nenn, n_EM_nenn, M_EM_max, n_EM_max, P_EM_nenn, Choice)

if P_EM_nenn == 0
    vektor_n = (0:n_EM_max/200:n_EM_max)';  % muss für Simulation belegt sein (in embedded matlab function)
    step_n = vektor_n(2)-vektor_n(1);
    vektor_eta = 0;
    step_M = 1;             % wird in Umrechnung als Divisor benötigt; vermeidet somit Division durch 0
    vektor_M_max = 0;
    vektor_M = 0;
    m_EM = 0;
    J_EM = 0;
else
    
    % Kennfelder K1, K2 laden & Leistungen P1, P2 laden
    switch Choice
        case {1}
            Kennfelder_temp = load('KennfelderPSM.mat');
            Kennfelder = Kennfelder_temp.Kennfelder;
            clear Kennfelder_temp
        case {2}
            Kennfelder_temp = load('KennfelderASM.mat');
            Kennfelder = Kennfelder_temp.Kennfelder;
            clear Kennfelder_temp
    end
    
    P_all = Kennfelder(:,4);
    P_all(1) = [];
    P_all = cell2mat(P_all);
    P(1) = max(P_all(P_all<=P_EM_nenn));
    P(2) = min(P_all(P_all>=P_EM_nenn));
    File1 = Kennfelder{find(P_all==P(1))+1,1};
    File2 = Kennfelder{find(P_all==P(2))+1,1};
%     K1 = importdata([cwd filesep 'Angepasst' filesep File1]);
%     K2 = importdata([cwd filesep 'Angepasst' filesep File2]);
    K1 = importdata(File1);
    K2 = importdata(File2);
    clear('P_all', 'File1', 'File2', 'Kennfelder');

    % Interpolieren
    [a b] = size(K1.K);
    vektor_eta = zeros(a,b);
    for i = 1:a
        for j = 1:b
            if K1.K(i,j)*K2.K(i,j)>0
                vektor_eta(i,j) = interp1([P(1) P(2)],...
                    [K1.K(i,j) K2.K(i,j)],P_EM_nenn);
            end
        end
    end
    M_s = K1.Stuetzstellen.M_s;
    n_s = K1.Stuetzstellen.n_s;
    clear('i', 'j')

    % Gradient berechnen und Kennfeld erweitern
    % in M-Richtung
    [~, col] = find(vektor_eta>0);
    c = max(col);
    for j = 1:c
        m_1 = find(vektor_eta(:,j)>0,1,'first');
        m_2 = find(vektor_eta(:,j)>0,1,'last');
        if isempty(m_1)
        else
            for i = 1:a/2
                if and(and(K1.K(i,j)~=0, vektor_eta(i,j)==0), K2.K(202-i,j)==0)
                    vektor_eta(i,j) = max(vektor_eta(m_1,j) + K1.K(i,j) - K1.K(m_1,j), 0);
                elseif and(and(K2.K(i,j)~=0, vektor_eta(i,j)==0), K1.K(202-i,j)==0)
                    vektor_eta(i,j) = max(vektor_eta(m_1,j) + K2.K(i,j) - K2.K(m_1,j), 0);
                end
            end
            for i = ceil(a/2):a
                if and(K1.K(i,j)~=0, vektor_eta(i,j)==0)
                    vektor_eta(i,j) = max(vektor_eta(m_2,j) + K1.K(i,j) - K1.K(m_2,j), 0);
                elseif and(K2.K(i,j)~=0, vektor_eta(i,j)==0)
                    vektor_eta(i,j) = max(vektor_eta(m_2,j) + K2.K(i,j) - K2.K(m_2,j), 0);
                end
            end
        end
    end
    % in n-Richtung
    for i = 1:a
        for j = c+1:b
            if and(K1.K(i,j)~=0, vektor_eta(i,c)~=0)
                vektor_eta(i,j) = max(vektor_eta(i,c) + K1.K(i,j) - K1.K(i,c), 0);
            elseif and(K2.K(i,j)~=0, vektor_eta(i,c)~=0)
                vektor_eta(i,j) = max(vektor_eta(i,c) + K2.K(i,j) - K2.K(i,c), 0);
            end
        end
    end
    clear('K1', 'K2', 'P', 'a', 'b', 'c', 'col', 'i', 'j', 'm_1', 'm_2');


    % Auf 201x201 Form bringen
    vektor_M = (-M_EM_max/M_EM_nenn:M_EM_max/M_EM_nenn/100:M_EM_max/M_EM_nenn)';
    vektor_n = (0:n_EM_max/n_EM_nenn/200:n_EM_max/n_EM_nenn)';
    vektor_eta = MnInterpol(vektor_M, vektor_n, M_s, n_s, vektor_eta);
    clear('M_s', 'n_s');

    % in M-Richtung
    vektor_eta = Erw(vektor_eta, vektor_M, vektor_n, Choice, 'M');
    % in n-Richtung
    vektor_eta = Erw(vektor_eta, vektor_M, vektor_n, Choice, 'n');
    % in M0-Richtung
    vektor_eta = Erw(vektor_eta, vektor_M, vektor_n, Choice, 'M0');
    % in n0-Richtung
    vektor_eta = Erw(vektor_eta, vektor_M, vektor_n, Choice, 'n0');

    % Normierung aufheben
    vektor_M = vektor_M*M_EM_nenn;
    vektor_n = vektor_n*n_EM_nenn;

    %Leistung an Grenzkurve prüfen
    %P = P_anpassung(M_EM_nenn, n_EM_nenn, vektor_eta, vektor_M, vektor_n)/P_EM_nenn;

    % Schrittweiten und Vektor maximalen Moments bestimmen
    step_M = vektor_M(2)-vektor_M(1);
    step_n = vektor_n(2)-vektor_n(1);
    vektor_M_max = zeros(1,201);
    for i = 1:201
        vektor_M_max(i) = floor(min(M_EM_nenn*n_EM_nenn/vektor_n(i), M_EM_max)*100) /100; % M_max wird auf 2. Stelle (deswegen *100 und /100) hinter Komma abgerundet, wegen numerichser Ungenauigkeiten in Sim
    end
    clear('M_max', 'i');

    % WGK in Vektorform bringen
    v = zeros(201*201,1);
    v(1:201) = vektor_eta(:,1);
    for i = 2:201
        v((i-1)*201+1:i*201) = vektor_eta(:,i);
    end
    vektor_eta = v;
    vektor_eta(vektor_eta<0.01&vektor_eta~=0) = 0.01;
    %clear('i', 'v', 'Choice', 'M_EM_max', 'M_EM_nenn', 'n_EM_nenn', 'n_EM_max', 'P_EM_nenn');

    % Masse und Trägheit
    if Choice == 1 % PSM
        m_EM = (max(18.093*log(P_EM_nenn/1000)-27.285, 14) + max(16.935*log(M_EM_nenn)-37.531, 14)) / 2;
        J_EM = max(0.0006*M_EM_nenn-0.0153, 0.001);
    else % ASM
        m_EM = (max(30.463*log(P_EM_nenn/1000)-37.225, 34) + max(33.331*log(M_EM_nenn)-85.079, 34)) / 2;
        J_EM = max(0.0007*M_EM_nenn-0.0226, 0.001);
    end

end

end

