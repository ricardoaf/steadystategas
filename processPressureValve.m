function unit_c = processPressureValve (P, unit, unit_c, p_exp)

% init
u = length(unit);

% filter by unit type
for i = 1:u
    type = unit{i}.type;
    conn = unit{i}.conn;
    val = unit{i}.value;
    
    if strcmp(type, 'pressure_valve')

        [Pmax, idx] = max(P(conn));
        if Pmax > (val^p_exp)
            
            if idx==1
                unit_c(i,:) = [0 1 0 val^p_exp];
            else
                unit_c(i,:) = [1 0 0 val^p_exp];
            end
        else
            unit_c(i,:) = [1 -1 0 0];
        end
    end
end
