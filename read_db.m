function mdl = read_db (dbfile)

dbpath = fullfile(pwd, dbfile);
conn = sqlite(dbpath, 'connect');

% nodes
nodes_data = fetch(conn, 'select * from nodes');
% topology = cell2mat(nodes_data(:,1));
mdl.node_id = nodes_data(:,2);
mdl.node_desc = nodes_data(:,3);
% node_role = nodes_data(:,4);
mdl.x = cell2mat(nodes_data(:,6));
mdl.y = cell2mat(nodes_data(:,5));
nn = length(mdl.x);
map_nodeid_pos = containers.Map(mdl.node_id', 1:nn);

% composition data
composition_data = fetch(conn, 'select * from gas_composition_data');
gas_id = composition_data(:,1);
mdl.gas = cell2mat(composition_data(:,2:end));
ngas = size(mdl.gas,1);
map_gasid_pos = containers.Map(gas_id', 1:ngas);

% suppliers
suppliers_data = fetch(conn, 'select * from suppliers');
supplier_node_id = suppliers_data(:,2);
supplier_gas_id = suppliers_data(:,3);
netc = size(supplier_gas_id, 1);

mdl.etc.node = zeros(1, netc);
mdl.etc.gas = zeros(1, netc);
for i = 1:netc
    mdl.etc.node(i) = map_nodeid_pos(supplier_node_id{i});
    mdl.etc.gas(i) = map_gasid_pos(supplier_gas_id{i});
end

% flow data
flow_data = fetch(conn, 'select * from nodal_flow_data');
flow_node_id = flow_data(:,2);
flow_values = cell2mat(flow_data(:,3));
mdl.q = zeros(nn,1);
for i = 1:size(flow_values,1)
    pos = map_nodeid_pos(flow_node_id{i});
    mdl.q(pos) = flow_values(i);
end

% pressure data
pressure_data = fetch(conn, 'select * from nodal_pressure_data');
pressure_node_id = pressure_data(:,2);
pressure_values = cell2mat(pressure_data(:,3));
mdl.p = zeros(nn,1);
for i = 1:size(pressure_values,1)
    pos = map_nodeid_pos(pressure_node_id{i});
    mdl.p(pos) = pressure_values(i);
end

% materials
mat_data = fetch(conn, 'select * from materials');
mat_id = mat_data(:,1);
mat_roughness = cell2mat(mat_data(:,3));
mat_diameter = cell2mat(mat_data(:,5));
mat_eff = cell2mat(mat_data(:,9));
nmat = size(mat_diameter,1);
map_matid_pos = containers.Map(mat_id', 1:nmat);

% pipes
pipe_data = fetch(conn, 'select * from pipes');
% pipe_topology = cell2mat(pipe_data(:,1));
mdl.pipe_id = pipe_data(:,2);
mdl.pipe_desc = pipe_data(:,3);
% pipe_role = pipe_data(:,4);
pipe_nodeI = pipe_data(:,5);
pipe_nodeJ = pipe_data(:,6);
mdl.len = cell2mat(pipe_data(:,8));
pipe_mat = pipe_data(:,9);
pipe_eff = cell2mat(pipe_data(:,11));
ne = size(pipe_nodeI,1);
map_pipeid_pos = containers.Map(mdl.pipe_id', 1:ne);

mdl.conn = zeros(ne,2);
mdl.roughness = zeros(ne,1);
mdl.diameter = zeros(ne,1);
mdl.efficiency = ones(ne,1);

for i = 1:ne
    
    node_i = map_nodeid_pos(pipe_nodeI{i});
    node_j = map_nodeid_pos(pipe_nodeJ{i});
    mdl.conn(i,:) = [node_i node_j];
    
    mat_pos = map_matid_pos(pipe_mat{i});
    mdl.roughness(i) =  mat_roughness(mat_pos);
    mdl.diameter(i) =  mat_diameter(mat_pos);
    
    mdl.efficiency(i) = mat_eff(mat_pos);
    if pipe_eff(i) > 0 && pipe_eff(i) <= 1
        mdl.efficiency(i) = pipe_eff(i);
    end
end

% ERP
erp_data = fetch(conn, 'select * from pressure_valves');
% erp_data = [];
if isempty(erp_data)
    mdl.erp.pipe = [];
    mdl.erp.closed = [];
    mdl.erp.pressure = [];
    mdl.erp.enabled = [];
    
else
    erp_pipe_id = erp_data(:,2);
    erp_pressure = cell2mat(erp_data(:,3));
    erp_closed = cell2mat(erp_data(:,4));
    % erp_dir = cell2mat(erp_data(:,5));
    erp_enabled = cell2mat(erp_data(:,6));
    nerp = size(erp_pipe_id,1);
    
    mdl.erp.pipe = zeros(1, nerp);
    mdl.erp.closed = zeros(1, nerp);
    mdl.erp.pressure = zeros(1, nerp);
    mdl.erp.enabled = zeros(1, nerp);
    
    for i = 1:nerp
        mdl.erp.pipe(i) = map_pipeid_pos(erp_pipe_id{i});
        mdl.erp.closed(i) = erp_closed(i);
        mdl.erp.pressure(i) = erp_pressure(i);
        mdl.erp.enabled(i) = erp_enabled(i);
    end
end

% VAL
valve_data = fetch(conn, 'select * from flow_valves');
% valve_data = [];
if isempty(valve_data)
    mdl.valve.pipe = [];
    mdl.valve.closed = [];
    
else
    
    valve_pipe_id = valve_data(:,2);
    valve_closed = cell2mat(valve_data(:,3));
    nval = size(valve_pipe_id,1);
    
    mdl.valve.pipe = zeros(1, nval);
    mdl.valve.closed = zeros(1, nval);
    
    for i = 1:nval
        mdl.valve.pipe(i) = map_pipeid_pos(valve_pipe_id{i});
        mdl.valve.closed(i) = valve_closed(i);
    end
end

% company params
company_params = fetch(conn, 'select * from company_params');
if isempty(company_params)
    mdl.Patm = 14.73;
    mdl.Tb = 527.67;
    mdl.Pb = 14.73;
    mdl.Ta = 519.652;
    mdl.visc = 2.5e-7;
    
else
    mdl.Patm = cell2mat(company_params(1,1));
    mdl.Tb = cell2mat(company_params(1,2));
    mdl.Pb = cell2mat(company_params(1,3));
    mdl.Ta = cell2mat(company_params(1,4));
    mdl.visc = cell2mat(company_params(1,5));
end

% global parameters
nr_gp = fetch(conn, 'select * from nr_global_params');
% nr_gp = [];
if isempty(nr_gp)
    mdl.tolx = 1e-10;
    mdl.tolf = 1e-08;
    mdl.maxiter = 10000;
    
else
    mdl.tolx = cell2mat(nr_gp(1,1));
    mdl.tolf = cell2mat(nr_gp(1,2));
    mdl.maxiter = cell2mat(nr_gp(1,3));
end
