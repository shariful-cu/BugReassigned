function thresh = sample_scores(scores,nb_thresh)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% thresh = sample_scores(scores,nb_thresh)
%
% Uniform sampling of scores into nb_thresh bins.
%
% Last updated by Shariful Islam: 13 February 2016 - 14:43:13
% (mdsha_i@encs.concordia.ca)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if isempty(nb_thresh)
  thresh=scores;  % consider all scores.
  return
end
thresh = quantile(scores,linspace(0,1,nb_thresh).');
thresh = sort(thresh,'descend');
thresh = [+inf;thresh];
