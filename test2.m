f = @(x, y) min(1, max(0, sin(pi * x) .* exp(y .^ 2)));
testaxis = getaxis(-3, 3, 50, 'equidistant');
testgrid = tensorgrid(testaxis, testaxis);

result = {
    '| step size              '
    '|------------------------'
    '| linear interp2 (time)  '
    '| tensorinterp (time)    '
    '| linear interp2 (error) '
    '| tensorinterp (error)   '
};

for step = [1.0, 0.5, 0.25, 0.125, 0.0625, 0.03125]

    [xs, ys] = meshgrid(-3 : step : 3);
    zs = f(xs, ys);
    g = @(x, y) interp2(xs, ys, zs, x, y, 'spline');

    ax = getaxis(-3, 3, round(6 / step) + 1, 'equidistant');
    grid = tensorgrid(ax, ax);
    zs = zeros(grid.ns);
    for i = 1 : grid.ns(1)
        for j = 1 : grid.ns(2)
            zs(i, j) = f(grid.axes{1}(i), grid.axes{2}(j));
        end
    end
    h = @(x, y) tensorinterp(grid, zs, [x, y]);
    
    % error functions
    ge = @(x, y) abs(g(x, y) - f(x, y));
    he = @(x, y) abs(h(x, y) - f(x, y));
    
    rg = findmax2(ge, testgrid);
    rh = findmax2(he, testgrid);
    
    fprintf('step: % 4.8f\n', step);
    
    column = {
        sprintf('| % 4.8f ', step)
        '|----------'
        sprintf('| % 4.8f ', rg(1))
        sprintf('| % 4.8f ', rh(1))
        sprintf('| % 4.8f ', rg(2))
        sprintf('| % 4.8f ', rh(2))
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


