f = @(x, y, z)  x + sin(y .* z) .* max(exp(x - y), ones(size(x)));
testaxis = getaxis(-1, 1, 25, 'equidistant');
testgrid = tensorgrid(testaxis, testaxis, testaxis);

result = {
    '| step size              '
    '|------------------------'
    '| spline interp3 (time)  '
    '| ltinterp (time)        '
    '| spline interp3 (error) '
    '| ltinterp (error)       '
};

for step = [1.0, 0.5, 0.25, 0.125, 0.0625]%, 0.03125]

    [xs, ys, zs] = meshgrid(-1 : step : 1);
    vs = f(xs, ys, zs);
    g = @(x, y, z) interp3(xs, ys, zs, vs, x, y, z, 'spline');

    n = round(2 / step) + 1;
    ax = getaxis(-1, 1, n, 'equidistant');
    grid = tensorgrid(ax, ax, ax);
    vs = zeros(grid.ns);
    for i = 1 : grid.ns(1)
        for j = 1 : grid.ns(2)
            for k = 1 : grid.ns(3)
                vs(i, j, k) = f(grid.axes{1}(i), grid.axes{2}(j), grid.axes{3}(k));
            end
        end
    end
    h = @(x, y, z) tensorinterp(grid, vs, [x, y, z]);
    
    % error functions
    ge = @(x, y, z) abs(g(x, y, z) - f(x, y, z));
    he = @(x, y, z) abs(h(x, y, z) - f(x, y, z));
    
    rg = findmax3(ge, testgrid);
    rh = findmax3(he, testgrid);
    
    fprintf('step: % 4.5f\n', step);
    
    column = {
        sprintf('| % 4.5f ', step)
        '|----------'
        sprintf('| % 4.5f ', rg(1))
        sprintf('| % 4.5f ', rh(1))
        sprintf('| % 4.5f ', rg(2))
        sprintf('| % 4.5f ', rh(2))
    };
    result = [result, column];
    
end

[m, n] = size(result);
for i = 1 : m
    for j = 1 : n
        fprintf(result{i, j});
    end
    fprintf('|\n');
end


