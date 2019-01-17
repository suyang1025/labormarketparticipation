% Solve for the retirement periods
% Yang Su
% yangsu@uw.edu
%======================
%   Setup Control  Grids
%======================
cgrid = linspace(0, highc, nc);
pgrid = linspace(0, 1, np);
[CR, PR] = ndgrid(cgrid, pgrid);

fvalRET = zeros(lengthWVec, td - tr); 
pvalRET = zeros(lengthWVec, td - tr);
cvalRET = zeros(lengthWVec, td - tr);

%===================================
%   Terminal Period ( i.e. t = 100)
%===================================
fvalRET(:, td - tr)= u(wVec + (1-ht(80))*(1-taxss)*ret_y, Rho); % given beginning of period wealth,
                                        % the agent will consume all wealth
                                        % plus income in the very last
                                        % period, thus we get the last
                                        % period value function

cvalRET(:, td - tr) = wVec + (1-ht(80))*(1-taxss)*ret_y;


for i = 2:35
    tic
    t = td - tr - i + 1; %% t goes from 34 to 1 
    currentyr = td - i + 1; %% current age is 99 to 66
    
    net_income = (1 - ht(currentyr - tb))*(1 - taxss)*ret_y; % income is deterministic at each retirement age
    vtplusonei_R = griddedInterpolant(wVec, fvalRET(:, t + 1),  'pchip'); 

    for j = 1:length(wVec) 
        
         if(t == 34)
            lowc = cvalRET(j, t + 1)/2.5;
            highc = cvalRET(j, t + 1);
            if(wVec(j) >= 50)
                highc = cvalRET(j, t + 1)/1.2;
            end
         elseif(t < 34 && t > 31) 
            lowc = cvalRET(j, t + 1)/3.5;
            highc = cvalRET(j, t + 1);
            if(wVec(j) >= 50)
                highc = cvalRET(j, t + 1)/1.1;
            end
         else % t < 31
            lowc = cvalRET(j, t + 1) - 10;
            highc = cvalRET(j, t + 1) + 10;
          end
     
            lowc2 = ntoi(lowc, 1, cgrid, nc);
            highc2 = ntoi(highc, 1, cgrid, nc);
            cgrid2 = cgrid(1, lowc2 : highc2);
            
            
            lowp2 = 1;
            highp2 = np;
            
         if(wVec(j) > 40 && t < 35) % wealth larger than a threshold      
            lowp = pvalRET(j, t + 1) - 0.5;
            highp = pvalRET(j, t + 1) + 0.5; 
            lowp2 = ntoi(lowp, 1, pgrid, np);
            highp2 = ntoi(highp, 1, pgrid, np);
         end
         
         pgrid2 = pgrid(1, lowp2 : highp2);
       
        % update the control grid
            [CRN, PRN] = ndgrid(cgrid, pgrid);
            [nc2, np2] = size(CRN);  
     
        
        savings = (wVec(j) + net_income - CRN); % given the current state grid value, we know all the potential savings over the consumption grid
                                               % savings is updated with
                                               % every state grid value
                                               % return shock value
        savings2 = max(savings, zeros(size(savings)));
        
        ut = ul2(CRN, ones(size(CRN)), Rho, alpha);  
        ut2 = ut.*(savings >0) + infinity.*(savings <= 0); % assign current period utility a very small value when savings are negative
        
        vtnext = 0;  %set initial value of the next period value
        
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
        fvalRET(j, t) = val; % record the values and we are done for one state grid point! :)
        cvalRET(j, t) = CRN(index);
        pvalRET(j, t) = PRN(index);
    end
    
  toc   
end

