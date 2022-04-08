function mdl = iterative_solution (mdl)
% calc nonlinear iterative solution using fundamental pipe equation

% filter solver input data
%--------------------------------------------------------------------------

% define pipe equation
flow_eqn = @FPE;

% define tolerance
tol = mdl.tolf;

% swap conn form erp pipes with direction=1
nerp = length(mdl.erp.pipe);
for k = 1:nerp
    pipe = mdl.erp.pipe(k);
    dir = mdl.erp.dir(k);
    if dir==1
        mdl.conn(pipe, :) = mdl.conn(pipe, [2 1]);
    end
end

% define unit
netc = length(mdl.etc.node);
unit = cell(1,netc+nerp); u = 0;
for k = 1:netc
    node = mdl.nodal_activity(mdl.etc.node(k));
    pressure = mdl.p(node);
    gas = mdl.etc.gas(k);
    u = u + 1;
    unit{u} = struct('type','source', 'conn',[0 node], 'value',pressure, 'gas',gas);
end
for k = 1:nerp
    if mdl.erp.closed(k) || ~mdl.erp.enabled(k), continue; end
    pipe = mdl.erp.pipe(k);
    conn = mdl.nodal_activity(mdl.conn(pipe, :));
    if any(conn==0), continue; end
    pressure = mdl.erp.pressure(k);
    dir = mdl.erp.dir(k);
    u = u + 1;
    unit{u} = struct('type','pressure_valve', 'conn',conn, 'value',pressure, 'pipe', pipe, 'dir', dir);
    % also inactivate pipe
    mdl.inactive_pipe = unique([mdl.inactive_pipe pipe]);
    mdl.active_pipe = setdiff(1:size(mdl.conn,1), mdl.inactive_pipe);
end
unit = unit(1:u);

% define conn
conn = mdl.conn(mdl.active_pipe, :);
conn = mdl.nodal_activity(conn);

% define load
load = -mdl.q(mdl.active_node);

% define parameters
param = struct(...
    'Pb', mdl.Pb, ...
    'Tb', mdl.Tb, ...
    'Ta', mdl.Ta, ...
    'visc', mdl.visc, ...
    'r', mdl.roughness(mdl.active_pipe), ...
    'D', mdl.diameter(mdl.active_pipe), ...
    'e', mdl.efficiency(mdl.active_pipe), ...
    'L', mdl.len(mdl.active_pipe), ...
    'X', mdl.gas);

% call solver
%--------------------------------------------------------------------------
[pressure, L, Q, f, alpha, flowProps, nite, err] = steadyStateGas_old ...
    (conn, load, unit, flow_eqn, param, tol);
fprintf('[solver] %d ite, err: %g\n', nite, err);

% revert conn form erp pipes with direction=1
for k = 1:nerp
    pipe = mdl.erp.pipe(k);
    dir = mdl.erp.dir(k);
    if dir==1
        mdl.conn(pipe, :) = mdl.conn(pipe, [2 1]);
    end
end

% add results to model
%--------------------------------------------------------------------------
mdl.p(mdl.active_node) = pressure;
mdl.q(mdl.active_node) = -L;
mdl.qe(mdl.active_pipe) = Q;

for k = 1:u
    if strcmp(unit{k}.type, 'source')
        node = unit{k}.conn(2);
        mdl.q(node) = f(k);
    elseif strcmp(unit{k}.type, 'pressure_valve')
        pipe = unit{k}.pipe;
        mdl.qe(pipe) = f(k);
    end
end

mdl.nodal_etc_demand = alpha;

mdl.Re = zeros(size(mdl.qe));
mdl.f = zeros(size(mdl.qe));
mdl.Za = ones(size(mdl.qe));

if isfield(flowProps, 'Re'), mdl.Re(mdl.active_pipe) = flowProps.Re; end
if isfield(flowProps, 'f'), mdl.f(mdl.active_pipe) = flowProps.f; end
if isfield(flowProps, 'Za'), mdl.Za(mdl.active_pipe) = flowProps.Za; end
