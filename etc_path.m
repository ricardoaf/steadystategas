function [anode, apipe] = etc_path (node, mdl, anode, apipe, msh)
% apply non-zero mesh mark into active nodes and pipes
% (classify whole model into submeshs)

if anode(node)==0
    anode(node) = msh;
    
    for pipe = mdl.nodal_adj_pipe{node}
        
        % if closed valve, continue
        [flag, pos] = ismember(pipe, mdl.valve.pipe);
        if flag, if mdl.valve.closed(pos) == 1, continue; end, end
        
        % if closed erp, continue
        [flag, pos] = ismember(pipe, mdl.erp.pipe);
        if flag, if mdl.erp.closed(pos) == 1, continue; end, end
        
        % otherwise, mark pipe and recall recursive function fot its nodes
        apipe(pipe) = msh;
        c = mdl.conn(pipe,:);
        [anode, apipe] = etc_path (c(1), mdl, anode, apipe, msh);
        [anode, apipe] = etc_path (c(2), mdl, anode, apipe, msh);
    end
end