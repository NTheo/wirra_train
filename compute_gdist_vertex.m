% Compute distance for all points with respect to centroids
gdist_vertex = zeros(n_vertices, n_cars);
for c = 1:n_cars
   v = centroids_index_vertex(c);
   distance_vertices_to_v;
   gdist_vertex(:, c) = distances;
end