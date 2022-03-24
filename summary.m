function summary (mdl)

psi2kpa = 6.894757293168361; %psi2kpa = 1.0;
cfd2cmh = 0.001179868608; %cfd2cmh = 1.0;

% display ETC nodes
etc = mdl.etc.node; netc = length(etc);
fprintf('\nETC\n');
fprintf('%5s %20s\n', 'id', 'desc');
fprintf('%s\n', repmat('-',[1 26]));
for i = 1:netc, id = etc(i);
    desc = ''; if isfield(mdl, 'node_desc'), desc = mdl.node_desc{id}; end
    fprintf('%5d %20s\n', id, desc);
end

% display q>0 nodes
real_etc = find(mdl.q>mdl.tolf)'; nreal_etc = length(real_etc);
fprintf('\nSUPPLIERS\n');
fprintf('%5s %20s %12s %12s\n', 'id', 'desc', 'p [kPa]', 'q [scmh]');
fprintf('%s\n', repmat('-',[1 52]));
for i = 1:nreal_etc, id = real_etc(i);
    p = mdl.p(id)*psi2kpa; q = mdl.q(id)*cfd2cmh;
    desc = ''; if isfield(mdl, 'node_desc'), desc = mdl.node_desc{id}; end
    fprintf('%5d %20s %12g %+12.3f\n', id, desc, p, q);
end

% display q<0 nodes
demand = find(mdl.q<-mdl.tolf*max(abs(mdl.q)))'; ndemand = length(demand);
fprintf('\nDEMANDS\n');
fprintf('%5s %20s %12s %12s ', 'id', 'desc', 'p [kPa]', 'q [scmh]');

etcid = zeros(1, nreal_etc);
for i = 1:nreal_etc, id = real_etc(i);
    setc = sprintf('%%ETC-%d', id);
    etcid(i) = find(etc==id);
    fprintf('%11s ', setc);
end

fprintf('\n%s\n', repmat('-',[1 52+12*nreal_etc]));
for i = 1:ndemand, id = demand(i);
    p = mdl.p(id)*psi2kpa; q = mdl.q(id)*cfd2cmh;
    desc = ''; if isfield(mdl, 'node_desc'), desc = mdl.node_desc{id}; end
    fprintf('%5d %20s %12g %+12.3f ', id, desc, p, q);
    
    fprintf('%11.4f ', mdl.nodal_etc_demand(id, etcid)*100);
    fprintf('\n');
end
fprintf('\n');
