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

function points = getaxis(lb, ub, n, scale)

    % special case of chebyshev points
    if ~iscell(scale)
        if strcmpi(scale, 'chebyshev')
            nodes = cos((2 * (n : -1 : 1)' - 1) * pi / 2 / n);
            points = lb + (ub - lb) * (nodes + 1) / 2;
            return;
        end
    end

    % special case with parametrized polynomial
    if iscell(scale)
        if strcmpi(scale{1}, 'polynomial')
            f = @(x) x .^ scale{2};
        else
            error('unknown grid type: %s', scale{1});
        end
    else
        if strcmpi(scale, 'equidistant')
            f = @(x) x;
        elseif strcmpi(scale, 'quadratic')
            f = @(x) x .^ 2;
        elseif strcmpi(scale, 'cubic')
            f = @(x) x .^ 3;
        elseif strcmpi(scale, 'exponential')
            f = @(x) (exp(x) - exp(0)) / (exp(1) - exp(0));
        elseif strcmpi(scale, 'double-exponential')
            f = @(x) (exp(exp(x)) - exp(exp(0))) / (exp(exp(1)) - exp(exp(0)));
        elseif strcmpi(scale, 'triple-exponential')
            f = @(x) (exp(exp(exp(x))) - exp(exp(exp(0)))) / (exp(exp(exp(1))) - exp(exp(exp(0))));
        else
            error('unknown grid type: %s', scale);
        end
    end
    
    % realative offset on normal scale
    offsets = (0 : n - 1)' / (n - 1);
    
    % transformed offset
    % 0 and 1 stay fixed points
    % generate the grid
    points = f(offsets) * (ub - lb) + lb;
    
end