function result = findmax(f, grid)
    tic;
    max_value = 0;
    for i = 1 : grid.ns(1)
        for j = 1 : grid.ns(2)
            value = f(grid.axes{1}(i), grid.axes{2}(j));
            if value > max_value
                max_value = value;
            end
        end
    end
    result = [toc; max_value];
end