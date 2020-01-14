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


%% Generationsanzahl und jeweilige Poplationsgröße festlegen; Song2011, S.5
%    cd Verbrauchssimulation;
[ Param ] = VSim_parametrieren();
Param.VSim.Opt = true;

options.popsize = 2;                    % population size
options.maxGen  = 2;                    % max generation

%% Stopping Kriterium

options.impr_ratio = 0.6;               % Minimum Improvement Ratio from gen to next gen
options.stop_crit = 'off';               % On oder Off

%% #Objectives, #Variables, #Constraints, Bounds festlegen; Song2011, S.5 
% 

                options.numObj = 3;                                                       % number of objectives        
                options.numVar = 11;                                                         % number of design variables
                options.numCons = 3;                                                        % number of constraints
                options.vartype =   [1,  2, 2, 2, 1,   2,    2,    2,   1,   2, 2];                              % Variablentyp 1:kontinuierlich 2:diskret
                options.lb =        [10, 1, 0, 0, 2.5, 500,  1000, 10,  0.1, 1, 1];
                options.ub =        [22, 4, 1, 1, 3.5, 2000, 1500, 155, 1,   2, 2];

%% Achsbeschriftung, Plotintervall, Outputintervall festlegen
Param.Opt_groessen = 8;
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
    case 8    
        options.nameObj = {'TCO in €/tkm', 'Transporteffizienz in gCO2/100tkm', 'Elastizität von 60 auf 80 km/h in s'};
end
options.objfun = @Start_Mehrzielopti2015b_objfun_Paper2017;                   % objective function handle
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
%options.useParallel = 'no';             % parallel computation {‘yes’, ‘no’}
options.useParallel = 'yes';             % parallel computation {‘yes’, ‘no’}
options.poolsize = 2;                                           % number of worker processes
%result = nsga2(options);                                       % begin the optimization!
result = nsga2(options, Param);                                 % begin the optimization!
