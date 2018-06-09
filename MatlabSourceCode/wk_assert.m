function wk_assert(cond,msg)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% wk_assert(cond,msg)
% 
% Assert the input condition is true.
%
% cond: condition is the expression that must evaluate a logical true; otherwise
%       the program stops in debugging mode and the assertion message pops up. 
% msg:  is a message describing the assertion violation.
%
% e.g. wk_assert(~isscalar(ll),'ll must be a vector). 
%
% See also:
% dbstack, dbstop, eval, assert, error. 
  
% last updated by Shariful Islam: 13 February 2016 - 13:03:25 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~cond
  % beep
  fprintf(1,'\n+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n')
  fprintf(1,'!!! Assertion Failure:\n!!! MESSAGE:%s\n',msg);
  if ~isempty(dbstack) % not in command line 
    % Consider the stack of the calling function only.
    % Eliminate the first thrown error in wk_assert, which is misleading. 
    dbstack(2);
  end
  fprintf(1,'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n')
  keyboard
end
