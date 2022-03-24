function varargout = panhandleA (type, P, Q, ~, param, ~)

if strcmp(type, 'power')
    varargout = {2};
    
else
    L = param.L; D = param.D;
    if isfield(param, 'E'), E = param.E; else, E = 0.9; end
    m1 = 1.854; K = 18.43 * L ./ (E.*E .* D.^4.854);
    
    if strcmp(type, 'Lbd') % dP = Lbd .* Q
        Lbd = K .* abs(Q).^(m1-1);
        varargout = {Lbd, {}};
        
        
    elseif strcmp(type, 'Q') % dP = K .* Q.^m1
        dP = P(:,1) - P(:,2);
        Q = sign(dP) .* (abs(dP)./K).^(1/m1);
        varargout = {Q, {}};
    end
end
