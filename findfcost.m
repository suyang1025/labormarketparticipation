% A loop to match simulated labor market participaton rate with the data


datalprate = 0.829; 
tol = 0.1;
simlprate = 1;
fcost =  8e-06; 
step = 2*10^(-7);
trail = 0;

while abs(simlprate - datalprate) > tol
    fcost = fcost - step;
    trail = trail + 1;
    mainSS;
end
    



datalprate = 0.829; 
tol = 0.01;
simlprate = 0.7725;
fcost =  3.14e-06; 
step = 1*10^(-7);
trail = 0;

while abs(simlprate - datalprate) > tol
    fcost = fcost - step;
    trail = trail + 1;
    main_withbounds;
end
    

