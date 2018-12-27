% Copyright (c) 2013 Vasily Kartashov <info@kartashov.com>
%
% Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
% documentation files (the "Software"), to deal in the Software without restriction, including without limitation the
% rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
% permit persons to whom the Software is furnished to do so, subject to the following conditions:
%
% The above copyright notice and this permission notice shall be included in all copies or substantial portions of the
% Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
% WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
% COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
% OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

function dispgrid(grid, dims)

    if numel(dims) ~= 2
        error('dispgrid: Can only show exactly 2 dimensions');
    end

    % extract the grid
    grid = tensorgrid(grid.axes{dims});

    % displays 2 dimensional grid
    points = zeros(prod(grid.ns), 2);
    k = 1;
    
    for i1 = 1 : grid.ns(1)
        for i2 = 1 : grid.ns(2)
            points(k, :) = [grid.axes{1}(i1), grid.axes{2}(i2)];
            k = k + 1;
        end
    end
    
    figure;
    scatter(points(:, 1), points(:, 2));
    
end

