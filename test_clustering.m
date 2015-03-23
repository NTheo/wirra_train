edge_coords = (vertices_first + vertices_second)/2;
[idxs,C] = kmeans(edge_coords, n_cars,'MaxIter',1000);

cols = {'r','g','b','c','m','y','k', [0.5 0.5 0.5]};

figure;
hold on;
for i = 1:n_cars
    selected = (idxs == i);
    plot([vertices_first(selected,2) vertices_second(selected,2)]',[vertices_first(selected,1) vertices_second(selected,1)]','Color',cols{i});
    pause;
end
hold off;

%%

clustercost = zeros(1, n_cars);
for i = 1:n_cars
    selected = (idxs == i);
    clustercost(i) = sum(edges(4,selected));
end

clustercost