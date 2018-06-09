function [fpr tpr rs auch] = bctrt(r,ir,s,t,lab,bf,n)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [fpr tpr rs] = bct_rt(r,ir,s,t,lab,bf)
%
% BCT_RT: Boolean Combination (Testing) of Responses with Thresholds.
%
% Test combination previously achieved by BCV_RT (validation) using test sets.
% Combine new responses (r) and scores (s) according to previously selected
% indexes (ir) and thresholds (t) with the corresponding Boolean functions(bf)
% of the same classifiers on the labeled (lab) test set.
%
% INPUTS:
% r  : responses of 1st (1st ROC) or combined responses of several detectors
%      (several combined ROC curves) - test set.
% ir : indexes of selected responses from r (validation set).
% s  : scores of the 2nd detector or newly added detector  (test set).
% t  : selected thresholds from the 2nd or newly added ROC (validation set).
% lab: labels of the test set (0=negative, 1=positive)
% bf: corresponding Boolean function for each two thresholds (from bcv_tt): 
%      ROCHH(i) --> BC( r(ir(i)),bf(i), t(i)).
%
% OUTPUTS:
% fpr: false positive rate realized on the test set.
% tpr: true positive rate realized on the test set.
% rs: responses realized on the test set. This a matrix where each vector
%     contains the responses of one data point (it can be mapped to (fpr,tpr)
%     using RESP2PTS.
% auch: area under ROCCH.
%
% Last updated by Shariful Islam: 26 January 2018 - 08:59:23 
% (mdsha_i@encs.concordia.ca)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if sum(r(:,1)) ~= 0
   r = [false(size(r,1),1) r]; % include pt (0,0).
end

lab = lab>0;         
p   = sum( lab);     % # positives.
n   = sum(~lab);     % # negatives.
l   = length(lab);   % length of test labels (or samples).
nbf = length(bf);    % number of Boolean functions, also nb of cols in r1 or r2.
fpr = zeros(nbf,1);
tpr = zeros(nbf,1);
rs  = false(l,nbf);

for i=1:nbf
    b = bf(i);
    r_1 = r(:,ir(i));
    if(mod(n,2))
        r_2 = (s > t(i)); %odd
     else
        r_2 = (s <= t(i)); %even
     end
%     r_2 = (s >= t(i));
    switch b;
        case 1 %----------------> 'A AND B'
            r12 =   r_1 &  r_2;
        case 2 %----------------> 'NOT A AND B'
            r12 =  ~r_1 &  r_2;
        case 3 %----------------> 'A AND NOT B'
            r12 =   r_1 & ~r_2;
        case 4 %----------------> 'A NAND B'
            r12 = ~(r_1 &  r_2);
        case 5 %----------------> 'A OR B'
            r12 =   r_1 |  r_2;
        case 6 %----------------> 'NOT A OR B'; 'A IMP B'
            r12 =	 ~r_1 |  r_2;
        case 7 %----------------> 'A OR NOT B' ;'B IMP A'
            r12 =   r_1 | ~r_2;
        case 8 %----------------> 'A NOR B'
            r12 = ~(r_1 | r_2);
        case 9 %----------------> 'A XOR B'
            r12 =  xor(r_1,r_2);
        case 10 %----------------> 'A EQV B'
            r12 = ~xor(r_1,r_2);
        otherwise
            error('\n\n Unknown Boolean function in BCT_RT.\n\n')
    end
    tpr(i)  = sum( lab(r12));
    fpr(i)  = sum(~lab(r12));
    rs(:,i) = r12;
end
fpr = fpr/n;
tpr = tpr/p;
auch = auroc(fpr,tpr);



