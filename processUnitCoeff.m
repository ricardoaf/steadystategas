function [C1, C2, C3, d] = processUnitCoeff (n, unit, unit_c, network)

u = length(unit);

C1 = zeros(u, n-u);
for i = 1:u
    nodeI = unit{i}.conn(1);
    [flag, pos] = ismember(nodeI, network);
    if flag, C1(i,pos) = unit_c(i,1); end
end

C2 = diag(unit_c(:,2));

C3 = diag(unit_c(:,3));

d = unit_c(:,4);
