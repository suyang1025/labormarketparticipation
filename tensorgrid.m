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

function grid = tensorgrid(varargin)

    grid = [];
    
    % the number of dimensions
    grid.dims = nargin;
    
    % get the axes and inverse of cell length
    grid.axes = varargin;
    
    grid.hss = cell(size(axes));
    grid.iss = cell(size(axes));
    
    grid.ns = zeros(1, grid.dims);
    grid.bs = int32(zeros(1, grid.dims));
    
    grid.range = zeros(1, grid.dims * 2);
    
    for d = 1 : grid.dims
        grid.ns(d) = numel(grid.axes{d});
        
        grid.hss{d} = diff(grid.axes{d});
        grid.iss{d} = 1 ./ diff(grid.axes{d});
        
        grid.range(2 * d - 1) = min(grid.axes{d});
        grid.range(2 * d)     = max(grid.axes{d});
        
        grid.bs(d) = bitshift(1, floor(log(grid.ns(d) - 1) / log(2)));
    end
    
    % get offsets of the submatrices
    %
    % (..., i, ...) = values(n)
    % (..., i + 1, ...) = values(n + offset(dimension))
    %
    grid.offsets = ones(1, grid.dims);
    for d = 1 : grid.dims - 1
        grid.offsets(d + 1) = grid.offsets(d) * grid.ns(d);
    end
    
    % prepare data for c
    grid.dims    = uint32(grid.dims);
    grid.ins     = uint32(grid.ns);
    grid.offsets = uint32(grid.offsets);
    
end