function [mdl, err] = pre_process (mdl)
% preprocess model

% consistency check 1
%--------------------------------------------------------------------------
[mdl, err] = check_consistency_1 (mdl);
if err, return; end

% number of nodes, pipes and ETC
nn = length(mdl.p);
ne = size(mdl.conn,1);
netc = length(mdl.etc.node);

% for each node, store adjacent pipes
%--------------------------------------------------------------------------
nodal_adj_pipe{nn} = [];
for i = 1:ne
    c = mdl.conn(i,:);
    nodal_adj_pipe{c(1)} = [nodal_adj_pipe{c(1)} i];
    nodal_adj_pipe{c(2)} = [nodal_adj_pipe{c(2)} i];
end
mdl.nodal_adj_pipe = nodal_adj_pipe;

% find active/inactive nodes and pipes
%--------------------------------------------------------------------------
active_node = zeros(1, nn);
active_pipe = zeros(1, ne);
submesh = 0;
for i = 1:netc
    
    etc_node = mdl.etc.node(i);
    if active_node(etc_node)==0, submesh = submesh + 1; end
    
    [active_node, active_pipe] = etc_path(etc_node, mdl, ...
        active_node, active_pipe, submesh);
end
mdl.active_node = find(active_node);
mdl.active_pipe = find(active_pipe);
mdl.inactive_node = find(active_node==0);
mdl.inactive_pipe = find(active_pipe==0);

% submesh classification
mdl.submesh_node = active_node;
mdl.submesh_pipe = active_pipe;

% pressure (free) DOFs
%--------------------------------------------------------------------------
mdl.free = intersect(find(mdl.p==0)', mdl.active_node);
mdl.fix = setdiff(mdl.active_node, mdl.free);
mdl.fix_or_inactive = setdiff(1:nn, mdl.free);

nfree = length(mdl.free);
mdl.nodal_dof = zeros(1, nn);
mdl.nodal_dof(mdl.free) = 1:nfree;

mdl.nodal_activity = zeros(1, nn);
mdl.nodal_activity(mdl.active_node) = 1:length(mdl.active_node);

% add Patm to pressure values (convert gauge to absolute)
mdl.p = mdl.p + mdl.Patm;
mdl.erp.pressure = mdl.erp.pressure + mdl.Patm;

% branch flow
mdl.qe = zeros(size(mdl.len));

% etc demands
mdl.nodal_etc_demand = zeros(nn, netc);
mdl.nodal_etc_demand(:,1) = 1;

% % average conditions on pipes
% mdl.Pa = zeros(1,ne); mdl.Za = ones(1,ne);

% consistency check 2
%--------------------------------------------------------------------------
[mdl, err] = check_consistency_2 (mdl);
if err, return; end
