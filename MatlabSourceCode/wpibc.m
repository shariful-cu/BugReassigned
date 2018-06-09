
%% ======Weighted Pruning Iterative Boolean Combination (WPIBC)========
close('all');
clear;

%% ============================VALIDATION=================================
% LOADING the validation set
fprintf('\n\n*****************************************************\n');
fprintf('        Preparing candidate HMM_RAs soft detecotors          \n');
fprintf('*****************************************************\n');
hmpath = '/Users/Shariful/Documents/BugReAssgn/PreparedData/Eclipse/Sampling/OS/';
ldpath = strcat(hmpath, 'Val');
[valSeqs, valLab, noValNra, noValRa] = ldseqs(ldpath);
fprintf('Loaded %d "Not reassigned" (NRA) observations (val)\n', noValNra);
fprintf('Loaded %d "Reassigned" (RA) observations (val)\n', noValRa);

% COMPUTING scores on the Validation set for all the HMM_RAs soft detectors
trnHmmPath= '/Users/Shariful/Documents/BugReAssgn/TrainedHMMs/Eclipse/Os';
raHmms = (10:10:20); 
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

fprintf('***************************************************\n');
fprintf('         Weighted Pruning is DONE!        \n');
fprintf('*****************************************************\n');

% CONSTRUCTING Weighted Pruning Iterative Boolean Combination (WPIBC) rules   
max_iter = 5;
[wpbcFprVal, wpbcTprVal, aucWpbcVal, ttb] = ibcvr(scr_val,valLab,nb_thresh,max_iter);
fprintf('***************************************************\n');
fprintf('         VALIDATION of WPIBC is DONE!              \n');
fprintf('*****************************************************\n');

%% ANALASIS (Validation) on ROC spacc using 
figure; hold all; roc_fig_set; lmx=cell(1,1); lc=1;
set(gcf,'visible','on')

% ploting origianl ROC curves

for i = 1 : length(scrValRa)
    [fpr, tpr, auc, thr] = RocBugRa(scrValRa{i},valLab,nb_thresh);
    h1 = plot(fpr, tpr, ':ok');
end
% ploting selected diverse ROC curves
avgAucValRa = 0.0; avgAucValNra = 0.0;
for i = 1 : length(selHmms)
    [fpr, tpr, auc, thr] = RocBugRa(scrValRa{selHmms(i)},valLab,nb_thresh);
    avgAucValRa = avgAucValRa + auc;
    h2 = plot(fpr,tpr,'--sm');
    [fpr, tpr, auc, thr] = RocBugNra(scrValNra{i},valLab,nb_thresh);
    avgAucValNra = avgAucValNra + auc;
    h3 = plot(fpr,tpr,'--+b');
end
avgAucValRa = avgAucValRa / length(selHmms);
avgAucValNra = avgAucValNra / length(selHmms);
% ploting the ROCCH(val) 
% or a combination of the selected ROC curves using WPIBC
h4 = plot(wpbcFprVal,wpbcTprVal,'--*r');

legend([h1, h2, h3, h4],sprintf('%d pruned redundant HMMRAs soft detectors', length(scrValRa) - length(selHmms)),...
    sprintf('%d selected HMMRAs, Avg AUC=%.3f', length(selHmms), avgAucValRa),...
    sprintf('%d selected HMMNRAs, Avg AUC=%.3f', length(selHmms), avgAucValNra),...
    sprintf('WPIBC, AUC=%.3f', aucWpbcVal),...
    'location','southeast','interpreter','tex');
%title('ROC curves of 20 soft HMMs detectors')
svPath = '/Users/Shariful/Documents/BugReAssgn/Figures/';
figname = sprintf('%sWPIBC_Val', svPath);
% saveas(gcf,[figname,'.fig']);

set(gcf,'PaperPositionMode','auto');
set(gca,'fontsize',12);
xlhand = get(gca,'xlabel');
set(xlhand,'fontsize',12);
ylhand = get(gca,'ylabel');
set(ylhand,'fontsize',12);
print('-depsc', '-painters','-loose',[figname,'.eps']);
% print('-depsc','-pdf',figname)

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
[fprWpbc,tprWpbc,aucWpbcTest,rrr] = ibctr(scr_test,testlab,ttb);
fprintf('***************************************************\n');
fprintf('            TESTING of WPIBC is DONE!         \n');
fprintf('*****************************************************\n');


%% ANALASIS (Testing) on ROC space 
figure; hold all; roc_fig_set; lmx=cell(1,1); lc=1;
set(gcf,'visible','on')

% ploting selected diverse ROC curves
avgAucRaTest = 0.0; avgAucNraTest = 0.0;
for i = 1 : length(selHmms)
    [fpr, tpr, auc, thr] = RocBugRa(scrTestRa{i},testlab,nb_thresh);
    avgAucRaTest = avgAucRaTest + auc;
    h1 = plot(fpr,tpr,'--sm');
    [fpr, tpr, auc, thr] = RocBugNra(scrTestNra{i},testlab,nb_thresh);
    avgAucNraTest = avgAucNraTest + auc;
    h2 = plot(fpr,tpr,'--+b');
end
avgAucRaTest = avgAucRaTest / length(selHmms);
avgAucNraTest = avgAucNraTest / length(selHmms);
% lmx{lc} = sprintf('BBC2, AUC=%.3f', rBbc2Test.auch); lc = lc + 1;
% ploting the ROCCH(val) 
% or a combination of the selected ROC curves using WPIBC
h3 = plot(fprWpbc,tprWpbc,'--*r');

legend([h1, h2, h3],sprintf('%d selected HMMRAs, Avg AUC=%.3f', length(selHmms), avgAucRaTest),...
    sprintf('%d selected HMMNRAs, Avg AUC=%.3f', length(selHmms), avgAucNraTest),...
    sprintf('WPIBC, AUC=%.3f', aucWpbcTest),...
    'location','southeast','interpreter','tex');
%title('ROC curves of 20 soft HMMs detectors')
svPath = '/Users/Shariful/Documents/BugReAssgn/Figures/';
figname = sprintf('%sWPIBC_Test', svPath);
% saveas(gcf,[figname,'.ig']);

set(gcf,'PaperPositionMode','auto');
set(gca,'fontsize',12);
xlhand = get(gca,'xlabel');
set(xlhand,'fontsize',12);
ylhand = get(gca,'ylabel');
set(ylhand,'fontsize',12);
print('-depsc', '-painters','-loose',[figname,'.eps']);
% print('-depsc','-pdf',figname)
