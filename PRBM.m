%{
This script is written by:

Daniel Blommenstein
Pim de Bruin
Kiet Foeken
Jailing Zou

And functions as the main analysis tool for the analysis of a compliant
spider capodastro design for the course Compliant mechanisms ME46115
(2020/2021) at the Delft University of Technology. 

This file relies on the functions:
    kinModel
    makeTXT
    showme
Which can be found in the ./functions folder. 
    
%}

clear all
close all
set(groot, 'defaultTextInterpreter','latex');
clear showme                                                % Clear consistent variables!
addpath('./functions');                                     % add function folder to search path

%% settings
% Which plots do you want?
simulation = true;                  % plot the simulation? (true/false)
equilibria = false;                 % plot the equilibrium points? (true/false)
file = false;                       % make file the equations.txt file? (true/false)
visualisation = 'both';             % what to plot? ('PRBM' or 'Design' or 'both')
debug = false;                      % debug mode? Allow for debug functions (true/false)

% Simulation
A.theta_min = deg2rad(-24);         % minimum angle theta [rad]
A.theta_max = deg2rad(24);          % maximum angle theta [rad]
N = 100;                            % number of simulation steps []
   
%% Parameters
% Material
Epla = 2.5E9;  % pa
Epmma = 3E9;
Essteel = 200E9;
g = 5e-3;   % sheet thickness [m]

% Joints
    % a
    a.name = 'a';                   % its name
    a.E = Essteel;                  % E modulus
    a.h = 0.1e-3;                   % height [m]
    a.d = g;                        % depth [m]
    a.L = 8e-3;                     % length [m]
    
    % b
    b.name = 'b';
    b.E = Essteel;
    b.h = 0.4e-3;
    b.d = g;
    b.L = 8e-3;
    
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
    A.name = 'A';                   % its name
    A.L = 70e-3; % m                % length [m]
    A.h = 7e-3;                     % height [m]
    A.d = g;                        % depth [m]
    A.zeta = pi/9;                  % 
    A.delta = pi/4;                 % angle string finger [rad]
    A.w = 0;                        % length switch [m]
    A.v = 1e-2*1.3;                 % length string finger [m]
    A.s = 2*A.h;                    % length overhang [m]
    A.t = A.h;                      % thickness overhang [m]
    
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
    C.wmax = 3e-3;                  % maximum deflection
    C.alpha = 1/4;                  % location of torsion spring []
    
% Support
    S.name = 'S';
    S.h = 15e-3;
    S.L = -a.L-b.L-c.L-d.L+A.L+B.L+D.L-2*D.t-2*B.t-2*A.t-C.h/2-S.h-C.wmax;
    
%% Stiffnesses
% Surface moment of inertia
a.I = a.d*a.h^3/12;
b.I = b.d*b.h^3/12;
c.I = c.d*c.h^3/12;
d.I = d.d*d.h^3/12;
C.I = C.d*C.h^3/12;

% PRBM estimated parameters
gamma = 0.85165;
ktheta = 2.65;

% Stifnesses
a.k = gamma*ktheta*a.E*a.I/a.L; 
b.k = gamma*ktheta*b.E*b.I/b.L;
c.k = gamma*ktheta*c.E*c.I/c.L;
d.k = gamma*ktheta*d.E*d.I/d.L;
C.k = gamma*ktheta*C.E*C.I/C.L; 

% Generate equations.txt file from objects to be able to import the
% paremeters into SOLIDWORKS!
Objects = {A,B,C,D,a,b,c,d,S};              % pack up objects 
if file == true
    makeTXT(Objects);                       % Put them in equations.txt
end

% If you would like to test:
if debug == true                            % Only in debug mode!
    Plots = showme(0,0,0,0,Objects,false,visualisation,'Test');
    return
    disp('Press any key to continue');
    pause;
    disp('Continuing...')
    clear showme
end

% Get kinematic model equations as a function of theta and chi
[theta,chi,phi,cAng,bAng,aAng,w,~,~,~,~,~,~] = kinModel(Objects);


% The potential energy!
syms F
V_deformation = 1/2*(a.k*aAng^2+b.k*bAng^2+c.k*cAng^2+d.k*theta^2+C.k*phi^2);   % Deformation potential energy
Q_force = - F*((A.v)*sin(A.delta)+A.h+A.s)*sin(theta);                          % Generalised force

q = [theta,chi];                            % Generalised coordinates
dVdq = jacobian(V_deformation+Q_force,q);   % Jacobian J w.r.t. these coordinates
F_Lagrange = solve(dVdq(1)==0,F);           % solve J == 0 for string force. 


%% Main Loop for analysis
eqs = [];                                   % space for the equilibria
name = 'Analysis simulation';               % Figure name

% make waitbar (Only if simulation is not plotted)
if simulation == false
    f = waitbar(0,'Simulating');
end  

% Optimisation settings
x0 = 0;                                             % Initial guess for chi
options = optimoptions('fminunc','Display','off');  % Turn off displayed information

% Main loop
for theta = linspace(A.theta_min, A.theta_max, N)
    
    % Preliminaries
    eqflag= false;
    
    % For current angle theta, find chi for minimum of potential energy. 
    Vfunction = matlabFunction(subs(V_deformation));
    [chi_n,V,exitflag] = fminunc(Vfunction,x0,options); % minimise numerically
    
    if exitflag<=0                                      % Check if correctly optimised
        chi_n = 0;
        warning('Optimisation might have failed! (go have a look)')
    end
        
    F = eval(subs(F_Lagrange,'chi','chi_n'));           % substitude in equation for F
    
    if theta ~= A.theta_min                             % from second iteration
        x0 = chi_n;                                     % optimisation starting point as last chi 
       if simulation == true
           delete(Plots);                               % Delete last plot
       end
              
       % look for equilibria (and save the values at these equilibria)
        if sign(F)~=sign(F_1)                           % If F changes sign!
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
        Plots = showme(theta,chi_n,F,V,Objects,eqflag,visualisation,name);      % Plot the current configuration
    else
        range = abs(A.theta_min)+abs(A.theta_max);                              % Otherwise update waitbar
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


%% Plot equilibria
if equilibria == true
    if isempty(eqs)
        error("Simulation also needs to be run! (put simulation to 'true')")
    end
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



