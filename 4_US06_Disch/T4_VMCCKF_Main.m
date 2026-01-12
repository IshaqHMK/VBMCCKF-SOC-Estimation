
KF = "TEST04_VMCCKF_";

% EXT_LA92;
EXT_US06;
% FType = '-djpeg';
% fig
FType = 'fig';
%% Data:
global Q R
global Data_SOC OCV Current Voltage k_steps Cn N Time TDiff
global Resistor1 Capacitor1
global M Gamma pd

Q =  diag([1e-3 1e-3 1e-3]);      % Process Noise covariance // US06
R =  1e-1;                         % Measurement Noise Covariance

% disp(['Q (SN) = ', num2str(Q)])
disp(['R (MN) = ', num2str(R)])


% Size of simulation time steps
k_steps =   size(Data_SOC, 1);
KalmanGain= zeros(3,1,k_steps);
s =         zeros(k_steps,1);
xEstimate = zeros(k_steps,1);
zEstimate = zeros(k_steps,1);
zHat =      zeros(k_steps,1);
Ah =        zeros(k_steps,1);
state =     zeros(3,1,k_steps);        % 3 by 1
A =         zeros(3,3,k_steps);        % 3 by 3
B =         zeros(3,2,k_steps);        % 3 by 2
Bhat =      zeros(3,1,k_steps);        % 3 by 1
U =         zeros(2,1,k_steps);        % 2 by 1
H =         zeros(1,3,k_steps);        % 1 by 3
signIk =    ones(1,size(Current,1));
pbar =      zeros(3,3,k_steps);
Sk =        zeros(3,3,k_steps);

xTruth = Data_SOC;
zTruth = Voltage;

% Initialize simulation variables @ k=1
xhat0 =   0.8;
iR10  =   0;
Hk0   =   0;
state(:,:,1) =  [xhat0; iR10  ; Hk0];
Sk(:,:,1) = diag([0.05  0.046 0.062]);

pbar(:,:,1)  =  Sk(:,:,1)*Sk(:,:,1)';
xEstimate(1) =  state(1,1,1);
zHat(1)      =  zTruth(1);
zEstimate(1) =  zHat(1);
L(:,:,1)     =  [0; 0; 0];
s(1)         =  0;

% For VBCKF
Vprev = 0;
vprev = 0;

for k = 2:k_steps
   %% prediction STEP:
   % Model
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
   % Step 1b: Error covariance time update
   pbar(:,:,k) = A(:,:,k)*pbar(:,:,k-1)*A(:,:,k)' + diag(Bhat(:,:,k))*Q*diag(Bhat(:,:,k))';
   
   %% Update Step
   
   rho= 0.51;
    rho= 0.39;
   % Controlls the assumed dynamics
   % Higher values allow lower time fluctuations
   % rho ~ (0<rho<1)
   n =  1;  % number of measurements
   
   % 1. factorize pBar
   % Genrate a set of Cubature Points
   % state vector dimension
   nx = 3;
   
   % Number of cubature points
   m = 2*nx;   % No. of Cubature Points
   CubaturePoints = sqrt(m/2)*[eye(nx) -eye(nx)];
   
   % Singular Value Decomposition (SVD) to find Square Root of pbar
   pbar(:,:,k) = 0.5*(pbar(:,:,k)+pbar(:,:,k)'); % To make pbar symmetric (Recal prop. of covariance matrix)
   [u, S, V] =  svd(pbar(:,:,k));
   Skk = 0.5*(u+V)*sqrt(S);
   
   % 2. Evaluate Cubature Points
   Xi = repmat(state(:,:,k),1,m) + Skk*CubaturePoints;
   X = (Xi-repmat(state(:,:,k),1,m))/sqrt(m);
   
   %% VBCKF
   Bb = sqrt(rho)*1;
   % B is a matrix ~ (0<abs(b)<=1)
   Vk = Bb*Vprev*Bb';          %9d
   vk = rho*(vprev-n-1)+n+1; %9e
   
   vkk = 1+vk;                %VBCKF - Before iter
   
   %% CKF
   Zi = zeros(1, size(Xi,2));
   % 3. Evaluate the Propagated Cubature Points
   for i = 1: size(Xi,2)
      [Meas, OCV] = CKF_Meas2(Xi(:,i),k,signIk);
      Zi(i) = Meas;
   end
   
   % Update HYST
   H(1,1,k) = polyval(pd,state(1,1,k));
   H(1,2,k) = M;
   H(1,3,k) = -Resistor1;
   
   % 4. Evaluate the Predicted Measurements
   zHat = sum(Zi,2)/m;
   Z = (Zi-repmat(zHat,1,m))/sqrt(m);
   %% VBCKF
   for iter=1:2
      
      R = ((vkk - n - 1)^-1)*Vk;      % 11.a
      % 5. Evaluate the innovation Covariance
      Pzz = Z*Z'+ R;                  % 11.b
      % 6. Evaluate the cross covariance
      Pxz = X*Z';                     % Used to compute the gain
      % 7. Estimate the Kalman Gain
      sigma = 2;   % kernel bandwidth - 
      
      % When the measurement function is non-linear, the
      % measurement noise covariance can be modified using Lk
      
      % To compute ztelta ~ use predicted state
      PrdState = state(:,:,k);
      [PrdMeasr, ~] = CKF_Meas2(PrdState,k,signIk);
      
      % Gaussian Kernel:
      Lk = exp(-(norm(zTruth(k) - PrdMeasr))^2/(2*(sigma^2))); % 43b
      Ck =  Lk*(Z*Z')+ R;                                   % 43c
      W = Lk*Pxz*(pinv(Ck));                                % 43d
      
      % 8. Estimate the updated state
      state(:,:,k) = state(:,:,k) + W*(zTruth(k) - zHat);      % 43e
      % 9. Estimate the corresponding error covariance
      pbar(:,:,k) = pbar(:,:,k) - Lk*Pxz*(pinv(Ck)')*Pxz';  % 43f
      
      zthelta = PrdMeasr + sqrt(Lk)*(zTruth(k) - PrdMeasr);    % 43g
      
      %% VMCCKF
      [U1, S1, V1] =  svd(0.5*(pbar(:,:,k)+pbar(:,:,k)'));
      Skk1 = 0.5*(U1+V1)*sqrt(S1);
      
      % Evaluate Cubature Points
      Xik =  repmat(state(:,:,k),1,m) + Skk1*CubaturePoints; %43h
      
      % Evaluate the Propagated Cubature Points
      Zik = zeros(1, size(Xik,2));
      for i = 1: size(Xik,2)
         [Meas, ~] = CKF_Meas2(Xik(:,i),k,signIk);
         Zik(i) = Meas;
      end
      Zn = (repmat(zthelta,1,m)-Zik)/sqrt(m);
      Vk = Vk + Zn*Zn';   %43i
      
   end
   xEstimate(k)      = state(1,1,k);
   zEstimate(k)      = zHat;
   KalmanGain(:,:,k) = W;
   Vprev = Vk;
   vprev = vk;
end
MSE_VMCCKF = mean((xTruth - xEstimate).^2);
RMSE_VMCCKF = MSE_VMCCKF^(0.5);
AbsEr_VMCCKF = abs(xTruth - xEstimate);
VMCCKF = [xTruth,xEstimate,zEstimate];
VMCCKFmnr= [MSE_VMCCKF, RMSE_VMCCKF];
VMCCKF_MAEPercentage = mean(abs(xEstimate-xTruth))*100

% To Plot
VMCCKF1 = figure;
plot(Time, xTruth,'k-' ,'LineWidth',2 ); hold on
plot(Time, VMCCKF(:,2),'r-' ,'LineWidth',2 ); grid;
% legend('True SOC','Estimated SOC - VMCCKF','location','south');
legend('True SOC','Estimated SOC - VBMCCKF');

title('SOC Estimation - VBMCCKF');
xlabel('TimeSteps'); ylabel('State'); hold off
Name  = [num2str(KF),'SOC Estimation'];
% print(VMCCKF1,Name,FType);
  saveas(VMCCKF1,Name,FType);

VMCCKF2 = figure;
plot(Time, zTruth,'k-' ,'LineWidth',2 ); hold on
plot(Time, zEstimate,'r-' ,'LineWidth',2 ); grid;
% legend('Measured Voltage','Predicted Voltage - VMCCKF','location','south');
legend('Measured Voltage','Predicted Voltage - VBMCCKF');
title('Voltage Comparison - VMCCKF');
xlabel('TimeSteps'); ylabel('Voltage');  hold off
Name  = [num2str(KF),'Voltage Estimation'];
% print(VMCCKF2,Name,FType);
  saveas(VMCCKF2,Name,FType);

VMCCKF3 = figure;
plot(Time, AbsEr_VMCCKF,'k-' ,'LineWidth',2 ); grid;
legend('Absolute Error','location','northeast');
title('Absolute Error - VBMCCKF'); xlabel('TimeSteps'); ylabel('Error');
 Name  = [num2str(KF),'Abs Error'];
% print(VMCCKF3,Name,FType);
  saveas(VMCCKF3,Name,FType);

fprintf('The Mean Sq. SOC Estimation Error = %g\n',MSE_VMCCKF);
fprintf('The RMS SOC Estimation Error = %g\n',RMSE_VMCCKF);