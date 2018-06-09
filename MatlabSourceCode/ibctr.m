function [fpr,tpr,auc,rs] = ibctr(scores,lab,ttb)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [fpr,tpr,auc,rs] = ibctr(scores,lab,ttb)
%
% IBCTR: Iterative Boolean Combination (Testing) of multi-ROC curves.
%
% Test the combination of IBCV (using ttb).
%
% INPUTS:
% scores: scores associated with each of the two ROC curves in a cell array.
%         socres={s1,...,sn}. 
% lab:    labels of the validation set (0=negative, 1=positive)
% ttb:    cell array of structure comprising: thresholds 1 (or combined
%         responses), thresholds 2 and the corresponding Boolean function.
%         ttb{iteration, number of ROC curves}
%         - iteration 1:
%           ttb{1,1}: contains the nb_thresh used in IBCV,
%                     to use the same sampling in here. 
%           ttb{1,2}: means thresholds of ROC1 are combined with those of ROC2.
%           ttb{1,2}.t1, .t2, .bf: provides the thresholds and Boolean function.
%           ttb{1,3}: means combined responses of ROC(1,2) are combined with
%                     the thresh of ROC3. and so on until ttb{1,n)
%         - iteration 2:
%           ttb{2,1}: means combined responses of ROC(1,..,n) of previous
%                     iteration are re-combined with thresholds of ROC1.
%           ttb{2,1}.ir, .th, .bf: provides the indexes in previous responses
%                (ir), the thresholds of ROC1 (th) and Boolean function.
%           ttb{2,2}: means combined responses of ROC(1,..,n) of previous
%                     iteration are re-combined with thresholds of ROC2
%           ttb{2,2}.ir, .th, .bf: provides the indexes in previous responses
%                (ir), the thresholds of ROC2 (th) and Boolean function.
%         - And so on.
%
% OUTPUTS:
% fpr:    false positive rate of overall ROCCH. 
% tpr:    true positive rate of overall ROCCH. 
% auc:    area under ROCCH.
%  rs:    responses of the overall convex hall (ROCCH).
%
% NB:     fpr,tpr and auc are the mapping of rs into the ROC space. They can be
%         computed from rs using: RESP2PTS and AUROC.
%
%
% Last updated by Shariful Islam: 15 February 2018 - 11:08:52 
% (mdsha_i@encs.concordia.ca)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tic_bcvt=tic;
scores(cellfun(@isempty,scores))=[]; % delete empty cells.
ncurves = length(scores);
niter = size(ttb,1);
nb_thresh = ttb{1,1}.nb_thresh;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% First iteration: 
% Combine all ROCs (using ttb{1,:}), and output their combined
% responses (r_prev) as well as the (fp,tp) of their rocch.

[fp,tp,auc,r_prev] = bctm(scores,lab,ttb);

fpr=fp; tpr=tp;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Iterate using BCT_RT: 
% At each iteration combine resulting responses (r_prev) with the scores
% (or thresh) of EACH ROC curve.
 
for iter=2:niter
  r_new=[]; % reset accumulated repsonses after each iteration. 
  for n=1:ncurves
    if ~isempty(ttb{iter,n})
      s  = scores{n};      % scores or tresh of ROC(n).
      ir = ttb{iter,n}.ir; % index in responses (r)
      t  = ttb{iter,n}.th; % thresh in ROC 3 (4, ...)
      bf = ttb{iter,n}.bf; % corresponding Boolean function.

      [fp tp rs] = bctrt(r_prev,ir,s,t,lab,bf,n);

      % Accumulate resulting responses from each newly combined ROC curve (rs),
      % at each iteration only. (Reset after each iteration).
      r_new=[r_new rs];   %#ok<AGROW>

      % Accumulate emerging ROCCH points from each newly combined ROC curve
      % for all iterations. (keep accumulating).
      fpr = [fpr;fp];     %#ok<AGROW>
      tpr = [tpr;tp];     %#ok<AGROW>

    end 
  end % n
  r_prev=r_new; 
end % iter

rs=r_prev; % just to output.

% convex hull of combined responses.
[fpr,tpr] = rocch(fpr,tpr); % can be omitted.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Include MRROC of original curves as a lower-bound in case of partial
% improvement. 
 
[fpc tpc]=mrroc_n(scores,lab,nb_thresh);  

% Final rocch for the Boolean Combinations and MRROC (as a lower-bound).
[fpr,tpr,auc]=rocch([fpr;fpc], [tpr;tpc]);

