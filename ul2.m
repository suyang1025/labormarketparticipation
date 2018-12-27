function ul2 = ul2(c,l, Rho, Alpha)
%==========================================================================%          
% CRRA utility function with (spefical form) Cobb-Douglas labor supply            
%                                                                          %
%   Inputs:                                                                %
%       c - consumption level  
%       l - leisure level
%       Rho - coefficient of relative risk aversion  
%       Alpha - relative importance of leisure
%   Outputs:                                                               %
%       ul - value of utility given consumption c and leisure l
%
%                                                                          %
%__________________________________________________________________________%

if Rho==1
    ul2 =log(c.*(l.^Alpha));
else
    ul2 = (c.*(l.^Alpha)).^(1-Rho)./(1-Rho);
end
    
end
