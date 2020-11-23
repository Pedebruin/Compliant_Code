function Plots = showme(theta_n,F,V,Fb,Objects,name)
%{ 
The function calculates the correct positions and angles based on a kinematic
model. This model is then plotted in Figure 1: Analysis.  
It takes as inputs:

Theta: The current angle
F: The current force
V: The current potential energy
In Objects array:
    a: Object for joint a
    b: Object for joint b
    c: Object for joint c
    d: Object for joint d
    A: Object for link A
    B: Object for link B
    C: Object for beam C
    D: Object for beam D
    S: Object for support S
%}
[A,B,C,D,a,b,c,d,S] = Objects{:};               % Unpack the objects

P1x = [-5 20]*10^(-2);                      % Axes for plot 1
P2x = [-abs(A.theta_min) abs(A.theta_max)]; % Axes for plot 2
P3x = P2x+[1e-3 1e-3];                      % Axes for plot 3 (add small deviation to find it later)

%% For saving V, theta and F in vectors V_v, theta_v and F_v. %%%%%%%%%%%%%
persistent V_v;
persistent theta_v;
persistent F_v;

% Create consistent variables and fill them
if isempty(theta_v) && isempty(F_v) && isempty(V_v)
     theta_v = theta_n;
     F_v = F;
     V_v = V;    
else
    theta_v = [theta_v, theta_n];
    F_v = [F_v F];
    V_v = [V_v,V];    
end

%% Create the plot (if it does not already exist)%%%%%%%%%%%%%%%%%%%%%%%%%%
if isempty(findobj('type','figure','name',name)) % create it
    P = figure('Name',name);
    sgtitle 'Mechanism analysis'
    P1 = subplot(2,3,[1 2 4 5]);
        hold on
        xlabel 'x position [m]'
        ylabel 'y position [m]'
        title 'Visualisation'
        grid on
        axis equal
        xlim(P1x)
    P2 = subplot(2,3,3);
        hold on
        grid on
        title 'P. Energy V'
        xlabel 'angle $\theta$ [rad]'
        ylabel 'Potential energy [J]'
        xlim(P2x)
    P3 = subplot(2,3,6);
        hold on
        grid on
        title 'String force F'
        xlabel 'angle $\theta$ [rad]'
        ylabel 'Force [N]'
        xlim(P3x)
else % or find the figure again! (it is lost between function evaluations)
    P = findobj('type','figure','name','Analysis');
    P1 = findobj('type','axes','Xlim',P1x);
    P2 = findobj('type','axes','xlim',P2x);
    P3 = findobj('type','axes','xlim',P3x);
end


%% calculate phi (deflection angle of the beam) %%%%%%%%%%%%%%%%%%%%%%%%%%%
% Deflection as a function of theta
[~,beta,~,w,phi] = kinModel(Objects);

% Evaulate the angles from symbolic toolbox
theta = theta_n;                % angle theta
beta = eval(subs(beta));        % angle beta
phi = eval(subs(phi));          % angle phi
w = eval(subs(w));              % vertical displacement beam

    
%% Plot Force in P3 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if size(F_v,2)>=2
    F_p = plot(P3,theta_v,F_v,'b');
else
    F_p = plot(P3,theta_v,F_v,'b+');
end

%% Plot the potential energy %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if size(V_v,2)>=2
    V_p = plot(P2,theta_v,V_v,'k');  
else                                                % single evaluation
    V_p = plot(P2,theta_v,V_v,'K+');
end
%% Plot the equilibriumpoints in P2 & P3
if length(F_v) >= 2
    if sign(F_v(end))~=sign(F_v(end-1))
        xline(P2,theta_n,'k--');
        xline(P3,theta_n,'k--');
        disp(['Equilibrium at theta = ',num2str(theta_n)]);
    end
end


%% Plot the mechanism %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Rtheta = [cos(theta) -sin(theta);       % Bottom corner
         sin(theta) cos(theta)]; 
Rthetam = [cos(-theta) -sin(-theta);       % Bottom corner
         sin(-theta) cos(-theta)]; 
Rphi = [cos(phi) -sin(phi);             % Deflection angle
        sin(phi) cos(phi)];
Rbeta = [cos(-beta) sin(-beta);           % Top corner
        -sin(-beta) cos(-beta)];
Rphim = [cos(-phi) -sin(-phi);             % Deflection angle
        sin(-phi) cos(-phi)];
        
% Centers of rotation
C.CoR = [C.alpha*C.L;
        S.L];

c.CoR = C.CoR + Rphi*[(1-C.alpha)*C.L-c.h/2;
                      C.h/2+c.L/2];
b.CoR = c.CoR + Rbeta*Rphi * [0;
                        c.L/2-B.L+b.L/2+2*B.t];    
a.CoR = b.CoR+ Rphim*[0;
            -D.L+c.L/2+b.L/2+2*D.t];  
d.CoR = [C.L-a.h/2;
            -S.h-a.L/2];
     

%% Plot values in text
Fcr = min([a.Fcr,b.Fcr,c.Fcr]);
if exist('Fcrmax')
    Fcrmax = max(Fcrmax,Fcr);
else
    Fcrmax = Fcr;
end

y={strcat('$$F_b$$ = ',num2str(Fb,3),'N')
strcat('$$F_{cr}$$ = ',num2str(Fcr,3),'N')
strcat('$$F$$ = ',num2str(F,3),'N')};
str=sprintf('%s\n',y{:});


if Fb >= a.Fcr || Fb >= b.Fcr || Fb >= c.Fcr % If buckling is possible
    txt = text(P1,-S.h,a.L+b.L+c.L+A.L+B.L+C.h+0.01,str,'Color','red');
else
    txt = text(P1,-S.h,a.L+b.L+c.L+A.L+B.L+C.h+0.01,str);
end
    
    
 
%% Support
XS = [-S.h -S.h 0 0 C.L C.L];
YS = [-S.h S.L+C.h/2 S.L+C.h/2 0 0 -S.h];
S_p = patch(P1,XS,YS,'m');

%% Joints
% a   
aBOT = a.CoR + Rphim*[-a.h/2 0 a.h/2; 
                -a.L/2 0 -a.L/2];
aTOP = a.CoR + Rthetam*[-a.h/2 0 a.h/2;
                        a.L/2 0 a.L/2];
a_p = patch(P1,[aBOT(1,:)',aTOP(1,:)'],[aBOT(2,:)',aTOP(2,:)'],'y');

% b
bBOT = b.CoR + Rphi*Rbeta*[-b.h/2 0 b.h/2;
                -b.L/2 0 -b.L/2];
bTOP = b.CoR + Rphim*[0 b.h/2 -b.h/2;
                0 b.L/2 b.L/2];
b_p = patch(P1,[bBOT(1,:)',bTOP(1,:)'],[bBOT(2,:)',bTOP(2,:)'],'y');

% c
cTOP = c.CoR + Rphi*[0 c.h/2 -c.h/2;
                     0 -c.L/2 -c.L/2];
cBOT = c.CoR + Rphi*Rbeta*[0 -c.h/2 c.h/2;
                           0 c.L/2 c.L/2];
c_p = patch(P1,[cTOP(1,:),cBOT(1,:)]',[cTOP(2,:),cBOT(2,:)]','y');

% d
dBOT = d.CoR + Rthetam*[-d.h/2 0 d.h/2;
                       -d.L/2 0 -d.L/2];
dTOP = d.CoR + [0 d.h/2 -d.h/2;
                      0 d.L/2 d.L/2];
d_p = patch(P1,[dBOT(1,:)',dTOP(1,:)'],[dBOT(2,:)',dTOP(2,:)'],'y');

%% Links
% A
Apos = a.CoR + Rthetam*[A.s+A.h/2;
                        -A.L/2+a.L/2+A.t];
APOS = Apos + Rthetam*([-A.h/2 -A.s-A.h/2 -A.s-A.h/2 -A.h/2 A.h/2 0 A.h/2 A.h/2 A.w+A.h/2 A.w+A.h/2 -A.h/2 -A.s-A.h/2 -A.s-A.h/2 -A.h/2;
                       -A.L/2+A.t -A.L/2+A.t -A.L/2 -A.L/2 -A.L/2 0 -A.L/4 A.L/4 A.L/4 A.L/2 A.L/2 A.L/2 A.L/2-A.t A.L/2-A.t] + ... 
                      [0 0 0 0 0 A.h/2+A.v*sin(A.delta) 0 0 0 0 0 0 0 0;
                     0 0 0 0 0 -A.L/2-A.v*cos(A.delta) 0 0 0 0 0 0 0 0]);    
A_p = patch(P1,APOS(1,:),APOS(2,:),'r');
F = quiver(P1,APOS(1,6),APOS(2,6),0,F/150,'b');

% B
Bpos = c.CoR + Rphi*Rbeta*[B.s+B.h/2;
                        -B.L/2+c.L/2+B.t];
BPOS = Bpos + Rphi*Rbeta*[-B.h/2 -B.h/2-B.s -B.h/2-B.s -B.h/2 B.h/2 B.h/2 -B.h/2 -B.h/2-B.s -B.h/2-B.s -B.h/2;
                      -B.L/2+B.t -B.L/2+B.t -B.L/2 -B.L/2 -B.L/2 B.L/2 B.L/2 B.L/2 B.L/2-B.t B.L/2-B.t];
B_p = patch(P1,BPOS(1,:),BPOS(2,:),'r');

% C
CLEFT = C.CoR + [-C.alpha*C.L 0 0 -C.alpha*C.L;
                -C.h/2 0 0 C.h/2] +            Rphi*[0 0 0 0;
                                               0 -C.h/2 C.h/2 0];
CLEFT = circshift(CLEFT,1,2);                                
CRIGHT = C.CoR + Rphi*[0 (1-C.alpha)*C.L (1-C.alpha)*C.L 0;
                        -C.h/2 -C.h/2 C.h/2 C.h/2];
C_p = patch(P1,[CLEFT(1,:) CRIGHT(1,:)]',[CLEFT(2,:) CRIGHT(2,:)]','g');

% D
Dpos = b.CoR + Rphim*[-D.s-D.h/2;
                        -D.L/2+c.L/2+D.t];
DPOS = Dpos + Rphim*[-D.h/2 D.h/2 D.h/2+D.s D.h/2+D.s D.h/2  D.h/2 D.h/2+D.s D.h/2+D.s -D.h/2;
                        -D.L/2 -D.L/2 -D.L/2 -D.L/2+D.t -D.L/2+D.t D.L/2-D.t D.L/2-D.t D.L/2 D.L/2];
D_p = patch(P1,DPOS(1,:),DPOS(2,:),'r');

Plots = [a_p, b_p, c_p, d_p, A_p, B_p, C_p, D_p, F, F_p, V_p, txt]; 

end
