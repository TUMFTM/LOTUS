function result = nsga2(opt, varargin)
% Function: result = nsga2(opt, varargin)
% Description: The main flowchart of of NSGA-II. Note:
%   All objectives must be minimization. If a objective is maximization, the
%   objective should be multipled by -1.
%
% Syntax:
%   result = nsga2(opt): 'opt' is generated by function nsgaopt().
%   result = nsga2(opt, param): 'param' can be any data type, it will be
%       pass to the objective function objfun().
%
%   Then ,the result structure can be pass to plotnsga to display the
%   population:  plotnsga(result);
%
% Parameters:
%   opt : A structure generated by funciton nsgaopt().
%   varargin : Additional parameter will be pass to the objective functions.
%       It can be any data type. For example, if you call: nsga2(opt, param),
%       then objfun would be called as objfun(x,param), in which, x is the
%       design variables vector.
% Return:
%   result : A structure contains optimization result.
%
%         LSSSSWC, NWPU
%   Revision: 1.2  Data: 2011-07-26
%*************************************************************************


tStart = tic();
%*************************************************************************
% Verify the optimization model
%*************************************************************************
opt = verifyOpt(opt);

%*************************************************************************
% variables initialization
%*************************************************************************
nVar    = opt.numVar;
nObj    = opt.numObj;
nCons   = opt.numCons;
popsize = opt.popsize;

% pop : current population
% newpop : new population created by genetic algorithm operators
% combinepop = pop + newpop;
pop = repmat( struct(...
    'var', zeros(1,nVar), ...
    'obj', zeros(1,nObj), ...
    'cons', zeros(1,nCons),...
    'rank', 0,...
    'distance', 0,...
    'prefDistance', 0,...       % preference distance used in R-NSGA-II
    'nViol', 0,...
    'violSum', 0),...
    [1,popsize]);

% state: optimization state of one generation
state = struct(...
'currentGen', 1,...         % current generation number
'evaluateCount', 0,...      % number of objective function evaluation
'totalTime', 0,...          % total time from the beginning
'firstFrontCount', 0,...    % individual number of first front
'frontCount', 0,...         % number of front
'avgEvalTime', 0 ...        % average evaluation time of objective function (current generation)
);

result.pops     = repmat(pop, [opt.maxGen, 1]);     % each row is the population of one generation
result.states   = repmat(state, [opt.maxGen, 1]);   % each row is the optimizaiton state of one generation
result.opt      = opt;                              % use for output

% global variables
global STOP_NSGA;   %STOP_NSGA : used in GUI , if STOP_NSGA~=0, then stop the optimizaiton
STOP_NSGA = 0;


%*************************************************************************
% initialize the P0 population
%*************************************************************************
ngen = 1;

% Startwerte f�r Improvement Ratio anlegen
impr_ratio_stop = 1;
impr_ratio(1) = 1;

pop = opt.initfun{1}(opt, pop, opt.initfun{2:end});
[pop, state] = evaluate(opt, pop, state, varargin{:});
[opt, pop] = ndsort(opt, pop);

% state
state.currentGen = ngen;
state.totalTime = toc(tStart);
state = statpop(pop, state);

result.pops(1, :) = pop;
result.states(1)  = state;

% output
plotnsga(result, ngen);
opt = callOutputfuns(opt, state, pop);


%*************************************************************************
% NSGA2 iteration
%*************************************************************************

while (ngen < opt.maxGen && STOP_NSGA==0 && impr_ratio_stop >= opt.impr_ratio)
    % 0. Display some information
	ngen = ngen+1;
    state.currentGen = ngen;
    fprintf('\n\n************************************************************\n');
    fprintf('*      Current generation %d / %d\n', ngen, opt.maxGen);
    fprintf('************************************************************\n');
    
    % 1. Create new population
    newpop = selectOp(opt, pop);
    newpop = crossoverOp(opt, newpop, state);
    newpop = mutationOp(opt, newpop, state);
    [newpop, state] = evaluate(opt, newpop, state, varargin{:});

    % 2. Combine the new population and old population : combinepop = pop + newpop
    combinepop = [pop, newpop];
    
    % 3. Fast non dominated sort
    [opt, combinepop, domination] = ndsort(opt, combinepop);
    
    % Improvement Ratio berechnen; Wolff 2016
    impr_ratio(ngen) = sum(any(domination>0,1))/length(combinepop);
    % Speichern in result struct
    result.impr_ratio = impr_ratio;
    % Mittelwert berechnen, sodass glatter Verlauf entsteht
    result.impr_ratio_mean(ngen) = mean(result.impr_ratio);
    
    % Wenn Stopping Criteria eingeschaltet
    if ( strcmpi(opt.stop_crit, 'on') == 1 )
    impr_ratio_stop = result.impr_ratio_mean(end);
    end
    
    
    % 4. Extract the next population
    pop = extractPop(opt, combinepop);

    % 5. Save current generation results
    state.totalTime = toc(tStart);
    state = statpop(pop, state);
    
    result.pops(ngen, :) = pop;
    result.states(ngen)  = state;

    % 6. plot current population and output
    if( mod(ngen, opt.plotInterval)==0 )
        plotnsga(result, ngen);
    end
    if( mod(ngen, opt.outputInterval)==0 )
        opt = callOutputfuns(opt, state, pop);
    end
    
end

% call output function for closing file
opt = callOutputfuns(opt, state, pop, -1);

% Improvement Ratio plotten
figure('Name', 'Improvement Ratio');
hold on
plot(1:length(result.impr_ratio), result.impr_ratio(1:end))
plot(1:length(result.impr_ratio_mean), result.impr_ratio_mean(1:end))
xlabel('Number of Generations');
ylabel('Ratio of Individuals P (i) dominating Individuals of P (i-1)');
legend('Improvement Ratio', 'Mean Improvement Ratio overall Generations', 'Location', 'Northeast');
hold off

% close worker processes
if( strcmpi(opt.useParallel, 'yes'))
    delete(gcp('nocreate'))
end

toc(tStart);


