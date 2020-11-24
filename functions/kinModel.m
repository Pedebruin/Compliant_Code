function [theta,chi,phi,dAng,cAng,bAng,aAng,w,At,Bt,Ct,Dt] = kinModel(Objects)
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
Ct = (1-C.alpha)*C.L;       % total length C
Dt = D.L-d.L/2-a.L/2-2*D.t; % total length D

% joint deflection angles
dAng = theta;
cAng = -asin((sin(theta)*At+sin(chi)*Dt)/Bt); 
bAng = chi-cAng;
aAng = theta-chi;

Lcurr = At*cos(theta)+Bt*cos(cAng)+Dt*cos(chi)-C.h/2-c.L/2-S.h-d.L/2;   % Current length from center of bendin beam to y = 0. 

w = S.L-Lcurr;                                                   % Deflection of the beam

% to deflection angle
phi = atan(w/Ct);
end

%S.L = -a.L-b.L-c.L-d.L+A.L+B.L+D.L-S.h-2*D.t-2*B.t-2*A.t-C.h/2-C.wmax;