load('6_LA92.mat')

global Data_SOC Data_OCV Current Voltage k_steps Cn N Time TDiff   OCV dOCV
global Resistor1 Resistor0 Capacitor1
global M0 M Gamma

k_steps = 131000;
TDiff = mean(diff(meas.Time));
Time  = meas.Time(1:k_steps)/60;
Current = meas.Current(1:k_steps);
Current = -Current;
Voltage = meas.Voltage(1:k_steps);
Data_SOC = (meas.Ah(1:k_steps))/max(abs(meas.Ah))+1;
Cn = max(abs(meas.Ah))*3600;
N = 1;
p = [ -6611.9895, 36163.86, -84850.309, 111637.95, -90357.197, 46432.971, -15097.185, 3005.5943, -343.42631, 21.054408, 2.8267426];
pd=polyder(p);

OCV = polyval(p,Data_SOC);
Data_OCV = OCV;
dOCV = polyval(pd,Data_SOC);
% Capacitor1=25000;
% Gamma=0.5;
% M=0.0005;
% M0=0.01;

% Resistor1=0.03; %para(set,3);
Rd=0.03;   %para(set,4);
% Resistor0=0.005; %para(set,1);

[ M0,  M,  Gamma, Resistor0, Resistor1, Capacitor1] = deal(0.000254239512146078,0.00443416994185655,149.500764762029,0.0349115765054921,0.00804322425989483,380000);


