function output = panhandleA (type, P, Q, param, ite)
output = [];

if strcmp(type, 'power')
    output = 2;
    
else
    L = param.L; D = param.D;
    if isfield(param, 'E'), E = param.E; else, E = 0.9; end
    m1 = 1.854; K = 18.43 * L ./ (E.*E .* D.^4.854);
    
    if strcmp(type, 'Lbd') % dP = Lbd .* Q
        output = K .* abs(Q).^(m1-1);
        
        
    elseif strcmp(type, 'Q') % dP = K .* Q.^m1
        dP = P(:,1) - P(:,2);
        output = sign(dP) .* (abs(dP)./K).^(1/m1);
    end
end
