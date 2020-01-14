function [pop, state] = evaluate(opt, pop, state, varargin)
% Function: [pop, state] = evaluate(opt, pop, state, varargin)
% Description: Evaluate the objective functions of each individual in the
%   population.
%
%         LSSSSWC, NWPU
%    Revision: 1.0  Data: 2011-04-20
%*************************************************************************

N = length(pop);
allTime = zeros(N, 1);  % allTime : use to calculate average evaluation times

%*************************************************************************
% Evaluate objective function in parallel
%*************************************************************************
if( strcmpi(opt.useParallel, 'yes'))
    %curPoolsize = parpool('size');

    poolobj = gcp('nocreate'); % If no pool, do not create new one.
    if isempty(poolobj)
        curPoolsize = 0;
    else
        curPoolsize = poolobj.NumWorkers;
    end
    
    % There isn't opened worker process
    if(curPoolsize == 0)
        if(opt.poolsize == 0)
            poolobj = parpool('local')
        else
            poolobj = parpool(opt.poolsize)
        end
    % Close and recreate worker process
    else
        if(opt.poolsize ~= curPoolsize)
            delete(gcp('nocreate'))
            %parpool close
            poolobj = parpool('opt.poolsize')
        end
    end
    
   
% addpath auf jedem Worker ausführen
pctRunOnAll        addpath('Classes');
pctRunOnAll        addpath('Functions');
pctRunOnAll        addpath(genpath('Consumption_simulation'));
pctRunOnAll        addpath('Optimization');
pctRunOnAll        addpath('TCO');
pctRunOnAll        addpath('Post-processing');
pctRunOnAll        warning('off','all')
    
    parfor i = 1:N
        
        fprintf('\nEvaluating the objective function... Generation: %d / %d , Individual: %d / %d \n', state.currentGen, opt.maxGen, i, N);
        [pop(i), allTime(i)] = evalIndividual(pop(i), opt.objfun, varargin{:});
  
    end
    
    % Verzeichnis updaten, damit nächste Generation funktioniert
%    updateAttachedFiles(poolobj)
    
%*************************************************************************
% Evaluate objective function in serial
%*************************************************************************
else
    for i = 1:N
        fprintf('\nEvaluating the objective function... Generation: %d / %d , Individual: %d / %d \n', state.currentGen, opt.maxGen, i, N);
        [pop(i), allTime(i)] = evalIndividual(pop(i), opt.objfun, varargin{:});
    end
end

%*************************************************************************
% Statistics
%*************************************************************************
state.avgEvalTime   = sum(allTime) / length(allTime);
state.evaluateCount = state.evaluateCount + length(pop);
end



function [indi, evalTime] = evalIndividual(indi, objfun, varargin)
% Function: [indi, evalTime] = evalIndividual(indi, objfun, varargin)
% Description: Evaluate one objective function.
%
%         LSSSSWC, NWPU
%    Revision: 1.1  Data: 2011-07-25
%*************************************************************************

tStart = tic;
[y, cons] = objfun( indi.var, varargin{:} );
evalTime = toc(tStart);

% Save the objective values and constraint violations
indi.obj = y;
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


