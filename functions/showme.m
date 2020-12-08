function Plots = showme(theta_n,chi_n,F,V,Objects,eqflag,visualisation,name)
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

MaxDisp = abs(((A.v)*sin(A.delta)+A.h+A.s)*sin(A.theta_max));


P1x = [-S.h*2,C.L*4];                      % Axes for plot 1
P2x = [-MaxDisp MaxDisp]; % Axes for plot 2
P3x = P2x+[1e-3 1e-3];                      % Axes for plot 3 (add small deviation to find it later)

% Calculate displacement of force at angle theta
Disp = ((A.v)*sin(A.delta)+A.h+A.s)*sin(theta_n);

%% For saving V, theta and F in vectors V_v, theta_v and F_v. %%%%%%%%%%%%%
persistent V_v;
persistent theta_v;
persistent chi_v;
persistent F_v;
persistent Disp_v;

% Create consistent variables and fill them
if isempty(theta_v) && isempty(F_v) && isempty(V_v) && isempty(Disp_v)
     theta_v = theta_n;
     chi_v = chi_n;
     F_v = F;
     V_v = V; 
     Disp_v = Disp;
else
    theta_v = [theta_v, theta_n];
    chi_v  = [chi_v,chi_n];
    F_v = [F_v F];
    V_v = [V_v,V];
    Disp_v = [Disp_v,Disp];
end


%% Create the plot (if it does not already exist)%%%%%%%%%%%%%%%%%%%%%%%%%%
if isempty(findobj('type','figure','name',name)) % create it
    P = figure('Name',name);
    sgtitle(name)
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
        xlabel 'Displacement finger [m]'
        ylabel 'Potential energy [J]'
        xlim(P2x)
    P3 = subplot(2,3,6);
        hold on
        grid on
        title 'String force F'
        xlabel 'Displacement finger [m]'
        ylabel 'Force [N]'
        xlim(P3x)
else % or find the figure again! (it is lost between function evaluations)
    P = findobj('type','figure','name',name); 
    P1 = findobj('type','axes','Xlim',P1x,'parent',P);
    P2 = findobj('type','axes','xlim',P2x,'parent',P);
    P3 = findobj('type','axes','xlim',P3x,'parent',P);
end


%% Evaluate kinematic model at current timestep %%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get symbolic expressions
[~,~,phi,cAng,bAng,aAng,w,At,Bt,Ctx,Cty,Ct,Dt] = kinModel(Objects);

theta = theta_n;                % angle theta
chi = chi_n;                    % angle chi

% Evaulate the kinematic model!
cAng = eval(subs(cAng));        % angle cAng
bAng = eval(subs(bAng));        % angle bAng
aAng = eval(subs(aAng));        % angle aAng
phi = eval(subs(phi));          % angle phi
w = eval(subs(w));              % vertical displacement beam

%% Plot Force in P3 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if size(F_v,2)>=2
    F_p = plot(P3,Disp_v,F_v,'b');
else
    F_p = plot(P3,Disp_v,F_v,'b+');
end

%% Plot the potential energy in P2 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if size(V_v,2)>=2
    V_p = plot(P2,Disp_v,V_v,'k');  
else                                                % single evaluation
    V_p = plot(P2,Disp_v,V_v,'K+');
end

%% Plot the equilibriumpoints in P2 & P3
if eqflag == true
    xline(P2,Disp,'k--');
    xline(P3,Disp,'k--');
    disp(['Equilibrium at :------------------------------------------------',newline,...
        'theta = ',num2str(theta_n),' [rad]', newline, ...
        'Displacement = ',num2str(Disp),' [mm]']);
end


%% Plot the mechanism %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Rtheta = [cos(theta) -sin(theta);       % deflection angle for joint d
         sin(theta) cos(theta)]; 
RaAng = [cos(aAng) -sin(aAng);          % deflection angle for joint a
         sin(aAng) cos(aAng)]; 
Rphi = [cos(phi) -sin(phi);             % deflection angle for beam C
        sin(phi) cos(phi)];
RcAng = [cos(cAng) -sin(cAng);          % deflection angle for joint c
        sin(cAng) cos(cAng)];
RbAng = [cos(bAng) -sin(bAng);          % deflection angle for joint b
        sin(bAng) cos(bAng)];
        
% Centers of rotation
C.CoR = [C.alpha*C.L;
        S.L];
c.CoR = C.CoR + Rphi*[Ctx;
                      Cty];
b.CoR = c.CoR + RcAng*[0;
                       -Bt];    
a.CoR = b.CoR+ RcAng*RbAng*[0;
                      -Dt];  
d.CoR = a.CoR+Rtheta*[0;
                       -At];

%% Plot values in text
Fmax = max(abs(F_v));
y={strcat('$$F$$ = ',num2str(F,3),' N');
    strcat('$$F_{max}$$ = ',num2str(Fmax,3),' N')};
str=sprintf('%s\n',y{:});
txt = text(P1,-S.h,S.L+C.h+0.02,str);

%% Support
XS = [-S.h -S.h 0 0 C.L C.L];
YS = [-S.h S.L+C.h/2 S.L+C.h/2 0 0 -S.h];
S_p = patch(P1,XS,YS,'m');

if strcmp(visualisation,'PRBM')
    prbm = true;
    Design = false;
elseif strcmp(visualisation,'Design')
    prbm = false;
    Design = true;
elseif strcmp(visualisation,'both')
    prbm = true;
    Design = true;
end



%% PRBM model plot
if prbm == true
    cors = [C.CoR,c.CoR,b.CoR,a.CoR,d.CoR];
    Cors = plot(P1,cors(1,:),cors(2,:),'Oc');
    LA = plot(P1,[d.CoR(1) a.CoR(1)],[d.CoR(2) a.CoR(2)],'c');
    LB = plot(P1,[b.CoR(1) c.CoR(1)],[b.CoR(2) c.CoR(2)],'c');
    LD = plot(P1,[a.CoR(1) b.CoR(1)],[a.CoR(2) b.CoR(2)],'c');
    LC = plot(P1,[C.CoR(1) c.CoR(1)],[C.CoR(2) c.CoR(2)],'c');
    LC2 = plot(P1,[0 C.CoR(1)],[S.L C.CoR(2)],'c');
    links = [LA, LB, LC, LD, LC2];
    
    if exist('Plots')
        Plots = [Plots, F_p, V_p, Cors, links, txt];
    else
        Plots = [F_p, V_p, Cors, links, txt];
    end
end

if Design == true
    %% Joints
    % a   
    aBOT = a.CoR + RaAng*Rtheta*[-a.h/2 0 a.h/2; 
                    -a.L/2 0 -a.L/2];
    aTOP = a.CoR + Rtheta*[-a.h/2 0 a.h/2;
                            a.L/2 0 a.L/2];
    a_p = patch(P1,[aBOT(1,:)',aTOP(1,:)'],[aBOT(2,:)',aTOP(2,:)'],'y');

    % b
    bBOT = b.CoR + RcAng*[-b.h/2 0 b.h/2;
                    -b.L/2 0 -b.L/2];
    bTOP = b.CoR + RcAng*RbAng*[0 b.h/2 -b.h/2;   
                    0 b.L/2 b.L/2];
    b_p = patch(P1,[bBOT(1,:)',bTOP(1,:)'],[bBOT(2,:)',bTOP(2,:)'],'y');

    % c
    cTOP = c.CoR + RcAng*[0 -c.h/2 c.h/2;
                               0 c.L/2 c.L/2];
    cBOT = c.CoR + Rphi*[0 c.h/2 -c.h/2;
                         0 -c.L/2 -c.L/2];
    c_p = patch(P1,[cTOP(1,:),cBOT(1,:)]',[cTOP(2,:),cBOT(2,:)]','y');

    % d
    dBOT = d.CoR + Rtheta*[-d.h/2 0 d.h/2;
                           -d.L/2 0 -d.L/2];
    dTOP = d.CoR + [0 d.h/2 -d.h/2;
                          0 d.L/2 d.L/2];
    d_p = patch(P1,[dBOT(1,:)',dTOP(1,:)'],[dBOT(2,:)',dTOP(2,:)'],'y');

    %% Links
    % A
    Apos = a.CoR + Rtheta*[A.s+A.h/2;
                            -A.L/2+a.L/2+A.t];
    APOS = Apos + Rtheta*([-A.h/2 -A.s-A.h/2 -A.s-A.h/2 -A.h/2 A.h/2 0 A.h/2 A.h/2 A.w+A.h/2 A.w+A.h/2 -A.h/2 -A.s-A.h/2 -A.s-A.h/2 -A.h/2;
                           -A.L/2+A.t -A.L/2+A.t -A.L/2 -A.L/2 -A.L/2 0 -A.L/4 A.L/4 A.L/4 A.L/2 A.L/2 A.L/2 A.L/2-A.t A.L/2-A.t] + ... 
                          [0 0 0 0 0 A.h/2+A.v*sin(A.delta) 0 0 0 0 0 0 0 0;
                         0 0 0 0 0 -A.L/2-A.v*cos(A.delta) 0 0 0 0 0 0 0 0]);    
    A_p = patch(P1,APOS(1,:),APOS(2,:),'r');
    F = quiver(P1,APOS(1,6),APOS(2,6),0,F/150,'b');

    % B
    Bpos = c.CoR + RcAng*[B.s+B.h/2;
                            -B.L/2+c.L/2+B.t];
    BPOS = Bpos + RcAng*[-B.h/2 -B.h/2-B.s -B.h/2-B.s -B.h/2 B.h/2 B.h/2 -B.h/2 -B.h/2-B.s -B.h/2-B.s -B.h/2;
                          -B.L/2+B.t -B.L/2+B.t -B.L/2 -B.L/2 -B.L/2 B.L/2 B.L/2 B.L/2 B.L/2-B.t B.L/2-B.t];
    B_p = patch(P1,BPOS(1,:),BPOS(2,:),'r');

    % C
    CLEFT = C.CoR + [-C.alpha*C.L 0 0 -C.alpha*C.L;
                    -C.h/2 0 0 C.h/2] + Rphi*[0 0 0 0;
                                        0 -C.h/2 C.h/2 0];
    CLEFT = circshift(CLEFT,1,2);                                
    CRIGHT = C.CoR + Rphi*[0 (1-C.alpha)*C.L (1-C.alpha)*C.L 0;
                            -C.h/2 -C.h/2 C.h/2 C.h/2];
    C_p = patch(P1,[CLEFT(1,:) CRIGHT(1,:)]',[CLEFT(2,:) CRIGHT(2,:)]','g');

    % D
    Dpos = b.CoR + RcAng*RbAng*[-D.s-D.h/2;
                            -D.L/2+b.L/2+D.t];
    
    DPOS = Dpos + RcAng*RbAng*[-D.h/2 D.h/2 D.h/2+D.s D.h/2+D.s D.h/2  D.h/2 D.h/2+D.s D.h/2+D.s -D.h/2;
                               -D.L/2 -D.L/2 -D.L/2 -D.L/2+D.t -D.L/2+D.t D.L/2-D.t D.L/2-D.t D.L/2 D.L/2];
    D_p = patch(P1,DPOS(1,:),DPOS(2,:),'r');
    if exist('Plots')
        Plots = [ Plots, a_p, b_p, c_p, d_p, A_p, B_p, C_p, D_p, F, F_p, V_p, txt]; 
    else 
        Plots = [a_p, b_p, c_p, d_p, A_p, B_p, C_p, D_p, F, F_p, V_p, txt];
    end
end

    

end
