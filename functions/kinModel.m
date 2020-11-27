function [theta,chi,phi,cAng,bAng,aAng,w,At,Bt,Ctx,Cty,Ct,Dt] = kinModel(Objects)
%{
This function evaluates a kinematic model to calculate some important
angles. It outputs these angles as a function of the symbolic variable
theta and chi. 

%}
syms theta
syms chi
[A,B,C,D,a,b,c,d,S] = Objects{:};               % Unpack the objects

% Effective lengths (From CoR to CoR)
At = A.L-a.L/2-b.L/2-2*A.t; % total length A
Bt = B.L-b.L/2-c.L/2-2*B.t; % total length B
    Ctx = (1-C.alpha)*C.L;      % total length C (in x direction)
    Cty = (C.h/2+c.L/2);        % total length C (in y direction)
Ct = sqrt(Ctx^2+Cty^2);
Dt = D.L-d.L/2-a.L/2-2*D.t; % total length D

% joint deflection angles
dAng = theta;
cAng = -asin((sin(theta)*At+sin(chi)*Dt)/Bt); 
bAng = chi-cAng;
aAng = chi-theta;

Lcurr = At*cos(theta)+Bt*cos(cAng)+Dt*cos(chi)-C.h/2-c.L/2-S.h-d.L/2;   % Current length from center of bendin beam to y = 0. 

w = Lcurr-S.L;                                                          % Deflection of the beam

% to deflection angle
phi = asin(w/Ct);
end