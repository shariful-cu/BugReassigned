function cntgncy = contngncy(S1, S2, lavls)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   contngncy(S1, S2, lavls)
% 
%   CONTNGNCY: Compute the contingency matrix for the kappa coefficient
% 
% INPUTS:
% S1: scores produced by a soft detector (S1)
% S2: scores produced by another soft detector (S2)
% lavls : the aggrement levels or orders or ranks or thresholds between two
% soft detectors
% 
% OUTPUTS:
% cntgncy: contingency matrix based on the aggrement levels (lavls)
% 
% Code needs improvement
% 
% Last updated by Shariful Islam: 24 January 2018 - 15:49:17 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

K = length(lavls);
lavls = [inf; lavls];
cntgncy = zeros(K,K);
for i = 2 : K + 1
    for j = 2 : K + 1
%         S1_j = zeros(K,1); S2_i = zeros(K,1);
        count = 0;
        for l = 1 : length(S1)
            if(S1(l) >= lavls(j) && S1(l) < lavls(j-1))
                if(S2(l) >= lavls(i) && S2(l) < lavls(i-1))
%                 S1_j(k) = 1;
                    count = count + 1;
                end
            end
%             if(S2(l) >= lavls(i) && S2(l) < lavls(i-1))
% %                 S2_i(k) = 1;
%                 count_i = count_i + 1;
%             end
        end
%         cellVal = count_i + count_j;
        cntgncy(i - 1, j - 1) = count;
    end
end

end