%  close all; clear all;

% FType = '-djpeg';
% EXT_US06;
EXT_LA92;
KF = "TEST01_EKF_";
FType = 'fig';


%% Data:
global Q R
global Data_SOC OCV  Current Voltage k_steps Cn N Time TDiff  
global Resistor1 Capacitor1 Resistor0
global M0 M Gamma p pd

Q =  diag([1e-3 1e-3 1e-3]);      % Process Noise covariance // 
R =  1e-3;                         % Measurement Noise Covariance

% disp(['Q (SN) = ', num2str(Q)])
disp(['R (MN) = ', num2str(R)])

% Size of simulation time steps
k_steps = size(Data_SOC, 1);
L =         zeros(3,1,k_steps);
s =         zeros(k_steps,1);
xEstimate = zeros(k_steps,1);
zEstimate = zeros(k_steps,1);
zhat =      zeros(k_steps,1);
Ah =        zeros(k_steps,1);
% OCV =       zeros(k_steps,1);
state =     zeros(3,1,k_steps);        % 3 by 1
A =         zeros(3,3,k_steps);        % 3 by 3
B =         zeros(3,2,k_steps);        % 3 by 2
Bhat =      zeros(3,1,k_steps);        % 3 by 1
U =         zeros(2,1,k_steps);        % 2 by 1
H =         zeros(1,3,k_steps);        % 1 by 3
signIk =    zeros(1,size(Current,1));
pbar =      zeros(3,3,k_steps);

% Define SOC and Voltage v(t)
xTruth = Data_SOC;
zTruth = Voltage;

% Initialize simulation variables @ k=1
xhat0 =   0.8;
iR10  =   0;
Hk0   =   0;
state(:,:,1) =  [xhat0; iR10  ; Hk0];
Error = abs(xTruth(1) - xhat0);
Sk =  diag([0.065 0.07 0.07]);
pbar(:,:,1)  =  Sk*Sk';

xEstimate(1) =  state(1,1,1);
zhat(1)      =  zTruth(1);
zEstimate(1) =  zhat(1);
L(:,:,1)     =  [0; 0; 0];
s(1)         =  0;

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
   
   % Step 1b: Error covariance time update
   pbar(:,:,k) = A(:,:,k)*pbar(:,:,k-1)*A(:,:,k)' + diag(Bhat(:,:,k))*Q*diag(Bhat(:,:,k))';
   
   % KF Step 1c: Estimate system output
   
   % Compute OCV
   OCV(k) = polyval(p,state(1,1,k));
   zhat(k) =  OCV(k) + M0*signIk(k) + M*state(3,1,k) - Resistor1*state(2,1,k) - Resistor0*Current(k);
   
   % H(1,1,k) = dOCVfromSOC(SOC_TL, OCV_TL, state(1,1,k));
   H(1,1,k) = polyval(pd,state(1,1,k));
   H(1,2,k) = M;
   H(1,3,k) = -Resistor1;
   
   %% After Getting the Measurement
   
   % KF Step 2a: Compute Kalman gain matrix
   s(k) = H(:,:,k)*pbar(:,:,k)*H(:,:,k)' + R;
   L(:,:,k) = pbar(:,:,k) * H(:,:,k)'/s(k);
   
   % KF Step 2b: State-estimate measurement update
   
   %% Checked - less error
   if (zTruth(k) - zhat(k))^2 > 100*s(k)
      L(:,:,k)=0.0;
   end
   
   state(:,:,k) = state(:,:,k) + L(:,:,k)*(zTruth(k) - zhat(k));
   % state(3,1,k) = min(1,max(-1,state(3,1,k)));
   % state(1,1,k) = min(1.05,max(-0.05,state(1,1,k)));
   
   % KF Step 2c: Error-covariance measurement update
   pbar(:,:,k) = pbar(:,:,k) - L(:,:,k)*s(k)*L(:,:,k)';
   
   % Help maintain robustness:
   [~,S,V] = svd(pbar(:,:,k));
   HH = V*S*V';
   pbar(:,:,k) = (pbar(:,:,k) + pbar(:,:,k)' + HH + HH')/4; % Help maintain robustness
   
   xEstimate(k) = state(1,1,k);
   zEstimate(k) = zhat(k);
end

MSE_EKF = mean((xTruth - xEstimate).^2);
RMSE_EKF = MSE_EKF^(0.5);
AbsEr_EKF = abs(xTruth - xEstimate);
EKF = [xTruth,xEstimate,zEstimate];
EKFmnr= [MSE_EKF, RMSE_EKF];
EKF_MAEPercentage = mean(abs(xEstimate-xTruth))*100
   

EKF1 = figure;
plot(Time, xTruth,'k-' ,'LineWidth',2 ); hold on
plot(Time, xEstimate,'r-' ,'LineWidth',2 ); grid;
legend('True SOC','Estimated SOC - EKF','location','south');
legend('True SOC','Estimated SOC - EKF');
title('SOC Estimation - EKF');
xlabel('TimeSteps'); ylabel('State'); hold off
Name  = [num2str(KF),'SOC Estimation'];
% print(EKF1,Name,FType);
saveas(EKF1,Name,FType);

 EKF2 = figure;
plot(Time, zTruth,'k-' ,'LineWidth',2 ); hold on
plot(Time, zEstimate,'r-' ,'LineWidth',2 ); grid;
% legend('Measured Voltage','Predicted Voltage - EKF','location','south');
legend('Measured Voltage','Predicted Voltage - EKF');
title('Voltage Comparison - EKF');
xlabel('TimeSteps'); ylabel('Voltage');  hold off
Name  = [num2str(KF),'Voltage Estimation'];
% print(EKF2,Name,FType);
saveas(EKF2,Name,FType);

EKF3 = figure;
plot(Time, AbsEr_EKF,'k-' ,'LineWidth',2 ); grid;
legend('Absolute Error','location','northeast');
 title('Absolute Error - EKF'); xlabel('TimeSteps'); ylabel('Error');
 Name  = [num2str(KF),'Abs Error'];
% print(EKF3,Name,FType);
saveas(EKF3,Name,FType);

fprintf('The Mean Sq. SOC Estimation Error = %g\n',MSE_EKF);
fprintf('The RMS SOC Estimation Error = %g\n',RMSE_EKF);
