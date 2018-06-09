function [fpc tpc auch] = mrroc_n(scores,lab,nb_thresh)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [fpc tpc auch] = mrroc_n(scores,lab,nb_thresh)
%
% Returns the Maximum Realizable ROC (mrroc) of ROC curves associated with the
% scores and labels (lab).
%
% INPUTS:
% scores: row-cell array, where each column contains the output scores
%         (or probabilities) of a classifier.
%   lab : true labels of the test (or validation) set. 
%	    	  1 = positive or target    
%		      0 = negative or nontarget 
% nb_thresh: number of sampled thresholds, (or number of bins). 
%
% OUTPUTS:
%   fpc: false postive rate of final convex hull or mrroc.
%   tpc: true postive rate of final convex hull or mrroc.
%  auch: area under the roc convex hull.
%
% Last updated by Shariful Islam: 26 January 2018 - 12:29:07 
% (mdsha_i@encs.concordia.ca)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin<3, nb_thresh=[]; end % all scores are considered (in myroc).
[nrow ncurves]=size(scores);
fpc=[]; tpc=[]; 
for n=1:ncurves
  [fp tp]=myroc_n(scores{n},lab,nb_thresh,n);
  [fp tp]=rocch(fp,tp);
  fpc=[fpc;fp];  %#ok<AGROW>
  tpc=[tpc;tp];  %#ok<AGROW>
end
[fpc tpc auch] = rocch(fpc,tpc);
