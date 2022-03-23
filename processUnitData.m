function [K, unit_c, units, network] = processUnitData (n, unit)

% init
u = length(unit);
unit_conn = zeros(u, 2);
unit_c = zeros(u, 4);

% filter by unit type
for i = 1:u
    
    % set connectivities
    unit_conn(i,:) = unit{i}.conn;
    
    switch unit{i}.type
        case {'source', 'outlet_pressure'}
            unit_c(i,:) = [0 1 0 unit{i}.value];
            
        case 'inlet_pressure'
            unit_c(i,:) = [1 0 0 unit{i}.value];
            
        case 'pressure_ratio'
            unit_c(i,:) = [unit{i}.value -1 0 0];
            
        case 'flow'
            unit_c(i,:) = [0 0 1 unit{i}.value];
            
        case 'pressure_valve'
            unit_c(i,:) = [1 -1 0 0];
            
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
