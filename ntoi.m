function ntoi = ntoi(value, nrow, grid, n)
%==========================================================================%          
% THIS FUNCTION IS AN ADAPTATION OF CGM (2005)'S NTOI ROUNTINE
% THE ORIGINAL CODE WAS WRITTEN IN FORTRAN
% yangsu@uw.edu  
% 
% NTOI returns the position (distrance between the point and
% the first point of the gird) of a point on a grid vector
% Inputs: 
% 1. value takes in the value
% 2. nrow takes the number of rows of the value (i.e. the value could be a
% vector
% 3. grid is the grid vector (a row vector)
% 4. n is # of points in the grid
% 
% Output gives you the position of the value
%__________________________________________________________________________%
aux = min(value, grid(1, n)); % insure the value is less than the maximum of the grid vector
aux = max(aux, grid(1, 1)); % insure the value is larger than the minium of the grid vector

step = (grid(1, n) - grid(1, 1))/(n - 1); % calculate the distance of each point on the grid vector
vectorofones = ones(nrow, 1);

ntoi = round((aux - grid(1, 1).*vectorofones)./step + vectorofones, 0);


end