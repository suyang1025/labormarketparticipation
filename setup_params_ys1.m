%==========================================================================%
% Baseline Parameter values 
% Yang Su  
% yangsu@uw.edu
%__________________________________________________________________________%

Rho     = 5;                                %(* Coefficient of Relative Risk Aversion *)
Beta    = 0.97;                             %(* Discount factor *)
alpha   = 0.7;                              %(* Relative importance of leisure *)
RFree   = 1.02;                             %(* Gross interest rate *)


fcost = 3.14*10^(-6);                       %(* Utility cost of labor market participation
                                            %(* x means labor market
                                            %(* participation cost is x% of
                                            %(* permanent income *)


                                             
l_underlined = 1/3;                         %(* minimum leisure level *)

tb = 20;
tr = 65;
td = 100;                                   %(* length of years the agent lives *)

infinity = -1e+20;                          %(* my definition of a "very small number" *)

lambda = 0.68212;                           %(* replacement ratio *)


taxl = 0.3;                                 %(* tax rates *)
taxss = 0.15;
taxc = 0.2;

wMin    = 0.1;                                %(* Minimum point in wVec *)
wMax    = 400;                              %(* Maximum point in wVec *)

nc = 1500;                                  %(* number of control grids *)
np = 100;
nl = 80;

highc = 375;                                %(* maximum consumption value *)


sigma_t = 0.1389;                           %(* std dev of transitory income shocks *)
sigma_p = 0.1095;                           %(* std dev of permanent income shocks *)