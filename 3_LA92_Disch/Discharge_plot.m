%
load('Discharge_V_C.mat')
discharge_voltage = D_V_C(:,1);
discharge_current = D_V_C(:,2);

load('Discharge_SOC.mat')

TDiff; % 15 seconds for discharge
discharge_SOC = D_SOC;
k_stepsDisch = size(discharge_SOC,1); 
TimeDisch = 1:k_stepsDisch;
plot(TimeDisch, discharge_SOC(Time),'k-' ,'LineWidth',2 );