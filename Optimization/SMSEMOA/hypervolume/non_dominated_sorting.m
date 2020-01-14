function [nds_ranks] = non_dominated_sorting(F)
% [nds_ranks] = non_dominated_sorting(F)
%
% Apply non-dominated sorting on the l vectors of length M.
% It assumes minimization of the objectives. Returns in nds_ranks
% the rank for each function value vector.
%
%
% Input:
% - F					- A matrix of M x l, where M is the number
%						  of objectives, and l is the number of
%						  objective function value vectors of the
%						  solutions.
%
% Output:
% - nds_ranks			- a vector of 1 x l with the non-dominated
%						  sorting ranks  
%
% Author: Johannes W. Kruisselbrink
% Last modified: March 17, 2011

	[M, l] = size(F);

	nds_ranks = ones(1,l);

	P = [1:l];
	i = 1;
	while length(P) > 0
		[ndf_index, df_index] = non_dominated_front(F(:,P));
		nds_ranks(P(ndf_index)) = i;
		P = P(df_index);
		i = i + 1;
	end

end
