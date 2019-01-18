% EstimateFcost.m
% This file estimates fcost based on population data labor force participation rate, using method of simulated moment

% clear all; close all;

TimeS = cputime;
disp('=======================')

% Estimation
HoursWorked35to50 = 0.412;
LforceParticipationRate2454 = 0.829;
x0            = 0.01;
options=optimset('Display','final','MaxFunEvals',10000,'MaxIter',10000,'tolx',0.01,'tolfun',1); 
  % Option on display of output, # of evaluation and convergence criteria
[xMin,fval]   = fminsearch(@distance,x0,options); 

% Display results
disp('Estimated params with population data')
disp('alpha, fcost:')
disp(xMin) 
% Display time spent 
TimeE = cputime;
disp('Time Spent (mins)')
disp((TimeE - TimeS)/60)


% Estimation
HoursWorked35to50 = 0.412;
LforceParticipationRate2454 = 0.829;
data = [LforceParticipationRate2454, HoursWorked35to50]
x0            = [0.0001, 0.9];
options=optimset('Display','final','MaxFunEvals',10000,'MaxIter',10000,'tolx',0.00001,'tolfun', 1); 
  % Option on display of output, # of evaluation and convergence criteria
[xMin,fval]   = fminsearch(@finddistance,x0,options); 

% Display results
disp('Estimated params with population data')
disp('alpha, fcost:')
disp(xMin) 
% Display time spent 
TimeE = cputime;
disp('Time Spent (mins)')
disp((TimeE - TimeS)/60)