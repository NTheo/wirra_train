figure();
scatter(coords(2,:),coords(1,:),'.','y')
hold on;

unoriented = orientations==2;
oriented   = ~unoriented;

% Plot the unoriented in red
plot([vertices_first(unoriented,2) vertices_second(unoriented,2)]',[vertices_first(unoriented,1) vertices_second(unoriented,1)]','r');
% Plot oriented in blue
plot([vertices_first(oriented,2) vertices_second(oriented,2)]',[vertices_first(oriented,1) vertices_second(oriented,1)]','b');

axis equal
hold off