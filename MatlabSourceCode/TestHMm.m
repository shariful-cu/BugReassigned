close('all');
clear;

% Loading testing Not Reassigned (NRA) sequences
testSeqsNra_1 = importdata('/Users/Shariful/Documents/BugDataKorosh/Dataset/PreparedData/Gnome/Sampling/Component/ValNra_seqs.mat');
% Filtering sequences with length zero or one
testSeqsNra = cell(1,1); idx = 1;
for i = 1 : length(testSeqsNra_1)
    if(length(testSeqsNra_1{i,1})<=1)
        continue;
    else
       testSeqsNra{idx,1} = testSeqsNra_1{i,1};
       idx = idx + 1;
    end
end
testLabNra = zeros(length(testSeqsNra),1);

% Loading testing Reassigned (RA) sequences
testSeqsRa_1 = importdata('/Users/Shariful/Documents/BugDataKorosh/Dataset/PreparedData/Gnome/Sampling/Component/ValRa_seqs.mat');
% Filtering sequences with length zero or one
testSeqsRa = cell(1,1); idx = 1;
for i = 1 : length(testSeqsRa_1)
    if(length(testSeqsRa_1{i,1})<=1)
        continue;
    else
       testSeqsRa{idx,1} = testSeqsRa_1{i,1};
       idx = idx + 1;
    end
end
testLabRa = ones(length(testSeqsRa),1);

% Marging sequences from both classes
testSeqs = [testSeqsRa; testSeqsNra];
testLab = [testLabRa; testLabNra];


% loading trained HMM parameters
homPath= '/Users/Shariful/Documents/BugDataKorosh/Dataset/TrainHMM/Gnome/';
% homPath= '/Users/Shariful/Documents/BugDataKorosh/Dataset/TrainHMM';

% M = 56460; 
N = 110;
nb_thresh = 100;

% filePath = strcat(homPath, '/OSRA/', 'TrainHMM', num2str(N), '.mat');
filePath = strcat(homPath, 'ComponentRaHMM_', num2str(N), '.mat');
trn_HMM = importdata(filePath);

rAssA = trn_HMM.A; rAssB = trn_HMM.B; rAssP = trn_HMM.P;

% % filePath = strcat(homPath, '/OSNRA/', 'TrainHMM', num2str(N), '.mat');
% filePath = strcat(homPath, 'ComponentNraHMM_', num2str(N), '.mat');
% trn_HMM = importdata(filePath);
% 
% nrAssA = trn_HMM.A; nrAssB = trn_HMM.B; nrAssP = trn_HMM.P;

% Testing
scoresRa = test_forward(testSeqs, rAssA, rAssB, rAssP);
% scoresNra = test_forward(testSeqs, nrAssA, nrAssB, nrAssP);

% save('/Users/Shariful/Documents/BugDataKorosh/HMMScrEclps/OSTestScrNra_20.mat', 'scoresNra');
% save('/Users/Shariful/Documents/BugDataKorosh/HMMScrEclps/OSTestScrRa_20.mat', 'scoresRa');
% save('/Users/Shariful/Documents/BugDataKorosh/HMMScrEclps/OSTestLevel.mat', 'testLab');
% scores = [scoresRa scoresNra];

% res = scores(:,1) <= scores(:,2);


% class check further
% thRa = 76.8222;
thRa = mean(scoresRa(1:length(testSeqsRa)));
% thNra = mean(scoresNra(length(testSeqsRa)+1:end));
% update the scores
res = false([length(testSeqs),1]);
for i = 1 : length(scoresRa(:,1))
    if(scoresRa(i,1) <= thRa)
        res(i,1) = true;
%     elseif(scoresRa(i,1) < scoresNra(i,1))
%     elseif(scoresNra(i,1) > thNra)
%         res(i,1) = true;
%     else
%         res(i,1) = false;
    end
end




% res = scores(:,1) <= thRa;

% if(
% if(sRa>80 && sRa <= sNra)
%     
% end


lab = testLab > 0;


% lab = lab > 0;             
P   = sum( lab);          % # positives.
% N   = sum(~lab);          % # negatives.
% nb_thresh = length(thresh);
% pr = [];
% rc = [];
% fm = [];
% tp_fp = [];

% res = (scores <= thresh(i));
    rc = sum( lab(res)); % true positive
    pr = sum( lab(res)); % true positive
    tp_fp = pr + sum(~lab(res)); % true positive + false positive
    
    fpr = sum(~lab(res))/length(testSeqsNra);
    
    pr = pr/tp_fp;
    rc = rc/P;
    fm = (2*pr*rc)/(pr+rc);

    
%% Generate ROC figure 
[fpr1, tpr1, auc, thr] = roc_bug(scoresRa,testLab,nb_thresh);

% figure; hold all; roc_fig_set; lmx=cell(1,1); lc=1;
% set(gcf,'visible','off')
