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

fvalLife_nc = zeros(length(wVec), length(ThetaVals), tr - tb); 
lvalLife_nc = zeros(length(wVec), length(ThetaVals), tr - tb);
cvalLife_nc = zeros(length(wVec), length(ThetaVals), tr - tb);
pvalLife_nc = zeros(length(wVec), length(ThetaVals), tr - tb);

% =====================================
% Build a grid of shocks to calculate epxectations
% =====================================

[TShock, PShock, RShock] = ndgrid(ThetaVals, PShockVals, calRVals);
[TProb, PProb, RProb] = ndgrid(weig, weig, weig);


for i = 1 : 45
    tic
    t = tr - tb - i + 1; %% t goes from 45 to 1 
        
      % go through each (today's) state grid point
     for j = 1:length(wVec) 
     for k = 1:length(ThetaVals)
         
          if(t == 45)
            lowc = cvalRET(j, 1) - 10;
            highc = cvalRET(j, 1) + 10;
         elseif(t < 45 && t > 40) % t = 45 to 41
            lowc = cvalLife_nc(j, k, t + 1) - 8;
            highc = cvalLife_nc(j,k, t + 1) + 8;
         elseif(t < 41 && t > 31) % t = 40 to 32
            lowc = cvalLife_nc(j, k, t + 1) - 5;
            highc = cvalLife_nc(j, k, t + 1) + 5;
         else % t < 32
            lowc = cvalLife_nc(j, k, t + 1) - 5;
            highc = cvalLife_nc(j, k, t + 1) + 5;
          end
     
            lowc2 = ntoi(lowc, 1, cgrid, nc);
            highc2 = ntoi(highc, 1, cgrid, nc);
            cgrid2 = cgrid(1, lowc2 : highc2);
        
   
         if(wVec(j) > 40 && t < 46) % wealth larger than a threshold      
            if(t == 45)
            lowp = pvalRET(j, 1) - 0.2;
            highp = pvalRET(j, 1) + 0.2;
            else
            lowp = pvalLife_nc(j, k, t + 1) - 0.2;
            highp = pvalLife_nc(j, k, t + 1) + 0.2; 
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
            
        vtplusonei = griddedInterpolant(wVec, fvalRET(:, 1), 'pchip');
                
           % given wage rate today, get (after 
           % tax and after housing expenditure) earnings today on each L grid point 
        
            earnings = (1 - taxl)*(1-ht(t))*fl_y(t, k).*(1 - LN);
            
           % given earnings and today's wealth, we can calculate potential 
           % savings over all C(onsumption) grid point
        
            savings = (wVec(j) + earnings - CN);
            savings2 = max(savings, zeros(size(savings)));
        
          % assign current period utility a very small value when savings are negative
            ut_nc = ul2(CN, LN, Rho, alpha);
            ut_nc2 = ut_nc.*(savings >0) + infinity.*(savings <= 0); 
            
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
        
        vt_nc = ut_nc2 + Delta(t).*evtnext; % this is the current period value function corresponds to all the control grids; 
        
        [val_nc, index] = max(vt_nc(:)); % find the maximun vt value
        fvalLife_nc(j, k, t) = val_nc; % record the values and we are done for one state grid point! :)
        cvalLife_nc (j, k, t) = CN(index);
        pvalLife_nc(j, k, t) = PN(index);
        lvalLife_nc(j, k, t) = LN(index);
        
      else       
         
        % given wage rate (ThetaVals) today, get earnings today on each L grid point 
        earnings = (1 - taxl)*(1 - ht(t))*fl_y(t, k).*(1 - LN);
  
        % given earnings and today's wealth, we can calculate potential 
        % savings over all possible C grid point
    
        savings = (wVec(j) + earnings - CN);
                                               
        savings2 = max(savings, zeros(size(savings)));

        % assign current period utility a very small value when savings are negative
        
        ut_nc = ul2(CN, LN, Rho, alpha);
        ut_nc2 = ut_nc.*(savings >0) + infinity.*(savings <= 0); 
     
        
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
                  vtplusonei = griddedInterpolant(wVec, fvalLife_nc(:, thetaindx, t + 1), 'pchip');
                  vt1 =  vtplusonei(newwtplusone);
                  vt11 = reshape(vt1, nc2, np2, nl2);
                  weight = TProb(n)*PProb(n)*RProb(n);
                  evtplusone  =  evtplusone + weight*(PShock(n)^(1-Rho)).*vt11;
            end
         
            vt_nc = ut_nc2 + Delta(t).*evtplusone; % this is the current period value function corresponds to all the control grids; 
            [val_nc, index1] = max(vt_nc(:)); % find the maximun vt value
            fvalLife_nc(j, k, t) = val_nc; % record the values and we are done for one state grid point! :)
            cvalLife_nc (j, k, t) = CN(index1);
            pvalLife_nc(j, k, t) = PN(index1);
            lvalLife_nc(j, k, t) = LN(index1);
    
      end
     end
     end

      toc
end
 