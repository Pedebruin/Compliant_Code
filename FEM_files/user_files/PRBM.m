clear all
close all
set(groot, 'defaultTextInterpreter','latex');
clear V_v theta_v F_v                                    % Clear consistent variables!
addpath('./functions');                                     % add function folder to search path


%% settings
% Which plots do you want?
simulation = true;              % The simulation plot
equilibria = false;             % The equilibria plots

% make file??
file = false;


%% Parameters
% Material
Epla = 2.5E9;  % pa
Epmma = 3E9;
Essteel = 200E9;
g = 3e-3;   % m

% Joints
    % a
    a.name = 'a';
    a.E = Epmma;         % E modulus
    a.h = 1e-3;        % height [m]
    a.d = g;             % depth [m]
    a.L = 7.5e-3;          % length [m]
    
    % b
    b.name = 'b';
    b.E = Epmma;
    b.h = 0.15e-3;
    b.d = g;
    b.L = 7.5e-3;
    
    % c
    c.name = 'c';
    c.E = Epmma;
    c.h = 0.15e-3;
    c.d = g;
    c.L = 7.5e-3;
    
    % d
    e.name = 'd';
    d.E = Epmma;
    d.h = 2e-3;
    d.d = g;
    d.L = 7.5e-3;
    
% Links
    % A
    A.name = 'A';
    A.L = 6e-2; % m 
    A.h = 0.75e-2;  
    A.d = g;
    A.zeta = pi/9;
    A.delta = pi/4;     % Angle string finger
    A.w = 2e-2;         % Length switch
    A.v = A.w*6/4;          % Length string finger
    A.s = A.h;
    A.t = A.h/3;
    
    % B
    B.name = 'B';
    B.L = 6e-2; % m
    B.h = 0.75e-2;
    B.s = B.h;
    B.t = B.h/3;
   
    % D
    D.name = 'D';
    D.L = 6e-2; % m
    D.h = 0.75e-2;
    D.s = D.h;
    D.t = D.h/3;
   
% Beam
    C.name = 'C';
    C.E = Epmma;
    C.h = 0.4e-3;
    C.d = g;
    C.L = (D.L-b.L-a.L-2*D.t)*4/3;
    C.wmax = 8e-3;        % maximum deflection
    C.alpha = 1/4;
    
% Support
    S.name = 'S';
    S.h = 10e-3;
    S.L = -a.L-b.L-c.L-d.L-a.L-b.L+A.L+B.L+D.L-S.h-2*D.t-2*B.t-2*A.t-C.h/2+C.wmax;
    S.Li = -a.L-b.L-c.L-d.L+A.L+B.L-S.h-2*B.t-2*A.t-C.h/2+C.wmax;


% Simulation
A.theta_max = pi/12;
A.theta_min = -pi/6;
   
%% Stiffnesses
a.I = a.d*a.h^3/12;
b.I = b.d*b.h^3/12;
c.I = c.d*c.h^3/12;
d.I = d.d*d.h^3/12;
C.I = C.d*C.h^3/12;

gamma = 0.85165;
ktheta = 2.65;

a.k = gamma*ktheta*a.E*a.I/a.L; 
b.k = gamma*ktheta*b.E*b.I/b.L;
c.k = gamma*ktheta*c.E*c.I/c.L;
d.k = gamma*ktheta*d.E*d.I/d.L;
C.k = gamma*ktheta*C.E*C.I/C.L; 

%% Critical buckling forces (from hibbler)
K = 2;
a.Fcr = pi^2*a.E*a.I/(K*a.L)^2;
b.Fcr = pi^2*b.E*b.I/(K*b.L)^2;
c.Fcr = pi^2*c.E*c.I/(K*c.L)^2;
d.Fcr = pi^2*d.E*d.I/(K*d.L)^2;

% Generate equations.txt file from objects.
Objects = {A,B,C,D,a,b,c,d,S};              % Pack all objects in cell array for convenience. 
if file == true
    makeTXT(Objects);                       % Put them in equations.txt
end
% Get kinematic model equations. 
[theta,beta,alpha,w,phi] = kinModel(Objects);

% Calculate variances
dbeta = diff(beta,theta);
dphi = diff(phi,theta);
dalpha =  diff(alpha,theta);
dtheta = theta;

syms F
% The potential energy!
V_deformation = 1/2*(a.k*(phi+theta)^2+b.k*(phi+beta)^2+c.k*(phi+beta)^2+d.k*theta^2+C.k*phi^2);
V_force = - F*(A.L+A.s)*sin(theta);  % Potential energy as a function of theta

% Lagrangian
L = diff(V_deformation+V_force,theta);                                      % Lagrangian
F_lagrange = solve(L==0,F);                                                 % Lagrangian == 0 

% Purely the variance of the deformation potential energy
dVdtheta = diff(V_deformation);                                             % To find equilibrium points



%% Main Loop for analysis
eqs = [];
name = 'Analysis simulation';
N = 100;

% make waitbar 
if simulation == false
    f = waitbar(0,'Simulating');
end  

% Main loop
for theta = linspace(A.theta_min, A.theta_max, N)
    F = eval(subs(F_lagrange));                 % Calculate Force for equilibrium
    V = eval(subs(V_deformation));              % Calculate potential energy


    if theta ~= A.theta_min
       if simulation == true
           delete(Plots);                           % Delete last plot
       end
       % look for equilibria (and save the values at these equilibria)
        if sign(F)~=sign(F_1)
            theta_eq = eval(subs(theta));
            beta_eq = eval(subs(beta));
            phi_eq = eval(subs(phi));

            if isempty(eqs)
                eqs = [theta_eq, beta_eq, phi_eq, F, V];
            else
                eqs = [eqs; theta_eq, beta_eq, phi_eq, F, V];
            end
        end
    end


    % check for buckling
    phi_k = eval(subs(phi));
    Fb = abs(phi_k*C.k/((1-C.alpha)*C.L));

    if Fb >= a.Fcr || Fb >= b.Fcr || Fb >= c.Fcr % If buckling is possible
        disp('BUCKLINGGGGG');
    end
    
    if simulation == true
        Plots = showme(theta,F,V,Fb,Objects,name);          % SHOW ME
    else
        range = abs(A.theta_min)+abs(A.theta_max);
        progress = (theta+abs(A.theta_min))/range;
        waitbar(progress,f,sprintf('simulating: theta = %4.4f [rad]',theta));
    end
    
    
    F_1 = F;                                            % save last value of F
    pause(0.001);
end
if simulation == false
    close(f);
end
clear showme                                            % Clear consistent variables!
if equilibria == true
    if isempty(eqs)
        error("Simulation also needs to be run! (put simulation to 'true')")
    end
    %% Plot equilibria
    for i = 1:size(eqs,1)
        clear showme                                        % Clear consistent variables!
        theta = eqs(i,1);
        F = eqs(i,4);
        V = eqs(i,5);
        name = ['Equilibrium ',num2str(i)];
        Plots = showme(theta,F,V,Fb,Objects,name);
    end
end

%% Single point plotting for a specific force. 
F = 1;                                                      % Force i would like to see
N = 20;                                                     % Number of seeds between min and max

errFunc = matlabFunction(F_lagrange-F);
zeros = [];
for thetaInit = linspace(A.theta_min, A.theta_max, N)
    theta = round(fzero(errFunc,thetaInit),4);
    
    if sum(ismember(zeros, theta))==0
        zeros = [zeros,theta];
    end 
end




