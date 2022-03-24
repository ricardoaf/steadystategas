function mdl = post_process (mdl)
% postprocess model

% add Patm to pressure values (convert back absolut to gauge)
mdl.p = mdl.p - mdl.Patm;
mdl.erp.pressure = mdl.erp.pressure - mdl.Patm;

% compute pipe velocities
nea = length(mdl.active_pipe);
for i = 1:nea    
    
    e = mdl.active_pipe(i);
    q = abs(mdl.qe(e));
    
    c = mdl.conn(e,:);
    p = sort(mdl.p(c), 'descend');
    mdl.Pa(e) = 2/3*(p(1)+p(2)-p(1)*p(2)/(p(1)+p(2)));
    
    area = pi/4*(mdl.diameter(e)/12)^2;  % ft^2
    vb = q/area/1440;  % ft/min
    va = mdl.Pb / mdl.Tb * mdl.Ta / mdl.Pa(e) * mdl.Za(e) * vb;
    
    mdl.vel(e) = va;  % flow velocity [ft/min]
    % [km/h] = 0.018288 * [ft/min]
end
