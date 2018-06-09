function ll=loglik(Y,A,B,P)
% ll = loglik(Y,A,B,P)
% return the average log likelihood of all sequences in Y
%
% Y: martix or cell array of the test observation sequences 
% 	(pos integers, 1:M). Variable length seqs are considered, 
% 	shorter sequences already appended with 0 (in fb.m and ffbs.m).
% 	Zeros  are used as delimiters for computing the true sequence length.
%
% ll:	is a scalar that holds the AVERAGE log likelihood per sequence.
%   The log likelihood of each sequence divided by its length, ie (per symbol) 
%
% See also FB, and FFBS 

% Shariful Islam: 04 October 2016 - 04:20:32

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
args = '!!! ll=loglik(Y,A,B,P)' ;

if nargin ~=4
	fprintf(1,'%s\n',args);
    error('!!! wrong number of arguments !!!');
end

if(~iscell(Y)); Y = num2cell(Y,2); end
ll=zeros(size(Y));

for i=1:length(Y)
  % chose one evaluation method (similar results):
  % ll(i) = ffbs(Y{i},A,B,P);  
  ll(i) = fb(Y{i},A,B,P);  
end

% check for invalid loglik
wk_assert( all(isfinite(ll)),...
	'There are invalid values in the Log likelihood');
wk_assert( all(isreal(ll)),...
	'There are Imaginary numbers in the Log-likelihood.');

ll = mean(ll);
% ll = sum(ll);  
