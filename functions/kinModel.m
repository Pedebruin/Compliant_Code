function [theta,chi,phi,cAng,bAng,aAng,w,At,Bt,Ctx,Cty,Ct,Dt] = kinModel(Objects)
%{
This function evaluates a kinematic model to calculate the most important
angles in the kinematic model. 
Inputs: 
    Objects - All properties of the joints and links in objects array. 
Outputs:
    Angles          -       theta
                            chi
                            phi
                            cAng
                            bAng
                            aAng

    Deflection      -       w

    Effective lengths   -   At
                            Bt
                            Ct
                            Dt
%}

syms theta                                      
syms chi
[A,B,C,D,a,b,c,d,S] = Objects{:};               % Unpack the objects

% Effective lengths (From CoR to CoR)
At = A.L-a.L/2-d.L/2-2*A.t;                     % effective (total) length A
Bt = B.L-b.L/2-c.L/2-2*B.t;                     % effective (total) length B
    Ctx = (1-C.alpha)*C.L;                      % effective (total) length C (in x direction)
    Cty = (C.h/2+c.L/2);                        % effective (total) length C (in y direction)
Ct = sqrt(Ctx^2+Cty^2);                         % effective (total) length C
Dt = D.L-b.L/2-a.L/2-2*D.t;                     % effective (total) length D

% joint deflection angles
dAng = theta;
cAng = -asin((sin(theta)*At+sin(chi)*Dt)/Bt); 
bAng = chi-cAng;
aAng = chi-theta;

% Current length from center of bending beam to y = 0.
Lcurr = At*cos(theta)+Bt*cos(cAng)+Dt*cos(chi)-C.h/2-c.L/2-S.h-d.L/2;   

% Deflection of the beam
w = Lcurr-S.L;                        

% to deflection angle
phi = asin(w/Ct);
end