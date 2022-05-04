function [pressure, L, Q, f, alpha, flowProps, nite, err] = steadyStateGas ...
    (conn, load, unit, flow_eqn, param, tol)
% steadyStateGas
% Osiadacz A.J. (1988) Method of steady-state simulation of a gas network
% International Journal of Systems Science, Vol. 19, Issue 11, 2395-2405

% number of nodes, branches, units, sources
n = length(load); m = size(conn,1); u = length(unit);

% branch-node incidence matrix
A = zeros(n,m);
for j = 1:m, A(conn(j,:),j) = [-1; +1]; end

% convert pressure values
unit = adjustPressure('convert', flow_eqn, unit);

% branch flow vector (initial guess)
Q = min(load(load>0))*ones(m,1);
% Q = max(load)*ones(m, 1);
err = tol+1; nite = 0; pressure = zeros(n,1); f = zeros(u, 1);
lb = 1e-9;

lb = 1e-7;

% ERR = [];
while err > tol && nite < 50
    nite = nite + 1;
    % fprintf('nite %d\n', nite);
    
    % process unit data
    [K, C1, C2, C3, d, units, active_unit, network, nonetc, gas, erp] = ...
        processUnitData(n, unit, param, pressure, f);
    au = length(units);
    
    % inlet / outlet
    KI = K(network, :); KO = K(units, :);
    LI = load(network); LO = load(units);
    
    % first iteration branch compositions
    if nite == 1
        alpha = gas.alpha; X = gas.X;
        X_h = repmat(X(1,:), m, 1);
    end
    
    % Linearization of pipe flow equation
    invLbd = diag(1./flow_eqn('Lbd', pressure(conn), Q, X_h, param, nite));
    G = A * invLbd * A';
    
    Gn = G(network, network);
    Gh = G(network, units);
    Gs = G(units, units);
    
    % Gn = Gn + 1e-8 * mean(diag(Gn)) * eye(size(Gn));
    % U = chol(Gn);

    % [U, lb] = chol_lb (Gn, lb);

    Gn = Gn + lb * eye(size(Gn));

    L = U'; invL = inv(L); invU = inv(U);
    Tmp = invU*invL; TmpG = Gh'*Tmp; TmpC = C1*Tmp;
    
    D11 = Gs - TmpG*Gh; D12 = KO - TmpG*KI;
    D21 = C2 - TmpC*Gh; D22 = C3 - TmpC*KI;
    R1 = -LO + TmpG*LI; R2 = d + TmpC*LI;
    
    Pf = [D11 D12; D21 D22]\[R1; R2];
    P = Pf(1:au); f(active_unit) = Pf(au+1:2*au);    
    Ps = -invU*(invL*(LI+Gh*P+KI*f(active_unit)));
    
    pressure(network) = Ps; pressure(units) = P;
    [Qnew, flowProps] = flow_eqn('Q', pressure(conn), Q, X_h, param, nite);
    
    dQ = Qnew - Q;
    err = norm(dQ);
%     ERR = [ERR err];
    Q = Qnew;
        
    % update gas composition fraction
    [alpha, X_h] = updateComposition ...
        (alpha, X, A, Qnew, f, nonetc, conn, erp.unit, erp.conn, tol);
end
L = A*Q - K*f(active_unit);
% plot(ERR);

% revert pressure values
[~, pressure] = adjustPressure('revert', flow_eqn, unit, pressure);
