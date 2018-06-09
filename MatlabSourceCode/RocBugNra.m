function [fpr, tpr, auc, thr] = RocBugNra(scores,lab,nb_thresh)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [fpr, tpr, auc, thr] = RocBugNra(scores,lab,nb_thresh)
% 
% RocBugNra: Computes tpr,fpr, auc and unique thresholds.
%
% INPUTS:
% scores: the output predictions scores (or probabilities) of a classifier. The
%         degree of membership to the target (or positive) class.
% lab : true labels of the test (or validation) set. 
%		  0 = negative or nontarget 
%		  1 = positive or target    
% nb_thresh: number of sampled thresholds, (or number of bins).I.e., ROC
%     resolution. When empty all score values are considered (no sampling). 
%
% OUTPUTS:
%   fpr: false postive rate.
%   tpr: true postive rate.
%   auc: area under the roc curve.
%   thr: sampled thresholds. 
%
% Last updated by Shariful Islam: 25 January 2016 - 15:49:17 
% (mdsha_i@encs.concordia.ca)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 3 || isempty(nb_thresh)   % consider all scores  
  nb_thresh=[];
end
thresh=sample_scores(scores,nb_thresh);
thresh = sort(unique(thresh)); 
thresh = [thresh; +inf]; % add pt (0,0).
nb_thresh = length(thresh); 

lab = lab > 0;             
P   = sum( lab);          % # positives.
N   = sum(~lab);          % # negatives.
tpr = zeros(nb_thresh,1);
fpr = zeros(nb_thresh,1);

for i = 1:nb_thresh
    res = (scores > thresh(i));
    tpr(i) = sum( lab(res));
    fpr(i) = sum(~lab(res));
end

tpr = tpr./P; 
fpr = fpr./N;

tpr = sort(tpr,'ascend');
fpr = sort(fpr,'ascend');
auc = auroc(fpr,tpr);
thr = thresh;


