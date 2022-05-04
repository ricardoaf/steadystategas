function  [U, lb] = chol_lb (A, lb)
if nargin<2 || isempty(lb), lb=0; end

mA = max(abs(A(:)));

% Factorize with check of pos. def.
n = size(A,1);  chp = 1;
count = 0;
while  chp
    count = count + 1;
    [U, chp] = chol(A + lb*speye(n));
    if  chp == 0  % check for near singularity
        chp = rcond(U) < 1e-15; % estimate L1 condition - the same as 1/condest(R) and 1/cond(R,1) (exact)
    end
    if  chp,  lb = max(10*lb, eps*mA); end
end
fprintf('count: %d,  lb: %g\n', count, lb);