function auc = auroc(fp,tp)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% auc = auroc(fp,tp)
%
% Computes the area under the ROC curve, where tp and fp are column vectors
% defining the ROC or ROCCH curve of a classifier.
%
% Last updated by Shariful Islam: 16 February 2016 - 00:41:24 
% (mdsha_i@encs.concordia.ca)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
n=size(tp, 1);
auc=sum((fp(2:n) - fp(1:n-1)).*(tp(2:n)+tp(1:n-1)))./2;


