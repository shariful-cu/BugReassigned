function [fpr tpr rs auch] = bcttt(s1,t1,s2,t2,lab,bf)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [fpr tpr rs] = bct_tt(s1,t1,s2,t2,lab,bf)
%
% BCT_TT: Boolean Combination (Testing) of Thresholds with Thresholds.
%
% Test combination previously achieved by BCV_TT (validation) using test sets.
% Combine selected thresholds (t1,t2) with corresponding Boolean functions(bf)
% using the new scores (s1,s2) of the same classifiers on the labeled (lab)
% test set.
%
% INPUTS:
% s1: scores of the 1st detector (test set) - 1st ROC.
% t1: selected thresholds on the 1st ROC (validation set).
% s1: scores of the 2nd detector (test set) - 2nd ROC.
% t2: selected thresholds on the 2nd ROC (validation set).
% lab: labels of the test set (0=negative, 1=positive)
% bf: corresponding Boolean function for each two thresholds (from bcv_tt): 
%      ROCHH(i) --> BC( t1(i),bf(i),t2(i))
%
% OUTPUTS:
% fpr: false positive rate realized on the test set.
% tpr: true positive rate realized on the test set.
% rs: responses realized on the test set. This a matrix where each vector
%     contains the responses of one data point (it can be mapped to (fpr,tpr)
%     using RESP2PTS.
% auch: area under the ROCCH
%
% Last updated by Shariful Islam: 21 January 2018 - 21:32:33 
% (mdsha_i@encs.concordia.ca)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

lab = lab>0;          
p   = sum( lab);      % # positives.
n   = sum(~lab);      % # negatives.
l   = length(lab);    % length of test labels (or samples).
nbf = length(bf);     % number of Boolean functions, same length as t1 and t2.
fpr = zeros(nbf,1);
tpr = zeros(nbf,1);
rs  = false(l,nbf);

for i=1:nbf
    b = bf(i);
%     r_1 = (s1 >= t1(i));
    r_1 = (s1 > t1(i)); %odd order means NRA
    
%     r_2 = (s2 >= t2(i));
    r_2 = (s2 <= t2(i)); %even order means RA
    switch b;
        case 1 %----------------> 'A AND B'
            r =   r_1 &  r_2;
        case 2 %----------------> 'NOT A AND B'
            r =  ~r_1 &  r_2;
        case 3 %----------------> 'A AND NOT B'
            r =   r_1 & ~r_2;
        case 4 %----------------> 'A NAND B'
            r = ~(r_1 &  r_2);
        case 5 %----------------> 'A OR B'
            r =   r_1 |  r_2;
        case 6 %----------------> 'NOT A OR B'; 'A IMP B'
            r =	 ~r_1 |  r_2;
        case 7 %----------------> 'A OR NOT B' ;'B IMP A'
            r =   r_1 | ~r_2;
        case 8 %----------------> 'A NOR B'
            r = ~(r_1 | r_2);
        case 9 %----------------> 'A XOR B'
            r =  xor(r_1,r_2);
        case 10 %----------------> 'A EQV B'
            r = ~xor(r_1,r_2);
        otherwise
            error('\n\n Unknown Boolean function in BCT_TT.\n\n')
    end
    tpr(i) = sum( lab(r));
    fpr(i) = sum(~lab(r));
    rs(:,i) = r;
end
fpr = fpr./n;
tpr = tpr./p;
auch = auroc(fpr,tpr);



