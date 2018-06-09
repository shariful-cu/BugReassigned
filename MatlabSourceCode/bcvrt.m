function [RS IR TH BF FP TP AUCH] = bcvrt(r,ir,s,t,lab,fun,n)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [RS IR TH BF FP TP AUCH] = bcv_rt(r,ir,s,t,lab,fun)
%
% BCV_RT: Boolean Combination (Validation) of Responses with Thresholds.
%
% Combine the resulting responses (rs) of two or several ROC curves with
% the sampled thresholds (t) of another ROC curve according to each of the 10
% Boolean functions (fun), using the labels (lab) of the validation set. 
% The overall convex hull is then computed and its emerging points are selected.
%
% INPUTS:
% r : responses from previous combinations of two or several ROC curves
%     (validation set), i.e., result from BCV_TT or BCV_RT.
% ir: sampled indexes from r. When empty ([]) all vectors in r are considered.
% s : scores of the newly added detector or ROC curve to be combined  
% t : sampled thresholds from the newly added ROC curve.
% lab: labels of the validation set (0=negative, 1=positive)
% fun: ALL 10 Boolean function for two detectors such as AND, OR, XOR, etc.
%      Selecting fewer functions is also possible, e.g., fun = [1,5].
%
% OUTPUTS:
% RS: responses of the overall convex hall (ROCCH)  after processing all
%     Boolean functions.
% IR : index of the selected input responses (r)
% TH : selected (real) thresholds from the newly added ROC curves. 
% BF : corresponding Boolean function.
% FP: false positive rate of overall ROCCH. 
% TP: true positive rate of overall ROCCH. 
% AUCH: area under ROCCH.
%
% Last updated by Shariful Islam: 25 January 2018 - 12:50:58 
% (mdsha_i@encs.concordia.ca)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 6,fun = 1:10; end

% Adding trivial thresholds/points. 
if isempty(find(t==Inf, 1)), t = [inf;t]; end
if  any(r(:,1)),   r = [false(size(r,1),1), r]; end
if ~all(r(:,end)), r = [r, true(size(r,1),1)];  end

if isempty(ir)
   ir = 1:size(r,2); ir=ir'; % consider all previous responses.
end 

% Initialization:
lab = lab>0;         % logical
l   = length(lab);
lr  = size(r,2);     % number of points on previous ROCCH.
lt  = length(t);

FP=[]; TP=[];BF=[]; IR=[];TH=[];RS=logical([]);

% Loop over Boolean functions.
for b = fun
   k=1;
   rs = false(l,lr*lt); 
   for i=1:lr
      r_1 = r(:,ir(i));
      for j=1:lt
         if(mod(n,2))
            r_2 = (s > t(j)); %odd
         else
            r_2 = (s <= t(j)); %even
         end
         switch b;
            case 1 %----------------> 'A AND B'
               r12 =   r_1 &  r_2;
            case 2 %----------------> 'NOT A AND B'
               r12 =  ~r_1 &  r_2;
            case 3 %----------------> 'A AND NOT B'
               r12 =   r_1 & ~r_2;
            case 4 %----------------> 'A NAND B'
               r12 = ~(r_1 &  r_2);
            case 5 %----------------> 'A OR B'
               r12 =   r_1 |  r_2;
            case 6 %----------------> 'NOT A OR B'; 'A IMP B'
               r12 =	 ~r_1 |  r_2;
            case 7 %----------------> 'A OR NOT B' ;'B IMP A'
               r12 =   r_1 | ~r_2;
            case 8 %----------------> 'A NOR B'
               r12 = ~(r_1 | r_2);
            case 9 %----------------> 'A XOR B'
               r12 =  xor(r_1,r_2);
            case 10 %----------------> 'A EQV B'
               r12 = ~xor(r_1,r_2);
            otherwise
               error('\nUnknown Boolean function\n') 
         end
         rs(:,k) = r12;
         k=k+1;
      end  
   end 
   % Map the responses of the current Boolean function to the ROC space. 
   [fpr,tpr] = resp2pts(lab,rs); 

   % Compute the convex hull and indexes (ix) of emerging points.
   [fpc,tpc,auch,ix] = rocch(fpr,tpr);

   ixr = ceil(ix./lt);  % index of selected responses.
   ixt = mod (ix, lt);  % index of selected thresholds.
   ixt(ixt==0) = lt;      

   % Accumulate for all Boolean functions.
   FP  = [FP; fpr(ix)]; %#ok<*AGROW>
   TP  = [TP; tpr(ix)];
   IR  = [IR; ixr];
   TH  = [TH; t(ixt)];
   BF  = [BF; ones(length(ix),1)*b];
   RS  = [RS  rs(:,ix)];

end 

% Return overall convex hull and indexes for emerging points.
[FP,TP,AUCH,IX] = rocch(FP,TP);
IR = IR(IX);
TH = TH(IX);
BF = BF(IX);
RS = RS(:,IX); 
