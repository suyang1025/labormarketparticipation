% Solve for life-cycle model
% Yang Su
% yangsu@uw.edu

% open profiler
% set up num of workers; num needs to be changed depending on # of CPUs
profile on;
% c = parcluster('local');
% c.NumWorkers = 4;
% parpool(c, c.NumWorkers);

%================
%   Parameters
%================
setup_params_ys1;

% incorporate mortality risks into discount rate
spdef; 

%==================================
%   Setup grids and shocks
%==================================

wVec = linspace(wMin, wMax, 40);
ssVec = linspace(1, 40, 10);
 

%==================================
%   Gauss Quadrature 
% %==================================
 weig = zeros(1, 3);
 weig(1,1)= 0.1666666666666;
 weig(1,2)= 0.6666666666666;
 weig(1,3)= 0.1666666666666;
 grid = zeros(1, 3);
 grid(1,1)= -1.73205080756887;
 grid(1,2)=  0.0;
 grid(1,3)=  1.73205080756887;

ThetaVals = sigma_t.*grid;

ThetaVals = exp(ThetaVals);

PShockVals  = sigma_p.*grid;

PShockVals = exp(PShockVals);

calRStd = 0.205; % Standard deviation of (log) equity returns
gr = grid*calRStd;
calRPrm = 0.04; % Modest estimate of the equity premium of 4 percent
mu = calRPrm + RFree;
calRVals = mu + gr; 

%==================================
%   Wage Rate (nomalized)
%
%   fl_y(t) = exp(ft)*theta_t (theta_t is a shock that could have three values,
%   so y_t is a matrix with three columns 
%   
%   ret_y (retirement income) is straightforward
%   
%==================================
f_y = zeros(1, tr - tb);
lnf = zeros(1, tr - tb);
for i = tb + 1 : tr
    ft = 4.47 + 0.033*(i - 20) - 0.00067*(i - 20)^2;
    expft = exp(ft);
    f_y(1, i - tb) = expft;
    lnf(1, i - tb) = ft;
end

fl_y = f_y'.*ThetaVals;

% Gomes (2008) configuration of SS income (resulted ret_y = 3.56)
% ret_y = exp(lambda*mean(lnf)*(1 - l_underlined));

% % Chai et al (2010) configuration of SS income (resulted ret_y = 31.3483)
% ret_y = lambda*mean(f_y)*(1 - l_underlined);

%==================================
%   Housing Expenditures
%==================================
ht = zeros(1, td-tb);
ah = 0.703998;
b1h = -0.0352276;
b2h = 0.0007205;
b3h = -0.0000049;
for i = tb + 1 : td
    h = max(0, ah + b1h*i + b2h*i^2 + b3h*i^3);
    ht(1, i - tb) = h;
end

%==================================
%   Solve for the consumption and investment policy during retirement
%==================================s
retirementperiodsSS2;

%=================================================
%   Keep solving the model until we reach to t = 1
%=================================================
% otherperiods_wb_pchip_shockgrids; 
otherperiodsSS2parfor; 
% %=================================================
%  Simulation
%=================================================
% simulationSS2;
