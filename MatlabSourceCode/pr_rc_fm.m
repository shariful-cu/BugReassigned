function [pr, rc, fm] = pr_rc_fm(scores, lab, thresh)
% [pr, rc, fm] = pr_rc_fm(scores, lab, thresh)
% PR_RC_FM: Computes the precision, recall, and f-measure
% 
% INPUTS:
% scores: scores of each testing observation sequence
% lab: true labels of the testing set
% thresh: all the posible thresholds
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
nb_thresh = length(thresh);
pr = zeros(nb_thresh,1);
rc = zeros(nb_thresh,1);
fm = zeros(nb_thresh,1);
tp_fp = zeros(nb_thresh,1);
for i = 1:nb_thresh
    res = (scores <= thresh(i));
    rc(i) = sum( lab(res)); % true positive
    pr(i) = sum( lab(res)); % true positive
    tp_fp(i) = sum(~lab(res)) + pr(i); % true positive + false negative
    
    pr(i) = pr(i)/tp_fp(i);
    rc(i) = rc(i)/P;
    fm(i) = (2*pr(i)*rc(i))/(pr(i)+rc(i));
end

end