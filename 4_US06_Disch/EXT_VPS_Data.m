% clc; clear all; close all;
global Q R
global Data_SOC Data_OCV Current Voltage Resistance k_steps Cn N Time TDiff SOC_TL OCV_TL
global Resistor1 Resistor0 Capacitor1
global M M0 Gamma


load('4_VPS_Charging.mat')
Time = VariablePulsedata(:,1);
TDiff = Time(2)-Time(1);
voltage_charging = VariablePulsedata(:,2);
current_charging = VariablePulsedata(:,3);
SOC_charging = VariablePulsedata(:,4); % For Estimating

k_charging = size(SOC_charging); 

load('4_VPS_Discharging.mat')
Time_discharging = VariablePulsedataS1(:,1);
voltage_discharging = VariablePulsedataS1(:,2);
current_discharging = VariablePulsedataS1(:,3);
SOC_discharging = VariablePulsedataS1(:,4); % For Estimating

%% Lookup Table 
load('4_VPS_SOC_OCV_LTable.mat')
SOC_TL = table2array(VariablePulsedataS2(:,1));
OCV_TL =  table2array(VariablePulsedataS2(:,3));

%% MISSING OCV and Resistance % Charging
% But from lookuptable
% for i = 1:size(SOC_charging)
%     D_OCV(i) =  interp1(SOC_TL,OCV_TL, SOC_charging(i) ,'spline');
% end
% OCV_charging = D_OCV';
% 
% resistance_charging = abs((voltage_charging - OCV_charging)./current_charging);
% for i = 1:size(SOC_charging,1)
%    if isinf(resistance_charging(i))
%       resistance_charging(i) = resistance_charging(i-1);
%    end
% end
load('4_VPS_OCV_Charging.mat')
OCV_charging;
load('4_VPS_Resistance_Charging.mat')
resistance_charging;

%% MISSING OCV and Resistance % Charging
% But from lookuptable
% for i = 1:size(SOC_discharging)
%     D_OCV(i) =  interp1(SOC_TL,OCV_TL, SOC_discharging(i) ,'spline');
% end
% OCV_discharging = D_OCV';
% 
% resistance_discharging = abs((voltage_discharging - OCV_discharging)./current_discharging);
% for i = 1:size(SOC_discharging)
%    if isinf(resistance_discharging(i))
%       resistance_discharging(i) = resistance_discharging(i-1);
%    end
% end
load('4_VPS_OCV_Discharging.mat')
OCV_discharging;
load('4_VPS_Resistance_Discharging.mat')
resistance_discharging;
% resistance_discharging(end) = 0.6125;

k_discharging = size(SOC_discharging); 
k_steps = k_charging + k_discharging;


% Combine Disch and Ch
% Data_SOC = [SOC_charging; SOC_discharging];
% Data_OCV = [OCV_charging; OCV_discharging];
% Current =  [current_charging; current_discharging];
% Voltage =  [voltage_charging; voltage_discharging];
% Resistance = [resistance_charging; resistance_discharging];

Data_SOC = [SOC_charging;];
Data_OCV = [OCV_charging; ];
Current = [current_charging; ];
Voltage = [voltage_charging; ];
Resistance = [resistance_charging; ];


Data_SOC = [ SOC_discharging(1:717)];
Data_OCV = [ OCV_discharging(1:717)];
Current =  [ current_discharging(1:717)];
Voltage =  [ voltage_discharging(1:717)];
Resistance = [ resistance_discharging(1:717)];


k_steps = size(Data_SOC,1); 
Cn =   3.3715e+03; %trapz(current_charging)*TDiff; 
N = 1;
Time = 1:k_steps;


% plot(Time, Voltage )



% Charging Parameters 
V0 = 3.236;
V1 = 3.239;
dI = 1;
Resistor0 = abs((V0-V1)/dI);
V2 = 3.338;
Vinf = V2 - V1;
Resistor1 = Vinf/dI - Resistor0;
Capacitor1 = (TDiff*57)/(4*Resistor1);


% All
%  [ M0,  M,  Gamma, Resistor0, Resistor1, Capacitor1] = deal(0.0005546051,0.04035242,10.56234,0.007213209,0.09248129,222.896); % better
 Current = -Current; % ESC Model
 % Disch
%  [ M0,  M,  Gamma, Resistor0, Resistor1, Capacitor1] = deal(0.000642472702435698,0.0462013784339917,10.9299737515882,0.00749474851466379,0.0835936698021241,208.654839141358)
 % ext
[ M0,  M,  Gamma, Resistor0, Resistor1, Capacitor1] = deal(0.000346000000000000,0.0271200000000000,0.996757916808119,0.0612536540009704,0.0487273876963194,5446.09596101164); %  0.930094%
