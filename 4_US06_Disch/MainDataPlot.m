global Data_SOC Data_OCV Time 

% Plotting
% 1. SOC versus OCV
F1 = figure;
plot(Data_SOC,Data_OCV, 'm-' ,'LineWidth',2);
ylabel('Open-Circuit Voltage (V)');
xlabel('SOC (%) ');
title('SOC versus OCV');
grid;
Name  = 'TESTdata_SOC_vs_OCV';
saveas(F1,Name,'jpg');
close(F1)

% 2. SOC vs Time
F2 = figure;
plot(Time, Data_SOC, 'm-' ,'LineWidth',2);
ylabel('SOC (%) ');
xlabel('Open-Circuit Voltage (V)');
title('SOC versus Time');
grid;
Name  = 'TESTdata_SOC_vs_Time';
saveas(F2,Name,'jpg');
 close(F2)