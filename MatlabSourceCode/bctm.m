function [fpr,tpr,auc,rs] = bctm(scores,lab,ttb)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [fpr,tpr,auc,rs] = bct_m(scores,lab,ttb)
%
% BCT_M: Boolean Combination (Testing) of Multiple ROC curves (resulting 
%             from  BCV_M).
%
% INPUTS:
% scores: scores associated with each ROC curves in a cell array.
%           - The order of classifiers' scores (in scores) MUST be the same as
%             the order employed when combining with BCV_M.              
%    lab: labels of the validation set (0=negative, 1=positive)
%    ttb: cell array of thresholds and Boolean functions (output from BCV_M).   
%
% OUTPUTS:
%  fpr:  false positive rate of overall ROCCH. 
%  tpr:  true positive rate of overall ROCCH. 
%  auc:  area under ROCCH.
%   rs:  responses of the overall convex hall (ROCCH).
%
%
% Last updated by Shariful Islam: 17 February 2018 - 14:25:23 
% (mdsha_i@encs.concordia.ca)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fpr=[];tpr=[];  
ncurves=length(scores);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% First two ROCs:
s1 = scores{1};
s2 = scores{2};
t1 = ttb{1,2}.t1;
t2 = ttb{1,2}.t2;
bf = ttb{1,2}.bf;

[fp tp rs] = bcttt(s1,t1,s2,t2,lab,bf);

fpr = [fpr;fp];
tpr = [tpr;tp];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Remaining ROC curves:
for n=3:ncurves
    s  = scores{n};
    t1 = ttb{1,n}.t1; % index in responses (rs).
    t2 = ttb{1,n}.t2; % thresh of ROC 3 (4,...,ncurves).
    bf = ttb{1,n}.bf;

    [fp tp rs] = bctrt(rs,t1,s,t2,lab,bf,n);
    % acummulate to output the rocch.
    fpr = [fpr;fp];   %#ok<AGROW>
    tpr = [tpr;tp];   %#ok<AGROW>
end % n

[fpr,tpr,auc]=rocch(fpr,tpr); % final ROCCH of BCM.

