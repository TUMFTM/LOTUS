function [] = test_lebesgue_measure()
% [] = test_lebesgue_measure()
%
% Computes the hypervolumes of all non-dominated function value
% settings stored as text-files in the current directory. These
% text-files should be tab-separated files where each row
% represents a vector of function values.
%
% IMPORTANT:
%   Considers Minimization of the objective function values!
%
% Author: Johannes W. Kruisselbrink
% Last modified: March 17, 2011

	test_set = eval('dir(''*.txt'')');

	for i = 1:length(test_set)
		F = load(test_set(i).name);
		F = F';
		[ref_point] = compute_reference_point(F, 0);
		hv_leb(i) = lebesgue_measure(F, ref_point);
		hv_mc(i) = approximate_hypervolume_ms(F, ref_point, 100);
		disp([test_set(i).name, ': LEB = ', num2str(hv_leb(i)), ' - MC = ', num2str(hv_mc(i))])

		[ref_point] = compute_reference_point(F, 1);
		hv_leb(i) = lebesgue_measure(F, ref_point);
		hv_mc(i) = approximate_hypervolume_ms(F, ref_point, 100);
		disp([test_set(i).name, ': LEB = ', num2str(hv_leb(i)), ' - MC = ', num2str(hv_mc(i))])

	end
end
