%*************************************************************************
% Problem : 'Mehrzieloptimierung2015b'.
%
%
% Reference : [1]   ...

%*************************************************************************

%% Initialization of Simulation Parameters

% create default options structure for parameters used in SMS-EMOA
% options = nsgaopt();
options = SMSEMOA;

% parameterization of VSim
[ Param ] = VSim_parametrieren();
Param.VSim.Opt = true;

options.popsize = 4;                    % population size
options.maxGen  = 2;                    % maximum number of generations
options.maxEval = options.popsize*options.maxGen;
options.nOffspring = 2;                 % Ganzzahliger Teiler von der Popsize



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
                options.ub =        [22, 4, 1, 1, 3.5, 2500, 1200, 1400,10,90,40,40];                   % upper bound
                
                
    case {4,5,6}    %{'Diesel-Hybrid','CNG-Hybrid','LNG-Hybrid'}
                options.numObj = 3;                                                       % number of objectives        
                options.numVar = 27;                                                         % number of design variables
                options.numCons = 3;                                                        % number of constraints
                options.vartype =   [1,  2, 2, 2, 1, 1, 1, 1, 1, 2, 2, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2];                              % Variablentyp 1:kontinuierlich 2:diskret
                options.lb =        [10, 1, 0, 0, 2.5, 1500, 1000, 1250, 5, 1, 1, 1, 500, 1000, 10, 0, 0, 30, 5, 5, 0.01, 1000, 10, 0.1, 0.1 , 1, 1];                   % lower bound
                options.ub =        [22, 4, 1, 1, 3.5, 2500, 1200, 1400, 10, 90, 40, 40, 1500, 1500, 155, 1, 1, 60, 500, 500, 0.05, 10000, 100, 0.5, 1, 2, 2];                   % upper bound

    case 7          % Elektrisch  
            options.numObj = 3;                                                       % number of objectives
            options.numVar = 13;                                                       % number of design variables
            options.numCons = 2;                                                      % number of constraints
            options.vartype =   [1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 1, 1];     
            options.lb = [70, 400, 200, 0.05, 160, 0.5, 0.01, 10, 1, 0, 0, 750, 1200];                % lower bound 
            options.ub = [200, 2000, 800, 0.85, 500, 5, 0.99, 22, 4, 1, 1, 1200, 1750];              % upper bound
            
    case {8,9}      %Dual-Fuel {CNG, LNG}
                options.numObj = 3;                                                       % number of objectives        
                options.numVar = 12;                                                         % number of design variables
                options.numCons = 2;                                                        % number of constraints
                options.vartype =   [1,  2, 2, 2, 1, 1, 1, 1, 1, 2, 2, 2];                              % Variablentyp 1:kontinuierlich 2:diskret
                options.lb =        [10, 1, 0, 0, 2.5, 1500, 1000, 1250,5, 1 ,1 ,1];                   % lower bound
                options.ub =        [22, 4, 1, 1, 3.5, 2500, 1200, 1400,10,90,40,40];                   % upper bound
                
    case {10,11}    %Dual-Fuel Hybrid {CNG, LNG}
              options.numObj = 3;                                                       % number of objectives        
                options.numVar = 27;                                                         % number of design variables
                options.numCons = 3;                                                        % number of constraints
                options.vartype =   [1,  2, 2, 2, 1, 1, 1, 1, 1, 2, 2, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2];                              % Variablentyp 1:kontinuierlich 2:diskret
                options.lb =        [10, 1, 0, 0, 2.5, 1500, 1000, 1250, 5, 1, 1, 1, 500, 1000, 10, 0, 0, 30, 5, 5, 0.01, 1000, 10, 0.1, 0.1, 1, 1];                   % lower bound
                options.ub =        [22, 4, 1, 1, 3.5, 2500, 1200, 1400, 10, 90, 40, 40, 1500, 1500, 155, 1, 1, 60, 500, 500, 0.05, 10000, 100, 0.5,1, 2, 2];         
end


%% Achsbeschriftung, Plotintervall, Outputintervall festlegen

% select objective funtions (eplanation see 'Start_Mehrzielopti2015b_objfun.m')
Param.Opt_groessen = 8;

switch Param.Opt_groessen                                         %Theisen
    case 1
        options.numObj = 2;
        options.nameObj = {'Average_speed in km/h', 'Verbrauch in kWh/100tkm'};  % Song2011, S.3; the objective names are showed in GUI window.
    case 2
        options.numObj = 2;
        options.nameObj = {'Eigenschaftswert', 'Kosten in €/km'};  % Song2011, S.3; the objective names are showed in GUI window.
    case 3
        options.numObj = 2;
        options.nameObj = {'Average_speed in km/h', 'Verbrauch in l/100km'};  % Song2011, S.3; the objective names are showed in GUI window.
    case 4 % Optimierung Wolff
        options.numObj = 2;
        options.nameObj = {'TCO in €/km', 'Transporteffizienz in gCO2/tkm'};  % Song2011, S.3; the objective names are showed in GUI window.
    case 5
        options.numObj = 3;
        options.nameObj = {'TCO in €/km', 'Transporteffizienz in gCO2/tkm', 'Beschleunigung von 0 auf 80 km/h in s'};  % Song2011, S.3; the objective names are showed in GUI window.
    case 6
        options.numObj = 3;
        options.nameObj = {'TCO in €/km', 'Transporteffizienz in gCO2/tkm', 'Elastizität von 60 auf 80 km/h in s'};
    case 7
        options.numObj = 4;
        options.nameObj = {'TCO in €/km', 'Transporteffizienz in gCO2/tkm', 'Beschleunigung von 0 auf 80 km/h in s', 'Elastizität von 60 auf 80 km/h in s'};
    case 8    
         options.numObj = 3;
        options.nameObj = {'TCO in €/100tkm', 'Transporteffizienz in gCO2/tkm', 'Elastizität von 60 auf 80 km/h in s'};
end

Param.numObj = options.numObj;
Param.numCons = options.numCons;




%%  start optimization

% specify optimization settings
options.useOCD = false;
options.OCD_VarLimit      = 0.0001;
options.OCD_nPreGen       = 5;

% create objective function handle for VSim
problem = @Start_Mehrzielopti2015b_objfun;

% use parallel computing in MATLAB
% options.useParallel = 'no';                 % parallel computation {‘yes’, ‘no’}
options.useParallel = 'yes';              % parallel computation {‘yes’, ‘no’}
options.poolsize = 4;                       % number of worker processes

% start optimization
[paretoFront, paretoSet, result] = SMSEMOA(problem, options.lb, options.ub, options, Param);       % begin the optimization!