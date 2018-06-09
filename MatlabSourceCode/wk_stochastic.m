function [M, c] = wk_stochastic(A, dim)
% [M, c] = wk_stochastic(A, dim)
%
% Makes the entries of an array or a matrix A sum to 1 according to the given
% dimension (dim)
%
% 0=normalizes the whole array/matrix (A/sum(A(:)))
% 1=normalizes columns (column stochastic)
% 2=normalizes rows    (row stochastic)
% 
% OUTPUT:
% M: normalized version of A
% c: is the normalizing constant

% Shariful Islam: 18 November 2016 - 09:33:13 

wk_assert(nargin==2,sprintf('You must input dim = 0,1 or 2\n 0: Normalise the whole array\n 1: Normalize cols\n 2: Normalize rows\n ' ))

if dim==0
    c = sum(A(:));
    s = c + (c==0);
    M = A / s;
elseif dim==1 % normalize each column
    c = sum(A);
    s = c + (c==0);
    M = A ./ (ones(size(A,1),1)*s); 
elseif dim==2 % normalize each column
    c = sum(A,2);
    s = c + (c==0);
    norm =  s*ones(1,size(A,2));
    M = A ./ norm;
end

