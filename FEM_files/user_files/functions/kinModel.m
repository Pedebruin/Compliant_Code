function [theta,beta,alpha,w,phi] = kinModel(Objects)
%{
This function evaluates a kinematic model to calculate some important
angles. It outputs these angles as a function of the symbolic variable
theta. 

%}
syms theta
[A,B,C,D,a,b,c,d,S] = Objects{:};               % Unpack the objects

At = A.L-a.L/2-b.L/2-2*A.t; % total length A
Bt = B.L-b.L/2-c.L/2-2*B.t; % total length B
Ct = (1-C.alpha)*C.L;
Dt = D.L-d.L-2*D.t;

beta = asin(sin(theta)* At/Bt);                                 % intermediate angle   
Lnew = At*cos(theta)+Bt*cos(beta)-C.h/2-S.h;
alpha = theta+beta; 
w = Lnew-S.Li;                                                   % Deflection of the beam

% to deflection angle
phi = atan(w/Ct);
end

%S.L = -a.L-b.L-c.L-d.L+A.L+B.L+D.L-S.h-2*D.t-2*B.t-2*A.t-C.h/2-C.wmax;