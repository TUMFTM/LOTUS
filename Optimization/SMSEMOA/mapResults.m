function [ result_struct_plot ] = mapResults( result, options )
opts = options;

nVar    = opts.numVar;
nObj    = opts.numObj;
nCons   = opts.numCons;
popsize = opts.popsize;

opts.maxGen= size(result.front, 2)/opts.popsize;
opts.maxEval= size(result.front, 2);

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

result_struct_plot.pop     = repmat(pop, [opts.maxGen, 1]);     % each row is the population of one generation
result_struct_plot.states   = repmat(state, [opts.maxGen, 1]);   % each row is the optimizaiton state of one generation
result_struct_plot.opt      = opts;                              % use for output
result_struct_plot.opt.refPoints      = opts.refPoint; 

SMSparetoFronts{1} = result.front{1,1};
SMSparetoSets{1} = result.set{1,1};

countEval = opts.popsize+1;
while (countEval <= opts.maxEval)
    if mod(countEval, opts.popsize) == 0
        iteration = countEval/opts.popsize;
        SMSparetoFronts{iteration} = result.front{1, countEval};
        SMSparetoSets{iteration} = result.set{1, countEval};
    end
    countEval = countEval + 1;
end

for i = 1 : opts.maxGen
for j = 1 : opts.popsize
    result_struct_plot.pops(i, j).obj = SMSparetoFronts{1,i}(j, :);
    result_struct_plot.pops(i, j).var = SMSparetoSets{1,i}(j, :);
end
end

end

