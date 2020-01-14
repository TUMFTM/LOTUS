function [paretoFront, ...   % objectives
    paretoSet, result]... % parameters
    = SMSEMOA(...
    problem, ...             % function handle to the objective function
    rngMin, ...              % lower bound of decision variables
    rngMax, ...              % upper bound of decision variables
    inopts, ...              % struct with options (optional)
    Param, ...               % struct with problem specific parameters
    initPop)                 % initial population (optional)
% smsemoa.m, Version 1.0, last change: August, 14, 2008
% SMS-EMOA implements the S-Metric-Section-based Evolutionary
% Multi-Objective Algorithm for nonlinear vector minimization.
%
% OPTS = SMSEMOA returns default options.
% OPTS = SMSEMOA('defaults') returns default options quietly.
% OPTS = SMSEMOA('displayoptions') displays options.
% OPTS = SMSEMOA('defaults', OPTS) supplements options OPTS with default
% options.
%
% function call:
% [PARETOFRONT, PARETOSET] = SMSEMOA(PROBLEM[, OPTS])
%
% Input arguments:
%  PROBLEM is a function handle or a string function name like 'Sympart'.
%  PROBLEM.m takes as argument a row vector of parameters and returns
%  a row vector of objectives
%  OPTS (an optional argument) is a struct holding additional input
%     options. Valid field names and a short documentation can be
%     discovered by looking at the default options (type 'smsemoa'
%     without arguments, see above). Empty or missing fields in OPTS
%     invoke the default value, i.e. OPTS needs not to have all valid
%     field names.  Capitalization does not matter and unambiguous
%     abbreviations can be used for the field names. If a string is
%     given where a numerical value is needed, the string is evaluated
%     by eval, where
%     'numVar' expands to the problem dimension
%     'nObj' expands to the objectives dimension
%     'nPop' expands to the population size
%     'countEval' expands to the number of the recent evaluation
%     'nPV' expands to the number paretofronts
%
% Output:
%  PARETOFRONT is a struct holding the objectives in rows. Each row holds
%     the results of the objective function of one solution
%  PARETOSET is a struct holding the parameters. Each row holds one
%     solution.
%
% This software is Copyright (C) 2008
% Tobias Wagner, Fabian Kretzschmar
% ISF, TU Dortmund
% February 3, 2016
%
% This program is free software (software libre); you can redistribute it
% and/or modify it under the terms of the GNU General Public License as
% published by the Free Software Foundation; either version 2 of the
% License, or (at your option) any later version.
%
% This program is distributed in the hope that it will be useful, but
% WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
% Public License for more details.
%
% implementation based on [1][2] using
% *  Computation of the Hypervolume Indicator based on [3]
%    http://sbe.napier.ac.uk/~manuel/hypervolume
% *  Pareto Front Algorithms
%    http://www.mathworks.com/matlabcentral/fileexchange/loadFile.do?object
%    Id=17251&objectType=file
% *  coding-fragments from NSGA - II
%    http://www.mathworks.com/matlabcentral/fileexchange/loadFile.do?object
%    Id=10429&objectType=file
%
% [1] Michael Emmerich, Nicola Beume, and Boris Naujoks. An EMO algorithm
% using the hypervolume measure as selection criterion. In C. A. Coello
% Coello et al., Eds., Proc. Evolutionary Multi-Criterion Optimization,
% 3rd Int'l Conf. (EMO 2005), LNCS 3410, pp. 62-76. Springer, Berlin, 2005.
%
% [2] Boris Naujoks, Nicola Beume, and Michael Emmerich. Multi-objective
% optimisation using S-metric selection: Application to three-dimensional
% solution spaces. In B. McKay et al., Eds., Proc. of the 2005 Congress on
% Evolutionary Computation (CEC 2005), Edinburgh, Band 2, pp. 1282-1289.
% IEEE Press, Piscataway NJ, 2005.
%
% [3] Carlos M. Fonseca, Luís Paquete, and Manuel López-Ibáñez. An improved
% dimension-sweep algorithm for the hypervolume indicator.  In IEEE
% Congress on Evolutionary Computation, pages 3973-3979, Vancouver, Canada,
% July 2006.

% ----------- Set Defaults for Options ---------------------------------
% options: general - these are evaluated once
defopts.popsize           = '100           % size of the population';
defopts.maxEval           = 'inf           % maximum number of evaluations';
defopts.useOCD            = 'true          % use OCD to detect convergence';
defopts.OCD_VarLimit      = '1e-10         % variance limit of OCD';
defopts.OCD_nPreGen       = '15            % number of preceding generations used in OCD';
defopts.nPFevalHV         = 'inf           % evaluate 1st to this number paretoFronts with HV';
defopts.outputGen         = 'inf           % rate of writing output files';
defopts.outputType        = '0             % type of output (0 none, 1 population, 2 archive)';
defopts.vartype           = 'zeros(1, numVar)   % type of design variable 1:continous 2:discrete';

% options: generation of offsprings - these are evaluated each run
defopts.var_crossover_prob= '0.9           % [0.8, 1] % variable crossover probability';
defopts.var_crossover_dist= '15            % distribution index for crossover';
defopts.var_mutation_prob = '1./numVar       % variable mutation probability';
defopts.var_mutation_dist = '20            % distribution index for mutation';
defopts.var_swap_prob     = '0.5           % variable swap probability';
defopts.DE_F              = '0.2+rand(1).*0.6% difference weight for DE';
defopts.DE_CR             = '0.9           % crossover probability for differential evo';
defopts.DE_CombinedCR     = 'true          % crossover of blocks instead of single variables';
defopts.useDE             = 'false         % perform differential evo instead of SBX&PM';
defopts.refPoint          = '0             % refPoint for HV; if 0, max(obj)+1 is used';

defopts.numVar            = 'inf           % number of variables';
defopts.numObj            = 'inf           % number of objectives';
defopts.numCons           = 'inf           % number of constraints';
defopts.maxGen            = 'inf           % maximum number of generations';
defopts.nOffspring        = '1             % number of offsprings per generation';

% options: parallel computing
defopts.useParallel       = 'no            % parallel computing of objective function of a population(yes or no)';
defopts.poolsize          = '2             % number of workers used in parallel computation';
% ---------------------- Handling Input Parameters ----------------------

if nargin < 1 || isequal(problem, 'defaults') % pass default options
    paretoFront = defopts;
    if nargin > 1 % supplement second argument with default options
        paretoFront = getoptions(inopts, defopts);
    end
    return;
end

if isequal(problem, 'displayoptions')
    names = fieldnames(defopts);
    for name = names'
        disp([name{:} repmat(' ', 1, 20-length(name{:})) ': ''' defopts.(name{:}) '''']);
    end
    return;
end

if ~ischar(problem) && ~isa(problem, 'function_handle')
    error('first argument ''problem'' must be a string or a fhandle');
end

if nargin < 3
    error('problem, rngMin, and rngMax are required');
end;

% compose options opts
if nargin < 4 || isempty(inopts) % no input options available
    opts = defopts;
else
    opts = getoptions(inopts, defopts);
end

% initialize init pop param
if nargin < 6
    initPop = '';
end;

% reset the random number generator to a different state each restart
[v, d] = version;
if str2double(d(end-4:end)) > 2011
    rng('default');
    ropt = rng('shuffle');
    seed = ropt.Seed;
else
    d = clock;
    seed = double(ceil(d(end)*1e9));
    rand('seed', seed);
end;

%% initialize auxiliary parameters
numVar = length(rngMin);
% numObj = length(feval(problem, rngMin));  % comment this line reduces number of VSim evaluatiosn by 1
numObj = inopts.numObj;                    
nOffspring = inopts.nOffspring;

% get parameters for initialization
nPop = myeval(opts.popsize);
nPV = ceil((1/(2^(numObj-1)))*nPop); % guess number of Pareto-Ranks
maxEval = myeval(opts.maxEval);
useOCD = myeval(opts.useOCD);
OCD_VarLimit = myeval(opts.OCD_VarLimit);
OCD_nPreGen = myeval(opts.OCD_nPreGen);
nPFevalHV = myeval(opts.nPFevalHV);
outputGen = myeval(opts.outputGen);
outputType = myeval(opts.outputType);

%% calculate initial sampling
ranks = inf(nPop+1,1);
population = initialize_variables(nPop, numObj, numVar, rngMin, rngMax, problem, initPop, opts, Param);
countEval = nPop;
elementsOffspring = nPop+1 : nPop+nOffspring;

% save initial sampling
result.front{1} = population(1:nPop,numVar+1:numVar+numObj);
result.set{1} = population(1:nPop,1:numVar);
% result.population{1} = population(1:nPop,:);

% initialize new Element position
elementInd = nPop+1;

% write output files
if mod(countEval, outputGen)==0 && outputType > 0
    writeToFile(population, nPop, elementInd, numVar, numObj, ranks,...
        countEval, outdir)
end;

% % OCD data structures
% % if useOCD
% PF = cell(OCD_nPreGen,1);
% % PF{1} = population(1:nPop, numVar+1:numVar+numObj);
% PF{1} = result.front{1, 1}(1:nPop, :);
% % result.PFstart = PF{1};
% termCrit = [false false];
% result.OCD.p_chi2(1,1:OCD_nPreGen) = 1;
% result.OCD.p_Reg(1,1:OCD_nPreGen) = 0;
% result.OCD.terminationCrit(1:OCD_nPreGen, :) = false(OCD_nPreGen,2);
% alpha = 0.05;
% % end;

% initialize archive
if outputType == 2
    archive = nan(maxEval, numVar+numObj);
    archive(1:countEval,:) = population(1:countEval,:);
end;

countGen = 2;

%% evolutionary loop
%     while ~terminationCriterion && (countEval < maxEval)
while (countEval < maxEval)
    if mod(countEval, nPop) == 0
        fprintf('\n\n************************************************************\n');
        fprintf('*      Current generation %d / %d\n', (countEval/nPop)+1, inopts.maxGen);
        fprintf('************************************************************\n');
    end
    % evaluate parameters
    variable_crossover_prob = myeval(opts.var_crossover_prob);
    variable_crossover_dist = myeval(opts.var_crossover_dist);
    variable_mutation_prob = myeval(opts.var_mutation_prob);
    variable_mutation_dist =myeval(opts.var_mutation_dist);
    variable_swap_prob = myeval(opts.var_swap_prob);
    DE_F = myeval(opts.DE_F);
    DE_CR = myeval(opts.DE_CR);
    DE_CombinedCR = myeval(opts.DE_CombinedCR);
    useDE = myeval(opts.useDE);
    refPoint = myeval(opts.refPoint);
    
    elementInd = nPop+1;
    
    % generate and add offspring
    population(elementsOffspring, :) = generate_offspring(population, ...
        numObj, numVar, rngMin, rngMax, problem, ranks, ...
        variable_crossover_prob, variable_crossover_dist, ...
        variable_mutation_prob, variable_mutation_dist,...
        variable_swap_prob, useDE, DE_CombinedCR, DE_F, DE_CR, opts, Param);
    
    countEval = countEval+nOffspring;
    
    % update archive
    if outputType == 2
        archive(countEval,:) = population(elementInd,:);
    end;
    
    % environmental selection
    ranks = non_dominated_sorting((population(:,numVar+1:numVar+numObj))');
    nPV = max(ranks);
    clearedPop = select_element_to_remove(population, numObj, numVar, nPV,...
        ranks, nPFevalHV, refPoint, opts);
    
    % save generations
    tmp = clearedPop;
    result.front{countEval} = tmp(:,numVar+1:numVar+numObj);
    result.set{countEval}= tmp(:,1:numVar);
%     result.population{countEval} = population;
    clear tmp
    
    % perform OCD
%     if mod(countEval, nPop)==0
%         %                 iteration = int16(round(countGen./nPop));
%         %         populationOCD(1:nPop,numVar+1:numVar+numObj) = population(1:nPop,numVar+1:numVar+numObj);
%         populationOCD(1:nPop,numVar+1:numVar+numObj) = result.front{1, countEval}(1:nPop, :);
%         iteration = countGen;
%         if iteration > OCD_nPreGen+1
%             % shift reference fronts
%             for i = 2:OCD_nPreGen+1
%                 PF{i-1} = PF{i};
%             end
%             
%             PF{OCD_nPreGen+1} = populationOCD(:,numVar+1:numVar+numObj);
%             
%             [termCrit lb ub p pReg] = ...
%                 OCD(PF, OCD_VarLimit, alpha, [true false false], p, pReg);
%             
%             % save OCD data
%             result.OCD.p_chi2(1,iteration) = p;
%             result.OCD.p_Reg(1,iteration) = pReg;
%             result.OCD.terminationCrit(iteration, :) = termCrit;
%         else
%             PF{iteration} = populationOCD(1:nPop,numVar+1:numVar+numObj);
%             if iteration == OCD_nPreGen+1
%                 
%                 [termCrit lb ub p pReg] = OCD(PF, OCD_VarLimit, alpha, [true false false]);
%                 
%                 % save OCD data
%                 result.OCD.p_chi2(1,iteration) = p;
%                 result.OCD.p_Reg(1,iteration) = pReg;
%                 result.OCD.terminationCrit(iteration, :) = termCrit;
%             end;
%         end;
%     end
    
%     if mod(countEval, outputGen)==0 && outputType > 0
%         if outputType == 1
%             if useOCD && exist('p', 'var')
%                 writeToFile(population, nPop, elementInd, numVar, numObj,...
%                     ranks, countEval, outdir, p);
%             else
%                 writeToFile(population, nPop, elementInd, numVar, numObj,...
%                     ranks, countEval, outdir);
%             end;
%         elseif outputType == 2
%             if useOCD && exist('p', 'var')
%                 writeArchiveToFile(archive, numVar, numObj, countEval,...
%                     outdir, p);
%             else
%                 writeArchiveToFile(archive, numVar, numObj, countEval, outdir);
%             end;
%         end;
%     end;
    
    % use OCD
%     if useOCD
%         if termCrit(1)
%             disp('OCD detected convergence due to the variance test');
%             paretoFront = population(:,numVar+1:numVar+numObj);
%             paretoSet = population(:,1:numVar);
%             return;
%         end
%         if termCrit(2)
%             disp('OCD detected convergence due to the regression analysis');
%             paretoFront = population(:,numVar+1:numVar+numObj);
%             paretoSet = population(:,1:numVar);
%             return;
%         end
%     end
    if mod(countEval, nPop) == 0
        countGen = countGen + 1;
    end
    population = clearedPop;
    clear clearedPop
end;

% final paretofront and paretoset
paretoFront = population(:,numVar+1:numVar+numObj);
paretoSet = population(:,1:numVar);

end

%%-------------------------------------------------------------------------
%%-------------------------------------------------------------------------
function opts=getoptions(inopts, defopts)
% OPTS = GETOPTIONS(INOPTS, DEFOPTS) handles an arbitrary number of
% optional arguments to a function. The given arguments are collected
% in the struct INOPTS.  GETOPTIONS matches INOPTS with a default
% options struct DEFOPTS and returns the merge OPTS.  Empty or missing
% fields in INOPTS invoke the default value.  Fieldnames in INOPTS can
% be abbreviated.
if nargin < 2 || isempty(defopts) % no default options available
    opts=inopts;
    return;
elseif isempty(inopts) % empty inopts invoke default options
    opts = defopts;
    return;
elseif ~isstruct(defopts) % handle a single option value
    if isempty(inopts)
        opts = defopts;
    elseif ~isstruct(inopts)
        opts = inopts;
    else
        error('Input options are a struct, while default options are not');
    end
    return;
elseif ~isstruct(inopts) % no valid input options
    error('The options need to be a struct or empty');
end

opts = defopts; % start from defopts
% if necessary overwrite opts fields by inopts values
defnames = fieldnames(defopts);
idxmatched = []; % indices of defopts that already matched
for name = fieldnames(inopts)'
    name = name{1}; % name of i-th inopts-field
    idx = strncmpi(defnames, name, length(name));
    if sum(idx) > 1
        error(['option "' name '" is not an unambigous abbreviation. ' ...
            'Use opts=RMFIELD(opts, ''' name, ...
            ''') to remove the field from the struct.']);
    end
    if sum(idx) == 1
        defname  = defnames{find(idx)};
        if ismember(find(idx), idxmatched)
            error(['input options match more than ones with "' ...
                defname '". ' ...
                'Use opts=RMFIELD(opts, ''' name, ...
                ''') to remove the field from the struct.']);
        end
        idxmatched = [idxmatched find(idx)];
        val = getfield(inopts, name);
        % next line can replace previous line from MATLAB version 6.5.0 on and in octave
        % val = inopts.(name);
        if isstruct(val) % valid syntax only from version 6.5.0
            opts = setfield(opts, defname, ...
                getoptions(val, getfield(defopts, defname)));
        elseif isstruct(getfield(defopts, defname))
            % next three lines can replace previous three lines from MATLAB
            % version 6.5.0 on
            %   opts.(defname) = ...
            %      getoptions(val, defopts.(defname));
            % elseif isstruct(defopts.(defname))
            warning(['option "' name '" disregarded (must be struct)']);
        elseif ~isempty(val) % empty value: do nothing, i.e. stick to default
            opts = setfield(opts, defnames{find(idx)}, val);
            % next line can replace previous line from MATLAB version 6.5.0 on
            % opts.(defname) = inopts.(name);
        end
    else
        warning(['option "' name '" disregarded (unknown field name)']);
    end
end
end
%%-------------------------------------------------------------------------
%%-------------------------------------------------------------------------
function res=myeval(s)
if ischar(s)
    res = evalin('caller', s);
else
    res = s;
end
end
%%-------------------------------------------------------------------------
%%-------------------------------------------------------------------------
function f = initialize_variables(nPop, nObj, numVar, min_range, max_range, problem, initPop, opts, Param)
% function f = initialize_variables(nPop, nObj, numVar, min_range, max_range,
% problem)
% This function initializes the chromosomes. Each chromosome has the
% following at this stage
%       * set of decision variables
%       * objective function values
% where,
% nPop - population size
% nObj - Number of objective functions
% numVar - Number of decision variables
% min_range - A vector of decimal values which indicates the minimum value
%             for each decision variable.
% max_range - Vector of maximum possible values for decision variables.
% initPop - file with initial population, if empty a random initialization is performed

f = inf(nPop,numVar+nObj); %preallocation
if exist(initPop, 'file')
    % load variables from file
    temp = load(initPop);
    if size(temp,1) ~= nPop
        error('data in file initPop has to be of size nPop');
    else
        f(1:nPop,1:numVar) = temp;
    end;
    if all(min(f(1:nPop,1:numVar))>=0) && all(max(f(1:nPop,1:numVar))<=1)
        % normalized designs have to be transformed
        f(1:nPop,1:numVar) = repmat(min_range,nPop,1) + ...
            repmat((max_range - min_range),nPop,1).*f(1:nPop,1:numVar);
    end;
    f(nPop+1,1:numVar) = min_range + (max_range - min_range).*rand(1, numVar);
else
    % Initialize the decision variables based on the minimum and maximum
    % possible values. numVar is the number of decision variable. A random
    % number is picked between the minimum and maximum possible values for
    % the each decision variable.
    f(:,1:numVar) = repmat(min_range,nPop,1) + ...
        repmat((max_range - min_range),nPop,1).*rand(nPop, numVar);
    % round designvariables according to variable type: continuous or
    % discrete
    for v = 1:numVar
        for w = 1  : nPop
            if( opts.vartype(v) == 2)
                f(w, v) = round( f(w, v) );
            end
        end
    end
end;
% Evaluate each chromosome:
fprintf('\n\n************************************************************\n');
fprintf('*      Start generation/ population \n');
fprintf('************************************************************\n');
f = evaluateParallel(opts, problem, f, Param, nPop, numVar, nObj);
end


function f = evaluateParallel(opts, problem, f, Param, loop, numVar, nObj)
% Evaluate objective function in parallel
if( strcmpi(opts.useParallel, 'yes'))
    %curPoolsize = parpool('size');
    
    poolobj = gcp('nocreate'); % If no pool, do not create new one.
    if isempty(poolobj)
        curPoolsize = 0;
    else
        curPoolsize = poolobj.NumWorkers;
    end
    
    % There isn't opened worker process
    if(curPoolsize == 0)
        if(opts.poolsize == 0)
            poolobj = parpool('local')
        else
            poolobj = parpool(opts.poolsize)
        end
        % Close and recreate worker process
    else
        if(opts.poolsize ~= curPoolsize)
            delete(gcp('nocreate'))
            %parpool close
            poolobj = parpool('opts.poolsize')
        end
    end
    
    
    % addpath auf jedem Worker ausführen
    pctRunOnAll        addpath('Klassen');
    pctRunOnAll        addpath('Funktionen');
    pctRunOnAll        addpath(genpath('Verbrauchssimulation'));
    pctRunOnAll        addpath(genpath('Optimierung'));
    pctRunOnAll        addpath('TCO');
    
    parfor i = 1:loop
        objVal(i, :) = evalIndividual(problem, f(i,1:numVar), Param);
    end
    
    %*************************************************************************
    % Evaluate objective function in serial
    %*************************************************************************
else
    for i = 1:loop
        objVal(i, :) = evalIndividual(problem, f(i,1:numVar), Param);
    end
end
f(:, numVar+1:numVar+nObj) = objVal;

end
%%-------------------------------------------------------------------------
%%-------------------------------------------------------------------------

function objVal = evalIndividual(problem, designVar, Param)
[y, cons] = problem( designVar, Param);
% Save the objective values and constraint violations
objVal = y;
indi.cons=cons; %was missing!!!
if( ~isempty(indi.cons) )
    idx = find( cons );
    if( ~isempty(idx) )
        indi.nViol = length(idx);
        indi.violSum = sum( abs(cons) );
    else
        indi.nViol = 0;
        indi.violSum = 0;
    end
end

end


function clearedPop = select_element_to_remove(population, nObj, numVar, nPV, ranks, nPFevalHV, refPoint, opts)

nOffspring = opts.nOffspring;
currentPop = population;
for nDeleted = 1 : nOffspring
    
    elementsInd = find(ranks==nPV);
    frontsize = size(elementsInd,1);
    if frontsize==1
        elementInd = 1;
    elseif nPV > nPFevalHV
        % current front is higher than the threshold, select index randomly
        elementInd = int16(max(ceil(rand(1)*frontsize),1));
    else
        frontObjectives = currentPop(elementsInd,numVar+1:numVar+nObj);
        if refPoint==0
            % adaptive reference point
            refPoint = max(frontObjectives)+1;
        else
            % filter solutions not dominating the predefined reference point
            index = false(frontsize,1);
            for i = 1:frontsize
                if any(frontObjectives(i,:) >= refPoint)
                    index(i) = true;
                end;
            end;
            if sum(index) > 0
                % enough infeasible solutions, remove the one with the
                % strongest individual violation
                [maxVal, IX] = max(max(frontObjectives-...
                    repmat(refPoint,frontsize,1), [], 2));
                elementInd = elementsInd(IX(1));
                %                 clearedPop = currentPop;
                %                 return;
                %                 nDeleted = nDeleted + 1;
                ranks = non_dominated_sorting((currentPop(:,numVar+1:numVar+nObj))');
                nPV = max(ranks);
                continue;
            end;
        end
        deltaHV = zeros(1,frontsize);
        if nObj == 2
            % use fast calculation of HV contributions
            [frontObjectives, IX] = sortrows(frontObjectives, 1);
            deltaHV(IX(1)) = ...
                (frontObjectives(2,1) - frontObjectives(1,1)) .* ...
                (refPoint(2) - frontObjectives(1,2));
            for i = 2:frontsize-1
                deltaHV(IX(i)) = ...
                    (frontObjectives(i+1,1) - frontObjectives(i,1))...
                    .* ...
                    (frontObjectives(i-1,2) - frontObjectives(i,2));
            end;
            deltaHV(IX(frontsize)) = ...
                (refPoint(1) - frontObjectives(frontsize,1)) .* ...
                (frontObjectives(frontsize-1,2) - ...
                frontObjectives(frontsize,2));
        else
            % resort to general HV code for arbitrary dimension
            currentHV = compute_hypervolume(frontObjectives', refPoint);
            for i=1:frontsize
                myObjectives = frontObjectives;
                myObjectives(i,:)=[];
                myHV = compute_hypervolume(myObjectives', refPoint);
                deltaHV(i) = currentHV - myHV;
            end
        end
        [minVal, IX]=min(deltaHV);
        elementInd = IX(1);
    end;
    elementInd = elementsInd(elementInd);
    
    %     nDeleted = nDeleted + 1;
    currentPop(elementInd, :) = [];
    ranks = non_dominated_sorting((currentPop(:,numVar+1:numVar+nObj))');
    nPV = max(ranks);
end
clearedPop = currentPop;
end
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
function f = generate_offspring(population, ...
    nObj, numVar, rngMin, rngMax, problem, ranks, ...
    variable_crossover_prob, variable_crossover_dist, ...
    variable_mutation_prob, variable_mutation_dist, variable_swap_prob, ...
    useDE, DE_CombinedCR, DE_F, DE_CR, opts, Param)
% function child  = generate_offspring(population, ...
%    nObj, numVar, rngMin, rngMax, problem, ranks, ...
%    variable_crossover_prob, variable_crossover_dist, ...
%    variable_mutation_prob, variable_mutation_dist, variable_swap_prob, ...
%    useDE, DE_CombinedCR, DE_F, DE_CR)
%
% population - all possible parents
% nObj - number of objective functions
% numVar - number of decision varaiables
% rngMin - a vector of lower limit for the corresponding decsion variables
% rngMax - a vector of upper limit for the corresponding decsion variables
% problem - problem string
% ranks - ranks of the population
% variable_crossover_prob - probability for crossover
% variable_crossover_dist - distribution index for crossover
% variable_mutation_prob - probability for mutation
% variable_mutation_dist - distribution index for mutation
% variable_swap_prob - probability for swapping variables after crossover
% useDE - use differential evolution instead of SBX & PM (true/false)
% DE_CombinedCR - Crossover in blocks or bits
% DE_F - difference weight for differential evolution
% DE_CR - crossover probability for DE
%
% The genetic operation is performed only on the decision variables, that
% are the first V elements in the chromosome vector.

nPop = size(population,1);
% Pre-Allocation
nOffspring = opts.nOffspring;
parent = zeros(4,numVar);
children = zeros(1, numVar+nObj);
% offspring = zeros(nOffspring, numVar+nObj);
for nOffspr = 1 : nOffspring
    if useDE
        % use differential evolution
        % we need four different parents
        mypermutation = randperm(nPop);
        parent(1,:) = population(mypermutation(1),1:numVar);
        parent(2,:) = population(mypermutation(2),1:numVar);
        switch nPop
            case 2
                parent(3,:) = population(mypermutation(1),1:numVar);
                parent(4,:) = population(mypermutation(2),1:numVar);
            case 3
                parent(3,:) = population(mypermutation(3),1:numVar);
                parent(4,:) = population(mypermutation(1),1:numVar);
            otherwise
                parent(3,:) = population(mypermutation(3),1:numVar);
                parent(4,:) = population(mypermutation(4),1:numVar);
        end;
        % build help_child
        child_1 = parent(2,:) + DE_F.*(parent(3,:)-parent(4,:));
        %combine child_1 & parent_1
        l_index = ceil(numVar*rand(1));
        if l_index == 0
            l_index = 1;
        end
        if DE_CombinedCR
            l_index_add = 0;
            while (rand(1) < DE_CR) && (l_index_add < numVar-1)
                l_index_add = l_index_add + 1;
            end;
            if l_index+l_index_add > numVar
                r_index = l_index+l_index_add-numVar;
                for j=1:numVar
                    if (j<=r_index) || (j>=l_index)
                        children(j)=child_1(j);
                    else
                        children(j)=parent(1,j);
                    end
                end
            else
                r_index = l_index+l_index_add;
                for j=1:numVar
                    if (j>=l_index)&&(j<=r_index)
                        children(j)=child_1(j);
                    else
                        children(j)=parent(1,j);
                    end
                end
            end
        else
            for j=1:numVar
                if (j == l_index) || (rand(1) < DE_CR)
                    children(j)=child_1(j);
                else
                    children(j)=parent(1,j);
                end
            end;
        end;
    else
        % use SBX & PM
        % Initialize the parents for SBX
        % two binary tournaments
        randomindices = ceil(rand(1,4)*nPop);
        randomindices(randomindices==0)=1;
        parent(1,:) = population(randomindices(1),1:numVar);
        parent(2,:) = population(randomindices(2),1:numVar);
        parent(3,:) = population(randomindices(3),1:numVar);
        parent(4,:) = population(randomindices(4),1:numVar);
        if ranks(randomindices(1)) < ranks(randomindices(2))
            parent_1 = parent(1,:);
        elseif ranks(randomindices(1)) > ranks(randomindices(2))
            parent_1 = parent(2,:);
        elseif rand(1) > 0.5
            parent_1 = parent(1,:);
        else
            parent_1 = parent(2,:);
        end
        if ranks(randomindices(3)) < ranks(randomindices(4))
            parent_2 = parent(3,:);
        elseif ranks(randomindices(3)) > ranks(randomindices(4))
            parent_2 = parent(4,:);
        elseif rand(1) > 0.5
            parent_2 = parent(3,:);
        else
            parent_2 = parent(4,:);
        end
        % Perform crossover for each decision variable.
        child_1 = zeros(1,numVar);
        child_2 = zeros(1,numVar);
        for j = 1 : numVar
            if rand(1) < variable_crossover_prob
                % SBX (Simulated Binary Crossover)
                u = rand(1);
                if u <= 0.5
                    bq = (2*u)^(1/(variable_crossover_dist+1));
                else
                    bq = (1/(2*(1 - u)))^(1/(variable_crossover_dist+1));
                end
                % Generate the jth element of first child
                child_1(j) = ...
                    0.5*(((1 + bq)*parent_1(j)) + (1 - bq)*parent_2(j));
                % Generate the jth element of second child
                child_2(j) = ...
                    0.5*(((1 - bq)*parent_1(j)) + (1 + bq)*parent_2(j));
            else
                child_1(j) = parent_1(j);
                child_2(j) = parent_2(j);
            end
            if rand(1) < variable_swap_prob
                swap = child_1(j);
                child_1(j) = child_2(j);
                child_2(j) = swap;
            end;
        end
        if rand(1) < 0.5
            children(1:numVar) = child_1;
        else
            children(1:numVar) = child_2;
        end;
        % perform mutation. Mutation is based on polynomial mutation.
        % Perform mutation on each element of the selected parent.
        deltaMax = rngMax - rngMin;
        for j = 1 : numVar
            if rand(1) < variable_mutation_prob
                r = rand(1);
                if r < 0.5
                    delta = (2*r)^(1/(variable_mutation_dist+1)) - 1;
                else
                    delta = 1 - (2*(1 - r))^(1/(variable_mutation_dist+1));
                end
                % Generate the corresponding child element.
                children(j) = children(j) + delta.*deltaMax(j);
            end
        end
    end
    % Make sure that the generated element is within the decision space.
    children(1:numVar) = min([rngMax; children(1:numVar)]);
    children(1:numVar) = max([rngMin; children(1:numVar)]);
    
    % round discrete variables
    for v = 1:numVar
        if( opts.vartype(v) == 2)
            children(v) = round( children(v) );
        end
    end
    f(nOffspr, :) = children;
end

f = evaluateParallel(opts, problem, f, Param, nOffspr, numVar, nObj);

end

% function [stopFlag, pNew, refValue, PI] = OCD(PF, varLimit, alpha, ref, p)
% % Determination of convergence by means of statistical tests on the
% % variance of the internally optimized HV indicator
% %
% % Call: [stopFlag, pNew] = OCD(PF, varLimit, alpha, ref, p)
% %
% % Input arguments:
% % PF        is a 1xnPreGen+1 vector of cell arrays holding the current and
% %           the last nPreGen Pareto front approximations
% % varLimit  is the minimum variance limit (default: 1e-3)
% % alpha     is the significance level of the statistical tests
% %           (default: 0.05)
% % ref       is a 1xd vector with the reference point in the d-dimensional
% %           objective space (default: -inf(1,d))
% % pNew         is the p-value of the Chi^2 variance test in the last iteration
% %           (default: 1)
% %
% % Output arguments:
% % stopFlag  is a boolean indicating whether the test detect convergence
% % p         is the p-value of the variance test in the current iteration
% %
% % A detailed description of the procedure and the variables used in the
% % code can be found in:
% % Wagner, T.; Trautmann, H.: Online Convergence Detection for Evolutionary
% % Multi-Objective Algorithms Revisited. In: Proceedings of the 2010 IEEE
% % Congress on Evolutionary Computation (IEEE CEC 2010), July 18-23, 2010,
% % Barcelona, Spain, G. Fogel, H. Ishibuchi (eds.), pp. 3554-3561
% %
% % Author: Tobias Wagner, Institute of Machining Technology, TU Dortmund
% % License: GPLv2
% % Last Revision: 2016-02-03
% if nargin < 1
%     error('OCD requires Pareto front approximations to detect convergence');
% end;
% 
% % check input and initialize variables
% nPreGen = length(PF)-1;
% PI = zeros(1,nPreGen);
% PFi = PF{nPreGen+1};
% d = size(PFi,2);
% if nargin < 5 || isempty(p)
%     p = 1;
% end
% if nargin < 4 || isempty(ref) || ref == 0
%     % determine ub from the data
%     ref = -inf(1,d);
%     for i = 1:nPreGen+1
%         ref = max([ref; PF{i}]);
%     end;
%     ref = ref+1;
% end;
% if nargin < 3 || isempty(alpha)
%     alpha = 0.05;
% end;
% if nargin < 2 || isempty(varLimit)
%     varLimit = 1e-3;
% end;
% 
% % compute hypervolume of the reference set
% refValue = hv(PFi', ref);
% 
% for k = 1:nPreGen
%     % compute indicator values
%     PI(k) = refValue-hv(PF{k}', ref);
% end;
% pNew = Chi2(PI, varLimit); % perform Chi^2 test
% % evaluate test-based termination criteria
% stopFlag = (pNew <= alpha) && (p <= alpha);
% end
% 
% function p = Chi2(PI, VarLimit) % One-sided Chi^2 variance test
% N = size(PI,2)-1; % determine degrees of freedom
% Chi = (var(PI).*N)./VarLimit; % compute test statistic
% % look up p-value from Chi^2 distribution with N degrees of freedom
% p = chi2cdf(Chi, N);
% end

function writeToFile(population, nPop, elementInd, numVar, nObj, ranks,...
    countEval, outdir, p)
active = setdiff(1:nPop+1,elementInd);
PS = population(active,1:numVar);
PF = population(active,numVar+1:numVar+nObj);
dlmwrite(sprintf('%spar_%03d.txt', outdir, countEval), PS, ' ');
dlmwrite(sprintf('%sobj_%03d.txt', outdir, countEval), PF, ' ');
dlmwrite(sprintf('%sps_%03d.txt', outdir, countEval),...
    PS(ranks(active)==1,:), ' ');
dlmwrite(sprintf('%spf_%03d.txt', outdir, countEval),...
    PF(ranks(active)==1,:), ' ');
if nargin > 8
    dlmwrite(sprintf('%spvalue_%03d.txt', outdir, countEval), p, ' ');
end;
end

function writeArchiveToFile(archive, numVar, nObj, countEval, outdir, p)
X = archive(1:countEval,1:numVar);
Y = archive(1:countEval,numVar+1:numVar+nObj);
PF = Y(paretofront(Y),:);
dlmwrite(sprintf('%spar_%03d.txt', outdir, countEval), X, ' ');
dlmwrite(sprintf('%sobj_%03d.txt', outdir, countEval), Y, ' ');
dlmwrite(sprintf('%spf_%03d.txt', outdir, countEval), PF, ' ');
if nargin > 5
    dlmwrite(sprintf('%spvalue_%03d.txt', outdir, countEval), p, ' ');
end;
end