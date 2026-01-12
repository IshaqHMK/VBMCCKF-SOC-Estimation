function [z, OCV] = CKF_Meas2(state,k,signIk)

%% Data:
global Data_SOC dOCV Current Voltage k_steps Cn N Time TDiff SOC_TL OCV_TL
global Resistor1 Resistor0
global M0 M Gamma p

OCV = polyval(p,state(1,1));
z =  OCV + M0*signIk(k) + M*state(3,1) - Resistor1*state(2,1) - Resistor0*Current(k);

end