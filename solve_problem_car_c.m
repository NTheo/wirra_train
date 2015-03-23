% The index of the car is c;
% Test : to change be careful !!!
c=1; % TO REMOVE AFTER WHEN LOOPING OVER THE CARS

edges_u_c = edges(1:2, (idxs==c)' & edges(3,:)==2);
edges_o_c = edges(1:2, (idxs==c)' & edges(3,:)==1);

vertex_u_c = unique(edges_u_c(:));
vertex_o_c = unique(edges_o_c(:));

coords_u_c = coords(:, vertex_u_c);
coords_o_c = coords(:, vertex_o_c);

vertices_first_u_c  = coords(:, edges_u_c(1,:)+1)';
vertices_second_u_c = coords(:, edges_u_c(2,:)+1)';

vertices_first_o_c  = coords(:, edges_o_c(1,:)+1)';
vertices_second_o_c = coords(:, edges_o_c(2,:)+1)';


if display
    figure();
    scatter(coords_o_c(2,:),coords_o_c(1,:),'.','b')
    hold on;
    % Plot the : in red
    plot([vertices_first_o_c(:,2) vertices_second_o_c(:,2)]',[vertices_first_o_c(:,1) vertices_second_o_c(:,1)]','r');
    
    axis equal
    hold off  
end