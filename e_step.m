% E step of the algorithm : find the street that represents the assignemt

% Coord of edges (average position of intersection joining 2 streets)
edge_coords = (vertices_first + vertices_second)/2;
% Assignement is stored in idxs
centroids_coords = zeros(n_cars, 2);
centroids_index  = zeros(n_cars,1);
for c = 1:n_cars
   centroids_coords(c, :) = mean(edge_coords(idxs==c, :));
   % Compute L2 distance with this centroid
   dist_centroid_c         = sum((edge_coords(idxs==c,:)-repmat(centroids_coords(c,:),size(edge_coords(idxs==c,:),1),1)).^2,2);
   [~, centroids_index(c)] = min(dist_centroid_c);
    
   

end