function [ Steuer ] = Steuer( SSK, TCO_Trailer)
%Steuer( SSK ) berechnet die KFZ-Steuer abhängig vom zulässigen
%Gesamtgewicht (zGG) und der Schadstoffklasse (SSK).
%   Die Steuer wird berechnet anhand der Steuersätze nach §9 Absatz 1 Nr 3,
%   4  und 5 Kraftsteuergesetz (KraftStG)

% globale Variablen: Composition enthält die Objekte des Lastzuges, c_obj
% die Zahl der Objekte in Composition
%global Composition;

c_obj = TCO_Trailer;
Steuer = zeros(1,1);
zGG = 40;

% Besteuerung Kraftfahrzeuge mit einem zGG bis 3500 Kg  
% §9 Absatz 1 Nr 3
if(zGG <= 3.5) % zGG bis 3.5t
    for m = 0.2:0.2:(zGG+0.199) % Steuer berechnet sich in 200kg Schritten
        if(m <= 2)
            Steuer = Steuer + 11.25;
        elseif(m > 2.00001 && m <= 3.00001)
            Steuer = Steuer + 12.02;
        elseif(m > 3.00001)
            Steuer = Steuer + 12.78;
        end
    end
% Besteuerung Kraftfahrzeuge mit einem zGG von mehr als 3500 Kg
% §9 Absatz 1 Nr 4 Buchstabe a    
elseif(zGG > 3.5 && SSK > 1) % zGG ab 3.5t und Schadstoffklasse besser als S1
    for m = 0.2:0.2:(zGG+0.199) % Steuer berechnet sich in 200kg Schritten
        if(m <= 2)
            Steuer = Steuer + 6.42;
        elseif(m > 2.00001 && m <= 3.00001)
            Steuer = Steuer + 6.88;
        elseif(m > 3.00001 && m <= 4.00001)
            Steuer = Steuer + 7.31;
        elseif(m > 4.00001 && m <= 5.00001)
            Steuer = Steuer + 7.75;
        elseif(m > 5.00001 && m <= 6.00001)
            Steuer = Steuer + 8.18;
        elseif(m > 6.00001 && m <= 7.00001)
            Steuer = Steuer + 8.62;
        elseif(m > 7.00001 && m <= 8.00001)
            Steuer = Steuer + 9.36;
        elseif(m > 8.00001 && m <= 9.00001)
            Steuer = Steuer + 10.07;
        elseif(m > 9.00001 && m <= 10.00001)
            Steuer = Steuer + 10.97;
        elseif(m > 10.00001 && m <= 11.00001)
            Steuer = Steuer + 11.84;
        elseif(m > 11.00001 && m <= 12.00001)
            Steuer = Steuer + 13.01;
        elseif(m > 12.00001)
            Steuer = Steuer + 14.32;
        end
    end
    % Steuerhöchstgrenze 556 Euro
    if(Steuer > 556)
        Steuer = 556.00;
    end
        
end
    
% Besteuerung der Anhänger
% §9 Absatz 1 Nr 5
if(c_obj > 1)
    % Iteration durch alle Anhänger
    for i = 2:c_obj
        AnhSteuer = 0;
        zGG = 24; %Zulässigens Gesamtgewicht Anhänger
        % Steuersatz: 7,46 Euro pro 200Kg zGG
        for m = 0.2:0.2:(zGG+0.199)  % Steuer berechnet sich in 200kg Schritten
            AnhSteuer = AnhSteuer + 7.46;
        end
        % Steuerhöchstgrenze 373,24 Euro
        if(AnhSteuer > 373.24)
            AnhSteuer = 373.24;
        end

        Steuer(1,i) = AnhSteuer;
    end
end

% floor(Steuer);

end

