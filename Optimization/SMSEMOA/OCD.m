function [termCrit lb ub pChi2 pReg] = ...
            OCD(PF, VarLimit, alpha, PIindex, pChi2, pReg,lb, ub)
% Determination of convergence by means of statistical tests on performance
% indicator values of the last Pareto front approximations of a MOEA
%
% Call: [termCrit lb ub pChi2 pReg] = ...
%           OCD(PF, VarLimit, alpha, PIindex, lb, ub, pChi2, pReg)
%
% Input arguments:
% PF        is a 1xnPreGen+1 vector of cell arrays holding the current and 
%           the last nPreGen Pareto front approximations
% VarLimit  is the minimum variance limit (default: 1e-3)
% alpha     is the significance level of the statistical tests (default: 0.05)
% PIindex   is a 1x3 vector of booleans which determine the indictors to use
%           (0 or false: neglect, 1 or true: use, default: [1 1 1])
%           1. Hypervolume indicator
%           2. Additive epsilon indicator
%           3. R2 indicator
% lb        is a 1xd vector of the the currently approximated lower bound
%           of the d-dimensional objective space (default: inf(1,d))
% ub        is a 1xd vector of the the currently approximated upper bound
%           of the d-dimensional objective space (default: -inf(1,d))
% pChi2     is a 1x3 vector of p-values of the Chi^2 variance tests in the 
%           last iteration (default: ones(1,3))
% pReg      is the p-value of the linear regression analysis in the last 
%           iteration (default: 0)
%
% Output arguments:
% termCrit  is a 1x2 boolean vector indicating whether 
%               1. the Chi2 variance test and/or
%               2. the regression analysis
%           detect convergence
% lb        is the updated approximated lower bound of the objective space
% ub        is the updated approximated upper bound of the objective space
% pChi2     p-values of the Chi^2 variance tests in the current iteration 
% pReg      p-value of the linear regression analysis in the current iteration
%
% A detailied description of the procedure and the variables used in the
% code can be found in:
% Wagner, T.; Trautmann, H.; Naujoks, B.
% OCD: Online Convergence Detection for Evolutionary Multi-Objective Algorithms
% In: M. Ehrgott, C. M. Fonseca, X. Gandibleux, J.-K. Hao, M. Sevaux (eds.)
% Proc. 5th Int'l. Conf. Evolutionary Multi-Criterion Optimization (EMO 2009)
% LNCS 5467, Springer, ISBN 978-3-642-01019-4, pp. 198-215
%
% Changes in the implementation compared to the version described in the paper:
% -     The indicator values are calculated within OCD. In order to avoid
%       interfaces to extern calculations, a restriction to the three
%       indicators analyzed in the paper has been decided.
% -     The iterations are performed within the MOEA and OCD is evaluated
%       after each generation. The current generation i is not known in
%       OCD.
% ->    Only the Pareto fronts of the last nPreGen generations are passed
%       to OCD. Thus, nPreGen is parameter which has to be specified in the 
%       MOEA, not in OCD. The indices in the OCD pseudocode are changed to 
%       i=nPreGen+1, i-1=nPreGen, i-2=nPreGen-1, ...
% ->    The test whether i > nPreGen is performed in the MOEA.
% ->    The objective bounds lb and ub approximated in the last call to OCD
%       have to be stored in the MOEA and are returned to OCD for the update. 
%       If no bounds are passed, OCD reinitializes these according to PF.
% ->    The p-values computed in the last call to OCD have to be stored in 
%       the MOEA and are returned to OCD for the convergence decision. 
%       If no p-values are passed, OCD assumes no critical values and no 
%       convergence will be indicated. 
% ->    The termination criterion (i == MaxGen) && any(termCrit) has to be
%       evaluated within the MOEA after the call to OCD, since MaxGen is
%       not known in OCD.
%
% Author: Tobias Wagner, Institute of Machining Technology, TU Dortmund
% License: GPLv2
% Last Revision: 2009-09-17
if nargin < 1
    error('OCD requires Pareto front approximations to detect convergence');
end;
% check input and initialize variables
nPreGen = length(PF)-1;
PI = zeros(1,nPreGen+1);
pChi2New = zeros(1,1);
termCrit = false(1,2);
PFi = PF{nPreGen+1};
d = size(PFi,2);
if nargin < 8
    % determine ub from the data already known
    ub = -inf(1,d);
    for i = 1:nPreGen
        ub = max([ub; PF{i}]);
    end;
    if nargin < 7
        % determine lb from the data already known
        lb = inf(1,d);
        for i = 1:nPreGen
            lb = min([lb; PF{i}]);
        end;
        if nargin < 6
            pReg = 0;
            if nargin < 5
                pChi2 = ones(1,1);
                if nargin < 4
                    PIindex = true(1,1);
                    if nargin < 3
                        alpha = 0.05;
                        if nargin < 2
                            VarLimit = 1e-3;
                        end;
                    end;
                end;
            end;
        end
    end;
end;
n = sum(PIindex); % determine number of active performance indicators
lb = min([lb; PFi]); % update lower bound vector
ub = max([ub; PFi]); % update upper bound vector
if PIindex(1)    
    % compute hypervolume of the reference set
    refValue = sum(abs(compute_hypervolume(PFi', ub))); 
end;
for k = 1:nPreGen
    PFk = PF{k};    
    for j = 1
        if PIindex(j)
            % compute indicator values
            switch j
                case 1
                    PI(j,k) = refValue-sum(abs(compute_hypervolume(PFi', ub)));
                case 2
                    PI(j,k) = epsilonIndicator(PFk, PFi);                     
                case 3
                    PI(j,k) = rIndicator(PFk, PFi, lb, ub);
            end;            
        end;
    end;
end;
for j = 1
    if PIindex(j)
        pChi2New(j) = Chi2(PI(j,1:nPreGen), VarLimit); % perform Chi^2 test
    end;
end;
pRegNew = Reg(PI(PIindex,1:nPreGen)); % perform t-test
% evaluate test-based termination criteria
termCrit(1) = all(pChi2New <= alpha/n) && all(pChi2 <= alpha/n);
termCrit(2) = (pRegNew > alpha) && (pReg > alpha);
% update p-values
pChi2 = pChi2New; 
pReg = pRegNew;

function p = Chi2(PI, VarLimit) % One-sided Chi^2 variance test
N = size(PI,2)-1; % determine degrees of freedom
Chi = (var(PI).*N)./VarLimit; % compute test statistic
% look up p-value from Chi^2 distribution with N degrees of freedom
p = chi2cdf(Chi, N); 

function p = Reg(PI) % Two-sided t-test on the linear trend
N = numel(PI)-1; % determine degrees of freedom
% initialize variables
n = size(PI,1);
nPreGen = size(PI,2);
X = 1:nPreGen;
% X = repmat(X,1,n); % no standardization
X = repmat((X-mean(X))./std(X),1,n); % standardization
Y = zeros(1,N+1);
for j = 1:n
    if std(PI(j,:)) > 0 % improvement in the last generations
        PI(j,:) = (PI(j,:)-mean(PI(j,:)))./std(PI(j,:)); % standardization
    else
        PI(j,:) = (PI(j,:)-mean(PI(j,:)));
    end;
    Y((j-1)*nPreGen+1:j*nPreGen) = PI(j,:); % generate row vector of PI
end;
betaHat = inv(X*X')*X*Y'; % linear regression without intercept
epsilon = Y - X*betaHat; % compute residuals
s2 = (epsilon*epsilon')./N; % mean squared error of regression 
t = betaHat ./ sqrt(s2.*inv(X*X')); % compute test statistic
% look up p-value from t distribution with N degrees of freedom (2-sided)
p = 2*min(tcdf(t, N), 1-tcdf(t, N)); 