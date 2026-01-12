clc; close all; clear all

KF = "TEST02_CKF_";
EXT_Data;
FType = '-djpeg';


%% Data:
global Q R
global Data_SOC OCV dOCV Current Voltage k_steps Cn N Time TDiff 
global Resistor1 Capacitor1
global M Gamma


Q =  0.01;          % Process/Sensor-noise covariance
R =  0.01;          % Measurement Noise Covariance

disp(['Q (SN) = ', num2str(Q)])
disp(['R (MN) = ', num2str(R)])

% Size of simulation time steps
k_steps =   size(Data_SOC, 1);
KalmanGain= zeros(3,1,k_steps);
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
signIk =    ones(1,size(Current,1));
pbar =      zeros(3,3,k_steps);

xTruth = Data_SOC;
zTruth = Voltage;

% Initialize simulation variables @ k=1
xhat0 =   0.1;
iR10  =   0;
Hk0   =   0;
state(:,:,1) =  [xhat0; iR10  ; Hk0];
Error =abs(xTruth(1) - xhat0);
Sk = Error*eye(3)+0.01 ;

pbar(:,:,1)  =  Sk*Sk';
xEstimate(1) =  state(1,1,1);
zhat(1)      =  zTruth(1);
zEstimate(1) =  zhat(1);
L(:,:,1)     =  [0; 0; 0];
s(1)         =  0;

for k = 2:k_steps
    %% prediction:
    
    
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
    pbar(:,:,k) = A(:,:,k)*pbar(:,:,k-1)*A(:,:,k)' + Bhat(:,:,k)*Q*Bhat(:,:,k)';
    
    
    %% Update:
    
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
    
    Zi = zeros(1, size(Xi,2));
    
    % 3. Evaluate the Propagated Cubature Points
    for i = 1: size(Xi,2)
        [Meas, OCV] = CKF_Meas2(Xi(:,i),k,OCV,signIk);
        Zi(i) = Meas;
    end
    
    % Update HYST
%    H(1,1,k) = dOCVfromSOC(SOC_TL, OCV_TL, state(1,1,k));
     H(1,1,k) = polyval(pd,state(1,1,k));
    H(1,2,k) = M;
    H(1,3,k) = -Resistor1;
    
    % 4. Evaluate the Predicted Measurements
    zHat = sum(Zi,2)/m;
    Z = (Zi-repmat(zHat,1,m))/sqrt(m);
    % 5. Evaluate the innovation Covariance
    Pzz = Z*Z'+ R;
    % 6. Evaluate the cross covariance
    Pxz = X*Z';
    % 7. Estimate the Kalman Gain
    W = Pxz*pinv(Pzz) ;
    
    % 8. Estimate the updated state
    state(:,:,k) = state(:,:,k) + W*(zTruth(k) - zHat)  ;
    % 9. Estimate the corresponding error covariance
    pbar(:,:,k) = pbar(:,:,k) - W*Pzz*W';
    
    % Help maintain robustness:
%     [~,S,V] = svd(pbar(:,:,k));
%     HH = V*S*V';
%     pbar(:,:,k) = (pbar(:,:,k) + pbar(:,:,k)' + HH + HH')/4; % Help maintain robustness
%     
    
    %% End of CKF
    
    xEstimate(k)      = state(1,1,k);
    zEstimate(k)      = zHat;
    KalmanGain(:,:,k) = W;
    
end



MSE_CKF = mean((xTruth - xEstimate).^2);
RMSE_CKF = MSE_CKF^(0.5);
AbsEr_CKF = abs(xTruth - xEstimate);
CKF = [xTruth,xEstimate,zEstimate];
CKFmnr= [MSE_CKF, RMSE_CKF];

% To Plot

CKF1 = figure;
plot(Time, xTruth,'k-' ,'LineWidth',2 ); hold on
plot(Time, xEstimate,'r-' ,'LineWidth',2 ); grid;
% legend('True SOC','Estimated SOC - CKF','location','south');
legend('True SOC','Estimated SOC - CKF');
title('SOC Estimation - CKF');
xlabel('TimeSteps'); ylabel('State'); hold off
Name  = [num2str(KF),'SOC Estimation'];
print(CKF1,Name,FType);

CKF2 = figure;
plot(Time, zTruth,'k-' ,'LineWidth',2 ); hold on
plot(Time, zEstimate,'r-' ,'LineWidth',2 ); grid;
% legend('Measured Voltage','Predicted Voltage - CKF','location','south');
legend('Measured Voltage','Predicted Voltage - CKF');
title('Voltage Comparison - CKF');
xlabel('TimeSteps'); ylabel('Voltage');  hold off
Name  = [num2str(KF),'Voltage Estimation'];
print(CKF2,Name,FType);

CKF3 = figure;
plot(Time, AbsEr_CKF,'k-' ,'LineWidth',2 ); grid;
legend('Absolute Error','location','northeast');
title('Absolute Error - CKF'); xlabel('TimeSteps'); ylabel('Error');
 Name  = [num2str(KF),'Abs Error'];
print(CKF3,Name,FType);

fprintf('The Mean Sq. SOC Estimation Error = %g\n',MSE_CKF);
fprintf('The RMS SOC Estimation Error = %g\n',RMSE_CKF);
