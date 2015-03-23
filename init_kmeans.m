edge_coords = (vertices_first + vertices_second)/2;
[idxs,C] = kmeans(edge_coords, n_cars,'MaxIter',1000);

%%

clustercost = zeros(1, n_cars);
for i = 1:n_cars
    selected = (idxs == i);
    clustercost(i) = sum(edges(4,selected));
end
