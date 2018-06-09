
%% ======Weighted Pruning Iterative Boolean Combination (WPIBC)========
close('all');
clear;

%% ============================VALIDATION=================================
% LOADING the validation set
fprintf('\n\n*****************************************************\n');
fprintf('        Preparing candidate HMM_RAs soft detecotors          \n');
fprintf('*****************************************************\n');
hmpath = '/Users/Shariful/Documents/BugReassigned/PreparedData/Gnome/Sampling/Status/';
ldpath = strcat(hmpath, 'Val');
[valSeqs, valLab, noValNra, noValRa] = ldseqs(ldpath);
fprintf('Loaded %d "Not reassigned" (NRA) observations (val)\n', noValNra);
fprintf('Loaded %d "Reassigned" (RA) observations (val)\n', noValRa);

% COMPUTING scores on the Validation set for all the HMM_RAs soft detectors
trnHmmPath= '/Users/Shariful/Documents/BugReassigned/TrainedHMMs/Gnome/Status';
raHmms = (10:10:90); 
nb_thresh = 100;
fprintf('Computing... scores for %d HMM_RAs soft detectors (val)\n', length(raHmms));
[scrValRa, aucRaVal] = scr_ra(trnHmmPath, valSeqs, valLab, raHmms, nb_thresh);
% fprintf('DONE! \n');
fprintf('Computing scores is done!\n');
fprintf('***************************************************\n');
fprintf('   %d candidate HMM_RAs soft detectors are ready\n', length(raHmms));
fprintf('*****************************************************\n');

% PRUNING
fprintf('\n\n***************************************************\n');
fprintf('             Weighted Pruning is started          \n');
fprintf('*****************************************************\n');
% set the kappa aggrement threshold
agr_th = 0.90;
% Selecting the most diverse reassigned soft detectors
[selHmms] = wt_prune(scrValRa,valLab,nb_thresh,agr_th);
fprintf('Only %d HMM_RAs are selected as the most diverse HMM_RAs out of %d! \n', length(selHmms), length(raHmms)-length(selHmms));
% scores of the selected HMM_RA soft detectors 
% scrValRa = scrValRa(selHmms);

% COMPUTING scores for each corresponding selected HMM_NRAs soft detectors
fprintf('Computing... scores for the corresponding %d selected HMM_NRAs soft detectors (val)\n', length(selHmms));
[scrValNra, aucNraVal] = scr_nra(trnHmmPath, valSeqs, valLab, selHmms*10, nb_thresh);
% marging the selected validation scores
fprintf('Marging scores of the selected HMM_RAs & HMM_NRAs soft detectors\n');
scr_val = cell(1,length(selHmms)*2); idx = 1;
for i = 1 : length(selHmms)
    scr_val(1,idx) = scrValNra(1,i);
    scr_val(1,idx+1) = scrValRa(1,selHmms(i));
    idx = idx + 2;
end

% analysis on ROC space
figure; hold all; roc_fig_set; lmx=cell(1,1); lc=1;
set(gcf,'visible','off')

rsd = [60;70;90;100;110;120;130;140;150;170;180];
% TPR = []; FPR = [];
for i = 1 : length(scrValRa)
    [fpr, tpr, auc, thr] = RocBugNra(scrValRa{i},valLab,nb_thresh);
    h1 = plot(fpr, tpr, ':ok');
end

bsd = [10;20;30;40;80;160;190;200];
TPR = []; FPR = [];
for i = 1 : length(selHmms)
    [fpr, tpr, auc, thr] = RocBugNra(scrValRa{selHmms(i)},valLab,nb_thresh);
    h2 = plot(fpr,tpr,'--sr');   
end



fprintf('***************************************************\n');
fprintf('         Weighted Pruning is DONE!        \n');
fprintf('*****************************************************\n');

% CONSTRUCTING Weighted Pruning Iterative Boolean Combination (WPIBC) rules   
max_iter = 5;
[fpr, tpr, aucVal, ttb] = ibcvr(scr_val,valLab,nb_thresh,max_iter);
fprintf('***************************************************\n');
fprintf('         VALIDATION of WPIBC is DONE!              \n');
fprintf('*****************************************************\n');


%% ==========================TESTING================================
fprintf('\n\n***************************************************\n');
fprintf('           TESTING of WPIBC is started          \n');
fprintf('*****************************************************\n');
% LOADING Testing set
ldpath = strcat(hmpath, 'Test');
[testSeqs, testlab, nonra, nora] = ldseqs(ldpath);
fprintf('Loaded %d NRA observations (test)\n', nonra);
fprintf('Loaded %d RA observations (test)\n', nora);

% Computing scores on Testing set
fprintf('Computing...socres on testing set\n');
[scrTestRa, aucRaTest] = scr_ra(trnHmmPath, testSeqs, testlab, selHmms*10, nb_thresh);
[scrTestNra, aucNraTest] = scr_nra(trnHmmPath, testSeqs, testlab, selHmms*10, nb_thresh);
% marging the testing scores
scr_test = cell(1,length(selHmms)*2); idx = 1;
for i = 1 : length(selHmms)
    scr_test(1,idx) = scrTestNra(1,i);
    scr_test(1,idx+1) = scrTestRa(1,i);
    idx = idx + 2;
end
fprintf('Computing scores is done!\n');

% Combining decisions using the constructed Boolean combination rules
fprintf('Combining...decisions using the constructed Boolean combination rules\n')
[fprIbc,tprIbc,aucIbcTest,rrr] = ibctr(scr_test,testlab,ttb);
fprintf('***************************************************\n');
fprintf('            TESTING of WPIBC is DONE!         \n');
fprintf('*****************************************************\n');