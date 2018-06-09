function [fpr,tpr,auc,ttb,rs] = bcvm(scores,lab,nb_thresh,fun)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [fpr,tpr,auc,ttb,rs] = bcvm(scores,lab,nb_thresh,fun)
%
% BCVM: Boolean Combination (Validation) of Multiple ROC curves.
%
% Combine 1st TWO ROCs (using bcv_tt), then combine their resutling responses
% with the third, and so on. 
%
% INPUTS:
%     scores: scores associated with ROC each curves in a row-cell array.
%        lab: Labels of the validation set (0=negative, 1=positive)
%
%  nb_thresh: Number of bins for sampling thresholds. When nb_thresh=[], all
%             scores are considered. 
%        fun: Array of Boolean functions for combining two detectors, such as
%             AND, OR, XOR, etc. [1:10] (ALL). Selecting fewer functions is
%             also possible, e.g., (fun=[1,5], employs AND and OR only).
%
% OUTPUTS:
% fpr:    false positive rate of overall ROCCH. 
% tpr:    true positive rate of overall ROCCH. 
% auc:    area under ROCCH.
%  rs:    responses of the overall convex hall (ROCCH).
%
% ttb:    (Threshold-Threshold-Boolean) cell array of structure comprising:
%         thresholds 1 (or combined responses), thresholds 2 and the
%         corresponding Boolean function.
%
% Last updated by Shariful Islam: 16 February 2018 - 09:45:25 
% (mdsha_i@encs.concordia.ca)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 4, fun = 1:10; end
if nargin < 3, nb_thresh = []; end

ncurves = length(scores);

if isempty(nb_thresh)   % use all scores 
  thresh=scores;
else                    % sample socres into nb_thresh bins
  thresh=cell(1,ncurves);
  for n=1:ncurves 
    thresh{n}=sample_scores(scores{n},nb_thresh);
  end
end

fpr=[]; tpr=[];
ttb=cell(1,ncurves);
ttb{1,1}.nb_thresh = nb_thresh; % to provide bct_m with same nb_thresh.

fprintf(1,'\n*********************************************************\n')
fprintf(1,'BCVM: Cumulative Boolean Combination of Multiple ROC curves:\n')
fprintf(1,'Number of combined ROC curves=%d (#thresh=%d)\n',ncurves,nb_thresh);
fprintf(1,'combining: roc=1-2 ');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% First 2 ROC curves:
tic
[RS,t1,t2,bf,fp,tp,au] = bcvtt(scores{1},thresh{1},scores{2},thresh{2},...
                                   lab,fun);
time=toc;
fprintf(1,'auc=%.4f (# ch pts=%2d) time=%.3f sec.\n',au,length(fp),time)

% Acummulate to output the ROCCH.
fpr=[fpr;fp];
tpr=[tpr;tp];

% Store thresholds and Boolean functions.
ttb{1,2}.t1 = t1; % t1 thresholds on ROC 1.
ttb{1,2}.t2 = t2; % t2 thresholds on ROC 2.
ttb{1,2}.bf = bf; % corresponding Boolean functions.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Remaining 2 ROC curves:
for n=3:ncurves
   fprintf(1,'adding up: roc=  %d ',n);
   tic
   [RS,t1,t2,bf,fp,tp,au] = bcvrt(RS,[],scores{n},thresh{n},lab,fun,n);% doplot);
   time = toc;
   fprintf(1,'auc=%.4f (# ch pts=%2d) time=%.3f sec.\n',au,length(fp),time)

   % Acummulate to output the ROCCH.
   fpr=[fpr;fp];  %#ok<AGROW>
   tpr=[tpr;tp];  %#ok<AGROW>

   ttb{1,n}.t1 = t1; % t1 indexes in RS.
   ttb{1,n}.t2 = t2; % t2 thresholds of ROC 3 (4,...,ncurves).
   ttb{1,n}.bf = bf; % corresponding Boolean  function.
end % n
rs = RS;
[fpr,tpr,auc]=rocch(fpr,tpr);  % final ROCCH of BCM.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Include MRROC of original curves as a lower-bound in case of partial
% improvement. 

[fpc tpc]=mrroc_n(scores,lab,nb_thresh);  
  
% Final rocch for the Boolean Combinations and MRROC (as a lower-bound).
[fpr,tpr,auc]=rocch([fpr;fpc], [tpr;tpc]);



