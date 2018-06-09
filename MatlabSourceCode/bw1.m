function [A,B,P,ll] = bw1(Y,A,B,P,varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [A,B,P,ll] = bw1(Y,A,B,P,...)
% ONE iteration of Baum-Welch and one Update HMM parameters (if not clampped).
% 
% INPUT:
% Y is a vector (or cell array of vectors if many sequences) of integers
%
% Optional parameters may be passed as 'param_name', param_value pairs.
% Parameter names are shown below; default values are between: [] 
%
% 'e_step' - Which algorithm is used for the E-step computation ['fb']:
%     'fb'     - forward-backward
%     'ffbs'   - forward-filter backward-smoothing
%
% 'espi' - Smoothes the matrices not to contain zeros [sqrt(realmin)]
%           accounts for unseen observation symbols in training
%		      for testing, also useful for left-right HMMs
%
% To clamp some of the parameters, so learning does not change them:
% 'adj_prior' - if 0, do not change initial prior probabilities [1]
% 'adj_trans' - if 0, do not change state transition probabilities [1]
% 'adj_emiss' - if 0, do not change state output probabilities [1]
%
% A,P,B: initial estimates of HMM parameters:
% A(i,j) [N,N] is the probability of going to j next if you are now in i
% P(j)   [N,1] is the probability of starting in state j
% B(j,k) [N,M] is the probability of emitting symbol k if you are in state j
%
% OUTPUT:
% Updated HMM parameters after ONE BW iteration: A, B, and P 
%
% ll is a scalar (or vector for multiple sequences) that holds
%    the log likelihood per symbol (ie total divided by Y length)
%
% See also BW, and BWV

% last updated by Shariful Islam: 01 October 2016 - 15:12:20

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Options:
[e_step, epsi, adj_prior, adj_trans, adj_emiss] = ...
   process_options(varargin, 'e_step', 'fb', 'epsi',1E-15, ...
   'adj_prior', 1, 'adj_trans', 1, 'adj_emiss', 1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if(~iscell(Y))
   Y=num2cell(Y,2);
end

[N,M] = size(B);
ll  = zeros(size(Y));
sxi = zeros(N,N);    % sxi(i,j) = E(#(S_i --> S_j))
sgk = zeros(N,M);    % sgk(j,k) = E(#(O_k | S_j))
sg1 = zeros(N,1);    % sg1(i)   = E(#(S_i )


% loop over all sequences
for i=1:length(Y) % nb of seqs

   % select E-step algo
   if strcmpi(e_step, 'fb')
      [ll(i),ga,xi] = fb(Y{i},A,B,P);     
   elseif strcmpi(e_step,'ffbs')
      [ll(i),ga,xi] = ffbs(Y{i},A,B,P);
   elseif strcmpi(e_step,'fbns')
      [ll(i),ga,xi] = fbns(Y{i},A,B,P); 
   % fbns: no scaling (overflow for long sequence)
   else
      error('**** Uknown e_step algorithm (fb,ffbs,fbns) ****')
   end

   % Accumulate smoothed densities for EACH sequence (Yi)
   sg1 = sg1 + ga(:,1);
   sxi = sxi + xi;
   for k=1:M
      o_t = Y{i}==k; % positions (indices) where the obs = symbol k (in i'th Y)
      sgk(:,k) = sgk(:,k) + sum(ga(:,o_t),2);
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Update HMM params;

if adj_trans
   A = wk_stochastic(sxi+epsi,2);
end
if adj_emiss
   B = wk_stochastic(sgk+epsi,2);
end
if adj_prior
   P = wk_stochastic(sg1+epsi,1);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% average the loglik over all sequences

ll = mean(ll);
% ll = sum(ll); % better for comparing best ll value


