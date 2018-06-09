function ll=test_forward(Y,A,B,P)
% ll=test_forward(Y,A,B,P)
%
% Return the NEGATED log-likelihood for each input sequence Y{i} in Y.
%
% INPUT:
% Y:  matrix or cell array of the test observation sequences (of positive
%     integers from [1:M]). Variable length sequences are considered: 
%	     - When Y is matrix, shorter sequences are typically appended with 0.
%	       Zeros  are used as delimiters for computing the true length of each
%	       sequence. This is taken care of in fb.m and ffbs.m
% A: Transition matrix of HMM.
% B: Emission matrix of HMM.
% P: Prior distribution of HMM. When not given it is consider uniformly
%    distributed.
%
% OUTPUTS:
% ll:	is vector of length(Y) that holds the (NEGATED) log-likelihood per symbol 
%     of each sequence (i.e., divided by each sequence length T(i).

% Last updated by Shariful Islam: 03 October 2016 - 14:30:52

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 4,  N = length(A); P = ones(N,1)./N; end
if(~iscell(Y)), Y = num2cell(Y,2); end

ll=zeros(size(Y));

for i=1:length(Y)
%    ll(i) = ffbs(Y{i},A,B,P);  
	 ll(i) = fb(Y{i},A,B,P); % slightly slower 
   % both fb or ffbs take care of the true length and gives the ll of each seq
   % per symbol.
end

% % check for invalid loglik
% wk_assert( all(isfinite(ll)),...
% 	'There are invalid values in the Log likelihood. Check B for zeros');
% wk_assert( all(isreal(ll)),...
% 	'There are Imaginary values (Not real) in the Log likelihood.');

ll = -ll; % retrun positive log-likelihood. 
