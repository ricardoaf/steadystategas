function [mdl, err] = check_consistency_2 (mdl)
% perform consistency tests on input data [in progress]
% check_consistency_2 needs 'mdl.nodal_adj_pipe' data

err = 0;

% erp field
if ~isfield(mdl, 'erp')
    mdl.erp = struct('pipe',[],'closed',[],'pressure',[],'enabled',[]);
end
mdl.erp.incoming_pipe = [];

% check if all erp pipes are contained by only one pipe
nerp = length(mdl.erp.pipe);
for i = 1:nerp
    
    pipe = mdl.erp.pipe(i);
    c = mdl.conn(pipe,:);
    
    nadjpipe = [length(mdl.nodal_adj_pipe{c(1)}) ...
        length(mdl.nodal_adj_pipe{c(2)})];
    
    if any(nadjpipe ~= 2)
        fprintf('Check ERP pipe %d connectivities', pipe);
        err = 1; return;
    end
end

% [warning] check inactive nodes with non-zero flow
id = find(abs(mdl.q(mdl.inactive_node))>0);
for i = 1:length(id)
    node = mdl.inactive_node(id(i));
    flow = mdl.q(node);
    fprintf(['Inactive node %d has a non-zero flow %g, ' ...
        'fixing as 0.0\n'], node, flow);
    mdl.q(node) = 0;    
end