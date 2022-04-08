function [unit_c, f] = processPressureValve_old (P, unit, unit_c, f)

% filter by unit type
for i = 1:length(unit)
    
    conn = unit{i}.conn;
    val = unit{i}.value;
    
    if strcmp(unit{i}.type, 'pressure_valve')
        
        %-------------------------------------------------- node I > node J
        if P(conn(1)) > P(conn(2))
            if P(conn(1)) > val % regulating status
                unit_c(i,:) = [0 1 0 val];
            else % not regulating
                unit_c(i,:) = [1 -1 0 0];
            end
        else
            unit_c(i,:) = [1 -1 0 0]; % blocking status
        end                
        
        %-------------------------------------------------- both directions
        if f(i) < 0
            
            if P(conn(2)) > val % regulating status
                unit_c(i,:) = [1 0 0 val];
            else % not regulating
                unit_c(i,:) = [-1 1 0 0];
            end
            
        else
            
            if P(conn(1)) > val % regulating status
                unit_c(i,:) = [0 1 0 val];
            else % not regulating
                unit_c(i,:) = [1 -1 0 0];
            end
        end
    end
end
