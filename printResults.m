function printResults (P, L, Q, f, unit, nite, err)

n = length(P);
m = length(Q);
u = length(unit);

fprintf('\n');
fprintf('%s\n', repmat('_', 1, 25));
fprintf('%6s  %14s\n', 'Node', 'Pressure [bar]');
fprintf('%s\n', repmat('_', 1, 25));
fprintf('%6d  %14.4e\n', [(1:n)' P(:)]');
fprintf('%s\n', repmat('_', 1, 25));

fprintf('\n');
fprintf('%s\n', repmat('_', 1, 25));
fprintf('%6s  %14s\n', 'Node', 'Flow [m3/h]');
fprintf('%s\n', repmat('_', 1, 25));
fprintf('%6d  %14.4e\n', [(1:n)' L(:)]');
fprintf('%s\n', repmat('_', 1, 25));

fprintf('\n');
fprintf('%s\n', repmat('_', 1, 25));
fprintf('%6s  %14s\n', 'Pipe', 'Flow [m3/h]');
fprintf('%s\n', repmat('_', 1, 25));
fprintf('%6d  %+14.4e\n', [(1:m)' Q(:)]');
fprintf('%s\n', repmat('_', 1, 25));

etc = [];
for i = 1:u
    if strcmp(unit{i}.type, 'source'), etc = [etc i]; end
end

fprintf('\n');
fprintf('%s\n', repmat('_', 1, 25));
fprintf('%6s  %14s\n', 'ETC', 'Flow [m3/h]');
fprintf('%s\n', repmat('_', 1, 25));
fprintf('%6d  %+14.4e\n', [(1:length(etc))' f(etc)]');
fprintf('%s\n', repmat('_', 1, 25));

fprintf('\n');
fprintf('#ite: %d\n', nite);
fprintf('|dQ|: %g\n', err);
