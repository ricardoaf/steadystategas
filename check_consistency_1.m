function [mdl, err] = check_consistency_1 (mdl)
% perform consistency tests on input data [in progress]
err = 0;

if ~isfield(mdl,'x'), mdl.x = []; end
if ~isfield(mdl,'y'), mdl.y = []; end

if ~isfield(mdl,'etc'), disp('No given ETC'); err = 1; return; end
if ~isfield(mdl.etc,'node'), disp('No given ETC nodes'); err = 1; return; end
if isempty(mdl.etc.node), disp('No given ETC nodes'); err = 1; return; end
if ~isfield(mdl.etc,'gas'), disp('No given ETC gases'); err = 1; return; end
if isempty(mdl.etc.gas), disp('No given ETC gases'); err = 1; return; end
if length(mdl.etc.node)~=length(mdl.etc.gas), disp('Check ETC node/gas size'); err = 1; return; end

netc = length(mdl.etc.node);

if ~isfield(mdl,'p'), disp('No given pressure data'); err = 1; return; end
if ~isfield(mdl,'q'), disp('No given flow data'); err = 1; return; end
if length(mdl.p)~=length(mdl.q), disp('Check pressure/flow size'); err = 1; return; end
if any(mdl.p<0), disp('Check pressure values'); err = 1; return; end

nn = length(mdl.p);

if ~isfield(mdl, 'conn'), disp('No given pipe connectivities'); err = 1; return; end
if size(mdl.conn,1)==0, disp('No given pipe connectivities'); err = 1; return; end
if size(mdl.conn,2)~=2, disp('No given pipe connectivities'); err = 1; return; end

ne = size(mdl.conn,1);

if ~isfield(mdl, 'len'), disp('No given pipe length'); err = 1; return; end
if length(mdl.len)~=ne, disp('Check pipe length size'); err = 1; return; end
if any(mdl.len<=0), disp('Check pipe length values'); err = 1; return; end

if ~isfield(mdl, 'roughness'), disp('No given pipe roughness'); err = 1; return; end
if length(mdl.roughness)~=ne, disp('Check pipe roughness size'); err = 1; return; end
if any(mdl.roughness<=0), disp('Check pipe roughness values'); err = 1; return; end

if ~isfield(mdl, 'diameter'), disp('No given pipe diameter'); err = 1; return; end
if length(mdl.diameter)~=ne, disp('Check pipe diameter size'); err = 1; return; end
if any(mdl.diameter<=0), disp('Check pipe diameter values'); err = 1; return; end

if ~isfield(mdl, 'efficiency'), mdl.efficiency = ones(ne,1); end
if length(mdl.efficiency)~=ne, disp('Check pipe efficiency size'); err = 1; return; end
if any(mdl.efficiency<=0), disp('Check pipe efficiency values'); err = 1; return; end
if any(mdl.efficiency>1), disp('Check pipe efficiency values'); err = 1; return; end

% ...

