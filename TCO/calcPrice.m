function Param = calcPrice(Param, varargin)
% Die Funktion calcPrice iteriert �ber alle Objekte einer Param und
% erzeugt f�r jedes Objekt die Klasse Anschaffungspreis
% Zusa�tzlich werden Toll_rate und Taxes berechnet

if nargin == 1
    helpStruct = load('costStruct.mat');
    costStruct = helpStruct.costStruct;
else
    costStruct = varargin{1};
end

% F�r Optimierung, Fixer Steuersatz EURO VI
SSK = 6;
% Maut
Param.TCO.Toll_rate = Maut(SSK, costStruct);
if Param.Electric_Truck
    Param.TCO.Toll_rate = 0;
end
% Taxes
Param.TCO.Taxes = Steuer(SSK, 1+Param.TCO_Trailer);

% Infrastucture Paper Wolff
% Param.TCO.Toll_rate = 0;
% Param.TCO.Taxes = 0;

for k = 1:(1+Param.TCO_Trailer)%size(Param,2)
    %         % Anschaffungspreis initialisieren (class Constructor)
    %         Param.Anschaffungspreis = ...
    %             Anschaffungspreis(Param, costStruct.costFunction, k);
    
    if k==1% Purchase_price f�r SZM in Klasse TCO �bertragen
        Param.TCO.Purchase_price(1,k) = round(Param. ...
            acquisitionCosts.KA_ZM,0);
        % Reifenpreis in Klasse TCO �bertragen
        % Fixer Reifenpreis f�r Optimierer Preis f�r Michelin X-Line Energy
        % laut "g�terverkehr", Ausgabe: April 2014, MAN TGX 18.480 XXL Euro 6
        Param.TCO.Tire_costs_set(1,k) = ...
            450 * 6;
        % Insurance
        % Insurance f�r SZM
        Param.TCO.Insurance_vehicle(1,k) = ...
            costStruct.TCO.Insurance{2,1};
        % k Zugmaschine in Composition
        Param.TCO.Anschaffungspreis_Akkupack(1,k) = max((Param.acquisitionCosts.Bat - Param.acquisitionCosts.Bat_ZK) ...
            * Param.acquisitionCosts.Overhead_costs * Param.acquisitionCosts.OEM_Rendite * Param.acquisitionCosts.Haendlermarge, 0);
    end
    if k ==2
        %Param.TCO.Purchase_price(1,k)= 29172;                   % SZM
        Param.TCO.Purchase_price(1,k)= 59191;                    % Optimum concept
        %Param.TCO.Tire_costs_set(1,2) = 6*450;          % SZM
        Param.TCO.Tire_costs_set(1,2) = 8*626;           % Optimum Concept
        Param.TCO.Insurance_vehicle(1,k) = ...
            costStruct.TCO.Insurance{6,1};
%         Param.TCO.Anschaffungspreis_Akkupack(1,k) = 0;
        Param.TCO.residualValueBattery(1,k) = 0;
    end
end
end