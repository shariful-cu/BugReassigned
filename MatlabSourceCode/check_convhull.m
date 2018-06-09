function [NEW,improved,AUC] = check_convhull(NEW,OLD,tol)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  [NEW,improved,AUC] = check_convhull(NEW,OLD,tol)
%
% Check if NEW convex hull has improved over previous (OLD) one, up to tol
%
% OUTPUTS:
% NEW: the overall new convex hull.
% improved: is true if the AUC of overall NEW convex hull (NEW and OLD)
%           is greater than that of OLD, or AUC=1. Otherwise improved = false. 
%
% Last updated by Shariful Islam: 02 February 2018 - 16:17:58 
% (mdsha_i@encs.concordia.ca)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
if nargin < 3
  tol = 1E-3;
end

FP = [NEW(:,1);OLD(:,1)];
TP = [NEW(:,2);OLD(:,2)];
auc=auroc(OLD(:,1),OLD(:,2)); % old convhull.
[FPR TPR AUC]=rocch(FP,TP);   % new convhull.

if (AUC==1) || (AUC > (auc + tol))
  improved = true;
  NEW = [FPR TPR]; 
else
  improved = false;
  NEW = OLD;
  AUC = auc;
end

