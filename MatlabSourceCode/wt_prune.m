function [S, tm] = wt_prune(val_scrs,val_lab,nb_thresh, kp_th)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [S] = wt_prune(val_scrs,val_lab,nb_thresh, kp_th)
% 
% WT_PRUNE: selects the diverse base soft detectors while pruning redundant ones.
%
% INPUTS:
% val_scrs: the output predictions scores (or probabilities) of a classifier. The
%         degree of membership to the target (or positive) class.
% val_lab : true labels of the test (or validation) set. 
%		  0 = negative or nontarget 
%		  1 = positive or target    
% nb_thresh: number of sampled thresholds, (or number of bins).I.e., ROC
%     resolution. When empty all score values are considered (no sampling).
% kp_th: setting threshold on the computed kappa aggrement between two
%        soft detectors
%
% OUTPUTS:
%   S: selected diverse soft detectors
%
% Last updated by Shariful Islam: 7 June 2018 - 15:49:17 
% (mdsha_i@encs.concordia.ca)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



% pruning using weighted kappa
tic;
no_sd = length(val_scrs);
bsd = zeros(no_sd, 2);
for i = 1 : no_sd    
%     llv = val_scrs{i};
    [~,~,au,~] = roc_bug(val_scrs{i},val_lab,nb_thresh);
    bsd(i, 1) = i;
    bsd(i, 2) = au;
end


S = [];
k = no_sd;
hm_au = bsd;
kp_all = zeros(no_sd,1);
[~, I] = max(hm_au(:,2));
kp_all(I) = 1; flag = 1;
while k>1
    [~, I] = max(hm_au(:,2));
    bd = hm_au(I,1);
    scr1 = val_scrs{bd};
    
%     lavls1 = quantile(scr1,linspace(0,1,nb_thresh).');
%     lavls1 = unique(lavls1);
% %     lavls = unique(scr1);
%     lavls1 = sort(lavls1,'descend');
%     sz_l = length(lavls1);

    
    
    %weighted kappa between best_HMM_N and HMMs just before best_HMM_N 
    left_h = []; %rd = []; 
    for i = 1 : k
        hm = hm_au(i,1);
        if(~(hm == bd))
            scr2 = val_scrs{hm};
            
            lavls = quantile(scr2,linspace(0,1,nb_thresh).');
            lavls = unique(lavls);
        %     lavls = unique(scr1);
            lavls = sort(lavls,'descend');
            sz_l = length(lavls);
            
            % computing weights
            wt1=zeros(sz_l,sz_l);
            for m=1 : sz_l
                for n=1 : sz_l
                    wt1(m,n)=1-(abs(m-n)/(sz_l-1));
                end
            end
            
            tblContngncy = contngncy(scr1, scr2, lavls);
            kpp = wtkappa(tblContngncy, wt1);
            if(flag)
                kp_all(i) = kpp;
            end
            if (kpp>kp_th)
                continue;
%                 cp = [hm kpp hm_au(i,2)];
%                 rd = [rd; cp];
            else
                left_h = [left_h; i];
            end
        end
%         flag = 0;
    end
    flag = 0;
    hm_au = hm_au(left_h,:);
    k = length(hm_au(:,1));
    if(k~=1)
        S = [S; bd];      
    else
        S = [S; bd; hm_au(1,1)];
        break;
    end
end
%if(length(S)==1)
    [~, I] = sortrows(kp_all,1);
    if(S~=bsd(I(1),1))
        S = [S; bsd(I(1),1)];
    end
    [~, I] = min(bsd(:,2));
    if(S~=bsd(I(1),1))
        S = [S; bsd(I(1),1)];
    end
% end

tm = toc;
end