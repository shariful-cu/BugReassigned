function [ll,ga,sxi] = fb(Y,A,B,P)
% [ll,ga,sxi] = fb(Y,A,B,P)
%
% Forward-Backward for DISCRETE symbol HMMs 
%
% INPUT:
% Y = {o_1,o_2,...,o_T} = o_{1:T} is a ROW vector of pos integers, i.e,
%      ONE sequence of observation symbols
% P(j)   [N,1] is the probability of starting in state j
% A(i,j) [N,N] is the probability of going to j next if you are now in i
% B(j,k) [N,M] is the probability of emitting symbol k if you are in state j
%
% OUTPUT:
% Smoothed conditional densities (given all observations o_{1:T} and the model):
% ga(i,t)  = P(q_t=i|Y) are the state densities    [N,T] (gamma is a Matlab fun)
% sxi(i,j) = sum_t P(q_t=i,q_t+1=j|Y) trans counts [N,N]
%
% ll  = P(Y|model) = sum(log(c_t))/T; (normalized by sequence length)
% c_t = P(o_t|o_{1:t-1}) = sum_i(alpha(i,t)) are the scaling factors
%
% alpha(i,t) = P(q_t=i,o_{1:t})   given the model,[N,T]
% beta(i,t)  = P(o_{t+1:T}|q_t=i) given the model, [N,T]
%
% See also FFBS, BW1, and LOGLIK

% Last updated by Shariful Islam: 28 August 2016 - 11:40:14
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ASSERT=0; % if 0 no checking for speed (1 some checking, 2 extensive checking).

% Initial checking and nonsense (time consuming checking) 
[N,M] = size(B);
if ASSERT==1
    wk_assert(size(P,1)==N);% P is a column vector
    wk_assert(max(Y)<=M); 	% check for residual effects 
end
if ASSERT==2
    wk_assert(min(Y)>=1); 	% check for residual effects 
end
Y = Y(Y>0); 			          % eliminate trailing zeros (sequences delimitations)
T = length(Y);
if ASSERT==1
    wk_assert(T>0);
end

% allocate space for forward, backward variables and for scale
alpha=zeros(N,T); beta=zeros(N,T); c=zeros(1,T);

% compute the multinomial distribution of each obs symbol o_t of Y (with o_t in
% 1:M) according to all (N) states: bb(i,o_t) = B(o_t,i); for i=1:N and t=1:T
bb = B(:,Y);
if ASSERT==2
    [rows,cols]=size(bb);
    wk_assert(rows==N && cols==T);
end


% compute alpha, beta, and c (scale)
t=1; %#ok<NASGU>
alpha(:,1) = P.*bb(:,1);
c(1)       = sum(alpha(:,1));
alpha(:,1) = alpha(:,1)/c(1);
for t=2:T
	alpha(:,t) = (A'*alpha(:,t-1)).*bb(:,t);
	c(t)       = sum(alpha(:,t));
	alpha(:,t) = alpha(:,t)/c(t);
end


ll = sum(log(c))/T;

% no need to continue if only the likelihood is needed (evaluation)
if nargout==1; return; end

beta(:,T) = 1/c(T); 
for t=(T-1):-1:1
    beta(:,t) = A*(beta(:,t+1).*bb(:,t+1))/c(t); 
end

% compute sxi; the sum of xi over all time steps.
sxi = zeros(N,N);
for t=1:(T-1)
    xi = A.*(alpha(:,t)*(beta(:,t+1).*bb(:,t+1))'); 
    sxi = sxi + xi;
end

% compute ga (gamma)
ga = (alpha.*beta).*(ones(N,1)*c); 
if ASSERT==2
	wk_assert(wk_approxeq(sum(ga,1),ones(1,T)));
end

