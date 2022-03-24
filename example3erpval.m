function [pressure, L, Q, f, nite, err] = example3erpval
% Example 3 (erp + val) [ricardoaf]
%--------------------------------------------------------------------------

% materials: std, 1, 2
r = [0.001181102 0.0011811 0.0011811]';
D = [1.023622047 3.93701000000001 2.25197000000001]';
e = [1 1 1]';

% company params
Patm = 14.6950060302182;
Pb = 14.7300036363325;
Tb = 519.66;
Ta = 519.66;
mu = 2.49999900896861e-07;

% composition
X = zeros(1, 21); X(1:4) = [0.82 0.12 0.04 0.02];
G = 0.6518;

% pipe data
conn = [1 2; 2 3; 2 4; 3 5; 6 5; 6 7; 4 8; 8 9; ...
    9 7; 2 10; 10 11; 11 12; 12 13; 13 14];
L = [0.00124274238447467 0.00248548476894934 0.00124274238447467 ...
    6.21371192237334e-05 0.00124274238447467 0.00124274238447467 ...
    6.21371192237334e-05 0.00124274238447467 0.00124274238447467 ...
    0.00124274238447467 6.21371192237334e-05 0.00124274238447467 ...
    6.21371192237334e-05 0.00124274238447467]';
mat = [2 3 3 1 2 2 1 2 2 3 3 3 1 2];

param = struct('Pb', Pb, 'Tb', Tb, 'Ta', Ta, 'mu', mu, ...
    'r', r(mat), 'D', D(mat), 'e', e(mat), 'L', L, ...
    'G', G, 'X', X, 'visc', mu);

% node data
load = -[0 0 0 0 0 0 -254265.600394718 0 0 0 0 0 0 -84755.2001315727]';

% unit data
unit = {...
    struct('type', 'source', 'conn', [0 1], 'value', 21.7556606595313) ...
    struct('type', 'pressure_valve', 'conn', [3 5], 'value', 14.50377377) ...
    struct('type', 'pressure_valve', 'conn', [4 8], 'value', 14.50377377) ...
    struct('type', 'pressure_valve', 'conn', [12 13], 'value', 14.50377377)};

% flow equation
flow_eqn = @FPE;

% flow valve
% fvalve = [];
fvalve = [10 11];

% add atmospheric pressure
for k = 1:length(unit)
    unit{k}.value = unit{k}.value + Patm;
end

% convert units to solver
if strcmp(func2str(flow_eqn), 'panhandleA')
    for k = 1:length(unit)
        unit{k}.value = unit{k}.value * 0.06894757293; % P: psi -> bar
    end
    load = load .* 0.001179868608; % Q: ft3/d -> m3/h
    param.L = param.L .* 1609.344; % L: mi -> m
    param.D = param.D .* 25.4; % D: inch -> mm
end

% remove valves from pipes
[conn, param] = removePipes (unit, fvalve, conn, param);

% convergence tolerance
tol = 0.001;

%--------------------------------------------------------------------------
rem_pipe = [9 10];
rem_node = 11:14;

conn(rem_pipe,:) = [];
load(rem_node) = [];
unit = {unit{1} unit{2} unit{3}};

param.r(rem_pipe) = [];
param.D(rem_pipe) = [];
param.e(rem_pipe) = [];
param.L(rem_pipe) = [];
    
% parei aqui !!!!!!
% remover pipes e nodes desnecessários para ver se atende [sim]
% algoritmo de descartar non-ETC reachble nodes and pipes [missing]
% exemplo e apresentação

% compressibilidade [aga8d incorporado]
% testar ideia de composição [2do]

% 2DO list
% - Incorporar equação fundamental de fluxo no MATLAB
% - Testar modelos sintéticos com ERPs já simulados pelo MAPFLOW
% - Comparar resultados
% - Desenvolver parser para entrada de dados (db -> MATLAB)
% - Testar modelos maiores em que foram reportados problemas com ERPs
% - Incorporar nova formulação ao simulador do MAPFLOW (C++)

%--------------------------------------------------------------------------

% call solver
[pressure, L, Q, f, alpha, flowProps, nite, err] = steadyStateGas ...
    (conn, load, unit, flow_eqn, param, tol);

% revert units from solver
if strcmp(func2str(flow_eqn), 'panhandleA')
    pressure = pressure ./ 0.06894757293; % P: psi <- bar
    L = L ./ 0.001179868608; % L: ft3/d <- m3/h
    Q = Q ./ 0.001179868608; % Q: ft3/d <- m3/h
    f = f ./ 0.001179868608; % f: ft3/d <- m3/h
end

% remove atmospheric pressure
pressure = pressure - Patm;

% convert units to output
pressure = pressure .* 6.894757293; % P: psi -> kPa
L = L .* 0.001179868608; % L: ft3/d -> m3/h
Q = Q .* 0.001179868608; % Q: ft3/d -> m3/h
f = f .* 0.001179868608; % f: ft3/d -> m3/h

% print results
printResults (pressure, L, Q, f, unit, nite, err);

%--------------------------------------------------------------------------
function [conn, param] = removePipes (unit, fvalve, conn, param)
rem_pipe = [];
for k = 1:length(unit)
    c = unit{k}.conn;
    rem_pipe = [rem_pipe find( (conn(:,1)==c(1) & conn(:,2)==c(2)) ...
        | (conn(:,1)==c(2) & conn(:,2)==c(1)) )];
end
for k = 1:size(fvalve,1)
    c = fvalve(k,:);
    rem_pipe = [rem_pipe find( (conn(:,1)==c(1) & conn(:,2)==c(2)) ...
        | (conn(:,1)==c(2) & conn(:,2)==c(1)) )];
end
conn(rem_pipe,:) = [];
param.r(rem_pipe) = [];
param.D(rem_pipe) = [];
param.e(rem_pipe) = [];
param.L(rem_pipe) = [];
