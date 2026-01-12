clc; close all; clear all;

%% DataSets:
% Data Set 1:
% EXT_Data;
% Data Set 2:  
% EXT_DST_Data;
% EXT_VPS_Data;
%   EXT_LA92;
  EXT_US06;

% Figure Printing Type
FType = '-djpeg';

 MainDataPlot;

fprintf(['The available Estimation Algorithms are: \n' ...
   '[1] - Extended Kalman Filter \n' ...
   '[2] - Cubature Kalman Filter \n' ...
   '[3] - Variational B. Cubature Kalman Filter \n' ...
   '[4] - Variational Maximum C Cubature Kalman Filter \n' ...
   ]);

promptPSO = 'Please select the estimation algorithm [Default: (ENTER) Run All / "NaN" to abort]: ';
KF_TEST = input(promptPSO);

if KF_TEST == 1
   T1_EKF_Main;
elseif KF_TEST == 2
   T2_CKF_Main;
elseif KF_TEST == 3
   T3_VBCKF_Main;
   elseif KF_TEST == 4
   T4_VMCCKF_Main;
elseif isempty(KF_TEST)
   T1_EKF_Main;
   T2_CKF_Main;
   T3_VBCKF_Main;
   T4_VMCCKF_Main;
   
   % Plot and save figures.
   plotall;
else
   KF = NaN;
   disp("ERROR! Option does not exist. Aborting..");
   return;
end

% clc;