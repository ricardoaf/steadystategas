function [pressure, L, Q, f, alpha, flowProps, nite, err] = steadyStateGas_old ...
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

% process unit data
[K, unit_c, units, network, alpha, nonetc, X, erpunit, erpconn] = ...
    processUnitData_old(n, unit, param);
[C1, C2, C3, d] = processUnitCoeff_old (n, unit, unit_c, network);
X_h = repmat(X(1,:), m, 1);

% inlet / outlet
KI = K(network, :); KO = K(units, :);
LI = load(network); LO = load(units);

% branch flow vector (initial guess)
Q = min(load(load>0))*ones(m,1);
% Q = max(load)*ones(m, 1);
err = tol+1; nite = 0; pressure = zeros(n,1);
lb = 1e-6;

while err > tol && nite < 200
    nite = nite + 1;
%     fprintf('nite %d\n', nite);
    
    % Linearization of pipe flow equation
    invLbd = diag(1./flow_eqn('Lbd', pressure(conn), Q, X_h, param, nite));
    G = A * invLbd * A';
    
    Gn = G(network, network);
    Gh = G(network, units);
    Gs = G(units, units);
    
    % Gn = Gn + 1e-8 * mean(diag(Gn)) * eye(size(Gn));
    U = chol(Gn);
    % [U, lb] = chol_lb (Gn, lb);
    
    L = U'; invL = inv(L); invU = inv(U);
    Tmp = invU*invL; TmpG = Gh'*Tmp; TmpC = C1*Tmp;
    
    D11 = Gs - TmpG*Gh; D12 = KO - TmpG*KI;
    D21 = C2 - TmpC*Gh; D22 = C3 - TmpC*KI;
    R1 = -LO + TmpG*LI; R2 = d + TmpC*LI;
    
    Pf = [D11 D12; D21 D22]\[R1; R2];
    P = Pf(1:u); fnew = Pf(u+1:2*u);    
    Ps = -invU*(invL*(LI+Gh*P+KI*fnew));
    
    % assert pressure valves
    [unit_c, fnew] = processPressureValve_old (pressure, unit, unit_c, fnew);
    [C1, C2, C3, d] = processUnitCoeff_old (n, unit, unit_c, network);
    
    pressure(network) = Ps; pressure(units) = P;
    [Qnew, flowProps] = flow_eqn('Q', pressure(conn), Q, X_h, param, nite);
    
    if nite == 1
        dQ = Qnew - Q;
    else
        dQ = [Qnew - Q; fnew - f];
    end
    err = norm(dQ);
    Q = Qnew;
    f = fnew;
    
%     % assert pressure valves
%     [unit_c, f] = processPressureValve (pressure, unit, unit_c, f);
%     [C1, C2, C3, d] = processUnitCoeff (n, unit, unit_c, network);
    
    % update gas composition fraction
    [alpha, X_h] = updateComposition ...
        (alpha, X, A, Q, f, nonetc, conn, erpunit, erpconn, tol);
end
L = A*Q - K*f;

% revert pressure values
[~, pressure] = adjustPressure('revert', flow_eqn, unit, pressure);
