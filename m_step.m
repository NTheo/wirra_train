% M step : update idcs with respect to our criterion

% Parameter (exposant of cost(cluster_i) in the cost function)
exp_cost = 1;

%
compute_gdist_vertex;
% gdist_vertex to gdist_edge
gdist_edge = 0.5 * ( gdist_vertex(edges(1,:)+1,:)+gdist_vertex(edges(2,:)+1,:) );

% Assignment into the cluster
gdist_edge = gdist_edge .* repmat((centroids_cost') .^ exp_cost, n_edges, 1);

% Find the new assignement
[~, idxs_new] = min(gdist_edge, [], 2);