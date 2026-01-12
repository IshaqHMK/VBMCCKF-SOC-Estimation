% Charging
% % Compute Resistance 


 Resistance = abs((Voltage - Data_OCV)./Current);
for i = 1:k_steps
if isinf(Resistance(i))
   Resistance(i) = Resistance(i+1);
   
end
end

Resistance;

%% MISSING OCV and Resistance
% But from lookuptable
for i = 1:size(discharge_SOC,1)
D_OCV(i) =  interp1(SOC_Data,OCV_Data, discharge_SOC(i) ,'spline');
end
discharge_OCV = D_OCV';


 DischargeResistance = abs((discharge_voltage - discharge_OCV)./discharge_current);
for i = 1:size(discharge_SOC,1)
if isinf(DischargeResistance(i))
   DischargeResistance(i) = DischargeResistance(i-1);

end
end