function [z, OCV] = CKF_Meas(state,k,OCV,signIk)

global Current SOC_TL OCV_TL
global Resistor1 Resistor0  
global M0 M 

OCV(k) = interp1(SOC_TL,OCV_TL, state(1,1) ,'near','extrap');
z =  OCV(k) + M0*signIk(k) + M*state(3,1) - Resistor1*state(2,1) - Resistor0*Current(k);
   
end