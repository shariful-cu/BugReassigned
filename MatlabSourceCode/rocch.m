function [fp,tp,auch,idx] = rocch(fp,tp)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [fp,tp,auch,idx] = rocch(fp,tp)
%
% Computes the ROC Convex Hull (ROCCH):
% The smallest convex set containing the points of the ROC curve,
%
% Inputs:
%   fp: false postive rate of ROC curve(s).
%   tp: true postive rate of ROC curve(s).
% Outputs:
%   fp: false positive rate of the ROCCH.
%   tp: true positive rate of the ROCCH.
% auch: area under the ROCCH.
%  idx: indexes of selected points from (fp,tp) that defines the ROCCH.
%
% Last updated by  Shariful Islam: 03 October 2016 - 11:11:56
% Added convhull(..., 'simplify', true) for Matlab version > 2009a
% (mdsha_i@encs.concordia.ca)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

npts=length(fp);

% Adding pt (1,0) to close the square
fp=[fp; 1];
tp=[tp; 0];

% [idx, auch] = convhull(fp,tp); % Matlab <= 2009a
[idx, auch] = convhull(fp,tp,'simplify',true); % Matlab > 2009a
% removing vertices that do not contribute to the area/volume of the convex
% hull, the default is false

idx = unique(idx);

idx = idx(idx<=npts);
fp = fp(idx);
tp = tp(idx);

% When auc=1 (maximized), return pt(0,0) pt(0,1) and pt(1,1).
if auch==1
  fp=[0;0;1];
  tp=[0;1;1];
  return
end

% re-order just for plotting.
A = [fp tp idx];
AA = sortrows(A);
fp = AA(:,1);
tp = AA(:,2);
idx= AA(:,3);


