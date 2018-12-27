% Simulate a population of households
% Yang Su

% Define parameters and empty arrays
sim = 10000;     % number of households to simulate

cpath = zeros(td - tb, sim);
wpath = zeros(td - tb, sim);
lpath = zeros(td - tb, sim);
ppath = zeros(td - tb, sim);
lpartpath = zeros(td - tb, sim);
ppartpath = zeros(td - tb, sim);

cppartpath = zeros(td - tb, 1); % conditional stock market participation rate
clpartpath = zeros(td - tb, 1); % conditional labor market participation rate

fcl = zeros(td - tb, sim); % keep track of the consumption and leisure ratio

Thetapath = zeros (tr - tb, sim);
PShockpath = zeros (tr - tb, sim);
calRpath = zeros (td - tb, sim);

lprate = zeros(tr - tb, 1);
pprate = zeros(td - tb, 1);

% Initial Wealth Distributions 
% Initial wealth is drawn from a lognormal distribution
wpath(1, :) = lognrnd(0.988, 1.370, 1, sim);
llowerbound = l_underlined;
cplowerbound = 0;
cupperbound = highc;
pupperbound = 1;

perminc = ones(tr - tb, sim); 
perminc(1, :) = lognrnd(1, 0.512, 1, sim);

% income, consumption and wealth record the un-normalized consumption and wealth
income = ones(td - tb, sim); 
consumption = zeros (td - tb, sim);
wealth = zeros (td - tb, sim);

% first for each household j, generate the shocks that they are going to
% face over the life cycle

tic
for j = 1:sim % go through each household
    
    [~,thetaDraws] = histc(rand(tr - tb, 1),cumsum([0;weig(:)./sum(weig)]));
    [~,pshockDraws] = histc(rand(tr - tb, 1),cumsum([0;weig(:)./sum(weig)]));
    [~,calRDraws] = histc(rand(td - tb, 1),cumsum([0;weig(:)./sum(weig)]));

    Thetapath(:, j) = ThetaVals(thetaDraws);
    PShockpath(:, j) = PShockVals(pshockDraws);
    calRpath(:, j)= calRVals(calRDraws);
    
end
toc

tic
% simulate over all periods? for each household 
for i = 1 : 80
    for j = 1: sim
   
    age = tb + i;
    
  
    if( age < tr) % if age is less than 65 yrs old
    % Interpolate Policy Functions
    % Interpolation over the wealth dimension, the current period theta is
    % known
    
    thetaindx = find(ThetaVals == Thetapath(i, j));
    cvalLifei = griddedInterpolant(wVec, cvalLife_nc(:, thetaindx, i), 'pchip');
    lvalLifei = griddedInterpolant(wVec, lvalLife_nc(:, thetaindx, i), 'pchip');
    pvalLifei = griddedInterpolant(wVec, pvalLife_nc(:, thetaindx, i), 'pchip');
    
    
    % find current period policies given today's wealth and transitory
    % income draw
    
    cpath(i, j) = cvalLifei(wpath(i, j));
    cpath(i, j) = min( cpath(i, j), cupperbound);
    cpath(i, j) = max( cpath(i, j), cplowerbound);
    
    lpath(i, j) = lvalLifei(wpath(i, j));
    lpath(i, j) = min(lpath(i, j), pupperbound); % l & p's upper bound are the same
    lpath(i, j) = max(lpath(i, j), llowerbound);
    

    fcl(i, j) = cpath(i, j) * lpath(i, j)^alpha;
    
    if(lpath(i, j) < 1) % record whether or not this household participate in labor market
        lpartpath(i, j) = 1;
    else
        lpartpath(i, j) = 0;
    end
    
    ppath(i, j) = pvalLifei(wpath(i, j));
    ppath(i, j) = min( ppath(i, j), pupperbound);
    ppath(i, j) = max( ppath(i, j), cplowerbound);
    
    if(ppath(i, j) > 0) % record whether or not this household participate in stock market
        ppartpath(i, j) = 1;
    else
        ppartpath(i, j) = 0;
    end
    
    %update tomorrow's permanent income level since we draw tomorrow's
    % permanent income shock 
    perminc(i + 1, j) = perminc(i, j).*PShockpath(i + 1, j);
    
    
    
   % update end-of-period wealth
   
   
   investret = (1 + (1 - taxc).*(calRpath(i, j).* ppath(i, j) + RFree.*(1 - ppath(i, j)) - 1))./PShockpath(i + 1, j);
  
   
   earnings = (1 - taxl)*(1 - ht(i))*f_y(i).*Thetapath(i, j).*(1 - lpath(i, j));
   savings = wpath(i, j) + earnings - cpath(i, j);
   savings = max(savings, zeros(size(savings)));
   wpath(i + 1, j) = investret.*savings;
  
  
   income(i, j) = earnings.*perminc(i, j);
   consumption(i, j) =  cpath(i, j)*perminc(i, j);
   wealth(i, j) = wpath(i, j)*perminc(i, j);
    
     elseif( age == tr) % if age is equal to 65 yrs old
        
    % Interpolate Policy Functions
    % Interpolation over the wealth dimension, the current period theta is
    % known
    
    thetaindx = find(ThetaVals == Thetapath(i, j));
    cvalLifei = griddedInterpolant(wVec, cvalLife_nc(:, thetaindx, i), 'pchip');
    lvalLifei = griddedInterpolant(wVec, lvalLife_nc(:, thetaindx, i), 'pchip');
    pvalLifei = griddedInterpolant(wVec, pvalLife_nc(:, thetaindx, i), 'pchip');
    
    
    % % find current period policies given today's wealth and transitory
    % income draw
    
    
    cpath(i, j) = cvalLifei(wpath(i, j ));
    cpath(i, j) = min( cpath(i, j), cupperbound);
    cpath(i, j) = max( cpath(i, j), cplowerbound);
    
    lpath(i, j) = lvalLifei(wpath(i, j));
    lpath(i, j) = min(lpath(i, j), pupperbound); % l & p's upper bound are the same
    lpath(i, j) = max(lpath(i, j), llowerbound);
    
    
    fcl(i, j) = cpath(i, j) * lpath(i, j)^alpha;
    
    if(lpath(i, j) < 1) % record whether or not this household participate in labor market
        lpartpath(i, j) = 1;
    else
        lpartpath(i, j) = 0;
    end
    
    ppath(i, j) = pvalLifei(wpath(i, j));
    ppath(i, j) = min( ppath(i, j), pupperbound);
    ppath(i, j) = max( ppath(i, j), cplowerbound);
 
    if(ppath(i, j) > 0) % record whether or not this household participate in stock market
        ppartpath(i, j) = 1;
    else
        ppartpath(i, j) = 0;
    end
    
     % update end-of-period wealth
     
     
   investret = (1 + (1 - taxc).*(calRpath(i, j).* ppath(i, j) + RFree.*(1 - ppath(i, j)) - 1));
   earnings = (1 - taxl)*(1 - ht(i))*f_y(i).*Thetapath(i, j).*(1 - lpath(i, j));
   savings = wpath(i, j) + earnings - cpath(i, j);
   savings = max(savings, zeros(size(savings)));
   wpath(i + 1, j) = investret.*savings;
  

   income(i, j) = earnings.*perminc(i, j);
   consumption(i, j) =  cpath(i, j)*perminc(i, j);
   wealth(i, j) = wpath(i, j)*perminc(i, j);

    else % t > 65
    cvalLifei = griddedInterpolant(wVec, cvalRET(:, age - tr), 'pchip');
    pvalLifei = griddedInterpolant(wVec, pvalRET(:, age - tr), 'pchip');
    
    cpath(i, j) = cvalLifei(wpath(i, j));
    cpath(i, j) = min( cpath(i, j), cupperbound);
    cpath(i, j) = max( cpath(i, j), cplowerbound);
    
    fcl(i, j) = cpath(i, j);
    ppath(i, j) = pvalLifei(wpath(i, j));
    ppath(i, j) = min( ppath(i, j), pupperbound);
    ppath(i, j) = max( ppath(i, j), cplowerbound);
    
    if(ppath(i, j) > 0) % record whether or not this household participate in stock market
        ppartpath(i, j) = 1;
    else
        ppartpath(i, j) = 0;
    end
    
    lpath(i, j) = 1;
    earnings = (1-ht(i))*(1-taxss)*ret_y;
     
    investret = (1 + (1 - taxc).*(calRpath(i, j).* ppath(i, j) + RFree.*(1 - ppath(i, j)) - 1));
    savings = wpath(i, j) + earnings - cpath(i, j);
    savings = max(savings, zeros(size(savings)));
    wpath(i + 1, j) = investret.*savings;
    
    income(i, j) = earnings* perminc(45, j);
    consumption(i, j) = cpath(i, j)* perminc(45, j);
    wealth(i, j) = wpath(i, j) * perminc(45, j);
    end
    end
    
    if(i < 46) % after going through all households for this period, calcupate the population labor market participation rate of this period
    lprate(i, 1) = sum(lpartpath(i, :))/sim; 
    end
    
    clpartpath(i, 1) =  mean(1 - lpath(i, (lpath(i, :) < 1) )); % conditional labor supply
    
    
    pprate(i, 1) = sum(ppartpath(i, :))/sim;
    cppartpath(i, 1) = mean(ppath(i, (ppath(i, :) > 0) )); % conditional stock market participation rate
end
 

cpoppath = mean(cpath, 2);
wpoppath = mean(wpath, 2);
lpoppath = mean(lpath, 2);
ppoppath = mean(ppath, 2);
fclpath = mean(fcl, 2);
incpoppath = mean(income, 2);
wealthpoppath = mean(wealth, 2);
consumptionpath = mean(consumption, 2);
toc
% 
lprate2124 = mean(lprate(1:4, 1))
lprate2534 = mean(lprate(5:14, 1))
lprate3544 = mean(lprate(15:24, 1))
lprate4554 = mean(lprate(25:34, 1))
lprate5565 = mean(lprate(35:45, 1))

% 
% 
% hold on;
% plot(incpoppath(1:79))
% plot(ppoppath)
% plot(lpoppath(1:45))
% plot(fclpath)
agevec =tb + 1: 1:td;
figure;
hold on;
plot(agevec, incpoppath/incpoppath(1), '-d')
plot(agevec, wealthpoppath/incpoppath(1), '-*' )
plot(agevec, consumptionpath/incpoppath(1), '-s')
plot(agevec, fclpath/income(1, 1))
title('No Social Security  (no fixed cost)')
legend('Income','Wealth', 'Consumption', 'F(C, L)')
xlabel('Age') 
% 
% 
figure;
plot(agevec(1:79), savingpoppath(1:79))

% 
figure;
plot(agevec(1:79), ppoppath(1:79))
figure;
plot(agevec(1:45), lpoppath(1:45))
figure;
plot(agevec(1:45), lprate)
figure;
plot(agevec, pprate)

figure;
plot(agevec(1:79),  cdlriskyshare(1:79))
figure;
plot(agevec(1:45),   5200*cdllaborsupply(1:45))
