% Solve for the retirement periods
% Yang Su
% yangsu@uw.edu

tic %(tic tocs are used to measure time used)

%======================
%   Setup Control  Grids
%======================
cgrid = linspace(1, highc, nc);
pgrid = linspace(0, 1, np);
[CR, PR] = ndgrid(cgrid, pgrid);

fvalRET = zeros(length(wVec), length(ssVec), td - tr); 
pvalRET = zeros(length(wVec), length(ssVec), td - tr);
cvalRET = zeros(length(wVec), length(ssVec), td - tr);

rety  = zeros(length(ssVec), 1);


% Solve for the optimal policies for each SS values

%===================================
%   Terminal Period ( i.e. t = 100)
%===================================
for i = 1:length(ssVec) % loop through each SS value
    
    
    rety(i,1) = lambda*ssVec(i);


fvalRET(:, i, td - tr)= u(wVec + (1-ht(80))*(1-taxss)*rety(i, 1), Rho); % given beginning of period wealth,
                                        % the agent will consume all wealth
                                        % plus income in the very last
                                        % period, thus we get the last
                                        % period value function
                                        % I keep the tax rate here
                                        % (changing the tax rate won't
                                        % change much)
                                  

cvalRET(:, i, td - tr) = wVec + (1-ht(80))*(1-taxss)*rety(i, 1);
end

tic
for i = 2:35
    
    t = td - tr - i + 1; %% t goes from 34 to 1 
    currentyr = td - i + 1; %% current age is 99 to 66
    
    for ii = 1:length(ssVec)
        
%          if(ssVec(ii) < 0.2) % given the current state (SS value), retirement income is determined
%             rety(ii, 1) = 0.9*ssVec(ii);
%          elseif(ssVec(ii) < 1 && ssVec(ii) >= 0.2 )
%             rety(ii, 1) = 0.18 + 0.32*ssVec(ii);
%          else
%             rety(ii, 1) = 0.5 + 0.15*ssVec(ii);
%          end

          rety(ii,1) = exp(lambda*log(ssVec(ii))); % a second naive specification: retirement
   % income is a portion of avg of highest 35 year incomes, no bend points
   % involved 

        
        net_income = (1-ht(currentyr - tb))*(1-taxss)*rety(ii); % income is deterministic at each retirement age (I deleted the lambda in here)
        vtplusonei_R = griddedInterpolant(wVec, fvalRET(:, ii, t + 1),  'pchip'); % interpolate given each SS value

    for j = 1:length(wVec) 
        
         if(t == 34)
            lowc = cvalRET(j, ii,  t + 1)/2.5;
            highc = cvalRET(j, ii, t + 1);
            if(wVec(j) >= 50)
                highc = cvalRET(j, ii, t + 1)/1.2;
            end
         elseif(t < 34 && t > 31) 
            lowc = cvalRET(j, ii, t + 1)/3.5;
            highc = cvalRET(j, ii, t + 1);
            if(wVec(j) >= 50)
                highc = cvalRET(j, ii, t + 1)/1.1;
            end
         else % t < 31
            lowc = cvalRET(j, ii, t + 1) - 10;
            highc = cvalRET(j, ii, t + 1) + 10;
          end
     
            lowc2 = ntoi(lowc, 1, cgrid, nc);
            highc2 = ntoi(highc, 1, cgrid, nc);
            cgrid2 = cgrid(1, lowc2 : highc2);
            
            
            lowp2 = 1;
            highp2 = np;
            
         if(wVec(j) > 40 && t < 35) % wealth larger than a tresshold      
            lowp = pvalRET(j, ii, t + 1) - 0.2;
            highp = pvalRET(j, ii, t + 1) + 0.2; 
            lowp2 = ntoi(lowp, 1, pgrid, np);
            highp2 = ntoi(highp, 1, pgrid, np);
         end
         
         pgrid2 = pgrid(1, lowp2 : highp2);
       
        % update the control grid
            [CRN, PRN] = ndgrid(cgrid2, pgrid2);
            [nc2, np2] = size(CRN);  
     
        
        vtnext = 0;  %set initial value of the next period value
        
        savings = (wVec(j) + net_income - CRN); % given the current state grid value, we know all the potential savings over the consumption grid
                                               % savings is updated with
                                               % every state grid value
                                               % return shock value
        savings2 = max(savings, zeros(size(savings)));
        
        ut = ul2(CRN, ones(size(CRN)), Rho, alpha);  
        ut2 = ut.*(savings >0) + infinity.*(savings <= 0); % assign current period utility a very small value when savings are negative
  
        for k = 1:length(calRVals)
            % below is w(t+1) on all control grid points given the current
            % state and one return shock value, the loop goes through each
            % potential return shock points
            
            wtplusone_RET = (1 + (1 - taxc).*(calRVals(k).* PRN + RFree.*(1 - PRN) - 1)).*savings2; %wealth in the next period would be zero if current period savings is negative, this would result in a very small next period value function, so the corresponding consumption would never be chosen
            
             % reshape the w(t+1) matrix (the same size as the control
             % grid) into a column vector in order to get interporlated
             % values
            newwtplusone = reshape(wtplusone_RET, [], 1);
            vtplusone_RET = vtplusonei_R(newwtplusone);
            
              % reshape the interpolated value back to the same size as the
              % control grids 
              
            vtnext = vtnext + weig(1, k).*reshape(vtplusone_RET, nc2, np2);
        end
        
        vt = ut2 + Delta(currentyr - tb).*vtnext; % this is the current period value function corresponds to all the control grids; 
        [val, index] = max(vt(:)); % find the maximun vt value
        fvalRET(j, ii, t) = val; % record the values and we are done for one state grid point! :)
        cvalRET(j, ii, t) = CRN(index);
        pvalRET(j, ii, t) = PRN(index);
    end % after this loop we are done for all wealth state grid values given one SS value
    end
end
toc
