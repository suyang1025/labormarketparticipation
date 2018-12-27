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

fvalLife = zeros(length(wVec), length(ssVec), length(ThetaVals), tr - tb); % four state valuables (wealth, SS, Theta, and time)
lvalLife = zeros(length(wVec), length(ssVec), length(ThetaVals), tr - tb);
cvalLife = zeros(length(wVec), length(ssVec), length(ThetaVals), tr - tb);
pvalLife = zeros(length(wVec), length(ssVec), length(ThetaVals), tr - tb);

% ================================================
% Build a grid of shocks to calculate expectations
% ================================================

[TShock, PShock, RShock] = ndgrid(ThetaVals, PShockVals, calRVals);
[TProb, PProb, RProb] = ndgrid(weig, weig, weig);

[WW, SS] = ndgrid(wVec, ssVec);

for i = 1 : 2
    tic
    t = tr - tb - i + 1; %% t goes from 45 to 1 
        
      % go through each (today's) state grid point
     for j = 1:length(wVec) 
     for jj = 1:length(ssVec)
     for k = 1:length(ThetaVals)
         
          if(t == 45)
            lowc = 0.3*cvalRET(j, jj, 1);
            highc = cvalRET(j,jj, 1) + 10;
         elseif(t < 45 && t > 40) % t = 45 to 41
            lowc = cvalLife(j, jj, k, t + 1) - 5;
            highc = cvalLife(j, jj, k, t + 1) + 5;
         elseif(t < 41 && t > 31) % t = 40 to 32
            lowc = cvalLife(j, jj, k, t + 1) - 5;
            highc = cvalLife(j, jj, k, t + 1) + 5;
         else % t < 32
            lowc = cvalLife(j, jj, k, t + 1) - 5;
            highc = cvalLife(j, jj, k, t + 1) + 5;
          end
     
            lowc2 = ntoi(lowc, 1, cgrid, nc);
            highc2 = ntoi(highc, 1, cgrid, nc);
            cgrid2 = cgrid(1, lowc2 : highc2);
        
   
  
            if(t == 45 && wVec(j) > 40)
            lowp = pvalRET(j, jj, 1) - 0.2;
            highp = pvalRET(j, jj, 1) + 0.2;
            
            lowp2 = ntoi(lowp, 1, pgrid, np);
            highp2 = ntoi(highp, 1, pgrid, np);
            pgrid2 = pgrid(1, lowp2 : highp2);
            
            elseif(t < 45 && wVec(j) > 40)
            lowp = pvalLife(j, jj, k, t + 1) - 0.2;
            highp = pvalLife(j, jj, k, t + 1) + 0.2; 
            
            lowp2 = ntoi(lowp, 1, pgrid, np);
            highp2 = ntoi(highp, 1, pgrid, np);
            pgrid2 = pgrid(1, lowp2 : highp2);
            else
            pgrid2 = pgrid;
            end
            
           
            
        % update the control grid
            [CN, PN, LN] = ndgrid(cgrid2, pgrid2, lgrid);
            [nc2, np2, nl2] = size(CN);  
        
             
      if(t == 45)
        
            % then get an interporlation of tomorrow's value function
            % when t = 45, value function tomorrow is value function of the
            % first retirement period
            
           vtplusonei = griddedInterpolant(WW, SS, fvalRET(:, :, 1), 'linear', 'nearest'); 
                
           % given wage rate today, get (after 
           % tax and after housing expenditure) earnings today on each L grid point 
        
            earnings = (1 - taxl)*(1-ht(t))*fl_y(t, k).*(1 - LN);
            
            % Also, given today's income, update the next period SS level
            % (might change to pre tax income)
            sstplusone = ssVec(jj) + max(0, (fl_y(t, k).*(1 - LN) - ssVec(jj))/35);
            newsstplusone = reshape(sstplusone, [], 1);
            
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
             
            vtplusone = vtplusonei(newwtplusone, newsstplusone);
            
             % reshape the interpolated value back to the same size as the
             % control grids 
            evtnext = evtnext + weig(1, n).*reshape(vtplusone, nc2, np2, nl2);
            end
        
        vt = ut2 + Delta(t).*evtnext; % this is the current period value function corresponds to all the control grids; 
        
        [val, index] = max(vt(:)); % find the maximun vt value
        fvalLife(j, jj, k, t) = val; % record the values and we are done for one state grid point! :)
        cvalLife (j, jj, k, t) = CN(index);
        pvalLife(j, jj, k, t) = PN(index);
        lvalLife(j, jj, k, t) = LN(index);
        
      else       
         
        % given wage rate (ThetaVals) today, get earnings today on each L grid point 
        earnings = (1 - taxl)*(1 - ht(t))*fl_y(t, k).*(1 - LN);
        
            
                    % update the next period SS level
                    % (might change to pre tax income)
                     if(t > 55)
                     sstplusone = (ssVec(jj) + max(0, (fl_y(t, k).*(1 - LN) - ssVec(jj))./35));
                     else %in the first 35 years of working age, SS monotonically increase
                     sstplusone = (ssVec(jj) + (fl_y(t, k).*(1 - LN))./35);
                     end
                    newsstplusone = reshape(sstplusone, [], 1); % note this value is not fully normalized 
        
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
                    newsstplusone2 = newsstplusone./PShock(n);
                   
            
                  thetaindx = find(TShock(n) == ThetaVals);
                  vtplusonei = griddedInterpolant(WW, SS, fvalLife(:, :, thetaindx, t + 1), 'linear', 'nearest');
                  vt1 =  vtplusonei(newwtplusone, newsstplusone2);
                  vt11 = reshape(vt1, nc2, np2, nl2);
                  weight = TProb(n)*PProb(n)*RProb(n);
                  evtplusone  =  evtplusone + weight*(PShock(n)^(1-Rho)).*vt11;
            end
         
            vt = ut2 + Delta(t).*evtplusone; % this is the current period value function corresponds to all the control grids; 
            [val, index1] = max(vt(:)); % find the maximun vt value
            fvalLife(j, jj, k, t) = val; % record the values and we are done for one state grid point! :)
            cvalLife (j, jj, k, t) = CN(index1);
            pvalLife(j, jj, k, t) = PN(index1);
            lvalLife(j, jj, k, t) = LN(index1);
    
      end
     end
         end
     end
   
       toc 
end
  

   
 