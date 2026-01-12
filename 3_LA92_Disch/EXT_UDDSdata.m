% DATA faulty
global Q R
global Data_SOC Data_OCV Current Voltage Resistance k_steps Cn N Time TDiff SOC_TL OCV_TL
load('3_UDDSdata_Discharge.mat')
% Discharge Data
% Page 1:
Time = UDDSdata(:,1);
current_discharging = UDDSdata(:,2);
voltage_discharging = UDDSdata(:,3);
SOC_discharging = UDDSdata(:,4);

% Page 2: lookupTable

load('3_UDDSdata_LTable.mat')
SOC_TL = UDDSdataS1(:,1);
OCV_TL = UDDSdataS1(:,1);

Data_SOC = [SOC_discharging];
Current = [current_discharging];
Voltage = [voltage_discharging];
% Resistance = [resistance_charging; resistance_discharging];
k_steps = size(Data_SOC,1);


%% MISSING OCV and Resistance
% But from lookuptable
for i = 1:size(SOC_discharging,1)
   D_OCV(i) =  interp1(SOC_TL,OCV_TL, SOC_discharging(i) ,'spline');
end
Data_OCV = D_OCV';


return
resistance_discharging = abs((voltage_discharging - Data_OCV)./current_discharging);
for i = 1:size(SOC_discharging,1)
   if isinf(resistance_discharging(i))
      resistance_discharging(i) = resistance_discharging(i-1);
   end
end

Resistance = resistance_discharging;
Cn = 2.5350e+03;  % trapz(Current)*(Time(1)-Time(2))
N = 1;

TDiff = Time(2)-Time(1);

% DATA ERROR!

