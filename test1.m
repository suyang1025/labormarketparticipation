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

% Create with two axes
axis1 = getaxis(-1, 1, 20, 'equidistant');
axis2 = getaxis(-1, 1, 20, 'equidistant');
grid = tensorgrid(axis1, axis2);

% Create test function
f = @(x, y) min(1, max(0, sin(pi * x) .* exp(y .^ 2)));

% Initialize the grid
vs = zeros(grid.ns);
for i = 1 : grid.ns(1)
    for j = 1 : grid.ns(2)
        vs(i, j) = f(grid.axes{1}(i), grid.axes{2}(j));
    end
end

% Create interpolated function and the error
g = @(x, y) tensorinterp(grid, vs, [x, y]);
h = @(x, y) f(x, y) - g(x, y);


% display the approximation quality
figure;
subplot(1, 3, 1); ezsurf(f, grid.range);
subplot(1, 3, 2); ezsurf(g, grid.range);
subplot(1, 3, 3); ezsurf(h, grid.range);

% benchmark
n = 1e6;
xs = randn(n, 1);
ys = randn(n, 1);

tic;
g(xs, ys);
fprintf('Vector size: %d, Time spent: %2.8f\n', n, toc);