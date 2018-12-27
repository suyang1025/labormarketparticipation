% Simulate a population of households
% Yang Su

% Define parameters and empty arrays
sim = 10000;     % number of households to simulate

cpath = zeros(td - tb, sim);
wpath = zeros(td - tb, sim);
lpath = zeros(td - tb, sim);
ppath = zeros(td - tb, sim);
SSpath = zeros(td - tb, sim);
lpartpath = zeros(td - tb, sim);
ppartpath = zeros(td - tb, sim);
 savepath = zeros(td - tb, sim);
Thetapath = zeros (tr - tb, sim);
PShockpath = zeros (tr - tb, sim);
calRpath = zeros (td - tb, sim);

cdlriskyshare = zeros(td - tb, 1); % conditional stock market participation rate (condition on positive saving)
cdllaborsupply = zeros(td - tb, 1); % conditional labor supply
fcl = zeros(td - tb, sim); % keep track of the consumption and leisure ratio

lprate = zeros(tr - tb, 1);
pprate = zeros(td - tb, 1);

% Initial Wealth Distributions 
% 
wpath(1, :) = lognrnd(0.988, 1.370, 1, sim);
   
llowerbound = l_underlined;
cplowerbound = 0;
cupperbound = highc;
pupperbound = 1;

perminc = ones(tr - tb, sim); 
perminc(1, :) = lognrnd(1, 0.512, 1, sim);



% income, consumption and wealth srecord the un-normalized consumption and wealth
income = ones(td - tb, sim); 
consumption = zeros (td - tb, sim);
wealth = zeros (td - tb, sim);
socialsecurity = zeros (td - tb, sim);
% first for each household j, generate the shocks that they are going to
% face over the life cycle

for j = 1:sim % go through each household
    
    [~,thetaDraws] = histc(rand(tr - tb, 1),cumsum([0;weig(:)./sum(weig)]));
    [~,pshockDraws] = histc(rand(tr - tb, 1),cumsum([0;weig(:)./sum(weig)]));
    [~,calRDraws] = histc(rand(td - tb, 1),cumsum([0;weig(:)./sum(weig)])); % note to myself: this draws riksy returns for the next period

    Thetapath(:, j) = ThetaVals(thetaDraws);
    PShockpath(:, j) = PShockVals(pshockDraws);
    calRpath(:, j)= calRVals(calRDraws);
    
end

SSpath(1, :) = 0; % assume initial ss value equals zero


% simulate over all periods? for each household 
for i = 1 : 80
    for j = 1: sim
   
    age = tb + i;
    
  
    if( age < tr) % if age is less than 65 yrs old
        
    % Interpolate Policy Functions
    % Interpolation over the wealth dimension, the current period theta is
    % known
    
    thetaindx = find(ThetaVals == Thetapath(i, j));
    cvalLifei = griddedInterpolant(WW, SS, cvalLife(:, :, thetaindx, i));
    lvalLifei = griddedInterpolant(WW, SS, lvalLife(:, :, thetaindx, i));
    pvalLifei = griddedInterpolant(WW, SS, pvalLife(:, :, thetaindx, i));
    
    
    % find current period policies given today's wealth and transitory
    % income draw as well as an initial SS value
    cpath(i, j) = cvalLifei(wpath(i, j), SSpath(i, j));
    cpath(i, j) = max( cpath(i, j), cplowerbound);
    
    lpath(i, j) = lvalLifei(wpath(i, j), SSpath(i, j));
    lpath(i, j) = min(lpath(i, j), pupperbound); % l & p's upper bound are the same
    lpath(i, j) = max(lpath(i, j), llowerbound);
      
    if(lpath(i, j) < 1) % record whether or not this household participate in labor market
        lpartpath(i, j) = 1;
    else
        lpartpath(i, j) = 0;
    end
    
    % Given today's laobor supply, we know today's earnings
   earnings = (1 - taxl)*(1 - ht(i))*f_y(i).*Thetapath(i, j).*(1 - lpath(i, j));
   % We also know today's savings, but if saving < 0, restrict it to be
   % zero, and update today's consumption value
   savings = wpath(i, j) + earnings - cpath(i, j);
   
   if(savings < 0)
       cpath(i, j) = wpath(i, j) + earnings;
       savings = 0; 
   end
   
    fcl(i, j) = cpath(i, j) * lpath(i, j)^alpha;
    
    ppath(i, j) = pvalLifei(wpath(i, j), SSpath(i, j));
    ppath(i, j) = min( ppath(i, j), pupperbound);
    ppath(i, j) = max( ppath(i, j), cplowerbound);
    
     if(ppath(i, j) > 0) % record whether or not this household participate in stock market
        ppartpath(i, j) = 1;
    else
        ppartpath(i, j) = 0;
     end
    
   
   % update end-of-period/ beginning of next period wealth
   investret = (1 + (1 - taxc).*(calRpath(i, j).* ppath(i, j) + RFree.*(1 - ppath(i, j)) - 1))./PShockpath(i + 1, j);
   wpath(i + 1, j) = investret.*savings;

   % update un-normalized income, consumption, and wealth
   income(i, j) = earnings.*perminc(i, j);
   consumption(i, j) =  cpath(i, j)*perminc(i, j);
   wealth(i, j) = wpath(i, j)*perminc(i, j);
   socialsecurity(i, j) = SSpath(i, j)*perminc(i, j);

 
   if(age < 56)
    SSpath(i + 1, j) = SSpath(i, j)/PShockpath(i + 1, j) + ((f_y(i)*Thetapath(i, j)*(1 - lpath(i, j)))/35)/PShockpath(i + 1, j);
   else
    SSpath(i + 1, j) = SSpath(i, j)/PShockpath(i + 1, j) + max(0, ((f_y(i)*Thetapath(i, j)*(1 - lpath(i, j)) - SSpath(i, j))/35)/PShockpath(i + 1, j));
   end
   
    % update tomorrow's permanent income level since we draw tomorrow's
    % permanent income shock 
    perminc(i + 1, j) = perminc(i, j).*PShockpath(i + 1, j);

       elseif( age == tr) % if age is equal to 65 yrs old
        
    % Interpolate Policy Functions
    % Interpolation over the wealth dimension, the current period theta is
    % known
    
    thetaindx = find(ThetaVals == Thetapath(i, j));
    cvalLifei = griddedInterpolant(WW, SS, cvalLife(:, :, thetaindx, i));
    lvalLifei = griddedInterpolant(WW, SS, lvalLife(:, :, thetaindx, i));
    pvalLifei = griddedInterpolant(WW, SS, pvalLife(:, :, thetaindx, i));
    
    
    % % find current period policies given today's wealth and transitory
    % income draw
    
    
    cpath(i, j) = cvalLifei(wpath(i, j ), SSpath(i, j));
    cpath(i, j) = max( cpath(i, j), cplowerbound);
    
    lpath(i, j) = lvalLifei(wpath(i, j), SSpath(i, j));
    lpath(i, j) = min(lpath(i, j), pupperbound); % l & p's upper bound are the same
    lpath(i, j) = max(lpath(i, j), llowerbound);
    
     % Given today's laobor supply, we know today's earnings
    earnings = (1 - taxl)*(1 - ht(i))*f_y(i).*Thetapath(i, j).*(1 - lpath(i, j));
    % We also know today's savings, but if saving < 0, restrict it to be
    % zero, and update today's consumption value
    savings = wpath(i, j) + earnings - cpath(i, j);
   
   if(savings < 0)
       cpath(i, j) = wpath(i, j) + earnings;
       savings = 0; 
   end
   
    fcl(i, j) = cpath(i, j) * lpath(i, j)^alpha;
    
    if(lpath(i, j) < 1) % record whether or not this household participate in labor market
        lpartpath(i, j) = 1;
    else
        lpartpath(i, j) = 0;
    end
    
    ppath(i, j) = pvalLifei(wpath(i, j), SSpath(i, j));
    ppath(i, j) = min( ppath(i, j), pupperbound);
    ppath(i, j) = max( ppath(i, j), cplowerbound);
    
     if(ppath(i, j) > 0) % record whether or not this household participate in stock market
        ppartpath(i, j) = 1;
    else
        ppartpath(i, j) = 0;
     end
    
    
   income(i, j) = earnings.*perminc(i, j);
   consumption(i, j) =  cpath(i, j)*perminc(i, j);
   wealth(i, j) = wpath(i, j)*perminc(i, j);
   socialsecurity(i, j) = SSpath(i, j)*perminc(i, j);
    
     % update end-of-period wealth
     
   investret = (1 + (1 - taxc).*(calRpath(i, j).* ppath(i, j) + RFree.*(1 - ppath(i, j)) - 1));
   wpath(i + 1, j) = investret.*savings;
   SSpath(i + 1, j) = SSpath(i, j) + max(0, (f_y(i)*Thetapath(i, j)*(1 - lpath(i, j)) - SSpath(i, j))/35);%no need to devide by permenant shock here

    else % t > 65
    cvalLifei = griddedInterpolant(WW, SS, cvalRET(:, :, age - tr));
    pvalLifei = griddedInterpolant(WW, SS, pvalRET(:, :, age - tr));
    
    
    cpath(i, j) = cvalLifei(wpath(i, j), SSpath(i, j));
    cpath(i, j) = max( cpath(i, j), cplowerbound);
    
    fcl(i, j) = cpath(i, j);
     
    ppath(i, j) = pvalLifei(wpath(i, j), SSpath(i, j));
    ppath(i, j) = min( ppath(i, j), pupperbound);
    ppath(i, j) = max( ppath(i, j), cplowerbound);
    
     if(ppath(i, j) > 0) % record whether or not this household participate in stock market
        ppartpath(i, j) = 1;
    else
        ppartpath(i, j) = 0;
     end
     
    if(SSpath(i, j) < 0.2)
    rety = 0.9*SSpath(i, j);
    elseif(SSpath(i, j) < 1 && SSpath(i, j) >= 0.2 )
     rety = 0.18 + 0.32*SSpath(i, j);
    else
     rety = 0.5 + 0.15*SSpath(i, j);
    end

    
    lpath(i, j) = 1;
    earnings = (1-ht(i))*(1-taxss)*rety;
    savings = wpath(i, j) + earnings - cpath(i, j);
    if(savings < 0)
       cpath(i, j) = wpath(i, j) + earnings;
       savings = 0; 
   end
   
    investret = (1 + (1 - taxc)*(calRpath(i, j)* ppath(i, j) + RFree*(1 - ppath(i, j)) - 1));
    wpath(i + 1, j) = investret.*savings;
    SSpath(i + 1, j) = SSpath(i, j);
    
    income(i, j) = earnings* perminc(45, j);
    consumption(i, j) = cpath(i, j)* perminc(45, j);
    wealth(i, j) = wpath(i, j) * perminc(45, j);
    socialsecurity(i, j) = SSpath(i, j)*perminc(45, j);
    
    
    end
    end
    
    if(i < 46) % after going through all households for this period, calcupate the population labor market participation rate of this period
    lprate(i, 1) = sum(lpartpath(i, :))/sim; 
    end
    
    pprate(i, 1) = sum(ppartpath(i, :))/sim;
    cdllaborsupply(i, 1) =  mean(1 - lpath(i, (lpath(i, :) < 1) )); % conditional labor supply
    cdlriskyshare(i, 1) = mean(ppath(i, (ppath(i, :) > 0) )); % conditional stock market participation rate

end
 

cpoppath = mean(cpath, 2); 
wpoppath = mean(wpath, 2);
lpoppath = mean(lpath, 2);
ppoppath = mean(ppath, 2);
fclpath = mean(fcl, 2);
incpoppath = mean(income, 2);
wealthpoppath = mean(wealth, 2);
consumptionpath = mean(consumption, 2);
sspoppath = mean(socialsecurity, 2);

lprate2124 = mean(lprate(1:4, 1));
lprate2534 = mean(lprate(5:14, 1));
lprate3544 = mean(lprate(15:24, 1));
lprate4554 = mean(lprate(25:34, 1));
lprate5565 = mean(lprate(35:45, 1));

simlprate = mean(lprate(4:34, 1));
