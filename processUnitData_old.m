function [K, unit_c, units, network, ...
    alpha, nonetc, X, erpunit, erpconn] = processUnitData_old (n, unit, param)

% init
u = length(unit);
unit_conn = zeros(u, 2);
unit_c = zeros(u, 4);

% init gas composition fraction
netc = 0; etc = zeros(1, u);
alpha = zeros(n, u);
nerp = 0; erpconn = zeros(u, 2); erpunit = zeros(1, u);
X = zeros(u, 21);
if ~isfield(param, 'X'), param.X = zeros(1, 21); end

% filter by unit type
for i = 1:u
    
    % set connectivities
    unit_conn(i,:) = unit{i}.conn;
    
    switch unit{i}.type
        case {'source', 'outlet_pressure'}
            unit_c(i,:) = [0 1 0 unit{i}.value];
            
            % init gas composition fraction
            % (for each node i, Xi = alpha * X)
            netc = netc + 1;
            node = unit{i}.conn(2);
            etc(netc) = node;
            % initially, assume all non-etc nodes with first ETC composition
            gas = 1;
            if isfield(unit{i}, 'gas'), gas = unit{i}.gas; end
            if netc==1
                alpha(:, netc) = 1;
                X = repmat(param.X(gas, :), u, 1);
            else
                alpha(node, :) = 0;
                alpha(node, netc) = 1;
                X(netc, :) = param.X(gas, :);
            end
            
        case 'inlet_pressure'
            unit_c(i,:) = [1 0 0 unit{i}.value];
            
        case 'pressure_ratio'
            unit_c(i,:) = [unit{i}.value -1 0 0];
            
        case 'flow'
            unit_c(i,:) = [0 0 1 unit{i}.value];
            
        case 'pressure_valve'
            unit_c(i,:) = [1 -1 0 0];
            
            nerp = nerp + 1;
            erpconn(nerp, :) = unit{i}.conn;
            erpunit(nerp) = i;
            
        case 'flow_valve' % not working
            unit_c(i,:) = [0 0 1 -eps];
            
        otherwise
            disp('Unknown type');
    end
end

% Matrix K
K = zeros(n,u);
for j = 1:u
    nodeI = unit_conn(j,1); if nodeI>0, K(nodeI,j) = +1; end
    nodeJ = unit_conn(j,2); if nodeJ>0, K(nodeJ,j) = -1; end
end

% outlet and non-outlet pressure nodes
units = unit_conn(:,2)';
network = setdiff(1:n, units);

% init gas composition fraction
alpha = alpha(:, 1:netc);
etc = etc(1:netc);
nonetc = setdiff(1:n, etc);
X = X(1:netc, :);
erpunit = erpunit(1:nerp);
erpconn = erpconn(1:nerp, :);