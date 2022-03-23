function [pressure, Q, f, nite, err] = example2fv
% Osiadacz, A. J. (1988)
% Method of steady-state simulation of a gas network
% International Journal of Systems Science, Vol. 19, Issue 11, 2395-2405

% Example 2 pvalve [ricardoaf]
%--------------------------------------------------------------------------

% pipe data
conn = [1 1 2 2 3 5 7 8 8 9; 2 3 3 4 6 8 9 9 10 10]';
diam = [7 7 7 6 6 6 6 5 5 5]' * 100;
len = [70 60 90 50 45 70 80 70 45 75]' * 1000;

% node data
load = [0 20 20 0 0 0 0 15 300 45]' * 1000;

% unit data
unit = {};
unit{1} = struct('type', 'source', 'conn', [0 1], 'value', 50);
unit{2} = struct('type', 'pressure_ratio', 'conn', [4 5], 'value', 1.2);
% 6-7 connection removed (flow valve)

% convergence tolerance
tol = 1e-6;

%--------------------------------------------------------------------------

[pressure, Q, f, nite, err] = steadyStateGas ...
    (conn, load, unit, @panhandleA, struct('L',len,'D',diam), tol);
