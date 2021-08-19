function lbd = panhandleA_lbd (Q, L, D, E)
if nargin<4 || isempty(E), E=0.9; end
k = 18.43 * L ./ (E.*E .* D.^4.854); m1 = 1.854 * ones(size(k));
lbd = k .* abs(Q).^(m1-1);
