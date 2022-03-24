function Z = compressibility (T_R, P_PSIA, X) % aga8d

RANKINE_TO_KELVIN = 5/9; T = T_R * RANKINE_TO_KELVIN;
PSIA_TO_MPA = 0.006894757293168; P = P_PSIA * PSIA_TO_MPA;
% T = T_R + 273.15; P = P_PSIA; % (for AGA tests)

% T: line temperature (R) 
% P: line pressture (MPa)               [nbranches]
% X: mole fractions for the gas mixture [nbranches x 21]
%   01    CH4         Methane
%   02    N2          Nitrogen
%   03    CO2         Carbon Dioxide
%   04    C2H6        Ethane
%   05    C3H8        Propane
%   06    H20         Water
%   07    H2S         Hydrogen Sulfide
%   08    H2          Hydrogen
%   09    CO          Carbon Monoxide
%   10    O2          Oxygen
%   11    iso-C4H10   i-Butane
%   12    n-C4H10     n-Butane
%   13    iso-C5H12   i-Pentane
%   14    n-C5H12     n-Pentane
%   15    C6H14       n-Hexane
%   16    C7H16       n-Heptane
%   17    C8H18       n-Octane
%   18    C9H20       n-Nonane
%   19    C10H22      n-Decane
%   20    He          Helium
%   21    Ar          Argon

% Z: compressibility factor
% M: molar mass [g/mol]
% D: gas density at given T,P [kg/m3]

global RGAS; RGAS = 8.31451E-03;

global A B C K G Q F S W U
global MW EI KI GI QI FI SI WI
global EIJ UIJ KIJ GIJ
load aga8d_data.mat A B C K G Q F S W U MW EI KI GI QI FI SI WI EIJ UIJ KIJ GIJ

% Compressibility factor (Z)
m = length(P);
Z = ones(size(P));
parfor k = 1:m
    DCAGA(X(k,:));
    Z(k) = DZOFPT(P(k),T);
    
    % % Molar mass (M)
    % M(k) = sum(MW .* X);
    
    % % Gas density (D)
    % D(k) = M(k)*P(k)/(Z(k)*RGAS*T);
end

%--------------------------------------------------------------------------
function DCAGA (XJ)

XI = XJ;
SUM = sum(XI);
XI = XI./SUM;

global BI
BI = zeros(1,18);

global K1
global KI EI GI QI FI
K1 = sum(XI.*(KI.^2.5));
U1 = sum(XI.*(EI.^2.5));
G1 = sum(XI.*GI);
Q1 = sum(XI.*QI);
F1 = sum(XI.*XI.*FI);
K1 = K1 * K1;
U1 = U1 * U1;

global KIJ UIJ GIJ
for i = 1:20
    for j = i+1:21
        XIJ = XI(i) * XI(j);
        if XIJ ~=0
            K1 = K1 + 2*XIJ*(KIJ(i,j)^5-1)*((KI(i)*KI(j))^2.5);
            U1 = U1 + 2*XIJ*(UIJ(i,j)^5-1)*((EI(i)*EI(j))^2.5);
            G1 = G1 + XIJ*(GIJ(i,j)-1)*(GI(i)+GI(j));
        end
    end
end

global G Q F S W A U SI WI EIJ
for i = 1:21
    for j = i:21
        XIJ = XI(i)*XI(j);
        if XIJ ~=0
            if i ~=j, XIJ = 2*XIJ; end
            EIJ0 = EIJ(i,j)*sqrt(EI(i)*EI(j));
            GIJ0 = GIJ(i,j)*(GI(i)+GI(j))/2;
            for n = 1:18
                BI(n) = BI(n) + A(n)*XIJ*EIJ0^U(n)*(KI(i)*KI(j))^1.5*((GIJ0+1-G(n))^G(n) * (QI(i)*QI(j)+1-Q(n))^Q(n) * (sqrt(FI(i)*FI(j))+1-F(n))^F(n) * (SI(i)*SI(j)+1-S(n))^S(n) * (WI(i)*WI(j)+1-W(n))^W(n));
            end
        end
    end
end
K1 = K1^0.2;
U1 = U1^0.2;

global CNS
n = 13:58;
CNS(n) = (G1+1-G(n)).^G(n) .* (Q1*Q1+1-Q(n)).^Q(n) .* (F1+1-F(n)).^F(n) .* A(n).*U1.^U(n);

%--------------------------------------------------------------------------
function [P,Z,BMIX] = PZOFDT(D,T)

global K1 BI
DR = D*K1*K1*K1;

global U
i0 = 1:18;
BMIX = sum(BI(i0)./(T.^U(i0)));

global CNS B C K
i1 = 13:18;
i2 = 13:58;
Z = 1+BMIX*D - sum(DR*CNS(i1)./(T.^U(i1))) + sum(CNS(i2)./(T.^U(i2)).*(B(i2)-C(i2).*K(i2).*(DR.^K(i2))).*(DR.^B(i2)).*exp(-C(i2).*(DR.^K(i2))));

global RGAS
P = D*RGAS*T*Z;

%--------------------------------------------------------------------------
function [Z,BMIX] = DZOFPT(P,T)

% X1 = 0; X2 = 40;
X1 = 0.000001; X2 = 40;
TOL = 0.5E-09;

F1 = PZOFDT(X1,T);
[F2,Z,BMIX] = PZOFDT(X2,T);

F1 = F1 - P;
F2 = F2 - P;
if F1*F2>=0, return; end

for i=1:50
    
    X3 = X1-F1*(X2-X1)/(F2-F1);
    F3 = PZOFDT(X3,T);
    F3 = F3 - P;
    
    D = X1*F2*F3/((F1-F2)*(F1-F3))+X2*F1*F3/((F2-F1)*(F2-F3))+X3*F1*F2/((F3-F1)*(F3-F2));
    if (D-X1)*(D-X2)>=0, D = (X1+X2)/2; end
    
    [F,Z,BMIX] = PZOFDT(D,T);
    F = F - P;
    if abs(F)<=TOL, return; end
    
    if abs(F3)<abs(F) && F*F3>0
        
        if F3*F1>0, X1=X3; F1=F3;
        else, X2=X3; F2=F3;
        end
    else
        
        if F*F3<0, X1=D; F1=F; X2=X3; F2=F3;
        elseif F3*F1>0, X1=D; F1=F;
        else, X2=D; F2=F;
        end
    end
end
