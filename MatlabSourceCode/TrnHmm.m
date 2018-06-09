close('all');
clear;

%% ==Load the training & validation sets into the Cell Array of Vectrors===

hmPath = '/Users/Shariful/Documents/BugReassigned/BugReassigned/PreparedData/Gnome/Sampling/Component/';
filePath = strcat(hmPath, 'TrnRa_seqs.mat');
train_seqs = importdata(filePath);

%loading the validation set
filePath = strcat(hmPath, 'ValRa_seqs.mat');
valRaSeqs = importdata(filePath);
filePath = strcat(hmPath, 'ValNra_seqs.mat');
valNraSeqs = importdata(filePath);
val_seqs = [valRaSeqs; valNraSeqs];
val_lab = [ones(length(valRaSeqs),1); zeros(length(valNraSeqs),1)];


%% =======Train HMM parameters=======================   

% set the user defined parameters: 
% M (number of observation symbols) & N (number of hidden states)
hmOrgSeqPath = '/Users/Shariful/Documents/BugReassigned/BugReassigned/PreparedData/Gnome/OriginalSeqDataset/';
filePath = strcat(hmOrgSeqPath, 'Component/MapKeysVals_Component.mat');
M = importdata(filePath);
M = length(M);
svHmmPath = '/Users/Shariful/Documents/BugReassigned/BugReassigned/TrainedHMMs/Gnome/';
nb_thresh = 100; AUC = -inf; 

for N = 10 : 200 % number of hidden states varying from 10, 20,..200
%     initialize the model at random and train it
%     (10 times for each state size)
    trnHmm = [];
    for t = 1 : 10        
%         training
        tic;
        [AA, BB, PP] = init_hmm(M, N);
%         train the model
        [AA, BB, PP, llT] = bw(train_seqs , AA, BB, PP);
%         validate the model      
        scores = test_forward(val_seqs, AA, BB, PP);
        [fpr, tpr, auc, thr] = RocBugRa(scores,val_lab,nb_thresh);
        itr_t = toc;
        if(auc > AUC)
            trnHmm.A = AA; trnHmm.B = BB; trnHmm.P = PP;
        end
        fprintf( 'processed iteration %d for %d; AUC: %.2f, time: %.2f\n', t, N, AUC, itr_t);
    end
    
    %Save model parameters
    filePath = strcat(svHmmPath, '/', 'ProductRaHMM_', num2str(N), '.mat');
    save(filePath, 'trnHmm');
end
% =======End of training HMM parameters=============
