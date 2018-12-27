% Labor Market Participation and Life-cycle Model of Portfolio Choice
% Yang Su
% yangsu@uw.edu

% This file reproduces all the results and plots that are used in my thesis


% Section 1: Baseline Results
% No Cost vs. Low Cost vs. High Cost

% First run the no cost version, set fcost = 0; Then rename the relavent
% variables.
lambda = 0.68212;
fcost = 0;
alpha = 0.9
main_withbounds;
rename;

% Then run the low cost version
lambda = 0.68212;
fcost = 3.14e-6;
alpha = 0.9
main_withbounds;
rename;

% Then run the high cost version
lambda = 0.68212;
fcost = 1e-2;
alpha = 0.9
main_withbounds;
rename;

% Plot value functions, policy functions and simulation results. 
% Value Functions
figure;
subplot(3,1,1)
surf(WEALTH, THETA, fvalLifeLC(:, :, 45))
title('Value function at age 65')
xlabel('Wealth') 
ylabel('Theta') 
subplot(3,1,2)
surf(WEALTH, THETA, fvalLifeLC(:, :, 25))
title('Value function at age 45')
xlabel('Wealth') 
ylabel('Theta') 
subplot(3,1,3)
surf(WEALTH, THETA, fvalLifeLC(:, :, 5))
title('Value function at age 25')
xlabel('Wealth') 
ylabel('Theta') 

% Policy Functions
% plot leisure functions
figure
ax(1) = subplot(1,3,1);
hold on
plot(wVec, mean(lvalLifeNC(:, :, 45), 2), '-o')
plot(wVec, mean(lvalLifeNC(:, :, 15), 2), '-+')
plot(wVec, mean(lvalLifeNC(:, :, 5), 2), '-s')
title('No fixed cost')
legend('age = 65', 'age = 45', 'age = 25')
xlabel('Wealth') 
ylabel('Leisure') 

ax(2) = subplot(1,3,2);
hold on
plot(wVec, mean(lvalLifeLC(:, :, 45), 2), '-o')
plot(wVec, mean(lvalLifeLC(:, :, 15), 2), '-+')
plot(wVec, mean(lvalLifeLC(:, :, 5), 2), '-s')
title('Low fixed cost (fcost = 3.14e-6)')
legend('age = 65','age = 45', 'age = 25')
xlabel('Wealth') 
ylabel('Leisure') 

ax(3) = subplot(1,3,3);
hold on
plot(wVec, mean(lvalLifeHC(:, :, 45), 2), '-o')
plot(wVec, mean(lvalLifeHC(:, :, 15), 2), '-+')
plot(wVec, mean(lvalLifeHC(:, :, 5), 2), '-s')
title('High fixed cost (fcost = 1e-2)')
legend('age = 65','age = 45', 'age = 25')
xlabel('Wealth') 
ylabel('Leisure') 

linkaxes(ax,'y');

%plot Consumption functions
figure
ax(1) = subplot(1,3,1);
hold on
plot(wVec, mean(cvalLifeNC(:, :, 45), 2), '-o')
plot(wVec, mean(cvalLifeNC(:, :, 15), 2), '-+')
plot(wVec, mean(cvalLifeNC(:, :, 5), 2), '-s')
title('No fixed cost')
legend('age = 65', 'age = 45', 'age = 25')
xlabel('Wealth') 
ylabel('Consumption') 

ax(2) = subplot(1,3,2);
hold on
plot(wVec, mean(cvalLifeLC(:, :, 45), 2), '-o')
plot(wVec, mean(cvalLifeLC(:, :, 15), 2), '-+')
plot(wVec, mean(cvalLifeLC(:, :, 5), 2), '-s')
title('Low fixed cost (fcost = 3.14e-6)')
legend('age = 65','age = 45', 'age = 25')
xlabel('Wealth') 
ylabel('Consumption') 

ax(3) = subplot(1,3,3);
hold on
plot(wVec, mean(cvalLifeHC(:, :, 45), 2), '-o')
plot(wVec, mean(cvalLifeHC(:, :, 15), 2), '-+')
plot(wVec, mean(cvalLifeHC(:, :, 5), 2), '-s')
title('High fixed cost (fcost = 1e-2)')
legend('age = 65','age = 45', 'age = 25')
xlabel('Wealth') 
ylabel('Consumption') 

linkaxes(ax,'y');

%plot risky share functions
figure
ax(1) = subplot(1,3,1);
hold on
plot(wVec, mean(pvalLifeNC(:, :, 45), 2), '-o')
plot(wVec, mean(pvalLifeNC(:, :, 15), 2), '-+')
plot(wVec, mean(pvalLifeNC(:, :, 5), 2), '-s')
title('No fixed cost')
legend('age = 65', 'age = 45', 'age = 25')
xlabel('Wealth') 
ylabel('Risky Shares') 

ax(2) = subplot(1,3,2);
hold on
plot(wVec, mean(pvalLifeLC(:, :, 45), 2), '-o')
plot(wVec, mean(pvalLifeLC(:, :, 15), 2), '-+')
plot(wVec, mean(pvalLifeLC(:, :, 5), 2), '-s')
title('Low fixed cost (fcost = 3.14e-6)')
legend('age = 65','age = 45', 'age = 25')
xlabel('Wealth') 
ylabel('Risky Shares') 

ax(3) = subplot(1,3,3);
hold on
plot(wVec, mean(pvalLifeHC(:, :, 45), 2), '-o')
plot(wVec, mean(pvalLifeHC(:, :, 15), 2), '-+')
plot(wVec, mean(pvalLifeHC(:, :, 5), 2), '-s')
title('High fixed cost (fcost = 1e-2)')
legend('age = 65','age = 45', 'age = 25')
xlabel('Wealth') 
ylabel('Consumption') 

linkaxes(ax,'y');

% Simulation Results
% Lifepaths
agevec =tb + 1: 1:td;
figure;
ax(1) = subplot(1,3,1);
hold on;
plot(agevec, incpoppathNC/incpoppathNC(1, 1), '-d')
plot(agevec, wealthpoppathNC/incpoppathNC(1, 1), '-*' )
plot(agevec, consumptionpathNC/incpoppathNC(1, 1), '-s')
title('No fixed cost')
legend('Income','Wealth', 'Consumption')
xlabel('Age') 
 
ax(2) = subplot(1,3,2);
hold on;
plot(agevec, incpoppathLC/incpoppathLC(1, 1), '-d')
plot(agevec, wealthpoppathLC/incpoppathLC(1, 1), '-*' )
plot(agevec, consumptionpathLC/incpoppathLC(1, 1), '-s' )
title('Low fixed cost (fcost = 3.14e-6)')
legend('Income','Wealth', 'Consumption')
xlabel('Age') 
 
ax(3) = subplot(1,3,3);
hold on;
plot(agevec, incpoppathHC/incpoppathHC(1, 1), '-d')
plot(agevec, wealthpoppathHC/incpoppathHC(1, 1), '-*' )
plot(agevec, consumptionpathHC/incpoppathHC(1, 1), '-s')
title('High fixed cost (fcost = 1e-2)' )
legend('Income','Wealth', 'Consumption')
xlabel('Age') 
 
linkaxes(ax,'y');

% Labor Market Participation Rates
data(1:4, 1) =0.73
data(5:14, 1) =0.888
data(15:24, 1)= 0.906
data(25:34, 1)= 0.863
data(35:45, 1)= 0.702

figure;
hold on;
plot(agevec(1:45), lprateLC, '-*')
plot(agevec(1:45), lprateHC, '-s')
legend('Low Cost', 'High Cost')
xlabel('Age') 
ylabel('Labor Force Participation Rate') 

% Labor Supply in Hours
figure; 
hold on;
plot(agevec(1:45), cdllaborsupplyNC(1:45)*3800, '-D')
plot(agevec(1:45), cdllaborsupplyLC(1:45)*3800, '-*')
plot(agevec(1:45), cdllaborsupplyHC(1:45)*3800, '-s')
legend('No Cost','Low Cost', 'High Cost')
xlabel('Age') 
ylabel('Conditional Labor Supply in Hours') 

% Labor Supply in Hours
figure; 
hold on;
plot(agevec(1:45), (1 - lpoppathNC(1:45))*3800, '-D')
plot(agevec(1:45), (1 - lpoppathLC(1:45))*3800, '-*')
plot(agevec(1:45), (1 - lpoppathHC(1:45))*3800, '-s')
legend('No Cost','Low Cost', 'High Cost')
xlabel('Age') 
ylabel('Labor Supply in Hours') 


% Risky Shares
figure; 
hold on;
plot(agevec,  ppoppathNC, '-d')
plot(agevec,  ppoppathLC, '-*')
plot(agevec,  ppoppathHC, '-s')
legend('No Cost', 'Low Cost', 'High Cost')
xlabel('Age') 
ylabel('Risky shares') 

% Conditional Risky Shares
figure; 
hold on;
plot(agevec,  cdlriskyshareNC, '-d')
plot(agevec,  cdlriskyshareLC, '-*')
plot(agevec,  cdlriskyshareHC, '-s')
legend('No Cost', 'Low Cost', 'High Cost')
xlabel('Age') 
ylabel('Conditional Risky shares') 

% Section 2: Extension with Social Securities  
% Bench Mark, low replacement rate, high replacement rate, endogenous SS
lambda = 0.4;
fcost = 3.14e-6;
main_withbounds;
rename;

lambda = 0.9;
fcost = 3.14e-6;
main_withbounds;
rename;

% Lifepaths
agevec =tb + 1: 1:td;
figure;
ax(1) = subplot(1,3,1);
hold on;
plot(agevec, incpoppathLC/incpoppathLC(1, 1), '-d')
plot(agevec, wealthpoppathLC/incpoppathLC(1, 1), '-*' )
plot(agevec, consumptionpathLC/incpoppathLC(1, 1), '-s' )
title('Benchmark (\lambda = 0.68212)')
legend('Income','Wealth', 'Consumption')
xlabel('Age') 

ax(2) = subplot(1,3,2);
hold on;
plot(agevec, incpoppathLS/incpoppathLS(1, 1), '-d')
plot(agevec, wealthpoppathLS/incpoppathLS(1, 1), '-*' )
plot(agevec, consumptionpathLS/incpoppathLS(1, 1), '-s' )
title('Low \lambda (\lambda = 0.3)')
legend('Income','Wealth', 'Consumption')
xlabel('Age') 
 
ax(3) = subplot(1,3,3);
hold on;
plot(agevec, incpoppathHS/incpoppathHS(1, 1), '-d')
plot(agevec, wealthpoppathHS/incpoppathHS(1, 1), '-*' )
plot(agevec, consumptionpathHS/incpoppathHS(1, 1), '-s')
title('High \lambda (\lambda = 0.9)' )
legend('Income','Wealth', 'Consumption')
xlabel('Age') 
 
linkaxes(ax,'y');


figure; 
hold on;
plot(agevec,  cdlriskyshareLC, '-*')
% plot(agevec,  cdlriskyshareLS, '-d')
plot(agevec,  cdlriskyshareHS, '-*')
plot(agevec,  cdlriskyshare, '-*')
legend('Benchmark', 'High \lambda', 'Endo SS')
xlabel('Age') 
ylabel('Conditional Risky shares') 

figure; 
hold on;
plot(agevec(1:79),  ppoppathLC(1:79), '-*')
% plot(agevec,  ppoppathLS, '-d')
plot(agevec(1:79),  ppoppathHS(1:79), '-o')
plot(agevec(1:79),  ppoppath(1:79), '-s')
legend('Benchmark', 'High \lambda', 'Endo SS')
xlabel('Age') 
ylabel('Risky shares') 

figure; 
hold on;
% plot(agevec(1:45), cdllaborsupplyLC(1:45)*5200, '-D')
plot(agevec(1:45), cdllaborsupplyLC(1:45)*3800, '-*')
plot(agevec(1:45), cdllaborsupplyHS(1:45)*3800, '-s')
plot(agevec(1:45), cdllaborsupply(1:45)*3800, '-d')
% plot(agevec(1:45), clpartpath(1:45)*5200, '-s')
legend('Benchmark',  'High \lambda', 'Endo SS')
xlabel('Age') 
ylabel('Conditional Labor Supply in Hours') 

figure;
hold on;
plot(agevec(1:45), lprateLC, '-*')
% plot(agevec(1:45), lprateLS, '-s')
plot(agevec(1:45), lprateHS, '-o')
plot(agevec(1:45), lprate, '-d')
legend('Benchmark', 'High \lambda', 'Endo SS')
xlabel('Age') 
ylabel('Labor Force Participation Rate') 


figure;
hold on;
plot(agevec(1:45), lprateLC, '-*')
% plot(agevec(1:45), lprateLS, '-s')
plot(agevec(1:45), lprateLA, '-o')
plot(agevec(1:45), lprateHA, '-d')
plot(agevec(1:45), lprateHAS, '-s')
legend('Benchmark', 'Low \alpha', 'High \alpha', 'High \alpha + Endo SS')
xlabel('Age') 
ylabel('Labor Force Participation Rate') 


figure; 
hold on;
% plot(agevec(1:45), cdllaborsupplyLC(1:45)*5200, '-D')
plot(agevec(1:45), cdllaborsupplyLC(1:45)*3800, '-*')
plot(agevec(1:45), cdllaborsupplyLA(1:45)*3800, '-O')
plot(agevec(1:45), cdllaborsupplyHA(1:45)*3800, '-d')
plot(agevec(1:45), cdllaborsupplyHAS(1:45)*3800, '-s')
legend('Benchmark', 'Low \alpha', 'High \alpha', 'High \alpha + Endo SS')
xlabel('Age') 
ylabel('Conditional Labor Supply in Hours') 


figure; 
hold on;
plot(agevec(1:79),  ppoppathLC(1:79), '-*')
% plot(agevec,  ppoppathLS, '-d')
plot(agevec(1:79),  ppoppathLA(1:79), '-o')
plot(agevec(1:79),  ppoppathHA(1:79), '-D')
plot(agevec(1:79),  ppoppathHAS(1:79), '-s')
plot(agevec(1:79),  ppoppath(1:79), '-s')
legend('Benchmark', 'Low \alpha', 'High \alpha', 'High \alpha + Endo SS')
xlabel('Age') 
ylabel('Risky shares') 
