function Q = panhandleA_Q (P1, P2, L, D, E)
if nargin<5 || isempty(E), E=0.9; end
k = 18.43 * L ./ (E.*E .* D.^4.854); m1 = 1.854 * ones(size(k));
dP = P1 - P2; Q = sign(dP) .* exp(log(abs(dP)./k)./m1);
