function [hypervolume_contributions] = compute_hypervolume(F, ub)
% [hypervolume_contributions] = compute_hypervolume_contributions(F, ub)
%
% Computes the hypervolume contribution of each point.
% Minimization of the objective function values is assumed.
% The implementation follows the description of:
%
% 'M. Emmerich, N. Beume, and B. Naujoks. An EMO Algorithm Using
%  the Hypervolume Measure as Selection Criterion. EMO 2005.'
%
% IMPORTANT:
% This function assumes that all solutions of F are non-dominated!
%
% Input:
% - F						- A matrix of M x l, where M is the number
%							  of objectives, and l is the number of
%							  objective function value vectors of the
%							  solutions.
% - ub						- The reference point, or the upper bound
%							  of the hypervolume region.
%
% Output:
% - hypervolume_contributions - a vector of 1 x l with the hypervolume contributions.  
%
% Author: Johannes W. Kruisselbrink
% Last modified: March 17, 2011

	[M, l] = size(F);

	if (M == 2)
		hypervolume_contributions = compute_hypervolume_contributions_2D(F, ub);
	elseif (M == 3)
		hypervolume_contributions = compute_hypervolume_contributions_3D(F, ub);
	else
		hypervolume_contributions = zeros(1, l);
		S = lebesgue_measure(F, ub);
		for i = 1 : l
			hypervolume_contributions(i) = S - lebesgue_measure([F(:,1:i-1), F(:,i+1:end)], ub);
		end
	end

end

function [hypervolume_contributions] = compute_hypervolume_contributions_2D(F, ub)
% Alternative (efficient) method for 2D objective function values

	[M, l] = size(F);

	hypervolume_contributions = zeros(1, l);
	[sortF, Findex] = sort(F,2);
	Lindex = Findex(1,:);
    L = F(:,Lindex(1,:));
    % 	hypervolume_contributions(Lindex(1)) = Inf;
    % 	hypervolume_contributions(Lindex(l)) = Inf;
    hypervolume_contributions(Lindex(1)) = (L(2,1) - L(1,1)) .* (ub(2) - L(1,2));
    hypervolume_contributions(Lindex(l)) = (ub(1) - L(1,l)) .*(L(2,l-1) - L(2,l));
    for i = 2 : l - 1
        hypervolume_contributions(Lindex(i)) = (L(1,i+1) - L(1,i)) * (L(2,i-1) - L(2,i));
    end
end


function [hypervolume_contributions] = compute_hypervolume_contributions_3D(F, ub)
% Efficient method for 3D objective function values
%
% Implementation after:
%
%   'B. Naujoks, N. Beume, M. Emmerich. Multi-objective
%    optimisation using S-metric Selection: Application to
%    three-dimensional Solution Spaces. CEC 2005, 1282-1289,
%    2005.'

	[M, l] = size(F);

	a = sort(F(1,:), 'ascend');
	b = sort(F(2,:), 'ascend');
	a(end+1) = ub(1);
	b(end+1) = ub(2);

	best1_f3 = ub(3) * ones(l,l);
	best2_f3 = ub(3) * ones(l,l);

	for t = 1:l
		for i = 1:l
			for j = 1:l
				if (F(1,t) <= a(i) && F(2,t) <= b(j))
					if (F(3,t) < best1_f3(i,j))
						best2_f3(i,j) = best1_f3(i,j);
						best1_f3(i,j) = F(3,t);
					elseif (F(3,t) < best2_f3(i,j))
						best2_f3(i,j) = F(3,t);
					end
				end
			end
		end
	end

	hypervolume_contributions = zeros(1, l);
	for t = 1:l
		for i = 1:l
			for j = 1:l
				if (F(1,t) <= a(i) && F(2,t) <= b(j) && F(3,t) == best1_f3(i,j))
					hypervolume_contributions(t) = hypervolume_contributions(t) + (a(i+1) - a(i)) * (b(j+1) - b(j)) * (best2_f3(i,j) - best1_f3(i,j));
				end
			end
		end
	end

end
