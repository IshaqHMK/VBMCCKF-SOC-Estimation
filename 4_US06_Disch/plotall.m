global Time

fs=8;
% TimeIndx = 51.07;
TimeIndx = 51.1;
TimeLmtSOC = 2;
TimeLmtV = 0.2;

all_SOC = figure('PaperUnits','inches','PaperPosition', [0 0 3.5 3.5]);
% set(gcf,'Position',[200 200 600 500])
plot(Time, xTruth,'k-' ,'LineWidth',1 ); grid; hold on
plot(Time, EKF(:,2),'g-' ,'LineWidth',1 );
plot(Time, CKF(:,2),'r-' ,'LineWidth',1 );
plot(Time, VBCKF(:,2),'c-' ,'LineWidth',1 );
plot(Time, VMCCKF(:,2),'b-' ,'LineWidth',1 );
plot(Time, xTruth,'k-' ,'LineWidth',1 );
legend('True SOC','EKF','CKF','VBCKF','VBMCCKF','location','northeast','Fontsize',fs-2);
title('SOC Estimation','Interpreter','latex','Fontsize',fs);
xlabel('Time [min]','Interpreter','latex','Fontsize',fs');
ylabel('State of Charge','Interpreter','latex','Fontsize',fs');
ylim ([-0.05 1.05]);

% create a new pair of axes inside current figure
axes('position',[.20,.20 .25 .25])
box on % put box around new pair of axes
indexOfInterest = (Time < TimeIndx+TimeLmtSOC) & (Time > TimeIndx); % range of t near perturbation
plot(Time(indexOfInterest),xTruth(indexOfInterest),'k-' ,'LineWidth',1 ); hold on;
plot(Time(indexOfInterest),EKF(indexOfInterest,2),'g-' ,'LineWidth',1)
plot(Time(indexOfInterest),CKF(indexOfInterest,2),'r-' ,'LineWidth',1)
plot(Time(indexOfInterest),VBCKF(indexOfInterest,2),'c-' ,'LineWidth',1)
plot(Time(indexOfInterest),VMCCKF(indexOfInterest,2),'b-' ,'LineWidth',1)
plot(Time(indexOfInterest),xTruth(indexOfInterest),'k-' ,'LineWidth',1 );
grid;
set(gca,'FontSize',5)
axis tight; hold off

Name = 'TEST_ALL_SOC_Estimation';
saveas(all_SOC,Name,'fig');
print(all_SOC,Name,'-dpng',['-r' num2str(600)]);

%%

all_Vol = figure('PaperUnits','inches','PaperPosition', [0 0 3.5 3.5]);

plot(Time, zTruth,'k-' ,'LineWidth',1 ); grid; hold on
plot(Time, EKF(:,3),'g-' ,'LineWidth',1 );
plot(Time, CKF(:,3),'r-' ,'LineWidth',1 );
plot(Time, VBCKF(:,3),'c-' ,'LineWidth',1 );
plot(Time, VMCCKF(:,3),'b-' ,'LineWidth',1 );
plot(Time, zTruth,'k-' ,'LineWidth',1 );
legend('True SOC','EKF','CKF','VBCKF','VBMCCKF','location','northeast','Fontsize',fs-2);
title('Voltage Comparison','Interpreter','latex','Fontsize',fs');
xlabel('Time [min]','Interpreter','latex','Fontsize',fs');
ylabel('Voltage [V]','Interpreter','latex','Fontsize',fs');
hold off
ylim ([min(zTruth)-0.1 max(zTruth)+0.1]);

% create a new pair of axes inside current figure
axes('position',[.20,.20 .25 .25])
box on % put box around new pair of axes
indexOfInterest = (Time < TimeIndx+TimeLmtV) & (Time > TimeIndx); % range of t near perturbation
plot(Time(indexOfInterest),zTruth(indexOfInterest),'k-' ,'LineWidth',1 ); hold on;
plot(Time(indexOfInterest),EKF(indexOfInterest,3),'g-' ,'LineWidth',1)
plot(Time(indexOfInterest),CKF(indexOfInterest,3),'r-' ,'LineWidth',1)
plot(Time(indexOfInterest),VBCKF(indexOfInterest,3),'c-' ,'LineWidth',1)
plot(Time(indexOfInterest),VMCCKF(indexOfInterest,3),'b-' ,'LineWidth',1)
plot(Time(indexOfInterest),zTruth(indexOfInterest),'k-' ,'LineWidth',1 );
grid;
set(gca,'FontSize',5)
axis tight; hold off

Name = 'TEST_ALL_Vol_Comp';
print(all_Vol,Name,'-dpng',['-r' num2str(600)]);


all_AbsEr = figure('PaperUnits','inches','PaperPosition', [0 0 3.5 3.5/2]);
plot(Time, AbsEr_EKF,'g-' ,'LineWidth',1 ); grid; hold on
plot(Time, AbsEr_CKF,'r-' ,'LineWidth',1 );
plot(Time, AbsEr_VBCKF,'c-' ,'LineWidth',1 );
plot(Time, AbsEr_VMCCKF,'b-' ,'LineWidth',1 );
legend('EKF','CKF','VBCKF','VBMCCKF','location','northeast','Fontsize',fs-2);
title('Absolute Error','Interpreter','latex','Fontsize',fs');
xlabel('Time [min]','Interpreter','latex','Fontsize',fs');
ylabel('Error','Interpreter','latex','Fontsize',fs');
hold off
ylim([0 0.1])
Name = 'TEST_All_AbsEr';
print(all_AbsEr,Name,'-dpng',['-r' num2str(600)]);