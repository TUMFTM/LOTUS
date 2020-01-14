%*************************************************************************
% Problem : 'Mehrzieloptimierung2015b'.
% 
%
% Reference : [1] Deb K, Pratap A, Agarwal S, et al. A fast and elitist 
%   multiobjective genetic algorithm NSGA-II[J]. Evolutionary Computation. 
%   2002, 6(2): 182-197.
%*************************************************************************

%% Standardeinstellungen werden erzeugt

options = nsgaopt();                    % create default options structure

%% Standard settings for Vehicle Design
%  Fuel type
%     Fueltype = 1;     % Diesel
%     Fueltype = 2;     % CNG
%     Fueltype = 3;     % LNG
    Fueltype = 4;     % Diesel Hybrid
%     Fueltype = 5;     % CNG Hybrid
%     Fueltype = 6;     % LNG Hybrid
%     Fueltype = 7;     % Electric
%     Fueltype = 8;     % Diesel & CNG
%     Fueltype = 9;     % Diesel & LNG    
%     Fueltype = 10;    % Diesel & CNG Hybrid
%     Fueltype = 11;    % Diesel & LNG Hybrid
%     Fueltype = 12;    % Electric w/WPT
%     Fueltype = 13;    % Hydrogen fuel cell

[ Param ] = Parameterizing(Fueltype, 1, 1, 'empty', false); % Parameterizing creates the parameters and Param array

Param.VSim.Opt = true;

% Driving cycles
%     Param.dcycle = 1;             % ACEA cycle
%      Param.dcycle = 2;             % Truckerrunde
%     Param.dcycle = 3;             % Long_Haul
%     Param.dcycle = 4;             % Uphill climb
%     Param.dcycle = 5;             % Startup
%     Param.dcycle = 6;             % Test drive from Neuburg to Paderborn
%     Param.dcycle = 7;             % Test drive on 23-08-2012 Truckerrunde
%     Param.dcycle = 8;             % HERE maps drive from Neuburg to Paderborn
%     Param.dcycle = 9;             % HERE maps and smoothed Truckerrunde
%     Param.dcycle = 10;            % CSHVC cycle
%     Param.dcycle = 11;            % Test drive on 23-08-2012 Truckerrunde from Holledau to Langenbruck
    Param.dcycle = 12;            % Truck2030 for 100km [1]	M. Fries, A. Baum, M. Wittman, und M. Lienkamp, “Derivation of a real-life driving cycle from fleet testing data with the Markov-Chain-Monte-Carlo Method,” in IEEE ITSC 2018: 21st International Conference on Intelligent Transportation Systems : Mielparque Yokohama in Yokohama, Kanagawa, Japan, October 16-19, 2017, Piscataway, NJ: IEEE, 2018.
%     Param.dcycle = 13;            % Truck2030 for 200km [1]	M. Fries, A. Baum, M. Wittman, und M. Lienkamp, “Derivation of a real-life driving cycle from fleet testing data with the Markov-Chain-Monte-Carlo Method,” in IEEE ITSC 2018: 21st International Conference on Intelligent Transportation Systems : Mielparque Yokohama in Yokohama, Kanagawa, Japan, October 16-19, 2017, Piscataway, NJ: IEEE, 2018.
%     Param.dcycle = 14;            % Stationary cycle LVK
%     Param.dcycle = 15;            % Cycle for 30, 50, 60, 80 km/h
%     Param.dcycle = 16;            % Full cycle between Sorriso and Santos

%% Generationsanzahl und jeweilige Poplationsgröße festlegen; Song2011, S.5

% options.popsize = 512;                    % population size
% options.maxGen  = 192;                    % max generation
options.popsize = 4;                    % population size
options.maxGen  = 4;                    % max generation

Param.Opt_groessen = 8;  % Opti Fries
% Param.Opt_groessen = 11;   % 11 ist wie 8, nur mit Abfangen von negativer Nutzlast bei Elektro LKW

%% Stopping Kriterium

options.impr_ratio = 0.6;               % Minimum Improvement Ratio from gen to next gen
options.stop_crit = 'off';               % On oder Off

%% #Objectives, #Variables, #Constraints, Bounds festlegen; Song2011, S.5 
% 
% 
switch Param.Fueltype
    case {1,2,3}    %{'Diesel','CNG','LNG'}
                options.numObj = 3;                                                       % number of objectives        
                options.numVar = 12;                                                         % number of design variables
                options.numCons = 2;                                                        % number of constraints
                options.vartype =   [1,  2, 2, 2, 1, 1, 1, 1, 1, 2, 2, 2];                              % Variablentyp 1:kontinuierlich 2:diskret
                options.lb =        [10, 1, 0, 0, 2.5, 1500, 1000, 1250,5,1,1,1];                   % lower bound
                options.ub =        [22, 4, 1, 1, 2.9, 2500, 1200, 1400,10,90,40,40];                   % upper bound
                
                
    case {4,5,6}    %{'Diesel-Hybrid','CNG-Hybrid','LNG-Hybrid'}
                options.numObj = 3;                                                       % number of objectives        
                options.numVar = 28;                                                         % number of design variables
                options.numCons = 3;                                                        % number of constraints
                options.vartype =   [1,  2, 2, 2, 1,   1,    1,    1,    1,  2,  2,  2,  1,    1,    1,   1, 1, 2,    1, 1,   1,   1,    1,     1,   1,   1,   2, 2];                              % Variablentyp 1:kontinuierlich 2:diskret
                options.lb =        [10, 4, 0, 0, 2.5, 1500, 1000, 1250, 5,  1,  1,  1,  500,  1000, 10,  0, 0, 0,    0, 5,   5,   0.01, 1000,  10,  0.1, 0.1, 1, 1];                   % lower bound
                options.ub =        [22, 8, 1, 1, 2.9, 2500, 1200, 1400, 10, 90, 40, 40, 2000, 1500, 155, 1, 1, 2000, 1, 500, 500, 0.05, 10000, 100, 0.5, 1,   2, 2];                   % upper bound

    case {7}         % Elektrisch
                options.numObj =  3;                                                      % number of objectives
                options.numVar =  13;                                                     % number of design variables
                options.numCons = 6;                                                      % number of constraints

                options.vartype =   [2,    2,  1,    2,     1,   1,  2, 2, 2, 2,    2,    2, 2];
                options.lb =        [500,  1,  0.5,  700,   0.5, 1,  1, 0, 0, 750,  1200, 1, 1];               % lower bound
                options.ub =        [2000, 41, 1,    2000,  25,  22, 8, 1, 1, 1200, 1750, 2, 2];               % upper bound

    case {8,9}      %Dual-Fuel {CNG, LNG}
                options.numObj = 3;                                                       % number of objectives        
                options.numVar = 12;                                                         % number of design variables
                options.numCons = 3;                                                        % number of constraints
                options.vartype =   [1,  2, 2, 2, 1, 1, 1, 1, 1, 2, 2, 2];                              % Variablentyp 1:kontinuierlich 2:diskret
                options.lb =        [10, 1, 0, 0, 2.5, 1500, 1000, 1250,5, 1 ,1 ,1];                   % lower bound
                options.ub =        [22, 4, 1, 1, 2.9, 2500, 1200, 1400,10,90,40,40];                   % upper bound
                
    case {10,11}    %Dual-Fuel Hybrid {CNG, LNG}
              options.numObj = 3;                                                       % number of objectives        
                options.numVar = 27;                                                         % number of design variables
                options.numCons = 3;                                                        % number of constraints
                options.vartype =   [1,  2, 2, 2, 1, 1, 1, 1, 1, 2, 2, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2];                              % Variablentyp 1:kontinuierlich 2:diskret
                options.lb =        [10, 1, 0, 0, 2.5, 1500, 1000, 1250, 5, 1, 1, 1, 500, 1000, 10, 0, 0, 30, 5, 5, 0.01, 1000, 10, 0.1, 0.1, 1, 1];                   % lower bound
                options.ub =        [22, 4, 1, 1, 2.9, 2500, 1200, 1400, 10, 90, 40, 40, 2000, 1500, 155, 1, 1, 60, 500, 500, 0.05, 10000, 100, 0.5,1, 2, 2];         
    
    case {12}         % Elektrisch
                options.numObj =  3;                                                      % number of objectives
                options.numVar =  15;                                                     % number of design variables
                options.numCons = 6;                                                      % number of constraints

                options.vartype =   [2,    2,  1,    2,     1,   1,  2, 2, 2, 2,    2,    2, 2, 1, 1];
                options.lb =        [500,  1,  0.5,  700,   0.5, 1,  1, 0, 0, 750,  1200, 1, 1, 0, 0];               % lower bound
                options.ub =        [2000, 41, 1,    2000,  25,  22, 8, 1, 1, 1200, 1750, 2, 2, 1, 1];               % upper bound
end



%% Achsbeschriftung, Plotintervall, Outputintervall festlegen

switch Param.Opt_groessen                                         %Theisen
    case 1
        options.nameObj = {'Average_speed in km/h', 'Verbrauch in kWh/100tkm'};  % Song2011, S.3; the objective names are showed in GUI window.
    case 2
        options.nameObj = {'Eigenschaftswert', 'Kosten in €/km'};  % Song2011, S.3; the objective names are showed in GUI window.
    case 3
        options.nameObj = {'Average_speed in km/h', 'Verbrauch in l/100km'};  % Song2011, S.3; the objective names are showed in GUI window.
    case 4 % Optimierung Wolff
        options.nameObj = {'TCO in €/km', 'Transporteffizienz in gCO2/tkm'};  % Song2011, S.3; the objective names are showed in GUI window.
    case 5    
        options.nameObj = {'TCO in €/km', 'Transporteffizienz in gCO2/tkm', 'Beschleunigung von 0 auf 80 km/h in s'};  % Song2011, S.3; the objective names are showed in GUI window.
    case 6    
        options.nameObj = {'TCO in €/km', 'Transporteffizienz in gCO2/tkm', 'Elastizität von 60 auf 80 km/h in s'};
    case 7    
        options.nameObj = {'TCO in €/km', 'Transporteffizienz in gCO2/tkm', 'Beschleunigung von 0 auf 80 km/h in s', 'Elastizität von 60 auf 80 km/h in s'};
    case {8, 11}    
        options.nameObj = {'TCO in €/100tkm', 'Transporteffizienz in gCO2/tkm', 'Elastizität von 60 auf 80 km/h in s'};
    case 9    
        options.nameObj = {'TCO in €/100tkm', 'Transporteffizienz in gCO2/tkm', 'Average_speed in km/h'};
    case 10    
        options.nameObj = {'TCO in €/100tkm', 'Transporteffizienz in gCO2/tkm', 'RMSE Soll-Geschwindigkeit in km/h'};
end




options.objfun = @Start_Mehrzielopti2015b_objfun;                   % objective function handle
options.plotInterval = 1;                                           % Song2011, S. 11 interval between two calls of "plotnsga".
options.outputInterval = 1;                                        % Song2011, S. 9


%% Möglichkeit, die Population individuell zu initialisierien; Song2011, S. 6-7

%options.initfun={@initpop, strFileName, ngen}      % Restart from exist population file
%options.initfun={@initpop, oldresult, ngen}        % Restart from exist optimization result


%% Cossover-Optionen; Song2011, S. 7

%options.crossoverFraction = 0-1                     % Legt den Anteil der nächsten Generation fest, der durch Crossover produziert wird. Die restlichen Individuen der Folgegeneration werden durch Mutation produziert. Der Crossoveranteil muss zwischen 0 und 1 liegen
%options.crossover={'intermediate', ratio}           % ratio = “Verhältnis / Anteil”: child1 = parent1+rand*Ratio*(parent2 - parent1) 


%% Mutation - Optionen; Song2011, S. 8

%options.mutaionFraction = 1 - options.crossoverFraction     % Legt den Anteil der nächsten Generation fest, der durch Mutation produziert wird. Die restlichen Individuen der Folgegeneration werden durch Crossover produziert. Der Mutationsanteil muss zwischen 0 und 1 liegen
%options.mutation = {'gaussian', scale, shrink}              % scale = "Ausmaß-Parameter”);legt die Abweichung bei der ersten Generation fest.
                                                            % shrink = “Schrumpf-Parameter”); kontrolliert die Schrumpfung der Standardabweichung bei voranschreitenden Generationen
%% Mehrere Kerne aktivieren; Song2011, S. 11

Param.numObj = options.numObj;
Param.numCons = options.numCons;
options.useParallel = 'no';             % parallel computation {‘yes’, ‘no’}
% options.useParallel = 'yes';             % parallel computation {‘yes’, ‘no’}
% options.poolsize = 32;                                           % number of worker processes
options.poolsize = 4;
%result = nsga2(options);                                       % begin the optimization!
result = nsga2(options, Param);                                 % begin the optimization!
