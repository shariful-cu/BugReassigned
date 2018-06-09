function [fpr,tpr,auc,ttb,rs] = ibcvr(scores,lab,nb_thresh,max_iter,tol,fun)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% IBCV: Iterative Boolean Combination (Validation) of multi-ROC curves.
%
% Uses BCV_M to combine n ROC curves, then iterate while re-combining the
% resulting responses of previous iteration with the thresholds of each ROC
% curve, until the ROCCH stops improving. 
%
% INPUTS:
% scores: Scores associated with each of the two ROC curves in a cell array.
%         socres={s1,...,sn}.
% lab:    Labels of the validation set (0=normal, 1=anomaly)
%
% OPTIONS:
%  'nb_thresh': Number of thresholds to be sampled from the associated
%               scores with each ROC curve for a lower complexity.
%               - When nb_thresh=[], consider all scores, i.e.,
%                 no sampling  [default].
%               - in this case a warning is thrown, which can be turned off by:
%                  warning('off','BC:scores') 
%               - nb_thresh is passed to bct_m through ttb{1,1}.nb_thresh
%                 (see ttb below).
%        'fun': Array of Boolean functions for combining two detectors,
%               such as AND, OR, XOR, etc. [1:10] (ALL).
%               Selecting fewer functions is also possible, e.g., ('fun', [1,5])
%               uses only AND and OR.
%   'max_iter': Maximun number of iteration allowed for the algorithm 
%        'tol': Tolerance in difference between AUCs of ROCCH iter and iter-1 [1E-3]
%
% OUTPUTS:
% fpr:    false positive rate of overall ROCCH. 
% tpr:    true positive rate of overall ROCCH. 
% auc:    area under ROCCH.
% rs:     responses of the overall convex hall (ROCCH).
%
% ttb:    cell array of structure comprising: thresholds 1 (or combined
%         responses), thresholds 2 and the corresponding Boolean function.
%         ttb{iteration, number of ROC curves}
%         - iteration 1:
%           ttb{1,1}: contains the nb_thresh 
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
%
% Last updated by Shariful Islam: 04 February 2018 - 16:37:52 
% (mdsha_i@encs.concordia.ca)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
if nargin < 6, fun = 1:10; end
if nargin < 5, tol = 1E-3; end
if nargin < 4, max_iter = 20; end
if nargin < 3, nb_thresh = []; end
 
ncurves = length(scores);

% Sampling or not sampling thresh:
if isempty(nb_thresh)   % use all scores (no sampling). 
  thresh=scores;
else                    % sample scores into nb_thresh thresholds.
  thresh=cell(1,ncurves);
  for n=1:ncurves 
    thresh{n}=sample_scores(scores{n},nb_thresh);
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% First iteration:
% Combine all ROCs and output their fused resopnses (r_prev), as
% well as their rocch (ch_prev).

iter=1;
tic_global=tic; tic_bcv=tic;
fprintf(1,'\n***************************************************************\n')
fprintf(1,'WPIBC: Weighted Pruning Iterative Boolean Combination (Valid):\n')
 
% BCV:
[fp,tp,auc,ttb,r_prev]= bcvm(scores,lab,nb_thresh,fun);

ch_prev=[fp,tp];

fprintf('iter=%2d :  auc=%.4f (# ch pts=%2d) time=%7.3f sec \n',...
  iter,auc,length(ch_prev),toc(tic_bcv));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Successive iterations:
% At each iteration combine the responses (r_prev) with each curve, fuse new
% responses, check if it improved over previous iteration, then update the
% responses. Re-iterate until the convex hull stops improving.

for iter=2:max_iter
  r_new=[];      
  tic_iter=tic;
  for n=1:ncurves
    s=scores{n}; t=thresh{n};
    [rs,IR,TH,BF] = bcvrt(r_prev,[],s,t,lab,fun,n);

    % Accumulate resulting responses from each newly combined ROC curve (rs).
    r_new=[r_new rs];   %#ok<AGROW>

    % Store combinations.
    ttb{iter,n}.ir = IR;
    ttb{iter,n}.th = TH;
    ttb{iter,n}.bf = BF;

  end % n

  % Compute the new convhull of combinations. 
  [ff tt]=resp2pts(lab,r_new);
  [FP TP AA IX]=rocch(ff,tt);
  ch_new=[FP,TP]; 

  % Check if this current iteration has improved over previous convex hull.
  [ch_new,improved,auc] = check_convhull(ch_new,ch_prev,tol);
  if improved    
    ch_prev = ch_new; 
    r_prev= r_new(:,IX);  
    fprintf('iter=%2d :  auc=%.4f (# ch pts=%2d) time=%7.3f sec \n',...
      iter,auc,length(ch_new),toc(tic_iter));
  else 
    ttb(iter,:) = []; % back-off.
    break;
  end 
end % iter

rs=r_prev;  
fpr=ch_prev(:,1);
tpr=ch_prev(:,2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Include MRROC of original curves as a lower-bound in case of partial
% improvement. 

[fpc tpc]=mrroc_n(scores,lab,nb_thresh);  
  
% Final rocch for the Boolean Combinations and MRROC (as a lower-bound).
[fpr,tpr,auc]=rocch([fpr;fpc], [tpr;tpc]);

fprintf(1, 'Total Time = %.3f sec\n',toc(tic_global))
fprintf(1,'***************************************************************\n')

