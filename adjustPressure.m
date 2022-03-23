function varargout = adjustPressure(type, flow_eqn, unit, pressure)

% filter by unit type
for i = 1:length(unit)
    switch unit{i}.type
        case {'source', 'outlet_pressure', 'inlet_pressure', ...
                'pressure_ratio', 'pressure_valve'}
            unit{i}.value = feval(type, unit{i}.value, flow_eqn('power'));
    end
end

% set output
if nargin>3 && ~isempty(pressure)
    pressure = feval(type, pressure, flow_eqn('power'));
    varargout = {unit, pressure};
else
    varargout = {unit};
end

% convert/revert functions
function P = convert (p, p_pow), P = abs(p).^(p_pow-1) .* p;
function p = revert (P, p_pow), p = abs(P).^(1/p_pow-1) .* P;
