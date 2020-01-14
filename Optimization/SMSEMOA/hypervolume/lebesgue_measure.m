function [lm] = lebesgue_measure(F, ub)
% [lm] = lebesgue_measure(F, ub)
%
% Computes the hypervolume (or Lebesgue measure) of the M x l
% matrix F of l vectors of M objective function values.
%
% Implementation of the Lebesgue Measure Algorithm as described by:
%
% 'M. Fleischer. The measure of Pareto Optima Applications to 
%  Multi-objective Metaheuristics. EMO 2003, LNCSS 2632
%  519-533, 2003.'
%
% IMPORTANT:
%   Considers Minimization of the objective function values!
%   This function assumes that all solutions of F are non-dominated!
%
% Input:
% - F              - An M x l matrix where each of the l columns 
%                    represents a vector of M objective function values
%                    (note that this function assumes that all 
%                    solutions of F are non-dominated).
% - ub             - Optional: Upper bound reference point (default:
%                    the boundary point containing the maximum of F
%                    for each objective).
%
% Output:
% - lm             - The hypervolume (or lebesgue measure) of F.
%
% Author: Johannes W. Kruisselbrink
% Last modified: March 17, 2011

	if (nargin < 2), ub = (max(F,[],2)); end

	[M, l] = size(F);
	if (M == 2)
		lm = lebesgue_2D(F, ub);
	else
		lm = lebesgue_ND(F, ub);
	end

end


function [lm] = lebesgue_2D(F, ub)
% Efficient method for 2D objective function values
	L = sortrows(F',1)';
	l = length(L(1,:));
	lm = 0;
	for i = 1:l
		lm = lm + ((L(1,i) - ub(1)) * (L(2,i) - ub(2)));
		ub(2) = L(2,i);
	end
end


function [lm] = lebesgue_ND(F, ub)
% Method for ND objective function values as described in:
%
% 'M. Fleischer. The measure of Pareto Optima Applications to 
%  Multi-objective Metaheuristics. EMO 2003, LNCSS 2632
%  519-533, 2003.'
%
% Author: Johannes W. Kruisselbrink
% Last modified: March 17, 2011

	lm = 0;

	[M, l] = size(F);

	% Remove the duplicates from F and compute Lebesque measure of L
	L = unique(F','rows')';

	while l >= 1
		if (l > 1)
			b = zeros(M,1);
			spawn_vector = repmat(L(:,1), 1, M);
			for i = 1:M
				% Bound b(i) is either the least upper bound of the i-th value of the
				% other points or it is the value of the absolute upper bound ub(i)
				difL = (L(i,2:end) - L(i,1));
				lub = find(difL > 0);
				if (length(lub) > 0)
					b(i) = min(L(i,lub+1));
				else
					b(i) = ub(i);
				end

				b(i) = min((difL > 0) .* L(i,2:end) + (difL <= 0) * ub(i));
				% Update i-th spawn vector
				spawn_vector(i,i) = b(i);
			end

			% Compute lop-Off volume and update lebesgue measure
			lov = prod(b - L(:,1));
			lm = lm + lov;

			% Remove L(:,1) from L
			L = L(:,2:end);

			% Add the spawn_vector to L, but first filter dominated
			% solutions and the solutions that touch the upper bounds
			% from the spawn_vector
			L = nd_filter(L, spawn_vector, ub);

		else
			lov = prod(ub - L(:,1));
			lm = lm + lov;
			L = [];
		end
		% Update l
		[M, l] = size(L);
	end

end


function L = nd_filter(L, spawn_vector, ub)
% Implementation of the filter routine as described in:
%
% 'M. Fleischer. The measure of Pareto Optima Applications 
%  to Multi-objective Metaheuristics. EMO 2003, LNCSS 2632
%  519-533, 2003.'
%
% Author: Johannes W. Kruisselbrink
% Last modified: March 17, 2011

	[M, l_L] = size(L);
	[M, l_sp] = size(spawn_vector);
	do_assign = zeros(1, l_sp);

	for i = 1 : l_sp

		% Find if the spawnvector hits the upper bound
		at_ub = false;
		for j = 1:M
			if (spawn_vector(j,i) == ub(j))
				at_ub = true;
				break;
			end
		end

		% For this if statement, the following would be more elegant
		% (replacing the loop above), but less efficient:
		% if (all(spawn_vector(:,i) ~= ub))
		if (at_ub == false)
			do_assign(i) = 1;
			for j = 1 : l_L
				if (weakly_dominates(L(:,j), spawn_vector(:,i)))
					do_assign(i) = 0;
					break;
				end
			end
		end
	end
	L = [spawn_vector(:,find(do_assign == 1)), L];

end
