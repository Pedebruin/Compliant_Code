T1 = xlsread('test1.xlsx');
T2 = xlsread('test2.xlsx');
T3 = xlsread('test3.xlsx');
T4 = xlsread('test4.xlsx');

%%  Reading the columns from the data sheets in Excel
x1=T1(:,3);
y1=T1(:,4);
x2=T2(:,3);
y2=T2(:,4);
x3=T3(:,4);
y3=T3(:,3);
x4=T4(:,3);
y4=T4(:,4);
%%
hold on
plot(x1,y1)
plot(x2,y2)
plot(x3,y3)
plot(x4,y4)
title('Force displacement behaviour')
xlabel('Displacement [mm]')
ylabel('Force [N]')
legend('test1','test2','test3','test4')