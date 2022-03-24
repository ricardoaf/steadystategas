function mdl = flow (input)
% solve flow problem

% INIT model from input data
%--------------------------------------------------------------------------
switch class(input)
    case 'function_handle', mdl = input();
    case 'char', mdl = read_db(input);
    otherwise, return;
end

% PREPROCESS model: consistency check and topology validation
%--------------------------------------------------------------------------
[mdl, err] = pre_process (mdl);
if err, return; end

% CALC iterative (nonlinear) solution using fundamental pipe equation
%--------------------------------------------------------------------------
tic; mdl = iterative_solution (mdl); toc

% POSTPROCESS model
%--------------------------------------------------------------------------
mdl = post_process (mdl);

% SHOW summary results
%--------------------------------------------------------------------------
summary (mdl)
