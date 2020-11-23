clear all
close all

T_min = 60; %N
T_max = 80; %N
fret_h = 1.1938e-3; %m
fret_dist = 30e-3; %m
string_h = 2.6e-3; %m
scale_l = 647.7e-3; %m


h_ = linspace(0,1,4);        % 0-1 percentage of height of the fret
x_ = linspace(0,1,20);        % 0-1 percentage distance between the fret (from body)
t = 0.5;        % 0-1 percentage between T_min and T_max

Fs = zeros(20,4);
X = zeros(20,1);

for i = 1:4
    h = h_(i);
    for j = 1:20
        x = x_(j);
        T = (1-t)*T_min + t*T_max;                          % string tension

        phi = atan((x*fret_dist)/(h*fret_h));               % angle towards the body
        theta = atan(((1-x)*fret_dist)/(h*fret_h));     % angle towards the head

        F0 = 2*T*cos(atan((scale_l/2)/(string_h - fret_h))); % tension to press string down to the fret

        F = T*(cos(phi)+cos(theta)) + F0; % tension to press string all the way down below the fret
        Fs(j,i) = F;

        X(j) = x*fret_dist;
    end
 
end

figure(1)
hold on 
plot(X,Fs(:,1),'ok');
plot(X,Fs(:,2),'ob');
plot(X,Fs(:,3),'og');
plot(X,Fs(:,4),'or');
legend(strcat('h = ',num2str(h_(1))),strcat('h = ',num2str(h_(2))),strcat('h = ',num2str(h_(3))),strcat('h = ',num2str(h_(4))))
xlabel 'Position between fret [m]'
ylabel 'Tension to press string down [N]'
title(strcat('Push force for positions and heights for T = ',num2str(T)),' [N]');