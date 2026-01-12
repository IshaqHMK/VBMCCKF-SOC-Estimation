% Extracting Data (File: 1-A pulse)
% % Part 1 - Charge
global Data_SOC Data_OCV Current Voltage Resistance k_steps Cn N Time TDiff SOC_TL OCV_TL
global Resistor1 Resistor0 Capacitor1
global M0 M Gamma

load('1_Data_SOC_Charging');
SOC_charging = Data_SOC; % For Estimating
load('1_Data_OCV_Charging');
OCV_charging = Data_OCV; % For Estimating

k_charging = size(SOC_charging,1);

load('1_Data_Current_Charging');
current_charging = Current;
load('1_Data_Voltage_Charging');
voltage_charging = Voltage;
% load('1_Data_Resistance_Charging'); % from file
% Resistance;
load('1_Data_resistance_CHComp.mat')
resistance_charging = Resistance;

load('1_Data_Time_Charging');
time_charging = TimeSeconds(1:size(SOC_charging));
TDiff = time_charging(2)-time_charging(1);

% Discharging
load('2_discharge_SOC_Data.mat')
SOC_discharging = discharge_SOC;
load('2_discharge_OCV_Data.mat')
OCV_discharging = discharge_OCV; % For Estimating
load('2_discharge_current_Data.mat')
current_discharging = discharge_current;
load('2_discharge_voltage_Data.mat')
voltage_discharging = discharge_voltage;
load('2_discharge_resistance_Data.mat')
resistance_discharging = DischargeResistance;

k_discharging = size(Data_SOC,1);
% k_steps = k_charging + k_discharging;

% Table-Lookup
load('1_SOC_OCV_LTable.mat')% From Discharge Data
SOC_TL = SOC_OCV_LTable(:,1);
OCV_TL = SOC_OCV_LTable(:,3);

Cn = 3.544343e+03;  % trapz(Current)*TDiff
N = 1;

% Combine Disch and Ch
Data_SOC = [SOC_charging; SOC_discharging];
Data_OCV = [OCV_charging; OCV_discharging];
Current = [current_charging; current_discharging];
Voltage = [voltage_charging; voltage_discharging];
Resistance = [resistance_charging; resistance_discharging];
k_steps = size(Data_SOC,1);
Time = 1:k_steps;
%
% Data_SOC = [SOC_charging;];
% Data_OCV = [OCV_charging; ];
% Current = [current_charging; ];
% Voltage = [voltage_charging; ];
% Resistance = [resistance_charging; ];
% k_steps = size(Data_SOC,1);
% Time = 1:k_steps;
% %
% Data_SOC = [ SOC_discharging];
% Data_OCV = [ OCV_discharging];
% Current = [ current_discharging];
% Voltage = [ voltage_discharging];
% Resistance = [ resistance_discharging];
% k_steps = size(Data_SOC,1);
% Time = 1:k_steps;


% plot(Time, Voltage )

%%
% Discharging Parameters
% vInf = 0.02;
% vO = 0.044;
% dI = 1;
% Resistor1 = abs((vInf - vO)/dI) ;
% Resistor0 = vO/dI;
% Capacitor1 = (15*TDiff)/(15*Resistor1);


% Charging Parameters
V0 = 3.22;
V1 = 3.259;
dI = 1;
Resistor0 = abs((V0-V1)/dI);
V2 = 3.328;
Vinf = V2 - V1;
Resistor1 = Vinf/dI - Resistor0;
Capacitor1 = (TDiff*23)/(4*Resistor1);



[ M0,  M,  Gamma, Resistor0, Resistor1, Capacitor1] = deal(0.000346000000000000,0.0271200000000000,0.996757916808119,0.0612536540009704,0.0487273876963194,5446.09596101164); %  0.930094%
Current = -Current; % ESC Model