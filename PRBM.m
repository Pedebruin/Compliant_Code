clear all
close all
set(groot, 'defaultTextInterpreter','latex');
clear showme                                                % Clear consistent variables!
addpath('./functions');                                     % add function folder to search path


%% settings
% Which plots do you want?
simulation = true;                 % The simulation plot
equilibria = true;                 % The equilibria plots
% make file the equations.txt file??
file = true;
% show design or PRBM model??
visualisation = 'Design';         %'PRBM' or 'Design' or 'both'
% Debug mode
debug = false;
% Simulation
A.theta_min = deg2rad(-24);
A.theta_max = deg2rad(24);
N = 100;
   
%% Parameters
% Material
Epla = 2.5E9;  % pa
Epmma = 3E9;
Essteel = 200E9;
g = 3e-3;   % m


% Joints
    % a
    a.name = 'a';
    a.E = Essteel;            % E modulus
    a.h = 0.2e-3;             % height [m]
    a.d = g;                % depth [m]
    a.L = 8e-3;          % length [m]
    
    % b
    b.name = 'b';
    b.E = Essteel;
    b.h = 0.4e-3;
    b.d = g;
    b.L = 7e-3;
    
    % c
    c.name = 'c';
    c.E = Essteel;
    c.h = 0.1e-3;
    c.d = g;
    c.L = 10e-3;
    
    % d
    d.name = 'd';
    d.E = Essteel;
    d.h = 0.1e-3;
    d.d = g;
    d.L = 10e-3;
    
% Links
    % A
    A.name = 'A';
    A.L = 70e-3; % m 
    A.h = 7e-3;  
    A.d = g;
    A.zeta = pi/9;
    A.delta = pi/4;     % Angle string finger
    A.w = 2e-2;         % Length switch
    A.v = A.w*6/4;      % Length string finger
    A.s = 2*A.h;
    A.t = A.h;
    
    % B
    B.name = 'B';
    B.L = 65e-3; % m
    B.h = 8e-3;
    B.s = 2*B.h;
    B.t = B.h;
   
    % D
    D.name = 'D';
    D.L = 60e-3; % m
    D.h = 8e-3;
    D.s = 1.5*D.h;
    D.t = D.h;
   
% Beam
    C.name = 'C';
    C.E = Epmma;
    C.h = 6.5e-3;
    C.d = g;
    C.L = 50e-3;
    C.wmax = 5e-3;        % maximum deflection
    C.alpha = 1/4;
    
% Support
    S.name = 'S';
    S.h = 15e-3;
    S.L = -a.L-b.L-c.L-d.L+A.L+B.L+D.L-2*D.t-2*B.t-2*A.t-C.h/2-S.h-C.wmax;  % S.L at theta=0 -C.wmax
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

% Generate equations.txt file from objects.
Objects = {A,B,C,D,a,b,c,d,S};              % Pack all objects in cell array for convenience. 
if file == true
    makeTXT(Objects);                       % Put them in equations.txt
end

% If you would like to test:
if debug == true
    Plots = showme(0,0,0,0,Objects,false,visualisation,'Test');
    return
    disp('Press any key to continue');
    pause;
    disp('Continuing...')
    clear showme
end

% Get kinematic model equations as a function of theta and chi
[theta,chi,phi,cAng,bAng,aAng,w,~,~,~,~,~,~] = kinModel(Objects);

syms F
% The potential energy!
V_deformation = 1/2*(a.k*aAng^2+b.k*bAng^2+c.k*cAng^2+d.k*theta^2+C.k*phi^2);
Q_force = - F*(A.v)*sin(A.delta)*sin(theta);  % Potential energy as a function of theta (approx)

q = [theta,chi];
dVdq = jacobian(V_deformation+Q_force,q);
F_Lagrange = solve(dVdq(1)==0,F);

% X = linspace(A.theta_min, A.theta_max, 50);             % theta range
% Y = linspace(A.theta_min, A.theta_max, 50);                           % chi range
% Force = linspace(-5,5,50);
% Z = zeros(length(X),length(Y));
% 
%         
% for i = 1:length(Force)
%     for j = 1:length(Y)
%         theta = 0.1;
%         chi = Y(j);
%         F = Force(i);
%         Z(j,i) = real(subs(V_deformation));
%     end
% end
% 
% x0 = [0,0];
% theta = 0.1;
% 
% fun = matlabFunction(V_deformation);
% chimin = fminunc(@(x)Vfunction(x,V_deformation,theta),x0);
% surface(Force,rad2deg(Y),Z);
% xlabel('F')
% ylabel('chi')
% zlabel('Potential Energy');
% grid on


%% Main Loop for analysis
eqs = [];
name = 'Analysis simulation';

% make waitbar 
if simulation == false
    f = waitbar(0,'Simulating');
end  

% Optimisation settings
x0 = 0; % theta, F
options = optimoptions('fminunc','Display','off');

% Main loop
for theta = linspace(A.theta_min, A.theta_max, N)
    % For current angle theta, find chi for minimum of potential energy. 
    Vfunction = matlabFunction(subs(V_deformation));
    [chi_n,V,exitflag] = fminunc(Vfunction,x0,options);
    
    if exitflag<=0
        chi_n = 0;
        warning('Optimisation might have failed! (go have a look)')
    end
        
    F = eval(subs(F_Lagrange,'chi','chi_n'));
    eqflag= false;

    if theta ~= A.theta_min
       if simulation == true
           delete(Plots);                           % Delete last plot
       end
              
       % look for equilibria (and save the values at these equilibria)
        if sign(F)~=sign(F_1)                       % If dV changes sign!
            eqflag = true;
            theta_eq = theta;
            chi_eq = chi_n;

            if isempty(eqs)
                eqs = [theta_eq, chi_eq, F, V];
            else
                eqs = [eqs; theta_eq, chi_eq, F, V];
            end
        end
    end
    
    if simulation == true
        Plots = showme(theta,chi_n,F,V,Objects,eqflag,visualisation,name);
    else
        range = abs(A.theta_min)+abs(A.theta_max);
        progress = (theta+abs(A.theta_min))/range;
        waitbar(progress,f,sprintf('Simulating: theta = %4.4f [rad]',theta));
    end
    
    F_1 = F;                                            % save last value of F
    pause(0.000001);
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
        chi = eqs(i,2);
        F = eqs(i,3);
        V = eqs(i,4);
        name = ['Equilibrium ',num2str(i)];
        Plots = showme(theta,chi,F,V,Objects,eqflag,visualisation,name);
    end
end

%{
%% Single point plotting for a specific force. 
F = 1;                                                      % Force i would like to see
N = 20;                                                     % Number of seeds between min and max

errFunc = matlabFunction(F_lagrange_theta-F);
zeros = [];
for thetaInit = linspace(A.theta_min, A.theta_max, N)
    theta = round(fzero(errFunc,thetaInit),4);
    
    if sum(ismember(zeros, theta))==0
        zeros = [zeros,theta];
    end 
end
%}


