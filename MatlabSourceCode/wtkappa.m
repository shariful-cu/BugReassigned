function kp_cof = wtkappa(ctgncy, wt)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   kp_cof = wtkappa(ctgncy,wt)
% 
%   WTKAPPA: Compute the weighted kappa aggrement coefficient between two
%   sof detectors
% 
% INPUTS:
% ctgncy: contingency matrix between two soft detectors
% wt: linear weighted matrix (identity matrix if it is not weighted)
% 
% OUTPUTS:
% kp_cof = computed weighted kappa coefficient
% 
% Code needs improvement
% 
% Last updated by Shariful Islam: 24 January 2018 - 15:49:17 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

n=sum(ctgncy(:)); %Sum of Matrix elements
ctgncy=ctgncy./n; %proportion
r=sum(ctgncy,2); %rows sum
s=sum(ctgncy); %columns sum
Ex=r*s; %expected proportion for random agree
% pom=sum(min([r';s]));
po=sum(sum(ctgncy.*wt));
pe=sum(sum(Ex.*wt));
kp_cof=(po-pe)/(1-pe);
end