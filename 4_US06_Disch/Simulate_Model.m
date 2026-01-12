

% EXT_Data;
% EXT_VPS_Data;
% ESC_Model;
% EXT_DST_Data; 

%% Data:


global Data_SOC OCV dOCV Current Voltage k_steps Cn N Time TDiff 
global Resistor1 Capacitor1 Resistor0
global M0 M Gamma

% M0 =    P_test(1);
% M =     P_test(2);
% Gamma = P_test(3);
% Resistor0 = P_test(4);
% Resistor1 = P_test(5);
% Capacitor1 = P_test(6);

% Current = -Current; % ESC Model

% Size of simulation time steps
k_steps = size(Data_SOC, 1);


zhat =      zeros(k_steps,1);
Ah =        zeros(k_steps,1);
% OCV =       zeros(k_steps,1);
StateHat =  zeros(k_steps,1);
state =     zeros(3,1,k_steps);        % 3 by 1

state(1,1,:) = Data_SOC(:);

A =         zeros(3,3,k_steps);        % 3 by 3
B =         zeros(3,2,k_steps);        % 3 by 2
Bhat =      zeros(3,1,k_steps);        % 3 by 1
U =         zeros(2,1,k_steps);        % 2 by 1
H =         zeros(1,3,k_steps);        % 1 by 3
signIk =    zeros(1,size(Current,1));


% Define SOC and Voltage v(t)
xTruth = Data_SOC;
zTruth = Voltage;

% Initialize simulation variables @ k=1
xhat0 =   xTruth(1);
StateHat(1) = xhat0;
iR10  =   0;
Hk0   =   0;
state(:,:,1) =  [xhat0; iR10  ; Hk0];
zhat(1)      =  zTruth(1);


for k = 2 : k_steps
   
   % Instantaneous hysteresis
   if abs(Current(k)) > Cn/(3600*100) % or 0
      signIk(k) = sign(Current(k));
   else
      signIk(k) = signIk(k-1);
   end
   
   % The derivatives: Arc and Brc
   Arc = exp(-TDiff/(Resistor1*Capacitor1));     % Cnst
   Brc = 1-Arc;                                  % Cnst
   
   A(1,1,k) = 1;
   Bhat(1,1,k) = -TDiff/Cn;
   
   A(2,2,k) = Arc;
   Bhat(2,1,k) = 1-Arc;
   
   Ah(k) = exp(-abs((Current(k-1)*N*Gamma*TDiff)/Cn)); % Hysteresis Factor
   A(3,3,k) = Ah(k);
   
   B(:,:,k) = [Bhat(:,:,k) 0*Bhat(:,:,k)];
   
   Bhat(3,1,k) = -(abs((Gamma*TDiff)/Cn))*Ah(k)*(1+sign(Current(k-1)*state(3,1,k-1)));
   B(3,1,k) = Ah(k) - 1;
   
   % Input:
   U(:,:,k) = [ Current(k-1);
      sign(Current(k-1))];
   
   % Before Getting the Measurement
   % Step 1a: State estimate time update
   state(:,:,k) = A(:,:,k)*state(:,:,k-1) + B(:,:,k)*U(:,:,k);
   
   %    state(3,1,k) = min(1,max(-1,state(3,1,k)));
   %    state(1,1,k) = min(1.05,max(-0.05,state(1,1,k)));
   
   
   
   % Compute OCV
   % OCV(k) = interp1(SOC_TL,OCV_TL, state(1,1,k) ,'near','extrap');
   zhat(k) =  OCV(k) + M0*signIk(k) + M*state(3,1,k) - Resistor1*state(2,1,k) - Resistor0*Current(k);
   
   % H(1,1,k) = dOCVfromSOC(SOC_TL, OCV_TL, state(1,1,k));
   H(1,1,k) = dOCV(k);
   H(1,2,k) = M;
   H(1,3,k) = -Resistor1;
   
   StateHat(k) = state(1,1,k);
end

figure;
plot(Time, xTruth,'k-' ,'LineWidth',2 );  hold on
plot(Time, StateHat,'r-' ,'LineWidth',2 ); 
legend('True SOC','location','south');
title('SOC');
xlabel('TimeSteps'); ylabel('State'); hold off

figure;
plot(Time, Voltage,'k-' ,'LineWidth',2 ); hold on;
plot(Time, zhat,'r-' ,'LineWidth',2 );
legend('True Voltage','location','south');
title('OCV VOltage');
xlabel('TimeSteps'); ylabel('State'); hold off

% disp(['The RMS SOC Estimation Error =  ',num2str(sqrt(mean((100*(xTruth-xEstimate)).^2)))]);
% obfun = mean(((xTruth-xEstimate)).^2);
%  obfun = mean((zTruth - zhat).^2) + mean((xTruth - StateHat).^2);
%  obfun = mean((zTruth - zhat).^2);
