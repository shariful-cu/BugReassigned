function [RS TH1 TH2 BF FP TP AUCH] = bcvtt(s1,t1,s2,t2,lab,fun)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [RS TH1 TH2 BF FP TP AUCH] = bcvtt(s1,t1,s2,t2,lab,fun)
%
% BCVTT: Boolean Combination (Validation) of Thresholds with Thresholds.
%
% Combine each sampled threshold (t1) from the 1rst ROC with
% each sampled threshold (t2) from the 2nd ROC according to each of the 10
% Boolean functions (fun), using the labels (lab) of the validation set. 
% The ROC convex hull(ROCCH) of each Boolean function  is then
% computed and the parameters of emerging points (i.e., [t1(i),t2(i),fun(i)])
% are stored. Finally the overall convex hull is computed and its emerging
% points are selected.
%
% INPUTS:
% s1: scores of the 1st detector (validation set) - 1st ROC.
% t1: sampled thresholds from the 1st ROC (validation set).
% s1: scores of the 2nd detector (validation set) - 2nd ROC.
% t2: sampled thresholds from the 2nd ROC (validation set).
% lab: labels of the validation set (0=negative, 1=positive)
% fun: ALL 10 Boolean function for two detectors such as AND, OR, XOR, etc.
%      Selecting fewer functions is also possible, e.g. fun = [1,5].
%
% OUTPUTS:
% RS: responses of the overall convex hall (ROCCH)  after processing all
%     Boolean functions.
% TH1: selected thresholds from the 1st ROC.
% TH2: selected thresholds from the 2nd ROC.
% BF : corresponding Boolean function.
% NB : TH1, TH2, BF are vectors of the same length, this is also equal to the
%        number of RS columns. Number of rows in RS is the length of labels.
% FP: false positive rate of overall ROCCH. 
% TP: true positive rate of overall ROCCH. 
% AUCH: area under ROCCH.
% 
% Last updated by Shariful Islam: 25 January 2018 - 11:55:00 
% (mdsha_i@encs.concordia.ca)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 6, fun = 1:10; end

% Adding trivial threshold if they are not already input.
if isempty(find(t1==Inf, 1)), t1 = [inf;t1]; end
if isempty(find(t2==Inf, 1)), t2 = [inf;t2]; end

% Initialization:
lab = lab>0;      % logical
l   = length(lab);
l1  = length(t1);
l2  = length(t2);

FP=[];TP=[];BF=[];TH1=[];TH2=[];RS=logical([]);

% Loop over Boolean functions.
for b=fun
   k=1;
   rs  = false(l,l1*l2); 
   for i=1:l1
      r_1 = (s1>t1(i)); %odd order means NRA
      for j=1:l2
         r_2 = (s2<=t2(j)); %even order means RA
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


   % Mapping indexes of the emerging points, on the facet of the convex hull,
   % into those of original thresholds
   it1 = ceil(ix./l2);  
   it2 = mod (ix, l2);  
   it2(it2==0) = l2;    

   % Accumulate for all Boolean functions.
   TH1= [TH1; t1(it1)]; %#ok<*AGROW>
   TH2= [TH2; t2(it2)];
   RS = [RS rs(:,ix)];
   BF = [BF;ones(length(ix),1)*b];
   FP = [FP; fpr(ix)];
   TP = [TP; tpr(ix)];
end 

% Return overall convex hull and indexes for emerging points.
[FP,TP,AUCH,IX] = rocch(FP,TP);
RS  = RS(:,IX);
TH1 = TH1(IX);
TH2 = TH2(IX);
BF  = BF(IX);
