function [seqs, lab, nonra, nora] = ldseqs(path)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   [seqs, lab, nonra, nora] = ldseqs(path)
% 
%   LDSEQS: LOADING "Not reassigned" & "Reassigned" Sequences as a
%   Validation/Testing dataset
% 
% INPUTS:
% path: directory where the sequenes are stored

% OUTPUTS:
% seqs: stored the loaded validation/testing sset 
% lab : true labels of the test (or validation) set. 
%		  0 = negative or nontarget 
%		  1 = positive or target    
% nonra: number of observations for the "Not reassigned" class label (0)
% nora: number of observations for the "Reassigned" class label (1)
% Last updated by Shariful Islam: 25 January 2018 - 15:49:17 
% 
% Code needs the improvement
% Last updated by Shariful Islam: 25 January 2018 - 15:49:17 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% loading the "not reassigned" sequences
ldpath = strcat(path, 'Nra_seqs.mat');
seqsNra_1 = importdata(ldpath);

% filtering the sequences with the length only 1 or zero 
seqsNra = cell(1,1); idx = 1;
for i = 1 : length(seqsNra_1)
    if(length(seqsNra_1{i,1})<=1)
        continue;
    else
       seqsNra{idx,1} = seqsNra_1{i,1};
       idx = idx + 1;
    end
end

nonra = length(seqsNra);
labNra = zeros(nonra,1);

% loading the "reassigned" sequences 
ldpath = strcat(path, 'Ra_seqs.mat');
seqsRa_1 = importdata(ldpath);

% filtering the sequences with the length only 1 or zero 
seqsRa = cell(1,1); idx = 1;
for i = 1 : length(seqsRa_1)
    if(length(seqsRa_1{i,1})<=1)
        continue;
    else
       seqsRa{idx,1} = seqsRa_1{i,1};
       idx = idx + 1;
    end
end
nora = length(seqsRa);
labRa = ones(nora,1);

% marger all the loaded sequences and their corresponding labels
seqs = [seqsRa; seqsNra];
lab = [labRa; labNra];