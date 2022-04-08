function [K, C1, C2, C3, d, units, active_unit, network, nonetc, gas, erp] = ...
    processUnitData (n, unit, param, P, f)

% number of units
u = length(unit);
active_unit = 1:u;
unit_conn = zeros(u, 2);
unit_c = zeros(u, 4);

% init gas composition
netc = 0; etc = zeros(1, u);
gas = struct('alpha', zeros(n, u), 'X', zeros(u, 21));
if ~isfield(param, 'X'), param.X = zeros(1, 21); end

% init erp data
nerp = 0; erp.conn = zeros(u, 2); erp.unit = zeros(1, u);

% filter by unit type
for i = 1:u
    
    % set connectivities
    unit_conn(i,:) = unit{i}.conn;
    
    switch unit{i}.type
        case {'source', 'outlet_pressure'}
            unit_c(i, :) = [0 1 0 unit{i}.value];
            
            % init gas composition fraction
            netc = netc + 1;
            node = nonzeros(unit{i}.conn);
            etc(netc) = node;
            g = 1;
            if isfield(unit{i}, 'gas'), g = unit{i}.gas; end
            if netc==1
                gas.alpha(:, netc) = 1;
                gas.X = repmat(param.X(g, :), u, 1);
            else
                gas.alpha(node, :) = 0;
                gas.alpha(node, netc) = 1;
                gas.X(netc, :) = param.X(g, :);
            end
            
        case 'inlet_pressure'
            unit_c(i,:) = [1 0 0 unit{i}.value];
            
        case 'pressure_ratio'
            unit_c(i,:) = [unit{i}.value -1 0 0];
            
        case 'flow'
            unit_c(i,:) = [0 0 1 unit{i}.value];
            
        case 'pressure_valve'
            uconn = unit{i}.conn;
            
            if f(i) >= 0 % erp status
                nerp = nerp + 1;
                erp.conn(nerp, :) = uconn;
                erp.unit(nerp) = i;
                
                if P(uconn(1)) < unit{i}.value % not regulating
                    unit_c(i,:) = [1 -1 0 0];
                else % regulating status
                    unit_c(i,:) = [0 1 0 unit{i}.value];
                end
                
            else % blocking status
                active_unit = setdiff(active_unit, i);
            end
            
        case 'flow_valve' % not working
            unit_c(i,:) = [0 0 1 -eps];
            
        otherwise
            disp('Unknown type');
    end
end
% crop data
etc = etc(1:netc);
nonetc = setdiff(1:n, etc);
gas.alpha = gas.alpha(:, 1:netc);
gas.X = gas.X(1:netc, :);
erp.conn = erp.conn(1:nerp, :);
erp.unit = erp.unit(1:nerp);

% Matrix K
au = length(active_unit);
K = zeros(n, au);
for j = 1:au
    nodeI = unit_conn(active_unit(j),1);
    nodeJ = unit_conn(active_unit(j),2);
    if nodeI>0, K(nodeI, j) = +1; end
    if nodeJ>0, K(nodeJ, j) = -1; end
end

% outlet and non-outlet pressure nodes
units = unit_conn(active_unit,2)';
network = setdiff(1:n, units);

% process unit coefficients
C1 = zeros(au, n-au);
for i = 1:au
    nodeI = unit{active_unit(i)}.conn(1);
    [flag, pos] = ismember(nodeI, network);
    if flag, C1(i,pos) = unit_c(active_unit(i),1); end
end
C2 = diag(unit_c(active_unit,2));
C3 = diag(unit_c(active_unit,3));
d = unit_c(active_unit,4);
