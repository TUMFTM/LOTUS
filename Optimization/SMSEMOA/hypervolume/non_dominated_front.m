function [ndf_index, df_index] = non_dominated_front(F)
% [ndf_index, df_index] = non_dominated_front(F)
%
% Returns the indexes of the non-dominated front of the M vectors of
% l function values contained in F. 
%
% IMPORTANT:
%   Considers Minimization of the objective function values!
%
% Input:
% - F                   - A matrix of M x l, where M is the number
%                         of objectives, and l is the number of
%                         objective function value vectors of the
%                         solutions.
%
% Output:
% - ndf_index           - the indexes of the non-dominated front
% - df_index            - the indexes of the solutions that are dominated
%
% Author: Johannes W. Kruisselbrink
% Last modified: March 17, 2011

	[M, l] = size(F);

	df_index = [];
	ndf_index = [1];
	ndf_count = 1;
	for i = 2:l
		ndf_index = [ndf_index, i];
		ndf_count = ndf_count + 1;
		j = 1;
		while j < ndf_count
			if (dominates(F(:,i), F(:,ndf_index(j))))
				df_index = [df_index, ndf_index(j)];
				ndf_index = [ndf_index(1:j-1), ndf_index(j+1:end)];
				ndf_count = ndf_count - 1;
			elseif (dominates(F(:,ndf_index(j)), F(:,i)))
				df_index = [df_index, i];
				ndf_index = ndf_index(1:end-1);
				ndf_count = ndf_count - 1;
				break;
			else
				j = j + 1;
			end
		end
	end
end
