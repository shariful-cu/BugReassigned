function [pr, rc, fm, max_fm, best_idx] = f_measure(R, lab)
% tp = []; fp = [];
% fn = []; tn = [];

nb_thresh = size(R,2);
lab = lab > 0;             
P   = sum( lab);          % # positives.
% N   = sum(~lab);          % # negatives.
% nb_thresh = length(thresh);
pr = zeros(nb_thresh,1);
rc = zeros(nb_thresh,1);
fm = zeros(nb_thresh,1);
max_fm = -inf;
tp_fp = zeros(nb_thresh,1);
for i = 1:nb_thresh
    res = R(:,i);
    res = res > 0;
    rc(i) = sum( lab(res)); % true positive
    pr(i) = sum( lab(res)); % true positive
    tp_fp(i) = sum(~lab(res)) + pr(i); % true positive + false negative
    
    pr(i) = pr(i)/tp_fp(i);
    rc(i) = rc(i)/P;
    fm(i) = (2*pr(i)*rc(i))/(pr(i)+rc(i));
    if (fm(i) > max_fm)
        max_fm = fm(i);
        best_idx = i;
    end
end

end