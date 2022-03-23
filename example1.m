function [pressure, Q, f, nite, err] = example1
% Osiadacz, A. J. (1988)
% Method of steady-state simulation of a gas network
% International Journal of Systems Science, Vol. 19, Issue 11, 2395-2405

% Example 1
%--------------------------------------------------------------------------

% pipe data
conn = [1 1 1 4 3 2 2 5 22 6 4 4 4 12 12 11 13 10 14 10 15 15 16 10 9 9 ...
    8 9 8 7 6 18 7 20 20; 2 3 4 3 2 22 5 6 21 21 10 11 12 13 11 10 14 ...
    14 15 9 9 16 17 6 17 8 17 7 18 18 7 19 20 19 21]';
diam = 100*[7 7 7 7 7 7 6 6 7 6 7 6 7 6 7 6 6 6 7 6 7 6 7 6 7 6 6 6 ...
    7 6 7 6 7 6 7]';
len = 1000*[24 25 20 30 40 45 70 60 52 30 40 35 55 70 30 50 60 10 80 ...
    75 80 75 80 40 65 40 55 45 30 42 20 30 40 32 45]';

% node data
load = 1000*[0 90 29 75 0 55 85 28 90 41 39 20 0 80 45 0 12 42 18 ...
    35 29 71 0 0 0]';

% unit data
unit = {};
unit{1} = struct('type', 'source', 'conn', [0 1], 'value', 40);
unit{2} = struct('type', 'outlet_pressure', 'conn', [5 23], 'value', 40);
unit{3} = struct('type', 'outlet_pressure', 'conn', [13 24], 'value', 40);
unit{4} = struct('type', 'outlet_pressure', 'conn', [16 25], 'value', 40);

% convergence tolerance
tol = 1e-6;

%--------------------------------------------------------------------------

[pressure, Q, f, nite, err] = steadyStateGas ...
    (conn, load, unit, @panhandleA, struct('L',len,'D',diam), tol);

