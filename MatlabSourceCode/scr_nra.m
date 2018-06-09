function [scores, auc] = scr_nra(path, seqs, lab, no_hmms, nb_thresh)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   [scores, auc] = scr_nra(path, seqs, lab, no_hmms, nb_thresh)
% 
%   SCR_NRA: Compute the scores of multiple HMMs soft detectors
% 
% INPUTS:
% path: directory of the trained HMMs parameters 
% seqs: sequences of the validation/testing set
% lab : true labels of the test (or validation) set. 
%		  0 = negative or nontarget 
%		  1 = positive or target   
% no_hmms: number of trained HMMs soft detectors
% nb_thresh: number of sampled thresholds, (or number of bins).I.e., ROC
%     resolution. When empty all score values are considered (no sampling).
% 
% OUTPUTS:
% scores: computed scores for all the observation sequences
%  auc:  area under ROCCH
% 
% Code needs improvement
% 
% Last updated by Shariful Islam: 25 January 2018 - 15:49:17 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

noHMM = length(no_hmms);
scores = cell(1,noHMM); 
% aucRa = zeros(noHMM,1); 
auc = zeros(noHMM,1); 
idx = 1;
for k=1 : noHMM % Order is mandatory: 1st Nra then RA, then Nra, ...  
    filePath = strcat(path, 'NraHMM_', num2str(no_hmms(k)), '.mat');
    trn_HMM = importdata(filePath);
    A = trn_HMM.A; B = trn_HMM.B; P = trn_HMM.P;
    scr = test_forward(seqs, A, B, P);
    scores{1,idx} = scr; idx = idx + 1;
    [~,~,au,~] = RocBugNra(scr,lab,nb_thresh);
    auc(k,1) = au;
end