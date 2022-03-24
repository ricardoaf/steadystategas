function mdl = example_daniel_valves

% nodal coords (only for drawing purpose)
mdl.x = [-35.8925828131951 -35.8544963663248 -35.8290991026675 -35.8291054761286 -35.8074710100641 -35.7839621882744 -35.7839640287289 -35.8065356082084 -35.7839657159186 -35.8540309988176 -35.8535640466852 -35.8244096325898 -35.8093620837485 -35.7844396346406]';
mdl.y = [-9.53929685494598 -9.53931276869473 -9.5183176596648 -9.53978780638331 -9.51832325355002 -9.51832781378983 -9.52952964195256 -9.53979362641944 -9.53979798383564 -9.55238171054729 -9.56124997380541 -9.56172602593388 -9.56172987432128 -9.56220155752857]';

% ETC: nodes and gases (id arrays)
mdl.etc.node = 1;
mdl.etc.gas = 1;

% flow [scfd] and pressure [psig] vectors
mdl.q = zeros(14,1); mdl.q([7 14]) = [-3390208.0052629 -1695104.00263145]';
mdl.p = zeros(14,1); mdl.p(1) = 21.7556606595313;

% pipe connectivity
mdl.conn = [1 2; 2 3; 2 4; 3 5; 5 6; 6 7; 4 8; 8 9; 9 7; 2 10; 10 11; 11 12; 12 13; 13 14];

% pipes: length [mile], roughness [inch], diameter [inch] and efficiency
ne = size(mdl.conn,1);
mdl.len = [0.00124274238447467 0.00248548476894934 0.00124274238447467 6.21371192237334e-05 0.00124274238447467 0.00124274238447467 6.21371192237334e-05 0.00124274238447467 0.00124274238447467 0.00124274238447467 6.21371192237334e-05 0.00124274238447467 6.21371192237334e-05 0.00124274238447467]';
mdl.roughness = zeros(ne,1); mdl.diameter = zeros(ne,1);
std = [4 7 13]; nm1 = [1 5 6 8 9 14]; nm2 = [2 3 10 11 12];
mdl.roughness(nm1) = 0.0011811; mdl.diameter(nm1) = 3.93701000000001;
mdl.roughness(nm2) = 0.0011811; mdl.diameter(nm2) = 2.25197000000001;
mdl.roughness(std) = 0.001181102; mdl.diameter(std) = 1.023622047;
mdl.efficiency = ones(ne,1);

% gas compositions [fractions] from ETCs (each composition in a row)
mdl.gas = zeros(1,21);
mdl.gas(1,[1 2 4]) = [0.92 0.02 0.06];

% ERP: pipes, state, regulating pressure [psig], status
mdl.erp.pipe = [4 7 13];
mdl.erp.closed = [0 0 0];
mdl.erp.pressure = [14.50377377 14.50377377 21.75566066];
mdl.erp.enabled = [1 1 1];

% VALVE: pipes, state
mdl.valve.pipe = 11;
mdl.valve.closed = 1;

% company parameters: atmospheric pressure [psi], base temperature [R],
% base pressure [psi], line temperature [R], viscosity [lbf*s/ft/ft]
mdl.Patm = 14.73;
mdl.Tb = 527.67;
mdl.Pb = 14.73;
mdl.Ta = 519.652;
mdl.visc = 2.5e-7;

% iterative parameters
mdl.tolx = 1e-6;
mdl.tolf = 1e-5;
mdl.maxiter = 1000;
