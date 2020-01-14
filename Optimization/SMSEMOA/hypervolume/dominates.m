function d = dominates(fA, fB)
% [d] = dominates(fA, fB)
%
% Compares two solutions A and B given their objective function
% values fA and fB. Returns whether A dominates B.
%
% Input:
% - fA					- The objective function values of solution A
% - fB					- The objective function values of solution B
%
% Output:
% - d					- d is 1 if fA dominates fB, otherwise d is 0 
%
% Author: Johannes W. Kruisselbrink
% Last modified: March 17, 2011

	% Elegant, but not very efficient
	%d = (all(fA <= fB) && any(fA < fB));

	% Not so elegant, but more efficient
	d = false;
	for i = 1:length(fA)
		if (fA(i) > fB(i))
			d = false;
			return
		elseif (fA(i) < fB(i))
			d = true;
		end
	end
end
