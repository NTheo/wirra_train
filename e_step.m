% E step of the algorithm : find the street that represents the assignemt

% Coord of edges (average position of intersection joining 2 streets)
edge_coords = (vertices_first + vertices_second)/2;
% Assignement is stored in idxs
centroids_coords        = zeros(n_cars, 2);
centroids_index_edge    = zeros(n_cars, 1);
centroids_cost          = zeros(n_cars, 1);
centroids_index_vertex  = zeros(n_cars, 2);

for c = 1:n_cars
   centroids_coords(c, :) = mean(edge_coords(idxs==c, :));
   % Compute L2 distance with this centroid
   dist_centroid_c_edge         = sum((edge_coords-repmat(centroids_coords(c,:),size(edge_coords,1),1)).^2,2);
   [~, centroids_index_edge(c)] = min(dist_centroid_c_edge);
   % Compute L2 distance with respect to intersection
   dist_centroid_c_vertex         = sum((coords'-repmat(centroids_coords(c,:),size(coords',1),1)).^2,2);
   [~, centroids_index_vertex(c)]   = min(dist_centroid_c_vertex);
   
   centroids_coords(c, :)  = edge_coords(centroids_index_edge(c), :);
   % Update the cost per cluster
   centroids_cost(c)       = sum(edges(4, idxs==c));
end