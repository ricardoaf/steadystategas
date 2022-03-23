function f = friction (rr, Re)
ReL = 2000; ReT = 3250;
L = find(Re<ReL);
T = find(Re>ReT);
M = setdiff(1:length(Re), [L(:); T(:)]);

f = zeros(size(Re));
f(L) = laminar(Re(L));
if ~isempty(T)
    f(T) = turbulent(rr(T), Re(T));
end

if ~isempty(M)
    flam = laminar(ReL);
    ftur = turbulent(rr(M), ReT);
    f(M) = flam + (Re(M) - ReL)./(ReT-ReL) .* (ftur-flam);
end

function f = laminar(ReL)
f = 64./ReL;

function f = turbulent(rr, Re)
f = 0.015*ones(size(Re));
opt = optimoptions('fsolve', 'Display', 'off');
f = fsolve(@(f) colebrook(f, rr, Re), f, opt);

function F = colebrook(f, rr, Re)
F = 1./sqrt(f) + 2*log10(rr./3.7 + 2.51./(Re.*sqrt(f)));