% Solve for optmal choices (consumption, leisure/labor supply and risky
% share) for non retirement periods
% Yang Su

%======================
%  Add another control
%======================
lgrid = linspace(l_underlined, 1, nl);

%=====================================
% Set up empty arrays to store results
%=====================================

fvalLife = zeros(length(wVec), length(ThetaVals), tr - tb); 
lvalLife = zeros(length(wVec), length(ThetaVals), tr - tb);
cvalLife = zeros(length(wVec), length(ThetaVals), tr - tb);
pvalLife = zeros(length(wVec), length(ThetaVals), tr - tb);

% ================================================
% Build a grid of shocks to calculate expectations
% ================================================

[TShock, PShock, RShock] = ndgrid(ThetaVals, PShockVals, calRVals);
[TProb, PProb, RProb] = ndgrid(weig, weig, weig);


for i = 1 : 45
  t = tr - tb - i + 1; %% t goes from 45 to 1      
  % go through each (today's) state grid point
  tic
  cvalLifeCopy = cvalLife(:, :, :);
  pvalLifeCopy = pvalLife(:, :, :);
  if(t == 45)
    tplusonefval = fvalRET(:, 1);
  else
    tplusonefval = fvalLife(:, :, t + 1);
  end
  
  parfor j = 1:length(wVec)
    ctemp = zeros(length(ThetaVals), 1);
    ptemp = zeros(length(ThetaVals), 1);
    ltemp = zeros(length(ThetaVals), 1);
    ftemp = zeros(length(ThetaVals), 1);

    for k = 1:length(ThetaVals)   
      if(t == 45)
        lowc = cvalRET(j, 1) - 10;
        highc = cvalRET(j, 1) + 10;
      elseif(t < 45 && t > 40) % t = 45 to 41
        lowc = cvalLifeCopy(j, k, t + 1) - 8;
        highc = cvalLifeCopy(j, k, t + 1) + 8;
      elseif(t < 41 && t > 31) % t = 40 to 32
        lowc = cvalLifeCopy(j, k, t + 1) - 5;
        highc = cvalLifeCopy(j, k, t + 1) + 5;
      else % t < 32
        lowc = cvalLifeCopy(j, k, t + 1) - 5;
        highc = cvalLifeCopy(j, k, t + 1) + 5;
      end
     
      lowc2 = ntoi(lowc, 1, cgrid, nc);
      highc2 = ntoi(highc, 1, cgrid, nc);
      cgrid2 = cgrid(1, lowc2 : highc2);
        
      if(wVec(j) > 40 && t < 46) % wealth larger than a threshold      
        
        if(t == 45)
          lowp = pvalRET(j, 1) - 0.2;
          highp = pvalRET(j, 1) + 0.2;
        else
          lowp = pvalLifeCopy(j, k, t + 1) - 0.2;
          highp = pvalLifeCopy(j, k, t + 1) + 0.2; 
        end
            
        lowp2 = ntoi(lowp, 1, pgrid, np);
        highp2 = ntoi(highp, 1, pgrid, np);
        pgrid2 = pgrid(1, lowp2 : highp2);
            
      else % for all the rest of the wealth state points
        pgrid2 = pgrid;
      end
       
      % update the control grid
      [CN, PN, LN] = ndgrid(cgrid2, pgrid2, lgrid);
      [nc2, np2, nl2] = size(CN);  
        
      if(t == 45)
        % then get an interporlation of tomorrow's value function
        % when t = 45, value function tomorrow is value function of the
        % first retirement period

        vtplusonei = griddedInterpolant(wVec, tplusonefval, 'pchip');

        % given wage rate today, get (after 
        % tax and after housing expenditure) earnings today on each L grid point 

        earnings = (1 - taxl)*(1-ht(t))*fl_y(t, k).*(1 - LN);

        % given earnings and today's wealth, we can calculate potential 
        % savings over all C(onsumption) grid point

        savings = (wVec(j) + earnings - CN);
        savings2 = max(savings, zeros(size(savings)));
        
        % assign current period utility a very small value when savings are negative
        ut = ul2(CN, LN, Rho, alpha) -fcost.*(LN < 1);
        ut2 = ut.*(savings >0) + infinity.*(savings <= 0); 

        % Start calculate the expected value of the next period 

        evtnext = 0;  %set initial value of the next period value

        for n = 1:length(calRVals)
        % w(t+1) on all control grid points given the current
        % states and one return shock value, the loop goes through each
        % return shock values
            
          investret = 1 + (1 - taxc).*(calRVals(n).* PN + RFree.*(1 - PN) - 1); % after tax investment returns
          wtplusone = investret.*savings2; % wealth in the next period would be zero if current period savings is negative, this would result in a very small next period value function, so the corresponding consumption would never be chosen
            
          % reshape the w(t+1) matrix (the same size as the control
          % grid) into a column vector in order to get interporlated
          % values
             
          newwtplusone = reshape(wtplusone, [], 1);
          vtplusone = vtplusonei(newwtplusone);
            
          % reshape the interpolated value back to the same size as the
          % control grids 
          evtnext = evtnext + weig(1, n).*reshape(vtplusone, nc2, np2, nl2);
        end
        
        vt = ut2 + Delta(t).*evtnext; % this is the current period value function corresponds to all the control grids; 
        
        [val, index] = max(vt(:)); % find the maximun vt value  
        
        ftemp(k, 1) = val; % record the values and we are done for one state grid point! :)
        ctemp(k, 1) = CN(index);
        ptemp(k, 1) = PN(index);
        ltemp(k, 1) = LN(index);
    
      else       
         
        % given wage rate (ThetaVals) today, get earnings today on each L grid point 
        earnings = (1 - taxl)*(1 - ht(t))*fl_y(t, k).*(1 - LN);
  
        % given earnings and today's wealth, we can calculate potential 
        % savings over all possible C grid point
    
        savings = (wVec(j) + earnings - CN);                                       
        savings2 = max(savings, zeros(size(savings)));

        % assign current period utility a very small value when savings are negative
        ut = ul2(CN, LN, Rho, alpha)  - fcost.*(LN < 1);
        ut2 = ut.*(savings >0) + infinity.*(savings <= 0); 
            
        % now find the expected value function for t + 1
        % expectations are taken over three "shocks": stock returns,
        % transotry income shocks (ThetaVals) and permanent income shocks
        
        % set initial expected value function to be zero
        
        evtplusone = 0; 
            
          for n = 1: numel(TShock)
                
            investret = (1 + (1 - taxc).*(RShock(n).* PN + RFree.*(1 - PN) - 1))./PShock(n);
            wtplusone = investret.*savings2; % wealth in the next period would be zero if current period savings is negative, this would result in a very small next period value function, so the corresponding consumption would never be chosen

            % reshape the w(t+1) matrix (the same size as the control
            % grid) into a column vector in order to get interporlated
            % values
            newwtplusone = reshape(wtplusone(:, :, :), [], 1);

            thetaindx = find(TShock(n) == ThetaVals);
            vtplusonei = griddedInterpolant(wVec, tplusonefval(:, thetaindx, 1), 'pchip');
            vt1 =  vtplusonei(newwtplusone);
            vt11 = reshape(vt1, nc2, np2, nl2);
            weight = TProb(n)*PProb(n)*RProb(n);
            evtplusone  =  evtplusone + weight*(PShock(n)^(1-Rho)).*vt11;
          end
         
          vt = ut2 + Delta(t).*evtplusone; % this is the current period value function corresponds to all the control grids; 
          [val, index] = max(vt(:)); % find the maximun vt value
          ftemp(k, 1) = val; % record the values and we are done for one state grid point! :)
          ctemp(k, 1) = CN(index);
          ptemp(k, 1) = PN(index);
          ltemp(k, 1) = LN(index);
      end
 
    end
    
  fvalLife(j, :, t) = ftemp(:, 1);
  cvalLife(j, :, t) = ctemp(:, 1);
  pvalLife(j, :, t) = ptemp(:, 1);
  lvalLife(j, :, t) = ltemp(:, 1); 
  end
  toc
end  



   
 