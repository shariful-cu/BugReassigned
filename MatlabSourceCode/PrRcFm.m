function [pr, rc, fm] = PrRcFm(rr, lab)
% [pr, rc, fm] = PrRcFm(rr, lab)
% PR_RC_FM: Computes the precision, recall, and f-measure
% 
% INPUTS:
% rr: responses of each crisp detectors
% lab: true labels of the testing set
% 
% OUTPUTS:
% pr: precision of each crisp detector
% rc: recall of each crisp detector
% fm: f-measure of each crisp detector
% Code needs improvement!

% Last updated by Shariful Islam: 19 February 2018 - 14:25:23 
% (mdsha_i@encs.concordia.ca)

lab = lab > 0;             
P   = sum( lab);          % # positives.
% N   = sum(~lab);          % # negatives.
no_cd = length(rr(1,:));
pr = zeros(no_cd,1);
rc = zeros(no_cd,1);
fm = zeros(no_cd,1);
tp_fp = zeros(no_cd,1);
for i = 1:no_cd
    res = rr(:,i);
    res = res>0;
    rc(i) = sum(lab(res)); % true positive
    pr(i) = sum( lab(res)); % true positive
    tp_fp(i) = sum(~lab(res)) + pr(i); % true positive + false negative
    
    pr(i) = pr(i)/tp_fp(i);
    rc(i) = rc(i)/P;
    fm(i) = (2*pr(i)*rc(i))/(pr(i)+rc(i));
end

end