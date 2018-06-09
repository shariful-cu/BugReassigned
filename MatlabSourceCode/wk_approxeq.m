function p = wk_approxeq(a, b, tol)
% function p = wk_approxeq(a, b, tol)
%
% returns true if a and b are approximately equal 
% up to the specified tolerance: tol [1E-15]
% if a and b are arrays the comparison is done
% element by element, any mismatch returns false
%
% last updated by Shariful Islam: 27 August 2016 - 14:52:39

if nargin<3; tol = 1e-15; end

p = ~(any(abs(a(:)-b(:)) > tol));
