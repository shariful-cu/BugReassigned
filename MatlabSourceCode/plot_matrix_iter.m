function [] = plot_matrix_iter(mat_iter, mat_true, mat_name)
% [] = plot_matrix_iter(mat_true, mat_iter, mat_name)
%
% Plot parameters update at each iteration (transition or Emission)
% The same color mapping is used for each elem in both matrices for easy
% comparision.
%
% INPUTS:
%  mat_iter - Matrix  update at each iteration each row is a whole matrix in
%             row-wise order, e.g., [a11 a12 ... a21 a22 .. ann].
%
%  OPTIONAL ARGUMENTS:
%  mat_true - Original matrix of source (generator)
%  mat_name - Name of the matrices "string" for the legend [Mat]
%
% NB: legend is not shown when mat has more than 16 elements.


% Wael Khreich: 02 December 2009 - 02:20:02

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
iter_only=false;

if nargin<3
   mat_name = 'Mat';
end
if nargin<2 || isempty(mat_true)
   iter_only=true;
end

[niter, dim] = size(mat_iter);


if ~iter_only
   mat_true=mat_true';  % A(2) = A12 (matlab default column-wise,i.e., A(2) = A21)
end

figure; hold all
ylim([0,1]);
lmx=[];lc=1;

if dim <=20
   cc = num2cell(mycolors,2);
else
   colormap('default');
   cc = num2cell( colormap,2);
end

for k=1:dim
   % Estimated Matrix
   plot(mat_iter(:,k),'color',cc{k},'linewidth',2)

   if ~iter_only
      [x y] = ind2sub(size(mat_true),k);
      % matrix indexes (x,y switched since transposed)
      lmx{lc} = sprintf('%s_{%d%d}',mat_name,y,x);lc=lc+1;
   else
      % linear indexes
      lmx{lc} = sprintf('%s_{%d}',mat_name,k);lc=lc+1;
   end


   if ~iter_only % True Matrix
      % just to show true parameters when they coincide
      if k <= round(dim/2)
         plot(niter,mat_true(k),'+','color',cc{k},'markersize',10,'linewidth',2);
      else
         plot(niter,mat_true(k),'o','color',cc{k},'markersize',10,'linewidth',2);
      end
      [x y] = ind2sub(size(mat_true),k);
      lmx{lc} = sprintf('%s_{%d%d}\\surd',mat_name,y,x);lc=lc+1;
   end
end
if dim <=16
   legend(lmx,'location','EastOutside')
end

return

