function [A,B,P,llt,AA,BB] = bw(Y,A,B,P,varargin)
% [A,B,P,llt,AA,BB] = bw(Y,A,B,P,varargin)
%
% Train a discrete-output HMM using Baum-Welch
%
% This routine does the initialization and controls the number of
% iterations. See bw1.m for the code that does one iteration
%
% INPUT:
% Y: vector (or cell array of vectors if many sequences) of obs sym (positives)
% A,P,B: initial estimates of the parameters
% OUTPUT:
% A,B,P: new HMM parameters
% llt: vector of mean log likelihood (of training sequences) per iteration
% AA, BB: cell arrays of params at each iteration
%
% OPTIONAL ARGUMENTS:
% 'e_step' - Which algorithm is used for the E-step computation ['fb']:
%     'fb'     - forward-backward
%     'ffbs'   - forward-filter backward-smoothing
%     'effbs'  - effbs with linear memory see (Khreich2009)
%     'fbns'   - fb without scaling (overflows for large sequence)
% 'max_iter' - is the max nubmer of E-M iterations  [100]
% 'tol' - is the fractional change in log likelihood stopping creterion [1e-4]
% 'espi' - Smoothes the matrices not to contain zeros [1E-15]
%           accounts for unseen observation symbols in training
%		      for testing, also useful for left-right HMMs
% 'verbose' - if 0, do not ouptut [1]
%             if 1, print the loglik for 1st and last itrations
%             if 2, also plot the loglik at each iteration
%
% To clamp some of the parameters, so learning does not change them:
% 'adj_prior' - if 0, do not change prior [1]
% 'adj_trans' - if 0, do not change transmat [1]
% 'adj_emiss' - if 0, do not change obsmat [1]
%
% See also BW1 BWV

% Shariful Islam: 02 October 2016 - 04:20:32

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Options:
[e_step, max_iter, epsi, tol, verbose, adj_prior, adj_trans, adj_emiss] = ...
   process_options(varargin, 'e_step', 'fb', 'max_iter', 20,...
   'epsi',sqrt(realmin), 'tol', 1e-4, 'verbose', 1,...
   'adj_prior', 1, 'adj_trans', 1, 'adj_emiss', 1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Checking input and nonsense:
wk_assert(~isempty(A) && ~isscalar(A),...
   'Transition Matrix (A) is either empty or scalar!!');
wk_assert(~isempty(B) && ~isscalar(B),...
   'Emission Matrix (B) is either empty or scalar !!');
wk_assert(~isempty(P) && ~isscalar(P),...
   'Prior Vector (P) is either empty or scalar !!');
wk_assert(size(A,1)==size(B,1) && size(B,1)==size(P,1),...
   'Problem with HMM parameter sizes (A,B,P)');
wk_assert(strcmpi(e_step,'fb') || strcmpi(e_step,'ffbs') || ...
   strcmpi(e_step,'effbs') || strcmpi(e_step,'fbns'),...
   'e_step must be: ''fb'', ''ffbs'', ''effbs'', or ''fbns''\n%s')

if(~iscell(Y)),
   Y=num2cell(Y,2);
end

% Store A and B for init model
if nargout>4 || verbose>2 
   AA=reshape(A',1,[]);
end% row-wise
% e.g,. N=3 [a11 a12 a13 a21 a22 a23 ..]
if nargout>5 || verbose>3
   BB=reshape(B',1,[]);
end

tic

llt = loglik(Y,A,B,P);% store loglik for init model

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Loop up to max_iter or convergence
for iter=1:max_iter

   % one iter of BW (E-M step) for all train seqs
   [A,B,P] = bw1(Y,A,B,P,...
      'e_step',e_step, 'epsi', epsi,...
      'adj_prior', adj_prior, 'adj_trans', adj_trans, 'adj_emiss', adj_emiss);


   % Store A and B at each iteration
   if (nargout>4 || verbose>2) 
      AA(iter+1,:)=reshape(A',1,[]);
   end % row-wise
   if (nargout>5 || verbose>3)
      BB(iter+1,:)=reshape(B',1,[]);
   end % row-wise

   % Store mean loglik of training sequences according to the new model
   llt(iter+1,1) = loglik(Y,A,B,P);

   % convergence test on training sequences
   if((abs(llt(end)-llt(end-1))/((abs(llt(end))+abs(llt(end-1)))/2))<tol)
      break;
   end
end % iter
tt=toc;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Logging/Plotting
if verbose > 0            % print to command line
   fprintf(1,['BW:\tlogliktr start = %f end = %f (%4d iterations) '...
      '[%s]\t\t\t time: %.3f\n'], llt(1),llt(end),iter,e_step,tt);

   if verbose > 1;        % plot loglik
      figure; hold all; grid on; wk_fposition('TR');
      plot(llt,'-bx'); title(sprintf('BW (%s)',e_step));
      legend('train','Location','NorthEastOutside');
      xlabel('iteration'); ylabel('log-likelihood');

      if verbose>2;     % plot A at each iteration
         plot_matrix_iter(AA,[],'A');
         title(sprintf('BW (%s)',e_step));
         if verbose>3;  % plot B at each iteration
            plot_matrix_iter(BB,[],'B');
            title(sprintf('BW (%s)',e_step));
         end
      end
   end
end
end
