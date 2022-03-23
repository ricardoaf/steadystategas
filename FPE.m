function output = FPE (type, P, Q, param, ite)
% Fundamental pipe equation (FPE)
%
% Units
%--------------------------------------------------------------------------
% [temperature]: R
% [pressure]: PSIA
% [viscosity]: lbf*s/ft/ft
% [pipe length]: mile;
% [pipe elevation]: ft;
% [pipe diameter/roughness]: in
% [flow rate]: SCFD

output = [];

if strcmp(type, 'power')
    % P = p .^ power  =>  dP = P1 - P2
    output = 2;
    
else
    AIR_MOLAR_MASS = 28.9625;
    R_GAS_CONSTANT = 8.315952429;
    
    C1 = 77.54;
    % C2 = 0.0375; % for elevation only
    C3 = 0.000004258361678*AIR_MOLAR_MASS / R_GAS_CONSTANT;
    
    Pb = param.Pb; Tb = param.Tb; Ta = param.Ta; Za = 1;
    D = param.D; e = param.e; X = param.X; L = param.L; mu = param.visc;
    
    MW = [16.043 28.0135 44.01 30.07 44.097 18.0153 34.082 2.0159 ...
        28.01 31.9988 58.123 58.123 72.15 72.15 86.177 100.204 ...
        114.231 128.258 142.285 4.0026 39.948];
    M = sum(MW .* X);
    G = M / AIR_MOLAR_MASS;
    
    if (ite > 1)
        % compressibility method (AGA8D)
        p = abs(P).^(1/FPE('power')-1) .* P;
        Pa = 2/3 * (p(:,1) + p(:,2) - (p(:,1).*p(:,2))./(p(:,1)+p(:,2)));
        Za = compressibility (Ta, Pa, X);
    end
    
    % friction method (Colebrook-White)
    Re = C3*Pb/Tb*G .* abs(Q)./(mu.*D);
    f = friction (param.r./D, Re);
    
    K = C1*Tb/Pb*(D.^2.5).*e./sqrt(G.*Za.*Ta.*L);
    
    if strcmp(type, 'Lbd')
        % dP = Lbd .* Q  =>  Lbd = |Q|.*f(|Q|)./(K.^2)
        output = abs(Q).*f./(K.^2);
        
    elseif strcmp(type, 'Q')
        % Q = sign(dP) * K * 1/sqrt(f) * sqrt(|dP|)
        dP = P(:,1) - P(:,2);
        output = sign(dP) .* K .* sqrt(abs(dP)./f);
    end
end
