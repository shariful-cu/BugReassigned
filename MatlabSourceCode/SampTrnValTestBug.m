%% ===================sampling Bug datasets==================
close('all');
clear;

seq_nra = importdata('/Users/Shariful/Documents/BugDataKorosh/Dataset/PreparedData/Gnome/OriginalSeqDataset/Product/ProductNotReAsgnd_M2K.mat');
seq_ra = importdata('/Users/Shariful/Documents/BugDataKorosh/Dataset/PreparedData/Gnome/OriginalSeqDataset/Product/ProductReAsgnd_M2K.mat');

% ====sampling training (70%), validation(10%), & testing (30%) sequences
% (not re-assigned) 
no_samp = length(seq_nra);
% training not re-assigned sequences
idxTran = randperm(no_samp, uint64(no_samp * 0.70)); 
trnNraSeq = seq_nra(idxTran,1);
idxTest = ones(1,no_samp);
idxTest(idxTran) = 0;
idxTest = idxTest>0;
testNraSeq = seq_nra(idxTest,1); % testing not reassigned sequences

% 10% validation from testing not re-assigned sequences
no_samp = length(testNraSeq);
idxValNra = randperm(no_samp, uint64(no_samp * 0.10));
valNraSeq = testNraSeq(idxValNra,1);
idxTest = ones(1,no_samp);
idxTest(idxValNra) = 0;
idxTest = idxTest>0;
% testing not reassigned sequences(after taking validation sequences)
testNraSeq = testNraSeq(idxTest,1); 

% ====sampling training (60%), validation(10%), & testing (30%) sequences
% (re-assigned) 
no_samp = length(seq_ra);
% training  re-assigned sequences
idxTran = randperm(no_samp, uint64(no_samp * 0.60)); 
trnRaSeq = seq_ra(idxTran,1);
idxTest = ones(1,no_samp);
idxTest(idxTran) = 0;
idxTest = idxTest>0;
testRaSeq = seq_ra(idxTest,1); % testing not reassigned sequences

% 10% validation from testing re-assigned sequences
no_samp = length(testRaSeq);
idxValRa = randperm(no_samp, uint64(no_samp * 0.10));
valRaSeq = testRaSeq(idxValRa,1);
idxTest = ones(1,no_samp);
idxTest(idxValRa) = 0;
idxTest = idxTest>0;
%testing reassigned sequences (after taking validation sequences)
testRaSeq = testRaSeq(idxTest,1); 

% ====saving for training with reassigned final training, validation, and testing sets and their labels
save('/Users/Shariful/Documents/BugReAssgn/PreparedData/Gnome/Sampling/Product/TrnNra_seqs.mat', 'trnNraSeq');
save('/Users/Shariful/Documents/BugReAssgn/PreparedData/Gnome/Sampling/Product/ValNra_seqs.mat', 'valNraSeq');
save('/Users/Shariful/Documents/BugReAssgn/PreparedData/Gnome/Sampling/Product/TestNra_seqs.mat', 'testNraSeq');

save('/Users/Shariful/Documents/BugReAssgn/PreparedData/Gnome/Sampling/Product/TrnRa_seqs.mat', 'trnRaSeq');
save('/Users/Shariful/Documents/BugReAssgn/PreparedData/Gnome/Sampling/Product/ValRa_seqs.mat', 'valRaSeq');
save('/Users/Shariful/Documents/BugReAssgn/PreparedData/Gnome/Sampling/Product/TestRa_seqs.mat', 'testRaSeq');

