function [fp tp] = resp2pts(lab,r)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [fp tp] = resp2pts(lab,r)
%
% Map responses (r) into (fp,tp) pairs,
% using labels (lab). 
%
% Last updated by Shariful Islam: 21 June 2016 - 09:48:29 
% (mdsha_i@encs.concordia.ca)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

lab = lab>0;
r = r>0;
p = sum(lab);
n = sum(~lab);
[l np] = size(r);
tp = zeros(np,1);
fp = zeros(np,1);
for i=1:np
    tp(i) = sum( lab(r(:,i)));
    fp(i) = sum(~lab(r(:,i)));
end
tp = tp/p;
fp = fp/n;

