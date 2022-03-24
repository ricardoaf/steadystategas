function mdl = flow (varargin)
% solve flow problem

% INIT model from input data
%--------------------------------------------------------------------------
if nargin==0
    error(sprintf('mdl = flow(@problem)\nmdl = flow(@problem, args)'));
else
    fnc = varargin{1};
    if nargin==1, mdl = fnc(); else, mdl = fnc(varargin{2}); end
end

% PREPROCESS model: consistency check and topology validation
%--------------------------------------------------------------------------
[mdl, err] = pre_process (mdl);
if err, return; end

% calc iterative (nonlinear) solution using fundamental pipe equation
%--------------------------------------------------------------------------
tic; mdl = iterative_solution (mdl); toc

% % calc GAS MIXTURE
% %--------------------------------------------------------------------------
% % mdl = gas_mixture (mdl);
% [pipe_list, mdl] = pipe_order (mdl);

% POSTPROCESS model
%--------------------------------------------------------------------------
mdl = post_process (mdl);

% display SUMMARY results
%--------------------------------------------------------------------------
summary (mdl)
