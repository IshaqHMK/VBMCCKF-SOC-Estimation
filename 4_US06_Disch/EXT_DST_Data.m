% clc; clear all; close all;

global Data_SOC Data_OCV Current Voltage Resistance k_steps Cn N Time TDiff SOC_TL OCV_TL
global Resistor1 Resistor0 Capacitor1
global M0 M Gamma

load('5_DST_MainFiles.mat')

Time_discharging = DSTdata(1:10504, 1);
TDiff = Time_discharging(2)-Time_discharging(1);
voltage_discharging = DSTdata(1:10504, 3);
current_discharging = DSTdata(1:10504, 2);
SOC_discharging = DSTdata(1:10504, 4);
OCV_discharging = DSTdata(1:10504, 5);

 plot(Time, Voltage )

%% Lookup Table 
load('5_DST_LTable.mat')
SOC_TL = DSTdataS1(:, 12);
OCV_TL =  DSTdataS1(:, 11);

load('5_DST_Resistance_dischargingP2.mat')
resistance_discharging;

Data_SOC = [ SOC_discharging];
Data_OCV = [ OCV_discharging];
Current = [ current_discharging];
Voltage = [ voltage_discharging];
Resistance = [ resistance_discharging];

k_steps = size(Data_SOC,1); 
Cn =  abs(trapz(current_discharging)*TDiff); 
N = 1;
Time = 1:k_steps;
% plot(Time, Voltage )
% plot(Time, Data_SOC )
%  plot(Time, Voltage )
 
%  plot(Time, Current);

% Charging Parameters 
V0 = 13.5072;
V1 = 13.3531;
dI = 12.4938;
Resistor0 = abs((V0-V1)/dI);
V2 = 13.6013;
Vinf = V2 - V1;
Resistor1 = Vinf/dI - Resistor0;

Capacitor1 = (TDiff*24)/(4*Resistor1);

Current  = - Current;

% ESC_Model;
[ M0,  M,  Gamma, Resistor0, Resistor1, Capacitor1] = deal(0.000865,0.00846, 235,0.0066,0.00205,1.52e+05);
