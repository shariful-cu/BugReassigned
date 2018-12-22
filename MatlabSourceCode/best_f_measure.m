function [p, r, f, idx] = best_f_measure(pr, rc, fm)

best_pr = -inf;
best_rc = -inf;
for i = 1 : length(pr)
    if(pr(i) > best_pr && rc(i) > best_rc)
        best_pr = pr(i); best_rc = rc(i);
        idx = i;
    end
end

p = pr(idx); r = rc(idx); f = fm(idx);

end