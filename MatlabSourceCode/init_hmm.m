function [A,B,P] = init_hmm(M,N,varargin)
%  [A,B,P] = init_hmm(M,N,varargin)
%
% Initialize a discrete output HMM
%
% INPUT:
%  M : number of symbols (alphabet size)
%  N : number of hidden states
%
% OPTIONAL ARGUMENTS;
%  type  : 'ergodic' or 'left-right' [ergodic]
%  method: 'random'  or 'uniform'  	 [random]
%  restrict_boundary: ascertain A is not uniform and contains no small values 
%  warn: throw a warning when boundaries are violated before re-initializing,
%        just for debugging. [false]
%   tol: used in check_boundary as how much difference is tolerated [0.01]
%  epsi: smoothes A and P, by replacing zeros with small values [sqrt(realmin))]
%        to avoid division by zeros in loglik computations of left-right HMMs
%
% This code requires improvement! 

% Shariful Islam: 09 October 2016 - 12:21:25

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Options:
[type,method,restrict_boundary,do_warn,tol,epsi] = ...
   process_options(varargin, 'type', 'ergodic', 'method','random',...
   'restrict_boundary', 0, 'do_warn',0, 'tol',0.01,'epsi', sqrt(realmin) );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check for typos and non-sense (strcmpi is case insensitive):
wk_assert(strcmpi(type,'ergodic') || strcmpi(type,'left-right'),...
  sprintf(' %s must be:''ergodic'' or ''left-right'' ',type))
wk_assert(strcmpi(method,'random') || strcmpi(method,'uniform'),...
   sprintf(' %s must be:''random'' or ''uniform'' ', method))
wk_assert(M>1,'wrong number of symbols M');
wk_assert(N>1,'wrong number of states N');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ERGODIC
if (strcmpi(type,'ergodic') && strcmpi(method,'random') )
   A = wk_stochastic(rand(N,N),2);
   B = wk_stochastic(rand(N,M),2);
   P = wk_stochastic(rand(N,1),1);

   if restrict_boundary
      % ascertain A matrix is not uniform and contains no small values
      % (i.e., close to 0)
      while check_boundary(A,tol,do_warn) 
         % Generate a uniform distribution of random numbers
         % on the interval [a,b] to eliminate small values:
         a = 0.01; b=0.99;
         A = a + (b-a) * rand(N,N);
         A = wk_stochastic(A,2);
      end
   end
elseif strcmpi(type,'ergodic') && strcmpi(method,'uniform')
   A = wk_stochastic(ones(N,N),2);
   B = wk_stochastic(ones(N,M),2);
   P = wk_stochastic(ones(N,1),1);
end

% LEFT-RIGHT
if strcmpi(type,'left-right') && strcmpi(method,'random')
   for j=1:N
      A(j,j)=rand;
      if j<N
         A(j,j+1)=rand;
      end
   end
   A = wk_stochastic(A+epsi,2);
   B = wk_stochastic(rand(N,M),2);
   P = wk_stochastic([1;zeros(N-1,1)+epsi],1);
elseif strcmpi(type,'left-right') && strcmpi(method,'uniform')
   for j=1:N
      A(j,j)=0.5;
      if j<N
         A(j,j+1)=0.5;
      end
   end
   A = wk_stochastic(A+epsi,2);
   B = wk_stochastic(ones(N,M),2); % Uniform B
   P = wk_stochastic([1;zeros(N-1,1)+epsi],1);
end

assert(wk_approxeq(sum(A,2),ones(N,1),1E-12),'A is not row stochastic');
assert(wk_approxeq(sum(B,2),ones(N,1),1E-12),'B is not row stochastic');
assert(wk_approxeq(sum(P,1),1,1E-12),'P is not row stochastic');

